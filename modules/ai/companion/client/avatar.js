// Avatar window: renders the 3D/VRM model (three.js + @pixiv/three-vrm) and plays her speech
// with lip-sync. Receives events from the main process over IPC (window.companion) — never
// talks to the backend directly. The VRM bytes arrive over IPC ("model-data"). Text/logging
// lives in the prompt window.
import * as THREE from "three";
import { GLTFLoader } from "three/addons/loaders/GLTFLoader.js";
import { VRMLoaderPlugin, VRMUtils } from "@pixiv/three-vrm";
import { VRMAnimationLoaderPlugin, createVRMAnimationClip } from "@pixiv/three-vrm-animation";

// Lip-sync tuning: openness = min(1, volume^CURVE * GAIN). CURVE<1 lifts quiet speech.
const LIPSYNC_CURVE = 0.5;
const LIPSYNC_GAIN = 1.6;

// OLV carries the emotion as a name tag inside display_text, e.g. "[ sadness ] I feel…"
// (actions is empty). Map those persona tags to VRM expression presets.
const EMOTION_BY_NAME = {
  joy: "happy", smirk: "relaxed", playful: "relaxed", sadness: "sad", surprise: "surprised",
  fear: "surprised", disgust: "angry", anger: "angry", neutral: "neutral",
};
const EMOTION_TAG_RE = /\[\s*([a-zA-Z]+)\s*\]/g;

const $ = (id) => document.getElementById(id);
const setStatus = (s) => { const e = $("status"); if (e) e.textContent = s; };

// ---------------------------------------------------------------- three.js scene
let renderer, scene, camera, clock;
let vrm = null;
let mouthValue = 0;

// VRMA animation system (optional): drop .vrma clips in the animations dir (see main.js).
// "idle.vrma" loops as the body idle; a clip named after an emotion tag (e.g. "smirk.vrma",
// "joy.vrma") plays once when she emotes. With no clips present, the procedural idle runs.
let mixer = null;
const actions = {};        // emotion-tag name -> one-shot gesture AnimationAction
let pendingAnims = [];      // clips that arrived before the VRM finished parsing (async race)
const idles = [];          // idle* clips, cross-faded at random intervals
let currentIdle = null;
let idleTimer = null;
let idlePlaying = false;   // an idle clip is driving the body (suppresses procedural body idle)
let currentGesture = null;

// Camera framing = orbit around a look-at point at (0, camY, 0). Persisted like the old pan/zoom.
let camDist = parseFloat(localStorage.getItem("camDist") || "1.1");
let camY = parseFloat(localStorage.getItem("camY") || "1.30");
let camYaw = parseFloat(localStorage.getItem("camYaw") || "0");

function initThree() {
  const canvas = $("canvas");
  renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: true });
  renderer.setPixelRatio(window.devicePixelRatio);
  renderer.setSize(window.innerWidth, window.innerHeight);
  renderer.outputColorSpace = THREE.SRGBColorSpace;

  scene = new THREE.Scene();
  camera = new THREE.PerspectiveCamera(30, window.innerWidth / window.innerHeight, 0.1, 20);

  scene.add(new THREE.AmbientLight(0xffffff, 1.4));
  const dir = new THREE.DirectionalLight(0xffffff, 1.6);
  dir.position.set(1, 2, 2);
  scene.add(dir);

  clock = new THREE.Clock();
  updateCamera();
  window.addEventListener("resize", onResize);
  setupCameraControls();
  animate();
}

function onResize() {
  renderer.setSize(window.innerWidth, window.innerHeight);
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
}

function updateCamera() {
  const x = Math.sin(camYaw) * camDist;
  const z = Math.cos(camYaw) * camDist;
  camera.position.set(x, camY, z);
  camera.lookAt(0, camY, 0);
}

function saveFraming() {
  localStorage.setItem("camDist", String(camDist));
  localStorage.setItem("camY", String(camY));
  localStorage.setItem("camYaw", String(camYaw));
}

function setupCameraControls() {
  const c = $("canvas");
  c.addEventListener("wheel", (e) => {
    e.preventDefault();
    camDist = Math.max(0.25, Math.min(6, camDist * (e.deltaY < 0 ? 1 / 1.08 : 1.08)));
    updateCamera(); saveFraming();
  }, { passive: false });
  let dragging = false, lastX = 0, lastY = 0;
  c.addEventListener("pointerdown", (e) => { dragging = true; lastX = e.clientX; lastY = e.clientY; c.setPointerCapture(e.pointerId); });
  c.addEventListener("pointermove", (e) => {
    if (!dragging) return;
    camYaw -= (e.clientX - lastX) * 0.005;         // horizontal drag = orbit
    camY = Math.max(0.2, Math.min(1.8, camY - (e.clientY - lastY) * 0.004)); // vertical drag = pan height
    lastX = e.clientX; lastY = e.clientY;
    updateCamera();
  });
  const end = () => { if (dragging) { dragging = false; saveFraming(); } };
  c.addEventListener("pointerup", end);
  c.addEventListener("pointercancel", end);
}

// ---------------------------------------------------------------- VRM load
function loadVRM(arrayBuffer) {
  setStatus("parsing model…");
  const loader = new GLTFLoader();
  loader.register((parser) => new VRMLoaderPlugin(parser));
  loader.parse(arrayBuffer, "", (gltf) => {
    const v = gltf.userData.vrm;
    if (!v) { setStatus("not a VRM"); console.log("no vrm in gltf.userData"); return; }
    VRMUtils.rotateVRM0(v);              // VRM0 faces -z; make it face +z like VRM1 (no-op on VRM1)
    v.scene.traverse((o) => { o.frustumCulled = false; });
    scene.add(v.scene);
    vrm = v;
    mixer = new THREE.AnimationMixer(vrm.scene);
    mixer.addEventListener("finished", (e) => {
      if (e.action === currentGesture && currentIdle) {
        currentIdle.enabled = true; currentIdle.play();
        e.action.crossFadeTo(currentIdle, 0.3, false); // return to idle after a one-shot gesture
      }
      currentGesture = null;
    });
    // Process any animations that arrived before the VRM was ready.
    const queued = pendingAnims; pendingAnims = [];
    queued.forEach((p) => loadAnimation(p.name, p.arrayBuffer));
    if (vrm.lookAt) vrm.lookAt.target = null; // no eye-tracking -> idles looking forward
    const exprs = vrm.expressionManager ? vrm.expressionManager.expressions.map((e) => e.expressionName) : [];
    console.log("VRM loaded; expressions:", exprs.join(", ") || "(none)");
    setStatus("");
  }, (err) => { console.log("VRM parse error:", (err && err.message) || err); setStatus("model parse failed"); });
}

// ---------------------------------------------------------------- VRMA animation clips
// Parse a .vrma buffer, bind it to the VRM, register it under `name`. "idle" loops immediately.
function loadAnimation(name, arrayBuffer) {
  if (!vrm || !mixer) { pendingAnims.push({ name, arrayBuffer }); return; } // VRM not parsed yet -> queue
  const loader = new GLTFLoader();
  loader.register((parser) => new VRMAnimationLoaderPlugin(parser));
  loader.parse(arrayBuffer, "", (gltf) => {
    const anims = gltf.userData.vrmAnimations;
    if (!anims || !anims.length) { console.log("no vrmAnimation in", name); return; }
    const action = mixer.clipAction(createVRMAnimationClip(anims[0], vrm));
    console.log("animation loaded:", name);
    if (/^idle/.test(name)) {                 // idle, idle2, idle_lounge, … -> random-cycle pool
      action.setLoop(THREE.LoopRepeat, Infinity);
      idles.push(action);
      if (!currentIdle) { currentIdle = action; action.play(); idlePlaying = true; }
      scheduleNextIdle();                     // (re)arm once 2+ idles exist (clips load one by one)
    } else {
      actions[name] = action;                 // one-shot gesture keyed by emotion tag
    }
  }, (err) => console.log("vrma parse error", name, (err && err.message) || err));
}

// Cross-fade to a different random idle every ~12–28s (only if there are 2+ idle clips).
function scheduleNextIdle() {
  if (idleTimer) clearTimeout(idleTimer);
  if (idles.length < 2) return;
  idleTimer = setTimeout(cycleIdle, 12000 + Math.random() * 16000);
}
function cycleIdle() {
  if (idles.length >= 2 && !currentGesture) {
    let next = currentIdle;
    while (next === currentIdle) next = idles[Math.floor(Math.random() * idles.length)];
    next.reset().play();
    currentIdle.crossFadeTo(next, 1.0, false);
    currentIdle = next;
  }
  scheduleNextIdle();
}

// One-shot gesture (e.g. on an emotion), cross-fading from/back to the current idle.
function playGesture(name) {
  const a = actions[name];
  if (!a || a === currentGesture) return;
  currentGesture = a;
  a.reset(); a.setLoop(THREE.LoopOnce, 1); a.clampWhenFinished = true;
  if (currentIdle) currentIdle.crossFadeTo(a, 0.25, false); else a.play();
  a.play();
}

// ---------------------------------------------------------------- procedural idle
let blinkTimer = 0, nextBlink = 2 + Math.random() * 3, blinkPhase = -1;

// Rest pose: how far to lower the upper arms out of the VRoid T-pose (radians), plus a little
// elbow bend so the arms don't look stiff. Tunable.
const ARM_DOWN = 1.2;
const ELBOW_BEND = 0.18;

function updateIdle(dt) {
  const t = clock.elapsedTime;
  const h = vrm.humanoid;
  if (h && !idlePlaying) { // procedural body idle only when no idle clip is driving the bones
    const bone = (n) => h.getNormalizedBoneNode(n);
    // Static rest pose: lower the arms to the sides (kills the T-pose).
    const lUp = bone("leftUpperArm"), rUp = bone("rightUpperArm");
    if (lUp) lUp.rotation.z = -ARM_DOWN;
    if (rUp) rUp.rotation.z = ARM_DOWN;
    const lLo = bone("leftLowerArm"), rLo = bone("rightLowerArm");
    if (lLo) lLo.rotation.z = -ELBOW_BEND;
    if (rLo) rLo.rotation.z = ELBOW_BEND;

    // Living idle: breathing + a slow, relaxed weight-shift sway + faint head drift.
    const chest = bone("upperChest") || bone("chest");
    if (chest) chest.rotation.x = Math.sin(t * 1.1) * 0.022;    // breathing
    const spine = bone("spine");
    if (spine) { spine.rotation.y = Math.sin(t * 0.45) * 0.05; spine.rotation.z = Math.sin(t * 0.32) * 0.02; } // sway + weight shift
    const hips = bone("hips");
    if (hips) hips.rotation.z = Math.sin(t * 0.32) * 0.015; // subtle hip counter-sway
    const head = bone("head");
    if (head) { head.rotation.z = Math.sin(t * 0.4) * 0.02; head.rotation.y = Math.sin(t * 0.27) * 0.03; } // gentle look-around
  }
  // Blink: a quick down/up on the "blink" expression at random intervals.
  blinkTimer += dt;
  if (blinkPhase < 0 && blinkTimer > nextBlink) blinkPhase = 0;
  if (blinkPhase >= 0) {
    blinkPhase += dt * 9;
    const b = blinkPhase < 0.5 ? blinkPhase * 2 : Math.max(0, 2 - blinkPhase * 2);
    setExpr("blink", Math.min(1, b));
    if (blinkPhase >= 1) { blinkPhase = -1; blinkTimer = 0; nextBlink = 2 + Math.random() * 3; setExpr("blink", 0); }
  }
}

// ---------------------------------------------------------------- emotion
let currentEmotion = null, emotionValue = 0;

function applyEmotionFromText(text) {
  if (!text || !vrm) return;
  EMOTION_TAG_RE.lastIndex = 0;
  let m, name = null;
  while ((m = EMOTION_TAG_RE.exec(text)) !== null) name = m[1].toLowerCase(); // last tag wins
  if (!name) return;                       // no tag -> keep current emotion (it decays on its own)
  const emo = EMOTION_BY_NAME[name];
  if (emo === undefined) return;           // unknown tag -> ignore
  if (currentEmotion && emo !== currentEmotion) setExpr(currentEmotion, 0); // clear the old one
  if (emo !== "neutral") { currentEmotion = emo; emotionValue = 1; playGesture(name); } // gesture clip if present
  else { if (currentEmotion) setExpr(currentEmotion, 0); currentEmotion = null; emotionValue = 0; }
}

function updateEmotion(dt) {
  if (!currentEmotion) return;
  emotionValue = Math.max(0, emotionValue - dt / 4); // fade over ~4s (persists across untagged segments)
  setExpr(currentEmotion, emotionValue);
  if (emotionValue <= 0) { setExpr(currentEmotion, 0); currentEmotion = null; }
}

function setExpr(name, weight) {
  if (vrm && vrm.expressionManager) { try { vrm.expressionManager.setValue(name, weight); } catch (e) {} }
}

// ---------------------------------------------------------------- render loop
function animate() {
  requestAnimationFrame(animate);
  const dt = clock.getDelta();
  if (vrm) {
    // lip-sync target from the volume envelope, indexed by the Web Audio clock
    let target = 0;
    if (currentSource && currentVolumes && audioCtx) {
      const i = Math.floor((audioCtx.currentTime - currentStart) * 1000 / currentSlice);
      if (i >= 0 && i < currentVolumes.length) {
        target = Math.min(1, Math.pow(currentVolumes[i], LIPSYNC_CURVE) * LIPSYNC_GAIN);
      }
    }
    const rate = target > mouthValue ? 0.6 : 0.25;
    mouthValue += (target - mouthValue) * rate;

    updateIdle(dt);
    updateEmotion(dt);
    setExpr("aa", mouthValue);   // set all expressions before vrm.update applies them
    if (mixer) mixer.update(dt); // VRMA clips drive the bones (after procedural, so clips win)
    vrm.update(dt);              // also ticks spring bones (hair/clothes physics)
  }
  renderer.render(scene, camera);
}

// ---------------------------------------------------------------- audio + lip-sync (reused)
let audioCtx = null, currentSource = null, currentVolumes = null, currentSlice = 20, currentStart = 0;
let audioQueue = [], playing = false;

function enqueueAudio(seg) { audioQueue.push(seg); if (!playing) playNext(); }

async function playNext() {
  const seg = audioQueue.shift();
  if (!seg) { playing = false; currentVolumes = null; return; }
  playing = true;
  applyEmotionFromText(seg.display_text && seg.display_text.text);
  if (!seg.audio) { setTimeout(playNext, 30); return; }
  try {
    if (!audioCtx) audioCtx = new (window.AudioContext || window.webkitAudioContext)();
    if (audioCtx.state === "suspended") await audioCtx.resume();
    const bin = atob(seg.audio);
    const bytes = new Uint8Array(bin.length);
    for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
    const buf = await audioCtx.decodeAudioData(bytes.buffer);
    const src = audioCtx.createBufferSource();
    src.buffer = buf;
    src.connect(audioCtx.destination);
    currentSource = src;
    currentVolumes = (seg.volumes && seg.volumes.length) ? seg.volumes : null;
    currentSlice = seg.slice_length || 20;
    currentStart = audioCtx.currentTime;
    src.onended = () => {
      if (currentSource !== src) return;
      currentSource = null; currentVolumes = null;
      window.companion.toBackend({ type: "frontend-playback-complete" });
      playNext();
    };
    src.start();
  } catch (e) { console.log("audio err:", e.message); currentSource = null; currentVolumes = null; playNext(); }
}

function stopAudio() {
  audioQueue = [];
  if (currentSource) { try { currentSource.onended = null; currentSource.stop(); } catch (e) {} currentSource = null; }
  currentVolumes = null; playing = false; mouthValue = 0;
}

// ---------------------------------------------------------------- mic capture (hands-free)
// Stream 16kHz mono Float32 frames as raw-audio-data; the server's Silero VAD detects
// speech-end (main echoes mic-audio-end) and barge-in (control:interrupt -> we stop playback).
let micCtx = null, micStream = null, micNode = null, micSource = null, micSink = null, micOn = false;

async function startMic() {
  if (micOn) return;
  try {
    micStream = await navigator.mediaDevices.getUserMedia({
      audio: { channelCount: 1, echoCancellation: true, noiseSuppression: true, autoGainControl: true },
    });
    micCtx = new AudioContext({ sampleRate: 16000 });
    if (micCtx.state === "suspended") await micCtx.resume();
    micSource = micCtx.createMediaStreamSource(micStream);
    micNode = micCtx.createScriptProcessor(2048, 1, 1); // 2048/16k = 128ms frames
    micNode.onaudioprocess = (e) => {
      if (!micOn) return;
      // Backend does np.array(audio, float32) -> send a plain array of samples.
      window.companion.toBackend({ type: "raw-audio-data", audio: Array.from(e.inputBuffer.getChannelData(0)) });
    };
    micSink = micCtx.createGain(); micSink.gain.value = 0; // silent sink so we don't hear the mic
    micSource.connect(micNode); micNode.connect(micSink); micSink.connect(micCtx.destination);
    micOn = true;
    console.log("mic started @", micCtx.sampleRate, "Hz (hands-free)");
  } catch (e) { console.log("mic start failed:", e.message); setStatus("mic error: " + e.message); }
}

function stopMic() {
  micOn = false;
  try { if (micNode) { micNode.onaudioprocess = null; micNode.disconnect(); } if (micSource) micSource.disconnect(); if (micSink) micSink.disconnect(); } catch (e) {}
  if (micStream) { micStream.getTracks().forEach((t) => t.stop()); micStream = null; }
  if (micCtx) { micCtx.close().catch(() => {}); micCtx = null; }
  console.log("mic stopped");
}

// ---------------------------------------------------------------- IPC from main
window.companion.on("model-data", (ab) => loadVRM(ab));
window.companion.on("animation-data", (d) => loadAnimation(d.name, d.buffer));
window.companion.on("set-mic", (on) => (on ? startMic() : stopMic()));
window.companion.on("model-error", (m) => { console.log("model read error:", m); setStatus("model missing: " + m); });
window.companion.on("audio", (msg) => enqueueAudio(msg));
window.companion.on("stop", () => stopAudio());
window.companion.on("status", (s) => setStatus(s));
window.companion.on("set-model", () => { /* single hardcoded VRM for now; hook for later */ });

// ---------------------------------------------------------------- boot
try { initThree(); }
catch (e) { console.log("three init FAILED:", e.message); setStatus("three failed: " + e.message); }
startMic(); // hands-free by default
