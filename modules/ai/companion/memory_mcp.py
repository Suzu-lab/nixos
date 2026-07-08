#!/usr/bin/env python3
"""Long-term memory MCP server for the local AI companion.

A tiny SQLite-backed store of one-line memories the companion writes and reads
across sessions — the in-context half of the memory system (the overnight
consolidate.py job distills chat logs into this same store). Runs inside the OLV
container as an MCP stdio server (launched from mcp_servers.json), using the `mcp`
SDK already present in the image; only Python stdlib otherwise.

Store: SQLite at $MEMORY_DB (default /app/memory/memory.db), shared with the host
consolidation job. Facts are one-liners; for a companion they stay small enough to
load wholesale into context, so semantic/vector recall isn't needed yet.
"""
import os
import sqlite3
from datetime import datetime, timezone
from mcp.server.fastmcp import FastMCP

DB_PATH = os.environ.get("MEMORY_DB", "/app/memory/memory.db")
RECALL_CAP = int(os.environ.get("MEMORY_RECALL_CAP", "200"))

mcp = FastMCP("memory")


def _conn():
    conn = sqlite3.connect(DB_PATH, timeout=15)
    conn.execute("PRAGMA journal_mode=WAL;")
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS memories (
            id         INTEGER PRIMARY KEY AUTOINCREMENT,
            fact       TEXT NOT NULL UNIQUE,
            category   TEXT NOT NULL DEFAULT 'general',
            importance INTEGER NOT NULL DEFAULT 1,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            source     TEXT NOT NULL DEFAULT 'conversation'
        )
        """
    )
    return conn


def _now():
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


@mcp.tool()
async def remember(fact: str, category: str = "general", importance: int = 1) -> str:
    """Save one durable, first-person fact about the user or your relationship to
    long-term memory (persists across sessions). Use for things worth remembering
    weeks later: their name, where they live, language, job, relationships, strong
    preferences/dislikes, plans, recurring jokes. Keep `fact` to a single concise
    sentence. Do NOT save one-off small talk or things that change hourly.
    category: one of name, person, preference, fact, plan, relationship, general.
    importance: 1 (normal) to 3 (core identity)."""
    fact = (fact or "").strip()
    if not fact:
        return "Nothing to remember (empty fact)."
    importance = max(1, min(3, int(importance)))
    now = _now()
    with _conn() as conn:
        cur = conn.execute("SELECT id FROM memories WHERE fact = ?", (fact,))
        if cur.fetchone():
            conn.execute(
                "UPDATE memories SET updated_at=?, importance=MAX(importance,?), category=? WHERE fact=?",
                (now, importance, category, fact),
            )
            return f"Already knew that; refreshed: {fact}"
        conn.execute(
            "INSERT INTO memories (fact, category, importance, created_at, updated_at, source) "
            "VALUES (?,?,?,?,?, 'conversation')",
            (fact, category, importance, now, now),
        )
    return f"Saved to memory: {fact}"


@mcp.tool()
async def recall(query: str = "") -> str:
    """Load what you already know about the user from long-term memory. Call this
    silently at the START of a conversation (with an empty query) to remember who
    they are, and any time you need to check a stored fact (pass a keyword to filter,
    e.g. 'sister' or 'work'). Returns stored one-line memories, most important first."""
    query = (query or "").strip()
    with _conn() as conn:
        if query:
            like = f"%{query}%"
            rows = conn.execute(
                "SELECT fact, category FROM memories WHERE fact LIKE ? OR category LIKE ? "
                "ORDER BY importance DESC, updated_at DESC LIMIT ?",
                (like, like, RECALL_CAP),
            ).fetchall()
        else:
            rows = conn.execute(
                "SELECT fact, category FROM memories "
                "ORDER BY importance DESC, updated_at DESC LIMIT ?",
                (RECALL_CAP,),
            ).fetchall()
    if not rows:
        return "No memories stored yet." if not query else f"No memories match '{query}'."
    return "\n".join(f"- ({cat}) {fact}" for fact, cat in rows)


if __name__ == "__main__":
    mcp.run()  # stdio transport
