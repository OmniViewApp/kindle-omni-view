# 万象 (OmniView)

[简体中文](README.md) | [English](README_EN.md)

> **方寸之间，包罗万象。**

OmniView 是一个基于 KUAL 的 Kindle 插件，可将闲置的 Kindle 设备变身为智能电子墨水屏相框或信息展示屏。

---

## 功能特点

- **智能唤醒** - 利用 Kindle RTC (实时时钟) 实现深度休眠与定时唤醒，大幅延长电池续航
- **自动刷新** - 定期从服务器获取最新图像并自动展示
- **防残影处理** - 启动时自动清屏，避免 KUAL 菜单残影
- **设备绑定** - 通过二维码扫描与服务端进行设备绑定
- **状态显示** - 在屏幕上直观显示运行状态和错误信息
- **优雅退出** - 停止运行时自动返回 Kindle 主页
- **超长续航** - 一次充电可以持续使用一个月以上

---

## 系统要求

### 硬件
- 已越狱的 Kindle 设备 (测试于 Kindle Paperwhite 3)

### 软件
- [KUAL](https://bookfere.com/post/311.html#p_2) (KUAL)
- [fbink](https://github.com/NiLuJe/FBInk) (用于屏幕绘图，通常随 USBNetwork Hack 或WinterBreak安装)

---

## 示例截图
<div align="center">
<img src="./assets/kindle-example1.jpg" width="50%" alt="Kindle 运行效果" />
</div>

<details>

<summary>点击展开查看更多</summary>

### 微信小程序

<div align="center">
<img src="./assets/omni-view-minipcode.jpg" width="30%" alt="小程序" />
</div>

<div align="center">
<img src="./assets/minip00.jpg" width="30%" alt="小程序 1" />
<img src="./assets/minip01.jpg" width="30%" alt="小程序 2" />
<img src="./assets/minip02.png" width="30%" alt="小程序 3" />
<br>
<img src="./assets/minip03.jpg" width="30%" alt="小程序 4" />
<img src="./assets/minip04.jpg" width="30%" alt="小程序 5" />
<img src="./assets/minip05.jpg" width="30%" alt="小程序 6" />
</div>

### 主题样式

<div align="center">
<img src="./assets/kindle-theme01.jpg" width="47%" alt="主题样式" />
<img src="./assets/kindle-theme02.png" width="47%" alt="主题样式 2" />
</div>

### 交流群

<div align="center">
<img src="./assets/telegram-group.jpg" width="50%" alt="telegram group" />
</div>


</details>

---

## 安装与使用

### 前置准备

<details>

<summary>KUAL、fbink 安装指南 (如已安装请跳过)</summary>

#### KUAL
- [安装教程](https://bookfere.com/post/311.html#p_2)

#### USBNetwork Hack

- [安装教程](https://bookfere.com/post/59.html)
- [官方发布页](https://www.mobileread.com/forums/showthread.php?t=225030)
- [百度网盘下载](https://pan.baidu.com/share/init?surl=qAgVhwfLXY2Z6VyHh5PCEw&pwd=9tgy)

</details>

### 安装步骤

1. 下载 [OnniView.zip](https://raw.githubusercontent.com/OmniViewApp/kindle-omni-view/refs/heads/master/OmniView.zip) 并解压
2. 将 `OmniView` 文件夹传输至 Kindle：
   - **USB 方式**：通过 USB 数据线复制到 `/mnt/us/extensions/` 目录
   - **无线方式**：通过 USBNetwork 的 `scp` 命令传输
3. 断开 USB 数据线

### 使用流程

1. 在 Kindle 上打开 **KUAL**
2. 点击 **OmniView** 菜单

#### 首次使用（设备注册）

1. 点击 **Register Device**
2. 屏幕将显示二维码
3. 使用微信扫描二维码进行设备绑定
4. 注册成功后按提示重启应用

#### 运行与停止

**启动运行**
- 点击 **Start Frame** 即可开始循环展示图片

**停止运行**
- **方式一**：按下电源键唤醒，待屏幕显示 `stopping...` 后自动退出至主页
- **方式二**：长按电源键强制关机

---

## 文件说明

### 工作目录结构

```
/mnt/us/OmniView/
├── conf/
│   └── config.cfg          # 用户配置文件
├── tmp/                     # 临时图片存储
└── app.log                  # 运行日志
```

> **注意**：为保持系统整洁，所有运行时文件均存储在 `/mnt/us/OmniView` 目录，而非插件目录。

如遇问题，请查看 `/mnt/us/OmniView/app.log` 日志文件。

---

## 常见问题

| 问题 | 解决方案 |
|------|----------|
| 显示 "Server Request Failed" | 请检查 Kindle WiFi 连接状态 |
| KUAL 中看不到 OmniView | 请确认 `extensions/OmniView/config.xml` 文件存在 |
| 设备无法注册 | 请检查网络连接及服务器状态 |

---

## 问题反馈
- [Telegram 群组](https://t.me/OmniViewApp)
- 提交 [Issue](https://github.com/OmniViewApp/kindle-omni-view/issues)

---

## 许可证

[GPL-3.0](LICENSE.txt)
