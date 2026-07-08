// Prompt window: text input + running conversation log. Talks only to the main process
// over IPC (window.companion); the avatar window speaks the replies. One shared conversation.
"use strict";

const $ = (id) => document.getElementById(id);

function log(who, text) {
  const div = document.createElement("div");
  div.className = who;
  div.textContent = text;
  $("log").appendChild(div);
  $("log").scrollTop = $("log").scrollHeight;
}

// ---- image attachments (paste / drag-drop / file-pick) -> text-input images ----
let attachments = []; // { data: "data:image/…;base64,…", mime }

function renderAttachments() {
  const box = $("attachments");
  box.innerHTML = "";
  attachments.forEach((a, i) => {
    const d = document.createElement("div");
    d.className = "thumb";
    const img = document.createElement("img"); img.src = a.data; d.appendChild(img);
    const rm = document.createElement("button"); rm.className = "rm"; rm.textContent = "×";
    rm.addEventListener("click", () => { attachments.splice(i, 1); renderAttachments(); });
    d.appendChild(rm);
    box.appendChild(d);
  });
}

function addFile(file) {
  if (!file || !file.type.startsWith("image/")) return;
  const r = new FileReader();
  r.onload = () => { attachments.push({ data: r.result, mime: file.type }); renderAttachments(); };
  r.readAsDataURL(file); // -> "data:image/png;base64,…" (exactly what OLV wants)
}

function send() {
  const t = $("text").value.trim();
  if (!t && !attachments.length) return;
  const images = attachments.map((a) => ({ source: "upload", data: a.data, mime_type: a.mime }));
  logMe(t, attachments);
  window.companion.toBackend({ type: "text-input", text: t, images: images.length ? images : undefined });
  $("text").value = "";
  attachments = [];
  renderAttachments();
}

// "me" log entry that can carry image thumbnails alongside the text
function logMe(text, imgs) {
  const div = document.createElement("div");
  div.className = "me";
  if (text) div.appendChild(document.createTextNode(text));
  (imgs || []).forEach((a) => { const im = document.createElement("img"); im.src = a.data; div.appendChild(im); });
  $("log").appendChild(div);
  $("log").scrollTop = $("log").scrollHeight;
}

$("send").addEventListener("click", send);
$("text").addEventListener("keydown", (e) => { if (e.key === "Enter") send(); });

// Paste an image (e.g. a screenshot) straight into the conversation.
document.addEventListener("paste", (e) => {
  const items = (e.clipboardData && e.clipboardData.items) || [];
  for (const it of items) if (it.type.startsWith("image/")) { addFile(it.getAsFile()); e.preventDefault(); }
});

// Drag-and-drop image files.
const dz = $("dropzone");
let dragDepth = 0;
window.addEventListener("dragenter", (e) => { e.preventDefault(); if (++dragDepth === 1) dz.classList.add("on"); });
window.addEventListener("dragover", (e) => e.preventDefault());
window.addEventListener("dragleave", (e) => { e.preventDefault(); if (--dragDepth <= 0) { dragDepth = 0; dz.classList.remove("on"); } });
window.addEventListener("drop", (e) => {
  e.preventDefault(); dragDepth = 0; dz.classList.remove("on");
  for (const f of (e.dataTransfer && e.dataTransfer.files) || []) addFile(f);
});

// File picker.
$("attach").addEventListener("click", () => $("file").click());
$("file").addEventListener("change", (e) => { for (const f of e.target.files) addFile(f); e.target.value = ""; });

window.companion.on("log-ai", (text) => log("ai", text));   // her spoken text (synced to speech)
window.companion.on("log-me", (text) => log("me", text));   // voice transcription
window.companion.on("status", (s) => $("dot").classList.toggle("on", s === "connected"));

// Mic mute toggle. Capture runs in the avatar window; main relays the state to keep the button synced.
let micOn = true;
function setMic(on) {
  micOn = on;
  const b = $("mic");
  b.classList.toggle("off", !on);
  b.textContent = on ? "🎤" : "🔇";
  b.title = on ? "Microphone on — click to mute" : "Microphone muted — click to unmute";
}
$("mic").addEventListener("click", () => window.companion.control({ type: "mic", on: !micOn }));
window.companion.on("mic-state", (on) => setMic(on));

$("text").focus();
