#!/usr/bin/env python3
"""Sleep-time memory consolidation for the local AI companion.

Runs nightly (NixOS systemd timer, ~4 AM). Reads the day's OLV chat logs, asks the
local LLM to distill durable one-line facts about the user (merging/deduping against
what's already stored), and writes them into the same SQLite memory store the live
`memory` MCP tool uses. Also appends the day's exchanges to a JSONL corpus for future
fine-tuning (the "learn over time" path).

Stdlib only (sqlite3 + urllib + json) so it runs on a bare nixpkgs python3 with no deps.
Idempotent via a watermark stored in the DB: only messages newer than the last
successful run are processed, and the watermark only advances after the LLM call
succeeds (so an offline model just means we retry tomorrow).
"""
import glob
import json
import os
import sqlite3
import sys
import time
import urllib.request
from datetime import datetime, timezone
from urllib.parse import urlsplit

DB_PATH = os.environ.get("MEMORY_DB", "/home/suzu/ai-models/memory/memory.db")
CHAT_DIR = os.environ.get("CHAT_HISTORY_DIR", "/home/suzu/ai-models/olv/chat_history")
CONF_UID = os.environ.get("CONF_UID", "mao_pro_001")
LLAMA_URL = os.environ.get("LLAMA_URL", "http://localhost:8080/v1/chat/completions")
TRAINING_JSONL = os.environ.get("TRAINING_JSONL", "/home/suzu/ai-models/memory/training_data.jsonl")
MODEL = os.environ.get("LLAMA_MODEL", "chat")  # llama-swap profile name (Phase 7)


def log(*a):
    print(f"[consolidate {datetime.now().isoformat(timespec='seconds')}]", *a, flush=True)


def db():
    conn = sqlite3.connect(DB_PATH, timeout=30)
    conn.execute("PRAGMA journal_mode=WAL;")
    conn.execute(
        """CREATE TABLE IF NOT EXISTS memories (
            id INTEGER PRIMARY KEY AUTOINCREMENT, fact TEXT NOT NULL UNIQUE,
            category TEXT NOT NULL DEFAULT 'general', importance INTEGER NOT NULL DEFAULT 1,
            created_at TEXT NOT NULL, updated_at TEXT NOT NULL,
            source TEXT NOT NULL DEFAULT 'conversation')"""
    )
    conn.execute("CREATE TABLE IF NOT EXISTS meta (key TEXT PRIMARY KEY, value TEXT)")
    return conn


def get_watermark(conn):
    row = conn.execute("SELECT value FROM meta WHERE key='last_consolidated'").fetchone()
    return row[0] if row else "1970-01-01T00:00:00"


def set_watermark(conn, ts):
    conn.execute(
        "INSERT INTO meta (key, value) VALUES ('last_consolidated', ?) "
        "ON CONFLICT(key) DO UPDATE SET value=excluded.value",
        (ts,),
    )


def collect_new_messages(since_iso):
    """Return [(timestamp, role, content)] for human/ai messages newer than since_iso."""
    msgs = []
    for path in sorted(glob.glob(os.path.join(CHAT_DIR, CONF_UID, "*.json"))):
        try:
            with open(path, encoding="utf-8") as f:
                data = json.load(f)
        except Exception:
            continue
        for m in data:
            role = m.get("role")
            if role not in ("human", "ai"):
                continue
            ts = m.get("timestamp", "")
            if ts > since_iso and m.get("content"):
                msgs.append((ts, role, m["content"]))
    msgs.sort()
    return msgs


def strip_tags(text):
    """Remove [emotion] tags from AI turns so they don't pollute memory/training data."""
    import re
    return re.sub(r"\[[a-zA-Z]+\]", "", text).strip()


def wait_for_llama(max_wait=600):
    """Block until llama-server answers /health, or timeout. Handles the post-boot
    catch-up case: after a cold boot the container needs ~30-60s to load the model,
    and the (Persistent) timer may fire before it's ready."""
    parts = urlsplit(LLAMA_URL)
    health = f"{parts.scheme}://{parts.netloc}/health"
    deadline = time.time() + max_wait
    while time.time() < deadline:
        try:
            with urllib.request.urlopen(health, timeout=5) as r:
                if r.status == 200:
                    return True
        except Exception:
            pass
        time.sleep(10)
    return False


def call_llm(system, user, max_tokens=800):
    body = json.dumps({
        "model": MODEL, "temperature": 0.3, "max_tokens": max_tokens,
        "messages": [{"role": "system", "content": system}, {"role": "user", "content": user}],
    }).encode()
    req = urllib.request.Request(LLAMA_URL, data=body, headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=180) as r:
        data = json.load(r)
    return data["choices"][0]["message"]["content"]


def extract_json_array(text):
    start, end = text.find("["), text.rfind("]")
    if start == -1 or end == -1 or end <= start:
        return []
    try:
        return json.loads(text[start:end + 1])
    except Exception:
        return []


EXTRACT_SYSTEM = (
    "You are a memory consolidation assistant for a personal AI companion. From a day's "
    "conversation, extract only DURABLE facts worth remembering for months: the user's "
    "identity, name, location, language, work, relationships, strong preferences/dislikes, "
    "plans, and meaningful life events. Ignore small talk, transient topics, weather, news, "
    "and anything the companion said about itself. Merge with and do not duplicate the facts "
    "already known. Write each as one concise first-person-neutral sentence about the user. "
    'Reply with ONLY a JSON array of objects: [{"fact": str, "category": str, "importance": 1-3}]. '
    "category is one of: name, person, preference, fact, plan, relationship, general. "
    "If nothing new and durable came up, reply with []."
)


def main():
    conn = db()
    watermark = get_watermark(conn)
    msgs = collect_new_messages(watermark)
    if not msgs:
        log("no new messages since", watermark, "- nothing to do.")
        return 0
    log(f"{len(msgs)} new messages since {watermark}")

    # Build transcript + append training data.
    lines, train_turns = [], []
    for ts, role, content in msgs:
        who = "User" if role == "human" else "Aria"
        clean = strip_tags(content) if role == "ai" else content.strip()
        lines.append(f"{who}: {clean}")
        train_turns.append({"role": "user" if role == "human" else "assistant", "content": clean})
    transcript = "\n".join(lines)

    known = conn.execute(
        "SELECT fact FROM memories ORDER BY importance DESC, updated_at DESC LIMIT 300"
    ).fetchall()
    known_block = "\n".join(f"- {f[0]}" for f in known) or "(none yet)"

    user_prompt = (
        f"Facts already known about the user:\n{known_block}\n\n"
        f"Today's conversation:\n{transcript}\n\n"
        "Extract new durable facts as the JSON array described."
    )

    if not wait_for_llama():
        log("llama-server not reachable after waiting - leaving watermark, will retry.")
        return 1  # do NOT advance watermark (e.g. stack down / gaming mode)

    try:
        raw = call_llm(EXTRACT_SYSTEM, user_prompt)
    except Exception as e:
        log("LLM call failed (model offline?):", e, "- leaving watermark, will retry.")
        return 1  # do NOT advance watermark

    facts = extract_json_array(raw)
    now = datetime.now(timezone.utc).isoformat(timespec="seconds")
    added = 0
    for item in facts:
        if not isinstance(item, dict):
            continue
        fact = str(item.get("fact", "")).strip()
        if not fact:
            continue
        cat = str(item.get("category", "general")).strip() or "general"
        imp = max(1, min(3, int(item.get("importance", 1) or 1)))
        cur = conn.execute("SELECT id FROM memories WHERE fact=?", (fact,))
        if cur.fetchone():
            conn.execute("UPDATE memories SET updated_at=?, importance=MAX(importance,?) WHERE fact=?",
                         (now, imp, fact))
        else:
            conn.execute(
                "INSERT INTO memories (fact, category, importance, created_at, updated_at, source) "
                "VALUES (?,?,?,?,?, 'consolidation')", (fact, cat, imp, now, now))
            added += 1
    log(f"extracted {len(facts)} facts, {added} new.")

    # Append the day's exchanges as a training example (for future fine-tuning).
    try:
        os.makedirs(os.path.dirname(TRAINING_JSONL), exist_ok=True)
        with open(TRAINING_JSONL, "a", encoding="utf-8") as f:
            f.write(json.dumps({"date": now, "messages": train_turns}, ensure_ascii=False) + "\n")
    except Exception as e:
        log("training-data append failed (non-fatal):", e)

    set_watermark(conn, msgs[-1][0])
    conn.commit()
    log("done. watermark ->", msgs[-1][0])
    return 0


if __name__ == "__main__":
    sys.exit(main())
