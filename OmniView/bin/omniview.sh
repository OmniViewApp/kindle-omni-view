#!/bin/sh
# OmniView Master Control Script
# Usage: ./omniview.sh [command]

cd "$(dirname "$0")"
BIN_DIR=$(pwd)
# Assuming standard KUAL extension path structure
EXT_DIR="/mnt/us/extensions/OmniView"
WORK_DIR="/mnt/us/OmniView"
CLIENT_BIN="$BIN_DIR/omniview"
PID_FILE="$WORK_DIR/conf/omini-view-client.pid"
MONITOR_PID_FILE="$WORK_DIR/conf/event_monitor.pid"
AUTOSTART_FLAG="/mnt/us/ENABLE_BOOKSHELF_AUTOSTART"
UPSTART_CONF="/etc/upstart/bookshelf-sync.conf"
SOURCE_UPSTART="$EXT_DIR/upstart/bookshelf-sync.conf"

# --- Initialization ---

init() {
    # Validate binary exists
    if [ ! -f "$CLIENT_BIN" ]; then
        msg "Error: Binary not found"
        log "FATAL: $CLIENT_BIN missing"
        exit 1
    fi

    # Set executable permission
    chmod +x "$CLIENT_BIN" || {
        msg "Error: Cannot set executable permission"
        exit 1
    }

    # Create required directories
    mkdir -p "$WORK_DIR/logs" "$WORK_DIR/conf" || {
        msg "Error: Cannot create directories"
        exit 1
    }
}

# --- Display Functions ---

# Detect fbink path (POSIX-compatible, no arrays)
detect_fbink() {
    # Check common fbink installation paths
    if [ -x "/usr/bin/fbink" ]; then
        echo "/usr/bin/fbink"
        return 0
    elif [ -x "/mnt/us/libkh/bin/fbink" ]; then
        echo "/mnt/us/libkh/bin/fbink"
        return 0
    elif [ -x "/mnt/us/koreader/fbink" ]; then
        echo "/mnt/us/koreader/fbink"
        return 0
    elif [ -x "/mnt/us/extensions/MRInstaller/bin/KHF/fbink" ]; then
        echo "/mnt/us/extensions/MRInstaller/bin/KHF/fbink"
        return 0
    elif [ -x "/mnt/us/extensions/MRInstaller/bin/PW2/fbink" ]; then
        echo "/mnt/us/extensions/MRInstaller/bin/PW2/fbink"
        return 0
    elif [ -x "/mnt/us/linkss/bin/fbink" ]; then
        echo "/mnt/us/linkss/bin/fbink"
        return 0
    elif [ -x "/mnt/us/usbnet/bin/fbink" ]; then
        echo "/mnt/us/usbnet/bin/fbink"
        return 0
    fi

    # Try 'which' as last resort
    if command -v fbink >/dev/null 2>&1; then
        which fbink
        return 0
    fi

    return 1
}

# Detect eips path (POSIX-compatible)
detect_eips() {
    # Check common eips paths
    if [ -x "/usr/sbin/eips" ]; then
        echo "/usr/sbin/eips"
        return 0
    elif [ -x "/usr/bin/eips" ]; then
        echo "/usr/bin/eips"
        return 0
    elif [ -x "/bin/eips" ]; then
        echo "/bin/eips"
        return 0
    fi

    # Try 'which' as last resort
    if command -v eips >/dev/null 2>&1; then
        which eips
        return 0
    fi

    return 1
}

# Initialize display commands (detect once at startup)
FBINK_PATH=$(detect_fbink)
EIPS_PATH=$(detect_eips)

# Log detected paths for debugging
if [ -n "$FBINK_PATH" ]; then
    echo "[INIT] FBInk detected at: $FBINK_PATH" >> /tmp/omniview-display.log
elif [ -n "$EIPS_PATH" ]; then
    echo "[INIT] EIPS detected at: $EIPS_PATH" >> /tmp/omniview-display.log
else
    echo "[INIT] No display tool detected, using echo fallback" >> /tmp/omniview-display.log
fi

# Logging helper
log() {
    local file="${LOG_FILE:-$WORK_DIR/logs/omniview.log}"
    # Rotate log if too big (simple check)
    if [ -f "$file" ] && [ $(stat -c%s "$file") -gt 1024000 ]; then
        mv "$file" "$file.old"
    fi
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$file"
}

# FBInk helper (safe call)
msg() {
    if [ -n "$FBINK_PATH" ]; then
        "$FBINK_PATH" -m -q "$1"
    else
        echo "$1"
    fi
}

# Bottom message helper (non-intrusive, KUAL-friendly)
# Uses detected fbink/eips path for better compatibility
bottom_msg() {
    local message="$1"

    # Log to debug file
    echo "[$(date '+%H:%M:%S')] bottom_msg called: $message" >> /tmp/omniview-display.log

    if [ -n "$FBINK_PATH" ]; then
        # Use fbink with message mode (-m) and quiet (-q)
        # No -c flag to avoid clearing screen
        echo "[DEBUG] Using fbink: $FBINK_PATH" >> /tmp/omniview-display.log
        "$FBINK_PATH" -m -q "$message" 2>> /tmp/omniview-display.log
        local exit_code=$?
        echo "[DEBUG] fbink exit code: $exit_code" >> /tmp/omniview-display.log
    elif [ -n "$EIPS_PATH" ]; then
        # Display at bottom line (y=39 for most Kindle devices)
        echo "[DEBUG] Using eips: $EIPS_PATH" >> /tmp/omniview-display.log
        "$EIPS_PATH" 1 39 "$message" 2>> /tmp/omniview-display.log
        local exit_code=$?
        echo "[DEBUG] eips exit code: $exit_code" >> /tmp/omniview-display.log
    else
        # Fallback: try to write directly to framebuffer status area
        echo "[DEBUG] Using echo fallback" >> /tmp/omniview-display.log
        echo "$message" >> /tmp/omniview-display.log
        # Also try direct eips if available at runtime
        if command -v eips >/dev/null 2>&1; then
            eips 1 39 "$message" 2>> /tmp/omniview-display.log
        fi
    fi
}

# --- Registration Check ---

# Check if device is registered
# Returns 0 if registered, 1 if not registered
check_registration() {
    local config_file="$WORK_DIR/conf/config.cfg"

    # If config file doesn't exist, device is not registered
    if [ ! -f "$config_file" ]; then
        return 1
    fi

    # Config exists, device is registered
    return 0
}

# --- Unified Client Execution ---

run_client() {
    local mode="$1"
    local log_file="${2:-app.log}"
    local show_result="${3:-true}"

    log "Executing: $CLIENT_BIN -mode $mode"

    "$CLIENT_BIN" -mode "$mode" -workdir "$WORK_DIR" \
        > "$WORK_DIR/logs/$log_file" 2>&1

    local exit_code=$?
    log "Exit code: $exit_code"

    if [ "$show_result" = "true" ]; then
        if [ $exit_code -eq 0 ]; then
            msg "Success!"
        else
            msg "Failed. Check logs: logs/$log_file"
        fi
    fi

    return $exit_code
}

# --- Internal Monitor Management (not exposed to users) ---

_start_monitor() {
    if [ -f "$MONITOR_PID_FILE" ] && [ -d "/proc/$(cat "$MONITOR_PID_FILE")" ]; then
        log "Monitor already running"
        return 0
    fi

    log "Starting event monitor..."
    nohup "$CLIENT_BIN" -mode event-monitor -workdir "$WORK_DIR" > /dev/null 2>&1 &

    bottom_msg "Monitor Started"
}

_stop_monitor() {
    if [ -f "$MONITOR_PID_FILE" ]; then
        local mpid=$(cat "$MONITOR_PID_FILE")
        if [ -d "/proc/$mpid" ]; then
            kill "$mpid" 2>/dev/null
            log "Monitor stopped (PID: $mpid)"
            bottom_msg "Monitor stopped"
        else
            log "Monitor not running (stale PID)"
        fi
        rm -f "$MONITOR_PID_FILE"
    else
        log "Monitor not running (no PID file)"
    fi
}

# --- User Commands ---

cmd_start() {
    if ! check_registration; then
        bottom_msg "Please register device first (请先注册设备)"
        log "ERROR: Attempted to start frame without registration"
        exit 1
    fi
    msg "Starting OmniView..."
    run_client "frame" "app.log" "false"
}

cmd_stop() {
    if [ ! -f "$PID_FILE" ]; then
        bottom_msg "OmniView not running"
        exit 0
    fi

    local pid=$(cat "$PID_FILE")
    if [ ! -d "/proc/$pid" ]; then
        rm -f "$PID_FILE"
        bottom_msg "Cleaned stale PID"
        exit 0
    fi

    bottom_msg "Stopping..."
    kill "$pid"
    sleep 2
    if [ -d "/proc/$pid" ]; then
        kill -9 "$pid"
    fi
    rm -f "$PID_FILE"
    bottom_msg "Stopped"
}

cmd_register() {
    msg "Starting Registration..."
    run_client "register" "app.log"
}

cmd_update() {
    if ! check_registration; then
        bottom_msg "Please register device first (请先注册设备)"
        log "ERROR: Attempted to update without registration"
        exit 1
    fi
    msg "Starting Update..."
    run_client "update" "update.log"
}

cmd_sync() {
    if ! check_registration; then
        bottom_msg "Please register device first (请先注册设备)"
        log "ERROR: Attempted to sync without registration"
        exit 1
    fi
    msg "Syncing Bookshelf..."
    run_client "sync-bookshelf" "manual_sync.log"
}

cmd_status() {
    if ! check_registration; then
        bottom_msg "Please register device first (请先注册设备)"
        log "ERROR: Attempted to check status without registration"
        exit 1
    fi

    local sync_file="$WORK_DIR/conf/last_bookshelf_sync.txt"
    local last_sync="Never"
    local auto_status="Disabled"
    local monitor_status="Stopped"

    # Check last sync time
    if [ -f "$sync_file" ]; then
        last_sync=$(cat "$sync_file")
    fi

    # Check autostart flag
    if [ -f "$AUTOSTART_FLAG" ]; then
        auto_status="Enabled"
    fi

    # Check monitor process
    if [ -f "$MONITOR_PID_FILE" ]; then
        local mpid=$(cat "$MONITOR_PID_FILE")
        if [ -d "/proc/$mpid" ]; then
            monitor_status="Running"
        else
            monitor_status="Stopped"
            rm -f "$MONITOR_PID_FILE"
        fi
    fi

    # Display status at bottom (non-intrusive, KUAL-friendly)
    bottom_msg "Status: Auto=$auto_status | Monitor=$monitor_status | LastSync=$last_sync"
    log "Status check: sync=$last_sync, auto=$auto_status, monitor=$monitor_status"
}

cmd_clear_cache() {
    rm -f "$WORK_DIR/conf/last_bookshelf_sync.txt"
    rm -f "$WORK_DIR/logs/"*.log
    bottom_msg "Cache & Logs Cleared"
    log "Cache and logs cleared"
}

cmd_enable_autostart() {
    if ! check_registration; then
        bottom_msg "Please register device first (请先注册设备)"
        log "ERROR: Attempted to enable auto-sync without registration"
        exit 1
    fi

    # Install upstart config if needed
    if [ ! -f "$UPSTART_CONF" ]; then
        if [ -f "$SOURCE_UPSTART" ]; then
            cp "$SOURCE_UPSTART" "$UPSTART_CONF"
            chmod 644 "$UPSTART_CONF"
            log "Upstart script installed"
        else
            bottom_msg "Error: Upstart source missing"
            log "ERROR: $SOURCE_UPSTART not found"
            exit 1
        fi
    fi

    # Enable autostart flag
    touch "$AUTOSTART_FLAG"

    # Start event monitor
    _start_monitor

    bottom_msg "Auto-Sync Enabled"
    log "Auto-sync enabled"
}

cmd_disable_autostart() {
    if ! check_registration; then
        bottom_msg "Please register device first (请先注册设备)"
        log "ERROR: Attempted to disable auto-sync without registration"
        exit 1
    fi

    rm -f "$AUTOSTART_FLAG"

    # Stop monitor if running
    _stop_monitor

    bottom_msg "Auto-Sync Disabled"
    log "Auto-sync disabled"
}

cmd_uninstall_autostart() {
    cmd_disable_autostart

    if [ -f "$UPSTART_CONF" ]; then
        rm -f "$UPSTART_CONF"
        bottom_msg "Upstart script removed"
        log "Upstart script removed"
    else
        bottom_msg "Upstart script not found"
    fi
}

# --- Main Entry Point ---

# Initialize once
init

# Dispatch command
case "$1" in
    "start")
        cmd_start
        ;;
    "stop")
        cmd_stop
        ;;
    "register")
        cmd_register
        ;;
    "update")
        cmd_update
        ;;
    "sync")
        cmd_sync
        ;;
    "status")
        cmd_status
        ;;
    "clear-cache")
        cmd_clear_cache
        ;;
    "enable-autostart")
        cmd_enable_autostart
        ;;
    "disable-autostart")
        cmd_disable_autostart
        ;;
    "uninstall-autostart")
        cmd_uninstall_autostart
        ;;
    "test")
        # Test command for debugging
        log "Test command executed"
        bottom_msg "Test message from OmniView - $(date '+%H:%M:%S')"
        sleep 2
        bottom_msg "Debug log saved to /tmp/omniview-display.log"
        ;;
    *)
        echo "Usage: $0 {start|stop|register|update|sync|status|clear-cache|enable-autostart|disable-autostart|uninstall-autostart|test}"
        exit 1
        ;;
esac
