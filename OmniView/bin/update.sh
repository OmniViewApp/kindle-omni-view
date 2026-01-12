#!/bin/sh
cd "$(dirname "$0")"
BIN_DIR=$(pwd)
WORK_DIR="/mnt/us/OmniView"

chmod +x "$BIN_DIR/omini-view-client"

# Ensure work directory exists
mkdir -p "$WORK_DIR"

# Run in update mode
"$BIN_DIR/omini-view-client" -mode update -workdir "$WORK_DIR" > "$WORK_DIR/update.log" 2>&1
