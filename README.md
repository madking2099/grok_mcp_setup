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
