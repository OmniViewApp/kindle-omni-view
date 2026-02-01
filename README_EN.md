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

**Start Running**
- Click **Start Frame** to begin cycling through images

**Stop Running**
- **Method 1**: Press the power button to wake, wait for `stopping...` to appear, then it will exit automatically to the home screen
- **Method 2**: Long-press the power button to force shutdown

#### 4. Bookshelf Synchronization

- **Manual Sync**: Tap **Sync Bookshelf** to immediately extract `cc.db` and `My Clippings.txt` and upload them.
- **Auto-Sync**: Tap **Enable Auto-Sync**. Once enabled, the device will silently sync data in the background whenever a WiFi connection or system wakeup is detected.
- **Status Check**: Tap **Status** to see the last sync timestamp and listener status at the bottom of the screen.

#### 4. Status Check
Tap **Status** to briefly display at the bottom:
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
│   └── *.pid               # Process identifier files
├── logs/
│   ├── app.log              # Master application log
│   └── update.log           # Update log
└── tmp/                     # Cached images
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
