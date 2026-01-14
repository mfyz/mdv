# Lightweight Real-Time Markdown Server Plan

## Research: Existing Tools

### Markdown Servers (Existing Solutions)

| Tool | Language | Single File | Live Reload | Notes |
|------|----------|-------------|-------------|-------|
| [markserv](https://github.com/markserv/markserv) | Node.js | No | Yes | GitHub-style, feature-rich but needs npm |
| [mdserve](https://github.com/jfernandez/mdserve) | Rust | Yes (binary) | Yes | Fast, single binary, WebSocket-based |
| [markdown-live](https://github.com/rgeoghegan/markdown-live) | Python | No | Yes | `pip install markdown-live` |
| [panserver](https://github.com/Marfisc/panserver) | Python | Yes-ish | Yes | Uses Pandoc for rendering |
| [markdown-server](https://github.com/ohbarye/markdown-server) | Python | Yes | No | Simple, no live reload |

**Verdict**: No perfect single-file Python solution with live reload exists. `mdserve` (Rust) is closest to your wishlist but isn't Python.

### CLI/TUI Markdown Viewers

| Tool | Language | Features |
|------|----------|----------|
| [glow](https://github.com/charmbracelet/glow) | Go | Beautiful rendering, TUI browser, GitHub integration |
| [md-tui](https://github.com/henriklovhaug/md-tui) | Rust | Tree navigation, 50+ language syntax highlighting |
| [treemd](https://github.com/Epistates/treemd) | Rust | Dual-pane, vim keys, newest (Dec 2025) |
| [frogmouth](https://github.com/Textualize/frogmouth) | Python | TUI browser, Textual-based |
| [mdcat](https://github.com/swsnr/mdcat) | Rust | Cat-like, inline images in iTerm2/Kitty |

**Recommendation**: `glow` is the most polished. For Python: `frogmouth`.

---

## Implementation Plan: Single-File Python MD Server

### Core Requirements
- Single `.py` file (~200-300 lines)
- Zero external dependencies beyond stdlib (or minimal: `markdown` lib)
- Directory listing with clickable navigation
- Markdown → HTML rendering
- Live reload via WebSocket or SSE
- Clean, readable HTML output

### Architecture

```
┌─────────────────────────────────────────────┐
│              mdserve.py                     │
├─────────────────────────────────────────────┤
│  HTTPServer (stdlib)                        │
│    ├── GET /           → Directory index    │
│    ├── GET /*.md       → Rendered HTML      │
│    ├── GET /*          → Static files       │
│    └── GET /__reload   → SSE endpoint       │
├─────────────────────────────────────────────┤
│  FileWatcher (watchdog or polling)          │
│    └── Notifies browser via SSE             │
└─────────────────────────────────────────────┘
```

### Implementation Steps

#### Phase 1: Basic Server (MVP)
1. Create HTTP server using `http.server` from stdlib
2. Implement directory listing handler (HTML with links)
3. Add markdown rendering (use `markdown` lib or `mistune` for speed)
4. Serve static files (CSS, images, etc.) passthrough
5. Embed minimal CSS for decent styling

#### Phase 2: Live Reload
1. Add SSE (Server-Sent Events) endpoint at `/__reload`
2. Implement file watcher:
   - Option A: Use `watchdog` library (external dep)
   - Option B: Poll with `os.stat()` mtime (no deps)
3. Inject reload script into rendered HTML pages
4. Browser auto-refreshes when files change

#### Phase 3: Polish
1. Add CLI arguments (`--port`, `--host`, `--no-reload`)
2. Syntax highlighting for code blocks (Pygments or highlight.js CDN)
3. Add dark/light theme toggle
4. Handle edge cases (binary files, large files, symlinks)

### Minimal Dependencies Strategy

**Option A: Zero external deps**
- Use `http.server` (stdlib)
- Use regex-based markdown parsing (limited but works)
- Use polling for file changes
- Embed CSS inline

**Option B: Minimal deps (recommended)**
- `mistune` - Fast markdown parser (single file, can vendor)
- Everything else from stdlib

### Code Structure Outline

```python
#!/usr/bin/env python3
"""mdserve.py - Lightweight markdown server with live reload"""

import http.server
import os
import json
import threading
import time
from pathlib import Path
from urllib.parse import unquote

# Optional: import mistune  # or use embedded minimal parser

PORT = 8000
WATCH_INTERVAL = 0.5  # seconds

# Embedded CSS (GitHub-ish style)
CSS = """..."""

# Embedded JS for live reload
RELOAD_SCRIPT = """
const es = new EventSource('/__reload');
es.onmessage = () => location.reload();
"""

class MarkdownHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        path = unquote(self.path)
        if path == '/__reload':
            self.handle_sse()
        elif path.endswith('.md'):
            self.serve_markdown(path)
        elif os.path.isdir(self.translate_path(path)):
            self.serve_directory(path)
        else:
            super().do_GET()

    def serve_markdown(self, path): ...
    def serve_directory(self, path): ...
    def handle_sse(self): ...

class FileWatcher(threading.Thread): ...

def main():
    # argparse setup
    # start watcher
    # start server

if __name__ == '__main__':
    main()
```

### File Size Target
- Goal: < 400 lines, < 15KB
- Can vendor `mistune` (~1000 lines) if needed

---

## Quick Start Alternative

If you just want something working NOW:

```bash
# Best existing Python option
pip install markdown-live
markdown-live .

# Best overall (Rust, single binary)
# Download from: https://github.com/jfernandez/mdserve/releases
mdserve .

# For TUI viewing
# Install glow: https://github.com/charmbracelet/glow
glow README.md
```

---

## Decision Points

1. **External dependencies?**
   - None: More work, limited markdown features
   - `mistune` only: Good balance, can vendor
   - `mistune` + `watchdog`: Full features, 2 deps

2. **Live reload method?**
   - SSE: Simple, works everywhere, one-way
   - WebSocket: More complex, bidirectional (overkill)
   - Meta refresh: Hacky, causes flicker

3. **Code highlighting?**
   - CDN (highlight.js): No deps, needs internet
   - Pygments: Python lib, works offline
   - None: Simplest, code blocks are plain

---

## Next Steps

1. Choose dependency strategy
2. I can implement the single-file server
3. Test on your target environment (Termux)
4. Iterate based on your feedback

Let me know which direction you want to go!
