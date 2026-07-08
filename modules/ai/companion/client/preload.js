// Bridge between the renderer windows and the main process (which owns the single
// WebSocket connection). Renderers call companion.toBackend(msg) to send to OLV, and
// companion.on(channel, cb) to receive routed events.
const { contextBridge, ipcRenderer } = require("electron");

contextBridge.exposeInMainWorld("companion", {
  toBackend: (msg) => ipcRenderer.send("to-backend", msg),
  control: (msg) => ipcRenderer.send("client-control", msg), // local client controls (e.g. mic mute)
  on: (channel, cb) => ipcRenderer.on(channel, (_e, data) => cb(data)),
});
