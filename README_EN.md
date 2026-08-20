# OmniView

[English](README_EN.md) | [简体中文](README.md)

> **A world of wonders in a single frame.**

OmniView is a KUAL-based Kindle plugin that transforms your idle Kindle into a smart E-Ink photo frame or information display, with support for automatic book and note synchronization.

---

## Features

### 🖼️ Smart Photo Frame
- **Smart Wake-Up** - Leverages Kindle RTC (Real-Time Clock) for deep sleep and scheduled wake-up, significantly extending battery life
- **Auto Refresh** - Periodically fetches and displays the latest images/widgets (Weather, Calendar, Quotes) from the server
- **Aesthetic Views** - Support for custom themes, elegant typography, and dynamic widgets
- **Ghosting Prevention** - Automatically clears screen on startup to avoid menu residue

### 🖼️ Sleep Wallpaper
- **Daily Wallpaper** - Shows the daily featured image on the Kindle native lock/screensaver screen; normal reading is fully unaffected
- **Non-intrusive** - No framebuffer takeover, no forced suspend; relies on the linkss hack and the native screensaver
- **Smart Cache** - The daily image downloads once per day and is shared by both photo-frame and screensaver modes — no duplicate downloads
- **Auto-restore** - Your existing screensaver images are temporarily backed up and automatically restored; your files are never deleted
- **Wake = Refresh** - Pulls the latest wallpaper on screen wake (`outOfScreenSaver`) and WiFi connect

### 📚 Bookshelf Sync
- **Note Extraction** - Automatically extracts book info and reading notes (My Clippings.txt) from your Kindle
- **Silent Background Sync** - Intelligent monitoring of WiFi and wakeup events to sync data without manual intervention
- **Cloud Management** - View, search, and export your reading notes anytime via the WeChat mini-program

### 🛠️ System Highlights
- **Flattened Menu** - Optimized KUAL menu structure with all functions directly accessible (only 2 levels deep)
- **Ultra-long Battery Life** - Lasts for more than a month on a single charge in deep sleep mode
- **Status Monitoring** - Real-time status display for battery, sync progress, and active modes

---

## Screenshots

### 🟢 Smart Photo Frame
<div align="center">
<img src="./assets/kindle-example1.jpg" width="45%" alt="Kindle display" />
<img src="./assets/kindle-theme01.jpg" width="45%" alt="Theme display" />
<br>
<img src="./assets/kindle-theme02.png" width="45%" alt="Theme display 2" />
</div>

<details>
<summary>View more frame styles</summary>
<div align="center">
<img src="./assets/minip03.jpg" width="30%" alt="Mini program 4" />
<img src="./assets/minip04.jpg" width="30%" alt="Mini program 5" />
<img src="./assets/minip05.jpg" width="30%" alt="Mini program 6" />
</div>
</details>

### 🔵 Bookshelf & Notes
<div align="center">
<img src="./assets/minip13.jpg" width="28%" alt="Mini-program bookshelf" />
<img src="./assets/minip11.jpg" width="28%" alt="Book details" />
<img src="./assets/minip12.jpg" width="28%" alt="Note details" />
</div>

<details>
<summary>More</summary>
<div align="center">
<img src="./assets/minip00.jpg" width="30%" alt="Mini-program notebooks" />
<img src="./assets/minip01.jpg" width="30%" alt="Mini-program note list" />
<img src="./assets/minip02.png" width="30%" alt="Note preview" />
</div>
</details>

<details>
<summary>Click to view Mini-program QR & Community</summary>
<div align="center">
<img src="./assets/omni-view-minipcode.jpg" width="30%" alt="Mini-program QR code" />
<img src="./assets/telegram-group.jpg" width="50%" alt="Telegram Group" />
</div>
</details>

---

## Installation & Usage

### Prerequisites

<details>
<summary>fbink Installation Guide (skip if already installed)</summary>

#### USBNetwork Hack (includes fbink)
- [Official Release](https://www.mobileread.com/forums/showthread.php?t=225030)

</details>

### Installation Steps

1. Download [OmniView.zip](https://raw.githubusercontent.com/OmniViewApp/kindle-omni-view/refs/heads/master/OmniView.zip) and extract
2. Transfer the `OmniView` folder to your Kindle:
    - **USB Method**: Copy to `/mnt/us/extensions/`
    - **Wireless Method**: Transfer via `scp` to `/mnt/us/extensions/`
3. Disconnect USB cable

### Quick Start

#### 1. Device Registration (First Time)
1. Open **KUAL** -> **OmniView** -> **Register Device** on your Kindle
2. Scan the QR code on screen to bind your device
3. You're ready to go after successful registration

#### 2. Configure Frame (on Phone)
1. Open the WeChat mini-program and tap on your bound device
2. **Select Source**: Upload photos, subscribe to Weather/Calendar widgets, or choose quote libraries
3. **Set Frequency**: Recommended refresh rate of 1-3 hours to balance battery and real-time updates

#### 3. Running & Stopping

The KUAL menu is **registration-gated**: while the device is unregistered the main menu (`OmniView(相框)`) shows only **Register Device** and **Uninstall**; once registered, the functional items appear.

Registered menu:
```
OmniView(相框)/
├── 启动休眠壁纸 ↔ 停止运行   (single start item, flips with state)
├── Clear Cache (清除缓存)
└── Online Update (在线更新)
OmniBookShelf(书架)/
├── Sync Now (立即同步)
├── View Status (查看状态)
└── 启用自动同步 ↔ 禁用自动同步  (single flip item)
```

The Sleep Wallpaper entry is a single start item whose label flips with the enabled state:

- While disabled it reads **「启动休眠壁纸」**; tapping it installs the daily wallpaper onto the native sleep/screensaver and enables auto-refresh (pulls the latest on screen wake / WiFi connect). Normal reading is unaffected
- After starting, KUAL refreshes and the item becomes **「停止运行」**; tapping it stops the wallpaper/monitor and restores your original screensaver directory, flipping the label back

**Uninstall** does a full cleanup: stops the screensaver/auto-sync and restores the system screensaver directory; downloaded cache and logs are retained for troubleshooting.

> Photo Frame is no longer a KUAL menu entry — it is CLI-only. If you want the always-on photo-frame loop (take over the screen and cycle through images), run `-mode frame` from the command line yourself. `uninstall-autostart` is likewise a CLI-only command (menu item removed); invoke it via `omniview.sh uninstall-autostart`.

#### 4. Bookshelf Synchronization

- **Sync Now**: Tap **Sync Now (立即同步)** to immediately extract `cc.db` and `My Clippings.txt` and upload them.
- **Auto-Sync**: Tap **启用自动同步 (Auto-Sync)** (when already enabled it reads 「禁用自动同步」, tapping disables it). Once enabled, the device will silently sync data in the background whenever a WiFi connection or system wakeup is detected.
- **Status Check**: Tap **View Status (查看状态)** to see the last sync timestamp and listener status at the bottom of the screen.

#### 5. Status Check
Tap **View Status (查看状态)** to briefly display at the bottom:
- `Auto=Enabled/Disabled`: Auto-sync status
- `Monitor=Running/Stopped`: Event listener status
- `LastSync`: Timestamp of the last successful sync

---

## File Structure

### Working Directory

The plugin lives in `extensions/OmniView`, while user configs and logs are stored at:

```
/mnt/us/OmniView/
├── conf/
│   ├── config.cfg          # Core configuration
│   ├── *.pid               # Process identifier files
│   ├── wallpaper_last_check.txt        # Wallpaper server-check cooldown
│   └── screensaver_installed_date.txt  # Date of the currently-installed screensaver
├── logs/
│   ├── app.log              # Master application log
│   └── update.log           # Update log
├── wallpapers/              # Dated daily wallpaper cache (<date>.png)
├── ss_backup/               # Backup of your screensaver images while wallpaper mode is active
└── tmp/                     # Temporary cache
```

If you encounter issues, please check the log file at `/mnt/us/OmniView/logs/app.log`.

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Register Failed" | Ensure WiFi is connected and you've created an account in the mini-program |
| Images not refreshing | Check refresh rate in `config.cfg` or WiFi signal strength |
| Menu elements missing | Ensure `templates/kual/menu.json` is intact and not truncated |

---

## Support

- [Telegram Group](https://t.me/OmniViewApp)
- Submit [Issues](https://github.com/OmniViewApp/kindle-omni-view/issues)

---

## License

[GPL-3.0](LICENSE.txt)
