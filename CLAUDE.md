# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

mdv (Markdown Live Server) is a local markdown server with live reload using Pandoc. It has two modes:
- **CLI mode**: Renders markdown to terminal with ANSI formatting
- **Server mode**: Web-based viewer with live reload, TOC, dark mode, and diagram rendering

## Commands

### CLI Mode (terminal output)
```bash
./mdv.sh file.md
```

### Server Mode (web browser)
```bash
./mdv.sh                    # Start server with auto-refresh in current directory
python panserver.py [path] [-p PORT] [-a] [-b] [-r]
```

Flags:
- `-a` Enable auto-refresh (live reload)
- `-b` Open browser automatically
- `-r` Allow remote connections (bind to all interfaces)
- `-p` Port number (default: 8080)

## Architecture

### Core Components

**mdv.sh** - Entry point script that dispatches between CLI and server modes

**panserver.py** - Main server application using Bottle framework:
- `FileProvider` - Handles file path resolution and mtime tracking for markdown/rst files
- `DocumentCompiler` - Converts markdown to HTML via Pandoc with configurable output formats (std, export, simple, inline)
- `EmbeddingProcessor` - Processes code blocks for diagram rendering (Graphviz dot, PlantUML)

### Routes
- `/` - Directory index listing markdown files
- `/view/<name>` - Rendered markdown/rst document
- `/refresh/<name>` - Polling endpoint for live reload (compares mtime)
- `/generated/<name>` - Serves generated diagram images

### Document Compilation Pipeline
1. Pandoc converts source to JSON AST
2. `process_document_json()` extracts/replaces diagram code blocks and adds metadata
3. Pandoc renders JSON to final HTML with injected CSS/JS

### Dependencies

**Python packages:** bottle

**External programs:**
- pandoc (required) - Markdown/RST to HTML/ANSI converter
- graphviz (optional) - For `dot` code blocks
- plantuml (optional) - For `plantuml` code blocks
