#!/bin/sh
# OmniView Master Control Script
# Usage: ./omniview.sh [command]

cd "$(dirname "$0")"
BIN_DIR=$(pwd)
# Assuming standard KUAL extension path structure
EXT_DIR="/mnt/us/extensions/OmniView"
WORK_DIR="/mnt/us/OmniView"
CLIENT_BIN="$BIN_DIR/omniview"
PID_FILE="$WORK_DIR/conf/omni-view-frame.pid"
MONITOR_PID_FILE="$WORK_DIR/conf/event_monitor.pid"
AUTOSTART_FLAG="/mnt/us/ENABLE_BOOKSHELF_AUTOSTART"
UPSTART_CONF="/etc/upstart/bookshelf-sync.conf"
SOURCE_UPSTART="$EXT_DIR/upstart/bookshelf-sync.conf"

# --- Initialization ---

# Rootfs write access. "/" is mounted RO at runtime; /usr/sbin/mntroot exists on
# some jailbreaks but is often NOT on PATH (KUAL/ssh use a minimal PATH), and
# older jailbreaks lack it entirely — fall back to a raw remount.
rootfs_rw() {
    if [ -x /usr/sbin/mntroot ]; then
        /usr/sbin/mntroot rw
    else
        mount -o remount,rw /dev/root /
    fi
}
rootfs_ro() {
    if [ -x /usr/sbin/mntroot ]; then
        /usr/sbin/mntroot ro
    else
        mount -o remount,ro /dev/root /
    fi
}

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

# The event monitor is shared by two independent features (screensaver wallpaper
# and bookshelf auto-sync). Keep it running iff at least one is enabled.
_refresh_monitor() {
    if [ -f "$WORK_DIR/conf/ss_enabled" ] || [ -f "$AUTOSTART_FLAG" ]; then
        _start_monitor
    else
        _stop_monitor
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

# Screensaver wallpaper mode: install today's wallpaper as the native
# screensaver (linkss bg_ss00.png) and enable the event monitor so it
# auto-refreshes on wake / WiFi connect. Non-intrusive (no framebuffer
# takeover, normal reading unaffected).
cmd_start_screensaver() {
    if ! check_registration; then
        bottom_msg "Please register device first (请先注册设备)"
        log "ERROR: Attempted to start screensaver mode without registration"
        exit 1
    fi

    SS_TARGET="/usr/share/blanket/screensaver"
    SS_OURDIR="$WORK_DIR/screensavers"

    # --- 0. 占用探测（安装前必须认定安全；与 Go redirect.Probe 同语义） ---
    if awk -v t="$SS_TARGET" '$5 == t { found = 1 } END { exit !found }' /proc/self/mountinfo 2>/dev/null; then
        bottom_msg "屏保路径被其他插件占用，请先停用 ScreenSavers Hack 后重试"
        log "screensaver: blocked ($SS_TARGET is a mount point)"
        return 2
    fi
    if [ -L "$SS_TARGET" ]; then
        local cur
        cur=$(readlink "$SS_TARGET")
        if [ "$cur" != "$SS_OURDIR" ]; then
            bottom_msg "屏保路径指向其他插件（$cur），请先停用后重试"
            log "screensaver: blocked ($SS_TARGET -> $cur)"
            return 2
        fi
    fi

    # latent linkss：hack 的 boot job 会 bind 到我们 symlink 的解析目标（源目录），
    # 造成重启后影子覆盖 + 我们的写入污染其目录——直接拦下要求先停用 hack。
    if [ -f /mnt/us/linkss/auto ] || [ -f /mnt/us/linkss/mounted_ss ]; then
        bottom_msg "检测到 ScreenSavers Hack 已启用，请先停用后再使用屏保模式"
        log "screensaver: blocked (ScreenSavers Hack active)"
        return 2
    fi

    # --- 1. symlink 安装（幂等；rootfs 手术） ---
    mkdir -p "$SS_OURDIR"
    install_ok=0
    if [ -L "$SS_TARGET" ]; then
        install_ok=1 # 已是我们的链接
    elif [ -e "$SS_TARGET" ]; then
        rootfs_rw 2>/dev/null
        mv "$SS_TARGET" "$SS_TARGET.bak" && {
            ln -s "$SS_OURDIR" "$SS_TARGET" && install_ok=1 || mv "$SS_TARGET.bak" "$SS_TARGET"
        }
        rootfs_ro 2>/dev/null
    else
        rootfs_rw 2>/dev/null
        ln -s "$SS_OURDIR" "$SS_TARGET" && install_ok=1
        rootfs_ro 2>/dev/null
    fi
    if [ "$install_ok" != "1" ]; then
        bottom_msg "无法写入系统目录，屏保未生效"
        log "screensaver: symlink install failed"
        return 3
    fi

    # --- 2. 启用标记 + bookShelf 注册 + event-monitor ---
    mkdir -p "$WORK_DIR/conf"
    touch "$WORK_DIR/conf/ss_enabled"
    # 防残留：被硬杀（kill -9）的 frame 会跳过 Go 清理，留下 preventScreenSaver=1，
    # 导致休眠不进屏保——显式复位，保证原生屏保对于本模式生效。
    lipc-set-prop com.lab126.powerd preventScreenSaver 0 2>/dev/null || true
    if [ -f "$SOURCE_UPSTART" ]; then
        rootfs_rw 2>/dev/null
        if cp "$SOURCE_UPSTART" "$UPSTART_CONF" 2>/dev/null; then
            chmod 644 "$UPSTART_CONF"
            /sbin/initctl start bookshelf-sync 2>/dev/null || true
            log "bookshelf-sync upstart job (re)installed"
        else
            log "WARN: cannot cp $SOURCE_UPSTART -> $UPSTART_CONF (boot refresh may not register)"
        fi
        rootfs_ro 2>/dev/null
    fi
    _refresh_monitor

    # --- 3. 安装今日壁纸 + Verify；按退出码提示 ---
    log "Executing: $CLIENT_BIN -mode screensaver"
    "$CLIENT_BIN" -mode screensaver -workdir "$WORK_DIR" >> "$WORK_DIR/logs/screensaver.log" 2>&1
    local rc=$?
    case "$rc" in
        0)  bottom_msg "Sleep wallpaper mode active" ;;
        2)  bottom_msg "屏保路径被其他插件占用，请先停用 ScreenSavers Hack 后重试" ;;
        3)  bottom_msg "屏保未生效，请查看日志" ;;
        *)  msg "Failed. Check logs: logs/screensaver.log" ;;
    esac
    return "$rc"
}

cmd_stop() {
    local stopped_any=0

    # 1. Stop the frame process (if running)
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if [ -d "/proc/$pid" ]; then
            bottom_msg "Stopping frame..."
            kill "$pid"
            sleep 2
            if [ -d "/proc/$pid" ]; then
                kill -9 "$pid"
            fi
            stopped_any=1
        fi
        rm -f "$PID_FILE"
    fi
    # 硬杀不触发 Go 清理：显式复位 preventScreenSaver，避免休眠不进屏保
    lipc-set-prop com.lab126.powerd preventScreenSaver 0 2>/dev/null || true

    # 2. Stop wallpaper mode: restore the system screensaver dir from backup,
    #    clear the durable flag. /etc is RO at runtime.
    run_client "screensaver-restore" "restore.log" "false"   # Go: 删 ss_enabled
    SS_TARGET="/usr/share/blanket/screensaver"
    rootfs_rw 2>/dev/null
    if [ -L "$SS_TARGET" ]; then
        # 防御：只删指向我们的链接
        [ "$(readlink "$SS_TARGET")" = "$WORK_DIR/screensavers" ] && rm -f "$SS_TARGET"
    fi
    if [ -d "$SS_TARGET.bak" ]; then
        if awk -v t="$SS_TARGET" '$5 == t { found = 1 } END { exit !found }' /proc/self/mountinfo 2>/dev/null; then
            log "WARN: screensaver dir occupied by another mount — omitting restore (stop the plugin, re-run stop)"
            bottom_msg "屏保路径仍被挂载占用，请先停用插件后重试"
        else
            mv "$SS_TARGET.bak" "$SS_TARGET" || log "WARN: restore mv failed ($SS_TARGET.bak retained)"
        fi
    else
        mkdir -p "$SS_TARGET"
    fi
    rootfs_ro 2>/dev/null

    # 3. Refresh the shared monitor: keep it only if bookshelf autostart is still on.
    _refresh_monitor

    if [ $stopped_any -eq 1 ]; then
        bottom_msg "Stopped & screensavers restored"
    else
        bottom_msg "Screensavers restored"
    fi
}

cmd_register() {
    msg "Starting Registration..."
    run_client "register" "app.log"
    # 以 config.cfg 是否真实写入 REGISTERED=1 判定成功（Go 所有退出路径均 rc0，
    # 超时/失败也返回 0）；该行由 updateConfigRegistered 以无引号整数写入，
    # 故 grep 精确匹配既可靠又可自愈（含 Already Registered 路径）。
    if grep -q '^REGISTERED=1' "$WORK_DIR/conf/config.cfg" 2>/dev/null; then
        mkdir -p "$WORK_DIR/conf"
        touch "$WORK_DIR/conf/registered.flag"
        log "registered.flag written"
    fi
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

    # (Re)install the upstart config so it stays current across upgrades (it
    # also carries the boot self-heal for the screensaver symlink).
    if [ -f "$SOURCE_UPSTART" ]; then
        rootfs_rw 2>/dev/null
        if cp "$SOURCE_UPSTART" "$UPSTART_CONF" 2>/dev/null; then
            chmod 644 "$UPSTART_CONF"
            log "Upstart script (re)installed"
        else
            log "WARN: cannot cp $SOURCE_UPSTART -> $UPSTART_CONF"
        fi
        rootfs_ro 2>/dev/null
    else
        bottom_msg "Error: Upstart source missing"
        log "ERROR: $SOURCE_UPSTART not found"
        exit 1
    fi

    # Enable autostart flag
    touch "$AUTOSTART_FLAG"

    # Start/refresh the shared event monitor
    _refresh_monitor

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

    # Refresh the shared monitor: keep it if screensaver is still on.
    _refresh_monitor

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

cmd_uninstall() {
    log "Uninstalling OmniView..."
    # 杀 frame（若在跑）+ 停 monitor
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        [ -d "/proc/$pid" ] && kill "$pid" 2>/dev/null
        rm -f "$PID_FILE"
    fi
    _stop_monitor
    # 还原系统屏保目录（防御：只删指向我们的 symlink；被挂载占用则跳过并提示）
    SS_TARGET="/usr/share/blanket/screensaver"
    rootfs_rw 2>/dev/null
    if [ -L "$SS_TARGET" ] && [ "$(readlink "$SS_TARGET")" = "$WORK_DIR/screensavers" ]; then
        rm -f "$SS_TARGET"
    fi
    if [ -d "$SS_TARGET.bak" ]; then
        if awk -v t="$SS_TARGET" '$5 == t { found = 1 } END { exit !found }' /proc/self/mountinfo 2>/dev/null; then
            log "WARN: screensaver dir occupied by another mount — omitting restore"
            bottom_msg "屏保路径仍被挂载占用，未还原；请先停用占用插件"
        else
            mv "$SS_TARGET.bak" "$SS_TARGET" || log "WARN: restore mv failed ($SS_TARGET.bak retained)"
        fi
    else
        mkdir -p "$SS_TARGET"
    fi
    rootfs_ro 2>/dev/null
    # 清理运行时与持久状态
    rm -f "$WORK_DIR/conf/ss_enabled" "$WORK_DIR/conf/registered.flag" /mnt/us/ENABLE_BOOKSHELF_AUTOSTART
    rootfs_rw 2>/dev/null
    rm -f /etc/upstart/bookshelf-sync.conf
    rootfs_ro 2>/dev/null
    bottom_msg "OmniView 已卸载（缓存与日志保留）"
}

# --- Main Entry Point ---

# Initialize once
init

# Dispatch command
case "$1" in
    "start")
        cmd_start
        ;;
    "start-screensaver")
        cmd_start_screensaver
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
    "uninstall")
        cmd_uninstall
        ;;
    "test")
        # Test command for debugging
        log "Test command executed"
        bottom_msg "Test message from OmniView - $(date '+%H:%M:%S')"
        sleep 2
        bottom_msg "Debug log saved to /tmp/omniview-display.log"
        ;;
    *)
        echo "Usage: $0 {start|start-screensaver|stop|register|update|sync|status|clear-cache|enable-autostart|disable-autostart|uninstall-autostart|uninstall|test}"

        exit 1
        ;;
esac
