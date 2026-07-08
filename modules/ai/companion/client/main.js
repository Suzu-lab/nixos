// Electron main process. Owns the ONE WebSocket connection to the OLV backend and paints
// two windows over IPC — so the avatar (Y70) and the prompt (main screen) share a single
// conversation. Renderers never talk to the backend directly; everything routes through here.
const { app, BrowserWindow, ipcMain, session } = require("electron");
const path = require("path");
const fs = require("fs");
const http = require("http");
const WebSocket = require("ws");

// Local control channel: niri keybinds poke this (Wayland blocks Electron's own globalShortcut).
const CTRL_PORT = 12395;

// Let AudioContext (mic capture + TTS playback) run without a user gesture.
app.commandLine.appendSwitch("autoplay-policy", "no-user-gesture-required");

const WS_URL = "ws://localhost:12393/client-ws";
const PRELOAD = path.join(__dirname, "preload.js");
// The VRM (VRoid export) lives on the models NVMe, not in git. Read here and hand the bytes
// to the avatar renderer over IPC so it never has to fetch a file:// URL (keeps webSecurity on).
const MODEL_PATH = process.env.COMPANION_VRM || "/home/suzu/ai-models/avatar/model.vrm";
// Optional authored animation clips. Drop .vrma files here; "idle.vrma" loops as the body idle,
// a clip named after an emotion tag (smirk.vrma, joy.vrma, …) plays once when she emotes. Empty
// or missing => the avatar's procedural idle runs instead.
const ANIM_DIR = process.env.COMPANION_VRMA_DIR || "/home/suzu/ai-models/avatar/animations";

let avatarWin = null;
let promptWin = null;
let ws = null;
let micEnabled = true; // hands-free by default; the avatar window auto-starts capture

function makeWindow(file, opts) {
  const win = new BrowserWindow({
    ...opts,
    webPreferences: {
      preload: PRELOAD,
      backgroundThrottling: false, // keep lip-sync / timers running when unfocused
      contextIsolation: true,
      nodeIntegration: false,
    },
  });
  win.removeMenu();
  win.loadFile(path.join(__dirname, file));
  win.webContents.on("console-message", (_e, _l, m) => console.log(`[${file}] ${m}`));
  return win;
}

function createWindows() {
  // Avatar: its own window (M5 pins it fullscreen on the Y70 / DP-2 via a niri rule).
  avatarWin = makeWindow("avatar.html", {
    width: 520, height: 760, backgroundColor: "#1e1e2e", title: "Companion Avatar",
  });
  // Once the renderer is up, ship it the VRM bytes to parse.
  avatarWin.webContents.on("did-finish-load", () => {
    fs.readFile(MODEL_PATH, (err, buf) => {
      if (err) { sendTo(avatarWin, "model-error", err.message); return; }
      // Copy into a fresh ArrayBuffer so structured-clone over IPC carries just the bytes.
      const ab = buf.buffer.slice(buf.byteOffset, buf.byteOffset + buf.byteLength);
      sendTo(avatarWin, "model-data", ab);
    });
    // Feed any authored .vrma clips (optional — none => procedural idle).
    fs.readdir(ANIM_DIR, (err, files) => {
      if (err) return;
      for (const f of files.filter((n) => n.toLowerCase().endsWith(".vrma"))) {
        fs.readFile(path.join(ANIM_DIR, f), (e, buf) => {
          if (e) return;
          const ab = buf.buffer.slice(buf.byteOffset, buf.byteOffset + buf.byteLength);
          sendTo(avatarWin, "animation-data", { name: f.replace(/\.vrma$/i, "").toLowerCase(), buffer: ab });
        });
      }
    });
  });
  // Prompt: frameless, summonable panel for the main screen.
  promptWin = makeWindow("prompt.html", {
    width: 460, height: 540, frame: false, backgroundColor: "#181825",
    title: "Companion Prompt", alwaysOnTop: true, skipTaskbar: false,
  });
  promptWin.webContents.on("did-finish-load", () => sendTo(promptWin, "mic-state", micEnabled));
}

function sendTo(win, channel, data) {
  if (win && !win.isDestroyed()) win.webContents.send(channel, data);
}
function broadcast(channel, data) { sendTo(avatarWin, channel, data); sendTo(promptWin, channel, data); }

// ---- prompt summon + screen capture, driven by the local control channel ----
function togglePrompt() {
  if (!promptWin) return;
  if (promptWin.isVisible()) promptWin.hide();
  else { promptWin.show(); promptWin.focus(); }
}

// Read a PNG that a niri keybind captured (via grim) and send it into the conversation as a
// "screen" image, so she answers in her voice/persona and follow-ups keep the image.
function captureAndSend(pngPath) {
  fs.readFile(pngPath, (err, buf) => {
    if (err) { console.log("screen capture read failed:", err.message); return; }
    const caption = "What do you see on my screen?";
    const dataUri = "data:image/png;base64," + buf.toString("base64");
    if (ws && ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify({ type: "text-input", text: caption,
        images: [{ source: "screen", data: dataUri, mime_type: "image/png" }] }));
    }
    sendTo(promptWin, "log-me", "🖥️ " + caption);
    if (promptWin && !promptWin.isVisible()) promptWin.show();
  });
}

function startControlServer() {
  const server = http.createServer((req, res) => {
    const send = (s) => { res.writeHead(200); res.end(s); };
    if (req.url === "/toggle-prompt") { togglePrompt(); return send("ok"); }
    if (req.url === "/show-prompt") { if (promptWin) { promptWin.show(); promptWin.focus(); } return send("ok"); }
    if (req.url === "/hide-prompt") { if (promptWin) promptWin.hide(); return send("ok"); }
    if (req.url === "/capture" && req.method === "POST") {
      let body = ""; req.on("data", (c) => (body += c));
      req.on("end", () => { captureAndSend(body.trim()); send("ok"); });
      return;
    }
    if (req.url === "/toggle-mic") {
      micEnabled = !micEnabled;
      sendTo(avatarWin, "set-mic", micEnabled);
      sendTo(promptWin, "mic-state", micEnabled);
      return send("ok");
    }
    if (req.url === "/interrupt") { // silence her now: stop playback + cancel backend generation
      sendTo(avatarWin, "stop", null);
      if (ws && ws.readyState === WebSocket.OPEN) ws.send(JSON.stringify({ type: "interrupt-signal", text: "" }));
      return send("ok");
    }
    res.writeHead(404); res.end("?");
  });
  server.on("error", (e) => console.log("control server not started (another instance?):", e.message));
  server.listen(CTRL_PORT, "127.0.0.1", () => console.log("control server on 127.0.0.1:" + CTRL_PORT));
}

// Route backend events to the right window(s).
function route(msg) {
  switch (msg.type) {
    case "audio": // speech: avatar plays + lip-syncs; prompt logs the text
      sendTo(avatarWin, "audio", msg); // avatar parses the [emotion] tag from the raw text
      if (msg.display_text && msg.display_text.text) {
        // Strip any [ word ] emotion tag (the LLM improvises tags beyond the documented set).
        const clean = msg.display_text.text
          .replace(/\[\s*[a-zA-Z]+\s*\]/g, "")
          .replace(/\s{2,}/g, " ").trim();
        if (clean) sendTo(promptWin, "log-ai", clean);
      }
      break;
    case "user-input-transcription":
      if (msg.text) sendTo(promptWin, "log-me", msg.text);
      break;
    case "interrupt-signal":
    case "force-new-message":
      sendTo(avatarWin, "stop", null);
      break;
    case "control":
      // Server-side VAD says the user's utterance ended -> trigger the conversation on the
      // audio it already buffered. (Hands-free: raw-audio-data only flows when mic is on.)
      if (msg.text === "mic-audio-end") {
        if (ws && ws.readyState === WebSocket.OPEN) ws.send(JSON.stringify({ type: "mic-audio-end" }));
      } else if (msg.text && /interrupt|stop/i.test(msg.text)) {
        sendTo(avatarWin, "stop", null); // barge-in: user spoke over her -> stop playback
      }
      break;
    case "set-model-and-conf":
      sendTo(avatarWin, "set-model", msg);
      break;
    default:
      break;
  }
}

function connectWS() {
  ws = new WebSocket(WS_URL);
  ws.on("open", () => broadcast("status", "connected"));
  ws.on("message", (data) => {
    let msg;
    try { msg = JSON.parse(data.toString()); } catch { return; }
    route(msg);
  });
  ws.on("close", () => { broadcast("status", "disconnected"); setTimeout(connectWS, 2000); });
  ws.on("error", () => {});
}

// Renderers -> backend (text-input, raw-audio-data, frontend-playback-complete, interrupt).
ipcMain.on("to-backend", (_e, msg) => {
  if (ws && ws.readyState === WebSocket.OPEN) ws.send(JSON.stringify(msg));
});

// Local client controls (not backend-bound). Mic mute toggle: drive the avatar's capture and
// mirror the state to the prompt's button.
ipcMain.on("client-control", (_e, msg) => {
  if (msg && msg.type === "mic") {
    micEnabled = !!msg.on;
    sendTo(avatarWin, "set-mic", micEnabled);
    sendTo(promptWin, "mic-state", micEnabled);
  }
});

// Single instance only — a second launch (autostart + manual, or a stray relaunch) just
// surfaces the prompt of the running one instead of colliding on the control port.
if (!app.requestSingleInstanceLock()) {
  app.quit();
} else {
  app.on("second-instance", () => { if (promptWin) { promptWin.show(); promptWin.focus(); } });

  app.whenReady().then(() => {
    // Auto-grant mic access (local app; the avatar window captures for hands-free voice).
    const allowMic = (_wc, permission) => permission === "media" || permission === "audioCapture";
    session.defaultSession.setPermissionRequestHandler((_wc, permission, cb) => cb(allowMic(_wc, permission)));
    session.defaultSession.setPermissionCheckHandler((_wc, permission) => allowMic(_wc, permission));

    createWindows();
    connectWS();
    startControlServer(); // niri keybinds drive prompt-summon + screen capture through this
  });

  app.on("window-all-closed", () => app.quit());
}
