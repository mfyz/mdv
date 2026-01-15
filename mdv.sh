#!/bin/bash
SCRIPT_DIR="$(dirname "$0")"

# CLI mode: if a file is passed, render to terminal with ANSI formatting
if [ -n "$1" ] && [ -f "$1" ]; then
    pandoc -t ansi --wrap=auto "$1"
    exit 0
fi

# Server mode: start the web server
SERVE_DIR="$(pwd)"
python "$SCRIPT_DIR/panserver.py" -a "$SERVE_DIR"
