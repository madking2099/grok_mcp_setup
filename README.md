# Grok MCP Setup

[![Docker](https://img.shields.io/badge/Docker-Compose-blue?logo=docker)](https://docs.docker.com/compose/) [![MCP](https://img.shields.io/badge/MCP-Protocol-v0.1.0-green?logo=python)](https://modelcontextprotocol.org/) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![Stars](https://img.shields.io/github/stars/madking2099/grok_mcp_setup?style=social)](https://github.com/madking2099/grok_mcp_setup)

A **free, open-source Dockerized stack** for integrating **Grok** (via xAI API and CodeGPT plugin) with **MCP (Model Context Protocol)** servers. This setup chains:
- **Git MCP**: Version control ops (diff, commit, grep) on local repos.
- **Web Search MCP**: Privacy-focused browsing/searches without external APIs.
- **Local Library MCP**: Scan/extract from PDFs, MDs, and file libs (e.g., ebooks).

Perfect for PyCharm users wanting Grok to "see" your LAN: Research web → Cross-ref local docs → Update Git—all in one prompt. Runs on a single Precision workstation or homelab server. **Zero third-party keys required** (uses self-hosted SearXNG for web).

## Features
- **Modular & Lightweight**: 3 isolated containers (<1GB RAM), HTTP-exposed for LAN access.
- **Air-Gapped Ready**: Local-only ops; web via self-hosted meta-search (no cloud lock-in).
- **Grok Synergy**: Hooks into CodeGPT for tool-calling—e.g., "Diff my repo, search 'PyTorch async', extract from ebook.pdf."
- **Extensible**: Easy to add MCP servers (e.g., OCR, DB queries) via compose.
- **Secure**: Read-only volumes, whitelisted paths, bridge network.

## Prerequisites
- Docker & Docker Compose (v2+).
- CodeGPT plugin in PyCharm (with xAI API key for Grok).
- Git repos/PDF libs mounted (e.g., `/pub/your-repo`, `/pub/ebooks`).
- Optional: `.env` file for custom paths/ports.

## Quick Start
1. **Clone & Prep**:
   ```bash
   git clone https://github.com/madking2099/grok_mcp_setup.git
   cd grok_mcp_setup
   # Create .env (optional; see example below)
   cp .env.example .env
   ```

2. **(Optional) Add Custom Scripts**:
   - For local lib PDF extraction, create `pdf_server.py` (MCP wrapper with `pdfplumber`—see [examples](https://github.com/modelcontextprotocol/servers/tree/main/src/pdf) or ping the repo issues).

3. **Launch the Stack**:
   ```bash
   docker compose up -d
   # Check: docker compose ps (all healthy?)
   # Logs: docker compose logs -f mcp-web
   ```

4. **Configure CodeGPT**:
   - In PyCharm > CodeGPT Settings > MCP tab, edit `~/.codegpt/mcp.json`:
     ```json
     {
       "mcpServers": {
         "lan-git": { "type": "http", "url": "http://localhost:8001" },
         "lan-web": { "type": "http", "url": "http://localhost:8002/search?q=query" },  // SearXNG endpoint
         "lan-lib": { "type": "http", "url": "http://localhost:8003" }
       }
     }
     ```
   - Refresh connections. Test in chat: "Using lan-git, ls /projects; lan-web, search 'MCP Docker tips'; lan-lib, extract text from /ebooks/sample.pdf."

5. **Access Services**:
   - Git: `curl http://localhost:8001/health`
   - Web: Browse `http://localhost:8002` (SearXNG UI for manual tests).
   - Lib: `curl http://localhost:8003/list?path=/ebooks`

## Customization
- **.env Example** (create `.env`):
  ```
  PROJECTS_PATH=/pub/your-repo  # Git mount
  LIBRARY_PATH=/pub/ebooks      # PDF/MD mount
  GIT_PORT=8001
  WEB_PORT=8002
  LIB_PORT=8003
  ```
- **Add SearXNG Config**: Drop `searxng-settings.yml` to filter engines (e.g., DuckDuckGo only). See [docs](https://docs.searxng.org/).
- **Extend Stack**: Add a service for Markdownify:
  ```yaml
  mcp-md:
    image: node:20-slim
    command: ["npx", "@modelcontextprotocol/server-markdownify", "--transport", "http", "--host", "0.0.0.0", "--port", "8004"]
    ports: ["8004:8004"]
  ```
- **LAN Mode**: Replace `localhost` with your IP (e.g., `192.168.1.x`) in `mcp.json`; firewall ports via UFW.

## Architecture
- **mcp-git**: Official MCP Git server for semantic repo queries.
- **mcp-web**: SearXNG meta-search (aggregates 70+ engines, self-hosted—no keys!).
- **mcp-lib**: Python-based filesystem + PDF reader (uses `pdfplumber` for text/regex extraction).

Prompt Flow: Grok → CodeGPT → MCP Call → Tool Response → Chained Output.

## Troubleshooting
- **Port Conflicts**: Tweak `.env` ports; `docker compose down` to reset.
- **Volume Permissions**: Ensure mounts are readable (`chmod -R o+r /pub`).
- **SearXNG Slow?**: Increase `UWSGI_WORKERS` in compose; it's CPU-bound on first run.
- **MCP Errors**: Check logs; ensure `mcp[cli]` deps if customizing Python services.
- **No Web Results?**: Verify SearXNG at `/8002`—if blank, restart and check settings.yml.

## Contributing
Fork, PR, or open issues! Ideas: Integrate Kavita API for ebook metadata, or Tesseract OCR for scanned PDFs.

## License
MIT © madking2099. See [LICENSE](LICENSE) (add one if missing).

## Acknowledgments
- [Model Context Protocol](https://modelcontextprotocol.org/) for the magic.
- [SearXNG](https://searxng.org/) for free web tools.
- xAI/Grok for the brainpower. 🚀

**Star if it sparks your homelab!** Questions? [@madking2099 on X](https://x.com/madking2099).
