#!/bin/sh
cd "$(dirname "$0")"
BIN_DIR=$(pwd)
WORK_DIR="/mnt/us/OmniView"

chmod +x "$BIN_DIR/omini-view-client"

# Run in register mode
"$BIN_DIR/omini-view-client" -mode register -workdir "$WORK_DIR" > "$WORK_DIR/app.log" 2>&1
