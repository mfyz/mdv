#!/bin/bash
SERVE_DIR="$(pwd)"
SCRIPT_DIR="$(dirname "$0")"
python "$SCRIPT_DIR/panserver.py" -a "$SERVE_DIR"
