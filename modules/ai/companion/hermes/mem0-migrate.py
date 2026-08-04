#!/usr/bin/env python3
"""One-shot migration: handmade SQLite memory  ->  mem0 (OSS).

Reads the companion's existing long-term memory (the `memories` table written by
memory_mcp.py / consolidate.py) and re-adds each fact into mem0, so nothing Reika has
learned about Suzu is lost when we retire the handmade store.

Run this AFTER the mem0 stack (qdrant + embeddings) is up and verified, and BEFORE
deleting memory.db / memory_mcp.py / consolidate.py. It is idempotent-ish: mem0 dedups
semantically, so re-running mostly no-ops, but check the count before/after.

Usage (needs `pip install mem0ai` and the companion stack running):
    MEMORY_DB=/home/suzu/ai-models/memory/memory.db python3 mem0-migrate.py

The mem0 config below MIRRORS hermes/mem0.json — keep them in sync. Endpoints use
127.0.0.1 (host-published ports) since this runs on the host, not inside the network.
"""
import os
import sqlite3
import sys

try:
    from mem0 import Memory
except ImportError:
    sys.exit("mem0 not installed. `pip install mem0ai` (in a venv) first.")

DB_PATH = os.environ.get("MEMORY_DB", "/home/suzu/ai-models/memory/memory.db")
USER_ID = os.environ.get("MEM0_USER_ID", "suzu")

CONFIG = {
    "llm": {
        "provider": "openai",
        "config": {
            "model": "chat",
            "openai_base_url": "http://127.0.0.1:8080/v1",
            "api_key": "local",
        },
    },
    "embedder": {
        "provider": "openai",
        "config": {
            "model": "intfloat/multilingual-e5-small",
            "openai_base_url": "http://127.0.0.1:7997/v1",
            "api_key": "local",
            "embedding_dims": 384,
        },
    },
    "vector_store": {
        "provider": "qdrant",
        "config": {
            "host": "127.0.0.1",
            "port": 6333,
            "collection_name": "reika_memory",
            "embedding_model_dims": 384,
        },
    },
}


def main() -> None:
    if not os.path.exists(DB_PATH):
        sys.exit(f"No memory db at {DB_PATH} — nothing to migrate.")

    conn = sqlite3.connect(DB_PATH)
    rows = conn.execute(
        "SELECT fact, category, importance, created_at FROM memories ORDER BY id"
    ).fetchall()
    conn.close()
    print(f"Found {len(rows)} facts in {DB_PATH}.")

    mem = Memory.from_config(CONFIG)
    migrated = 0
    for fact, category, importance, created_at in rows:
        fact = (fact or "").strip()
        if not fact:
            continue
        # Store the fact as a first-person memory, preserving its metadata.
        mem.add(
            fact,
            user_id=USER_ID,
            metadata={
                "category": category,
                "importance": importance,
                "source": "handmade-migration",
                "original_created_at": created_at,
            },
        )
        migrated += 1
        print(f"  [{migrated}/{len(rows)}] {fact[:80]}")

    print(f"Done. Pushed {migrated} facts into mem0 (collection reika_memory).")
    print("Verify with a search, then you can retire memory.db + consolidate.py.")


if __name__ == "__main__":
    main()
