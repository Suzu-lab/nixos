# Tailscale mesh VPN + phone access to the local services, centralized here because it spans all
# three AI stacks (companion, imagegen, roleplay) plus system stats — not any one stack's concern.
#
# POSTURE: every service is bound to 127.0.0.1 in its own compose/module (nothing published on the
# LAN). `tailscale serve` then proxies each onto the TAILNET over HTTPS. Net effect:
#   - Public internet: unreachable (plain Tailscale is a private mesh, not Funnel; no port-forward).
#   - LAN: unreachable (localhost binds; serve doesn't touch the host firewall).
#   - Tailnet: reachable by YOUR authenticated devices only (your phone).
# So the phone reaches everything from anywhere over the internet via Tailscale's encrypted tunnel
# (direct WireGuard, DERP relay fallback), and nothing else can.
#
# ONE-TIME MANUAL STEPS (nothing is exposed until you do them):
#   1. `sudo tailscale up`                      — authenticate this host onto your tailnet.
#   2. Admin console → enable MagicDNS + HTTPS   — lets `serve` provision TLS certs (free).
#   3. Install Tailscale on the phone, same login. Optionally disable this host's key expiry.
# After that the `tailscale-serve` unit below applies the proxy mappings on every activation/boot.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.suzu.system.remoteAccess;
  ts = "${config.services.tailscale.package}/bin/tailscale";

  # service → tailnet HTTPS port. Distinct ports (not path prefixes) because SwarmUI, netdata and
  # the llama-swap dashboards all use absolute asset paths, which a path-prefix proxy would break.
  # On the phone you bookmark https://<host>.<tailnet>.ts.net[:port] per service (MagicDNS name).
  serves = [
    { port = 443;  target = "http://127.0.0.1:8090";  desc = "ai-cockpit (control panel — landing page)"; }
    { port = 6443; target = "http://127.0.0.1:8000";  desc = "SillyTavern (roleplay)"; }
    { port = 8443; target = "http://127.0.0.1:8081";  desc = "llama-swap dashboard (RP backend)"; }
    { port = 7443; target = "http://127.0.0.1:7801";  desc = "SwarmUI (image generation)"; }
    { port = 9443; target = "http://127.0.0.1:19999"; desc = "netdata (GPU/VRAM/host stats)"; }
  ];
  serveLines = lib.concatMapStringsSep "\n"
    (s: "\"$ts\" serve --bg --https=${toString s.port} ${s.target}   # ${s.desc}") serves;
in
{
  options.suzu.system.remoteAccess.enable =
    lib.mkEnableOption "Tailscale + phone access (serve) for the local AI stacks and stats";

  config = lib.mkIf cfg.enable {
    services.tailscale.enable = true;

    # serve listens as REAL kernel sockets on the tailscale IP (100.x:443, :6443, …), so inbound TCP
    # from the tailnet must pass the host firewall — without this, peers can ping (ICMP) but every
    # TCP connection is silently dropped by the default-deny policy. Opened ONLY on tailscale0, and
    # derived from the serve list so the ports never drift out of sync with the mappings above.
    networking.firewall.interfaces."tailscale0".allowedTCPPorts = map (s: s.port) serves;

    # The phone control panel (served on :443 above). A tiny HTTP server on 127.0.0.1:8090; the
    # actual command execution and stats-reading live in cockpit/cockpit.py. It's spawned in the
    # niri session (modules/desktop/niri/niri.nix, gated on this same option) so it inherits docker
    # + niri/noctalia access for its actions — installing the binary here, autostarting it there.
    environment.systemPackages = [
      (pkgs.writeShellApplication {
        name = "ai-cockpit";
        runtimeInputs = [ pkgs.python3 ];
        text = "exec python3 ${./cockpit/cockpit.py}";
      })
    ];

    # Apply the serve mappings once the node is authenticated & up. `serve reset` first so this unit
    # is the single source of truth (drops any stale mappings); RemainAfterExit keeps it "active".
    # Idempotent: safe to re-run on every rebuild/boot. Best-effort before `tailscale up` — it just
    # waits out the loop and exits; the next activation after you authenticate applies it for real.
    systemd.services.tailscale-serve = {
      description = "Expose local services on the tailnet via tailscale serve";
      after = [ "tailscaled.service" "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "tailscale-serve-up" ''
          set -euo pipefail
          ts=${ts}
          # Wait (max ~60s) for the node to be authenticated & Running after a boot / `tailscale up`.
          for _ in $(seq 1 30); do
            if "$ts" status --json 2>/dev/null | ${pkgs.jq}/bin/jq -e '.BackendState=="Running"' >/dev/null; then
              break
            fi
            sleep 2
          done
          "$ts" status --json 2>/dev/null | ${pkgs.jq}/bin/jq -e '.BackendState=="Running"' >/dev/null || {
            echo "tailscale not Running yet (run 'sudo tailscale up'); skipping serve setup." >&2
            exit 0
          }
          "$ts" serve reset
          ${serveLines}
        '';
        ExecStop = "${ts} serve reset";
      };
    };
  };
}
