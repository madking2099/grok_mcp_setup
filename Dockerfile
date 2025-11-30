# Multi-stage: Build deps, then slim runtime
FROM python:3.12-slim AS builder

# Install uv (fast Python pkg mgr) and Node (for npx)
RUN apt-get update && apt-get install -y curl && \
    curl -LsSf https://astral.sh/uv/install.sh | sh && \
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy MCP server sources (clone these repos first on host, or fetch in build)
WORKDIR /app
COPY . /app  # Assumes you git clone the servers into here pre-build

# Install Python MCP deps (for Git/Filesystem/PDF)
RUN uv venv /app/.venv && \
    . /app/.venv/bin/activate && \
    uv pip install mcp[cli] mcp-server-git @modelcontextprotocol/server-filesystem pdfplumber  # For PDF extraction

# Install Node MCP deps (for Brave web search)
RUN npm install -g npx @modelcontextprotocol/server-brave-search

# Runtime stage
FROM python:3.12-slim
RUN apt-get update && apt-get install -y curl && apt-get clean
COPY --from=builder /app /app
COPY --from=builder /root/.local/bin/uv /root/.local/bin/uv
COPY --from=builder /usr/bin/node /usr/bin/node
ENV PATH="/root/.local/bin:/app/.venv/bin:$PATH"

# Expose ports for HTTP LAN access
EXPOSE 8001 8002 8003

# Healthcheck: Simple curl to self
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8001/health || exit 1

# Run script: Starts all three servers in background
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]
