# OmniView

[English](README_EN.md) | [简体中文](README.md)

> **A world of wonders in a single frame.**

OmniView is a KUAL-based Kindle plugin that transforms your idle Kindle into a smart E-Ink photo frame or information display.

---

## Features

- **Smart Wake-Up** - Leverages Kindle RTC (Real-Time Clock) for deep sleep and scheduled wake-up, significantly extending battery life
- **Auto Refresh** - Periodically fetches and displays the latest images from the server
- **Ghosting Prevention** - Automatically clears screen on startup to avoid KUAL menu residue
- **Device Binding** - Binds device to server via QR code scanning
- **Status Display** - Shows runtime status and error messages directly on screen
- **Graceful Exit** - Automatically returns to Kindle home when stopped

---

## Requirements

### Hardware
- Jailbroken Kindle device (tested on Kindle Paperwhite 3)

### Software
- [KUAL](https://www.mobileread.com/forums/showthread.php?t=203326) (Kindle Unified Application Launcher)
- [fbink](https://github.com/NiLuJe/FBInk) (For screen rendering, typically installed with USBNetwork Hack)

---

## Screenshots

<details>

<summary>Click to expand</summary>

### Kindle Display

<div align="center">
<img src="./assets/kindle-example1.jpg" width="50%" alt="Kindle running OmniView" />
</div>

### Mini Program

<div align="center">
<img src="./assets/omni-view-minipcode.jpg" width="30%" alt="小程序" />
</div>

<div align="center">
<img src="./assets/minip00.jpg" width="30%" alt="Mini program 1" />
<img src="./assets/minip01.jpg" width="30%" alt="Mini program 2" />
<img src="./assets/minip02.png" width="30%" alt="Mini program 3" />
<br>
<img src="./assets/minip03.jpg" width="30%" alt="Mini program 4" />
<img src="./assets/minip04.jpg" width="30%" alt="Mini program 5" />
<img src="./assets/minip05.jpg" width="30%" alt="Mini program 6" />
</div>

### Themes

<div align="center">
<img src="./assets/kindle-theme01.jpg" width="47%" alt="Theme 1" />
<img src="./assets/kindle-theme02.png" width="47%" alt="Theme 2" />
</div>

### Community

<div align="center">
<img src="./assets/telegram-group.jpg" width="50%" alt="Telegram Group" />
</div>

</details>

---

## Installation & Usage

### Prerequisites

<details>

<summary>fbink Installation Guide (skip if already installed)</summary>

#### USBNetwork Hack

- [Installation Tutorial](https://bookfere.com/post/59.html) (Chinese)
- [Official Release](https://www.mobileread.com/forums/showthread.php?t=225030)

</details>

### Installation Steps

1. Download [OnniView.zip](https://raw.githubusercontent.com/OmniViewApp/kindle-omni-view/refs/heads/master/OmniView.zip) and extract
2. Transfer the `OmniView` folder to your Kindle:
   - **USB Method**: Copy to `/mnt/us/extensions/` via USB cable
   - **Wireless Method**: Use `scp` command via USBNetwork
3. Disconnect USB cable

### Getting Started

1. Open **KUAL** on your Kindle
2. Click **OmniView** menu

#### First-Time Setup (Device Registration)

1. Click **Register Device**
2. A QR code will be displayed on screen
3. Scan the QR code with WeChat to bind your device
4. Restart the application when prompted

#### Running & Stopping

**Start Running**
- Click **Start Frame** to begin cycling through images

**Stop Running**
- **Method 1**: Press the power button to wake, wait for `stopping...` to appear, then it will automatically exit to home
- **Method 2**: Long-press the power button to force shutdown

---

## File Structure

### Working Directory

```
/mnt/us/OmniView/
├── conf/
│   └── config.cfg          # User configuration
├── tmp/                     # Temporary image storage
└── app.log                  # Runtime log
```

> **Note**: To keep the system clean, all runtime files are stored in `/mnt/us/OmniView`, not in the plugin directory.

If you encounter any issues, please check the log file at `/mnt/us/OmniView/app.log`.

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Server Request Failed" | Check Kindle WiFi connection |
| OmniView not visible in KUAL | Verify `extensions/OmniView/config.xml` exists |
| Device registration fails | Check network connection and server status |

---

## Support

- [Telegram Group](https://t.me/OmniViewApp)
- Submit [Issues](https://github.com/OmniViewApp/kindle-omni-view/issues)

---

## License

[GPL-3.0](LICENSE.txt)
