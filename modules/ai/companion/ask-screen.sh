# ask-screen [region] — capture the screen (or a slurp-selected region), ask the
# companion's vision model about it, show the answer as a notification, and speak it
# in her Kokoro voice. Talks DIRECTLY to the backend services (llama-server vision +
# Kokoro TTS), independent of OLV / the avatar frontend, so it survives a frontend swap.
#
# Packaged via writeShellApplication (provides the shebang, `set -euo pipefail`, and
# grim/slurp/jq/curl/mpv/libnotify/coreutils on PATH). Bound to keys in niri/keybinds.nix.

LLAMA="${LLAMA_URL:-http://localhost:8080/v1/chat/completions}"
KOKORO="${KOKORO_URL:-http://localhost:8880/v1/audio/speech}"
VOICE="${KOKORO_VOICE:-af_bella}"
SYS="You are Aria, a warm, quick-witted companion glancing at the user's screen over their shoulder. Reply in short, casual spoken prose (1-3 sentences). No markdown, no lists. If you see an error or something they might need help with, point it out plainly."
Q="${QUESTION:-Take a quick look at my screen. Tell me what you see, and flag anything I might need help with.}"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
img="$tmp/shot.png"

# Capture: a selected region (arg "region") or the whole output.
if [ "${1:-}" = "region" ]; then
  region="$(slurp)" || exit 0   # user hit escape -> abort quietly
  grim -g "$region" "$img"
else
  grim "$img"
fi

# A full-screen PNG's base64 is megabytes — too big for a CLI argument (ARG_MAX), so
# route it through files: build the data URI in a file, feed it to jq via --rawfile, and
# POST the request body from a file with `curl -d @`.
{ printf 'data:image/png;base64,'; base64 -w0 "$img"; } > "$tmp/img.txt"
jq -cn --arg q "$Q" --arg sys "$SYS" --rawfile img "$tmp/img.txt" \
  '{model:"chat", temperature:0.4, max_tokens:220,
    messages:[
      {role:"system", content:$sys},
      {role:"user", content:[{type:"text", text:$q},{type:"image_url", image_url:{url:($img|rtrimstr("\n"))}}]}
    ]}' > "$tmp/req.json"

resp="$(curl -sf --max-time 150 "$LLAMA" -H 'Content-Type: application/json' -d @"$tmp/req.json" || true)"
if [ -z "$resp" ]; then
  notify-send "Aria 👀" "I couldn't reach my eyes right now — is the stack running?"
  exit 0
fi

answer="$(printf '%s' "$resp" | jq -r '.choices[0].message.content // "I could not make that out."')"
notify-send "Aria 👀" "$answer"

# Speak it in her voice (best-effort; never fail the whole thing on TTS trouble).
say="$(jq -cn --arg t "$answer" --arg v "$VOICE" '{model:"kokoro", voice:$v, input:$t, response_format:"mp3"}')"
code="$(curl -s --max-time 60 "$KOKORO" -H 'Content-Type: application/json' -d "$say" -o "$tmp/say.mp3" -w '%{http_code}' || echo 000)"
if [ "$code" = "200" ]; then
  mpv --no-video --really-quiet "$tmp/say.mp3" >/dev/null 2>&1 || true
fi
