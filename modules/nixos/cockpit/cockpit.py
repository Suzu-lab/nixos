#!/usr/bin/env python3
# ai-cockpit — a tiny phone control panel for the local AI stacks. Spawned in the niri session
# (niri spawn-at-startup, gated on suzu.system.remoteAccess.enable) so it inherits the graphical
# session env: docker access, and niri/noctalia for the display commands — exactly like companion-ctl.
#
# It serves a mobile web page (buttons + live VRAM / loaded-model readout) on 127.0.0.1:8090, which
# Tailscale serve publishes to the tailnet on :443 (see modules/nixos/tailscale.nix). So the phone
# drives it over the encrypted tunnel; nothing on the LAN or public internet can reach it.
#
# Design notes:
#   - Every button maps to an ALLOWLISTED action (a fixed argv or an internal HTTP unload) — there is
#     no arbitrary command execution. The action names are the only thing the client can pick.
#   - The command actions reuse the exact CLIs the stream deck already uses (rp-on/off, companion-ctl,
#     imagegen-ctl), so behavior is identical to pressing the physical keys.
#   - /action/* requires a custom header the page sets; a cross-site "simple" POST can't set it,
#     which blocks CSRF from a random website that happens to know your tailnet name.
#   - Stdlib only (like consolidate.py), runs on a bare python3.
import glob
import json
import subprocess
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

BIND = ("127.0.0.1", 8090)

# name -> ("cmd", argv...) shells out; ("post", url) does an HTTP POST (model unload). Allowlist only.
ACTIONS = {
    "rp-on":            ("cmd", ["rp-on"]),
    "rp-off":           ("cmd", ["rp-off"]),
    "gpu-free":         ("cmd", ["companion-ctl", "gpu-free"]),
    "gpu-back":         ("cmd", ["companion-ctl", "gpu-back"]),
    "displays-toggle":  ("cmd", ["companion-ctl", "displays-toggle"]),
    "imagegen-free":    ("cmd", ["imagegen-ctl", "free"]),
    "companion-unload": ("post", "http://127.0.0.1:8080/api/models/unload"),  # full sleep (she unloads)
    "rp-unload":        ("post", "http://127.0.0.1:8081/api/models/unload"),  # drop the RP model
}

# Services the cockpit links to, published by Tailscale serve on these tailnet HTTPS ports. The page
# builds the URLs from the phone's own location.hostname, so they work under any tailnet name.
LINKS = [
    ("SillyTavern",   6443),
    ("SwarmUI",       7443),
    ("RP dashboard",  8443),
    ("netdata",       9443),
]


def _read(path):
    with open(path) as f:
        return f.read().strip()


def gpu_stats():
    """VRAM used/total (bytes) + GPU busy % from the amdgpu sysfs node, or None if unreadable."""
    for dev in sorted(glob.glob("/sys/class/drm/card*/device")):
        try:
            total = int(_read(dev + "/mem_info_vram_total"))
            if total <= 0:
                continue
            used = int(_read(dev + "/mem_info_vram_used"))
            try:
                busy = int(_read(dev + "/gpu_busy_percent"))
            except Exception:
                busy = None
            return {"used": used, "total": total, "busy": busy}
        except Exception:
            continue
    return None


def loaded_models(port):
    """Loaded model ids for a llama-swap on `port`: list (maybe empty), or None if unreachable."""
    try:
        with urllib.request.urlopen(f"http://127.0.0.1:{port}/running", timeout=2) as r:
            data = json.loads(r.read().decode())
        items = data.get("running", data) if isinstance(data, dict) else data
        names = []
        if isinstance(items, list):
            for it in items:
                if isinstance(it, dict):
                    names.append(it.get("model") or it.get("id") or "?")
        return names
    except Exception:
        return None


def comfy_up():
    try:
        urllib.request.urlopen("http://127.0.0.1:8188/system_stats", timeout=2).read()
        return True
    except Exception:
        return False


def stats():
    return {
        "gpu": gpu_stats(),
        "companion": loaded_models(8080),
        "rp": loaded_models(8081),
        "imagegen": comfy_up(),
    }


def run_action(name):
    kind, payload = ACTIONS[name]
    if kind == "post":
        try:
            req = urllib.request.Request(payload, method="POST")
            with urllib.request.urlopen(req, timeout=30) as r:
                return True, (r.read().decode()[:400] or "ok")
        except Exception as e:
            return False, f"{name}: {e}"
    try:
        p = subprocess.run(payload, capture_output=True, text=True, timeout=240)
        out = (p.stdout + p.stderr).strip()[-400:]
        return p.returncode == 0, out or "ok"
    except Exception as e:
        return False, f"{name}: {e}"


PAGE = """<!doctype html><html lang=en><head><meta charset=utf-8>
<meta name=viewport content="width=device-width,initial-scale=1,viewport-fit=cover">
<meta name=color-scheme content="dark"><title>yosai cockpit</title>
<style>
:root{--bg:#0f1115;--card:#181b22;--line:#272b36;--fg:#e6e8ee;--dim:#9aa1b2;--acc:#7aa2f7;--ok:#7bd88f;--warn:#e0af68;--bad:#f7768e}
*{box-sizing:border-box}body{margin:0;padding:16px;background:var(--bg);color:var(--fg);
font:16px/1.4 system-ui,-apple-system,sans-serif;max-width:560px;margin-inline:auto}
h1{font-size:18px;margin:4px 0 14px}h2{font-size:13px;text-transform:uppercase;letter-spacing:.06em;
color:var(--dim);margin:20px 0 8px}
.card{background:var(--card);border:1px solid var(--line);border-radius:14px;padding:14px;margin-bottom:12px}
.bar{height:10px;border-radius:6px;background:#22262f;overflow:hidden;margin:8px 0}
.bar>i{display:block;height:100%;background:linear-gradient(90deg,var(--ok),var(--warn),var(--bad));width:0}
.row{display:flex;justify-content:space-between;gap:10px;margin:4px 0;font-size:14px}
.row .k{color:var(--dim)}.mono{font-variant-numeric:tabular-nums}
.grid{display:grid;grid-template-columns:1fr 1fr;gap:10px}
button{appearance:none;border:1px solid var(--line);background:#20242e;color:var(--fg);
padding:14px;border-radius:12px;font-size:15px;font-weight:600;cursor:pointer;touch-action:manipulation}
button:active{background:#2b3040}button.wide{grid-column:1/3}button:disabled{opacity:.5}
button.danger{border-color:#3a2530;color:#ffc4cf}
a.link{display:block;padding:12px 14px;border:1px solid var(--line);border-radius:12px;
background:#181b22;color:var(--acc);text-decoration:none;margin-bottom:8px;font-weight:600}
#log{min-height:20px;color:var(--dim);font-size:13px;margin-top:6px;white-space:pre-wrap;word-break:break-word}
</style></head><body>
<h1>🖥️ yosai cockpit</h1>
<div class=card id=stats>loading…</div>

<h2>Roleplay ⇄ companion</h2>
<div class=grid>
<button onclick="act('rp-on',this)">🎭 RP on</button>
<button onclick="act('rp-off',this)">↩︎ RP off</button>
<button onclick="act('gpu-free',this)">🎮 gpu-free</button>
<button onclick="act('gpu-back',this)">🧠 gpu-back</button>
</div>

<h2>Unload / free VRAM</h2>
<div class=grid>
<button onclick="act('rp-unload',this)">Drop RP model</button>
<button onclick="act('imagegen-free',this)">Flush imagegen</button>
<button class="danger wide" onclick="act('companion-unload',this)">💤 Unload companion (sleep)</button>
</div>

<h2>System</h2>
<div class=grid>
<button class=wide onclick="act('displays-toggle',this)">🌙 Displays off / on</button>
</div>

<h2>Open</h2>
<div id=links></div>
<div id=log></div>
<script>
const $=s=>document.querySelector(s);
function fmtGB(b){return (b/1073741824).toFixed(1)}
function ml(v){return v===null?'<span style=color:var(--bad)>offline</span>':(v.length?v.join(', '):'<span style=color:var(--dim)>idle</span>')}
async function refresh(){
 try{const s=await (await fetch('stats')).json();
  const g=s.gpu; let h='';
  if(g){const pct=Math.round(g.used/g.total*100);
   h+=`<div class=row><span class=k>VRAM</span><span class=mono>${fmtGB(g.used)} / ${fmtGB(g.total)} GB · ${pct}%</span></div>`;
   h+=`<div class=bar><i style=width:${pct}%></i></div>`;
   h+=`<div class=row><span class=k>GPU busy</span><span class=mono>${g.busy==null?'—':g.busy+'%'}</span></div>`;
  }else{h+='<div class=row><span class=k>GPU</span><span>unreadable</span></div>'}
  h+=`<div class=row><span class=k>companion</span><span>${ml(s.companion)}</span></div>`;
  h+=`<div class=row><span class=k>roleplay</span><span>${ml(s.rp)}</span></div>`;
  h+=`<div class=row><span class=k>imagegen</span><span>${s.imagegen?'up':'<span style=color:var(--dim)>down</span>'}</span></div>`;
  $('#stats').innerHTML=h;
 }catch(e){$('#stats').textContent='stats unavailable'}
}
async function act(name,btn){
 const all=[...document.querySelectorAll('button')];all.forEach(b=>b.disabled=true);
 $('#log').textContent='running '+name+'…';
 try{const r=await fetch('action/'+name,{method:'POST',headers:{'X-Cockpit':'1'}});
  const t=await r.text();$('#log').textContent=(r.ok?'✓ ':'✗ ')+name+'  '+t;}
 catch(e){$('#log').textContent='✗ '+name+'  '+e}
 all.forEach(b=>b.disabled=false);refresh();
}
(function(){const h=location.hostname,base=location.protocol+'//'+h;
 const L=%%LINKS%%;$('#links').innerHTML=L.map(([n,p])=>`<a class=link href="${base}:${p}" target=_blank rel=noopener>${n} ↗</a>`).join('');})();
refresh();setInterval(refresh,3000);
</script></body></html>"""


class Handler(BaseHTTPRequestHandler):
    def log_message(self, *a):
        pass  # quiet; journald already has the unit

    def _send(self, code, body, ctype="text/html; charset=utf-8"):
        b = body.encode() if isinstance(body, str) else body
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(b)))
        self.end_headers()
        self.wfile.write(b)

    def do_GET(self):
        if self.path in ("/", "/index.html"):
            page = PAGE.replace("%%LINKS%%", json.dumps(LINKS))
            return self._send(200, page)
        if self.path == "/stats":
            return self._send(200, json.dumps(stats()), "application/json")
        self._send(404, "not found", "text/plain")

    def do_POST(self):
        if not self.path.startswith("/action/"):
            return self._send(404, "not found", "text/plain")
        # CSRF guard: our page sets this; a cross-site "simple" POST cannot.
        if self.headers.get("X-Cockpit") != "1":
            return self._send(403, "forbidden", "text/plain")
        name = self.path[len("/action/"):]
        if name not in ACTIONS:
            return self._send(404, "unknown action", "text/plain")
        ok, out = run_action(name)
        self._send(200 if ok else 500, out, "text/plain")


if __name__ == "__main__":
    ThreadingHTTPServer(BIND, Handler).serve_forever()
