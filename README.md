# Grok MCP Setup

[![Docker](https://img.shields.io/badge/Docker-Compose-blue?logo=docker)](https://docs.docker.com/compose/) [![MCP](https://img.shields.io/badge/MCP-Protocol-v0.1.0-green?logo=python)](https://modelcontextprotocol.org/) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![Stars](https://img.shields.io/github/stars/madking2099/grok_mcp_setup?style=social)](https://github.com/madking2099/grok_mcp_setup)

A **free, open-source Dockerized stack** for integrating **Grok** (via xAI API and CodeGPT plugin) with **MCP (Model Context Protocol)** servers. This setup chains:
- **Git MCP**: Version control ops (diff, commit, grep) on local repos.
- **Web Search MCP**: Privacy-focused browsing/searches without external APIs (via self-hosted SearXNG).
- **Local Library MCP**: Scan/extract from PDFs, MDs, and file libs (e.g., ebooks).

Perfect for PyCharm users wanting Grok to "see" your LAN: Research web → Cross-ref local docs → Update Git—all in one prompt. Runs on a single workstation or homelab server. **Zero third-party keys required**.

## Files Overview
This repo provides two deployment flavors: **Modular** (recommended for simplicity; separate containers) and **Bundled** (all-in-one image via Dockerfile/entrypoint.sh for advanced chaining).

- **[docker-compose.yml](https://github.com/madking2099/grok_mcp_setup/blob/master/docker-compose.yml)**: Orchestrates the modular stack (three services). Uses official images; no build needed.
- **[Dockerfile](https://github.com/madking2099/grok_mcp_setup/blob/master/Dockerfile)**: Builds a single "mcp-hub" image bundling all servers (Python/Node deps). Use for the bundled variant.
- **[entrypoint.sh](https://github.com/madking2099/grok_mcp_setup/blob/master/entrypoint.sh)**: Launches Git/Web/Library servers concurrently in the bundled image. Handles env vars like `ALLOWED_PATHS`.
- **[README.md](https://github.com/madking2099/grok_mcp_setup/blob/master/README.md)**: You're reading it! (This file.)
- **Optional**: `.env.example` (for paths/ports), `searxng-settings.yml` (web config), `pdf_server.py` (PDF extraction stub—add via PR).

For bundled mode, swap the compose service to `build: .` and reference entrypoint.sh.

## Features
- **Modular & Lightweight**: <1GB RAM, HTTP-exposed for LAN.
- **Air-Gapped Ready**: Local ops; SearXNG aggregates free engines (no cloud).
- **Grok Synergy**: CodeGPT tool-calls for chains like "Diff repo, search 'PyTorch async', extract ebook.pdf."
- **Extensible**: Add MCPs (e.g., OCR) via compose.
- **Secure**: Read-only volumes, whitelisted paths.

## Prerequisites
- Docker & Docker Compose (v2+).
- CodeGPT in PyCharm (xAI API key for Grok).
- Mounted dirs (e.g., `/pub/your-repo` for Git, `/pub/ebooks` for libs).
- Optional: Clone MCP sources into `./src` for bundled builds (`git clone https://github.com/modelcontextprotocol/servers src`).

## Quick Start
1. **Clone & Prep**:
   ```bash
   git clone https://github.com/madking2099/grok_mcp_setup.git
   cd grok_mcp_setup
   cp .env.example .env  # Customize paths/ports
   # For bundled: git clone https://github.com/modelcontextprotocol/servers src
   ```

2. **(Optional) Add PDF Extraction**:
   - Create `pdf_server.py` (MCP wrapper with `pdfplumber`—see [MCP PDF examples](https://github.com/modelcontextprotocol/servers/tree/main/src/pdf) or open an issue).

3. **Launch (Modular - Recommended)**:
   ```bash
   docker compose up -d
   # Verify: docker compose ps
   # Logs: docker compose logs -f mcp-git
   ```

4. **Or Launch (Bundled - Advanced)**:
   - Edit `docker-compose.yml`: Change `mcp-hub` service to `build: .` and add `entrypoint: ["/app/entrypoint.sh"]`.
   - Then: `docker compose up -d --build`.

5. **Configure CodeGPT**:
   - Edit `~/.codegpt/mcp.json`:
     ```json
     {
       "mcpServers": {
         "lan-git": { "type": "http", "url": "http://localhost:8001" },
         "lan-web": { "type": "http", "url": "http://localhost:8002/search?q=query" },
         "lan-lib": { "type": "http", "url": "http://localhost:8003" }
       }
     }
     ```
   - Refresh in PyCharm. Test: "Using lan-git, ls /projects; lan-web, search 'MCP tips'; lan-lib, extract /ebooks/sample.pdf."

6. **Access**:
   - Git: `curl http://localhost:8001/health`
   - Web: `http://localhost:8002` (SearXNG UI)
   - Lib: `curl http://localhost:8003/list?path=/ebooks`

## Customization
- **.env Example**:
  ```
  PROJECTS_PATH=/pub/your-repo
  LIBRARY_PATH=/pub/ebooks
  GIT_PORT=8001
  WEB_PORT=8002
  LIB_PORT=8003
  ```
- **SearXNG Config**: Edit `searxng-settings.yml` for engines (e.g., DuckDuckGo only). [Docs](https://docs.searxng.org/).
- **Bundled Tweaks**: In `entrypoint.sh`, adjust `BRAVE_API_KEY` env if adding back (optional).
- **Extend**: Add Markdownify service:
  ```yaml
  mcp-md:
    image: node:20-slim
    command: ["npx", "@modelcontextprotocol/server-markdownify", "--http", "0.0.0.0:8004"]
    ports: ["8004:8004"]
  ```

## Architecture
- **mcp-git**: Semantic repo queries ([command in compose](https://github.com/madking2099/grok_mcp_setup/blob/master/docker-compose.yml#L5)).
- **mcp-web**: SearXNG meta-search (no keys).
- **mcp-lib**: Filesystem + PDF reader (via `pdf_server.py`).

Bundled alt: [Dockerfile](https://github.com/madking2099/grok_mcp_setup/blob/master/Dockerfile) + [entrypoint.sh](https://github.com/madking2099/grok_mcp_setup/blob/master/entrypoint.sh) for single-container chaining.

Prompt Flow: Grok → CodeGPT → MCP → Tool Response.

## Troubleshooting
- **Hybrid Compose Errors**: If ports/volumes conflict, use the modular version above.
- **Build Fails**: Ensure `./src` for COPY in [Dockerfile](https://github.com/madking2099/grok_mcp_setup/blob/master/Dockerfile); check logs.
- **Permissions**: `chmod -R o+r /pub`; UFW for LAN: `ufw allow from 192.168.0.0/24 to any port 8001:8003`.
- **SearXNG Slow**: Bump `UWSGI_WORKERS=4`; initial run indexes engines.
- **No PDF Extract?**: Implement `pdf_server.py` or fallback to filesystem-only.

## Contributing
Fork/PR ideas: Tesseract OCR, Kavita ebook API, VS Code port. Open issues for bugs!

## License
MIT © madking2099. See [LICENSE](LICENSE) (add if missing).

## Acknowledgments
- [Model Context Protocol](https://modelcontextprotocol.org/).
- [SearXNG](https://searxng.org/).
- xAI/Grok. 🚀

**Star if it powers your setup!** [@madking2099 on X](https://x.com/madking2099).
