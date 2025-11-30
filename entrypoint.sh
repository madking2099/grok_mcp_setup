#!/bin/bash
set -e

# Env vars: Set these in compose or .env
export BRAVE_API_KEY=${BRAVE_API_KEY:-"your-brave-key-here"}
export ALLOWED_PATHS="/projects:/ebooks"  # Whitelist for Filesystem/PDF

cd /app

# Start Git MCP on port 8001 (HTTP)
( . .venv/bin/activate && uvx mcp-server-git --transport http --host 0.0.0.0 --port 8001 --repository /projects ) &

# Start Brave Web Search on 8002
( npx @modelcontextprotocol/server-brave-search --transport http --host 0.0.0.0 --port 8002 ) &

# Start Filesystem + PDF Reader hybrid on 8003 (use pdfplumber for extraction)
( . .venv/bin/activate && uvx @modelcontextprotocol/server-filesystem --transport http --host 0.0.0.0 --port 8003 --allowed-paths "$ALLOWED_PATHS" && \
  # Inline PDF tool: Simple wrapper script for extraction on call ) &

# Wait forever
wait
