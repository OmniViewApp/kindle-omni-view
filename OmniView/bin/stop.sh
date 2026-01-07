#!/bin/sh

# OmniView Stop Script

WORK_DIR="/mnt/us/OmniView"
PID_FILE="${WORK_DIR}/omini-view-client.pid"

# Check if PID file exists
if [ ! -f "${PID_FILE}" ]; then
    echo "OmniView is not running (no PID file found)"
    exit 0
fi

# Read PID from file
PID=$(cat "${PID_FILE}")

# Check if process is actually running
if [ ! -d "/proc/${PID}" ]; then
    echo "Stale PID file found, removing..."
    rm -f "${PID_FILE}"
    exit 0
fi

# Kill the process
echo "Stopping OmniView (PID: ${PID})..."
kill "${PID}"

# Wait a bit and force kill if needed
sleep 2
if [ -d "/proc/${PID}" ]; then
    echo "Process still running, forcing kill..."
    kill -9 "${PID}"
fi

# Clean up PID file
rm -f "${PID_FILE}"

echo "OmniView stopped successfully"
