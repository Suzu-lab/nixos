#!/usr/bin/env python3
"""Minimal, tolerant SearXNG MCP server for the local AI companion.

Replaces the PyPI `mcp-searxng` package, which (a) requires Python >=3.12 (our OLV
image is 3.11) and (b) validates SearXNG's JSON against a strict pydantic model that
requires `number_of_results` — a field recent SearXNG omits, causing a ValidationError
on every search so the model thinks search is broken and hallucinates.

This uses the `mcp` SDK + `httpx` already present in the OLV image, parses results
leniently (plain dict access), and is launched from mcp_servers.json:
    { "command": "python3", "args": ["/app/searxng_mcp.py"], "env": {"SEARXNG_URL": ...} }
"""
import os
import httpx
from mcp.server.fastmcp import FastMCP

SEARXNG_URL = os.environ.get("SEARXNG_URL", "http://searxng:8080")
MAX_RESULTS = int(os.environ.get("SEARXNG_MAX_RESULTS", "5"))

mcp = FastMCP("searxng")


@mcp.tool()
async def search(query: str) -> str:
    """Search the web via a self-hosted SearXNG instance (aggregates Google, Bing,
    Brave, DuckDuckGo, Wikipedia, Startpage and more). Use this for current events,
    news, weather, prices, sports, software versions, or any real-world fact that may
    have changed since training. Returns the top results as Title / URL / Content."""
    try:
        async with httpx.AsyncClient(base_url=SEARXNG_URL, timeout=20) as client:
            resp = await client.get("/search", params={"q": query, "format": "json"})
            resp.raise_for_status()
            data = resp.json()
    except Exception as e:  # network / non-200 / bad JSON
        return f"Search error: {e}"

    parts = []

    # Direct answers / infoboxes often carry the exact fact (e.g. Wikipedia summary).
    for ans in (data.get("answers") or [])[:2]:
        parts.append(f"Answer: {ans}")
    for ib in (data.get("infoboxes") or [])[:1]:
        content = (ib.get("content") or "").strip()
        if content:
            parts.append(f"Infobox ({ib.get('infobox', '')}): {content}")

    results = data.get("results") or []
    for r in results[:MAX_RESULTS]:
        title = (r.get("title") or "").strip()
        url = (r.get("url") or "").strip()
        content = (r.get("content") or "").strip()
        parts.append(f"Title: {title}\nURL: {url}\nContent: {content}")

    if not parts:
        return f"No results found for '{query}'."
    return "\n\n".join(parts)


if __name__ == "__main__":
    mcp.run()  # stdio transport (default)
