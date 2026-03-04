---
name: openclaw-installer
description: "OpenClaw one-click installer by world.je. Automatically install and configure OpenClaw with a single command. Supports Windows, macOS, Linux, and Android Termux."
category: utility
risk: safe
source: community
author: world.je
license: MIT
version: "1.0.0"
tags: "[installer, setup, deployment, automation, openclaw]"
date_added: "2026-03-04"
homepage: "https://world.je"
repository: "https://github.com/worldje/openclaw-installer"
support: "https://world.je"
price:
  self_install: free
  on_site_service: "888 CNY"
---

# 🚀 OpenClaw One-Click Installer

<div align="center">

**Install OpenClaw in One Command**

*Created with ❤️ by [world.je](https://world.je)*

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node: 18+](https://img.shields.io/badge/Node.js-18%2B-green.svg)](https://nodejs.org)
[![Platform](https://img.shields.io/badge/Platform-Win%20|%20Mac%20|%20Linux%20|%20Termux-blue.svg)](https://world.je)

</div>

---

## 🎯 Purpose

This skill provides a **one-click installer** for OpenClaw - your personal AI assistant. No technical knowledge required.

**Two Installation Options:**

| Option | Price | Description |
|--------|-------|-------------|
| 🆓 **Self-Install** | FREE | Run the installer yourself |
| 💰 **On-Site Service** | 888 CNY | We come to you, install + teach + support |

---

## 🚀 Quick Start

### Option 1: Self-Install (Free)

```bash
# One command, that's it!
npx @worldje/openclaw-installer
```

### Option 2: On-Site Service (888 CNY)

Contact us at [world.je](https://world.je) to schedule an appointment.

**Included:**
- ✅ On-site installation (2 hours)
- ✅ Hands-on teaching
- ✅ 30-day technical support
- ✅ Custom configuration

---

## 📋 What the Installer Does

1. **🔍 Detect System** - Automatically identify your OS
2. **📦 Check Dependencies** - Verify Node.js, Git, etc.
3. **⬇️ Download OpenClaw** - Clone from official repository
4. **🔧 Install Dependencies** - Install all required packages
5. **🏗️ Build Project** - Compile TypeScript to JavaScript
6. **⚙️ Configure** - Create default configuration
7. **🩺 Diagnose** - Run `openclaw doctor` to fix issues
8. **▶️ Start Service** - Launch OpenClaw Gateway
9. **🌐 Open Browser** - Navigate to Web UI
10. **✅ Done!** - Your AI assistant is ready

---

## 💻 Supported Platforms

| Platform | Status | Installer |
|----------|--------|-----------|
| Windows 10/11 | ✅ Supported | PowerShell |
| macOS 10.15+ | ✅ Supported | Bash |
| Linux (Ubuntu/Debian) | ✅ Supported | Bash |
| Linux (CentOS/RHEL) | ✅ Supported | Bash |
| Android (Termux) | ✅ Supported | Bash |

---

## 📖 Usage

### Basic Install

```bash
npx @worldje/openclaw-installer
```

### Advanced Options

```bash
# Specify version
npx @worldje/openclaw-installer --version 1.2.0

# Custom install directory
npx @worldje/openclaw-installer --dir ~/my-openclaw

# Headless mode (no browser)
npx @worldje/openclaw-installer --no-browser

# Verbose output
npx @worldje/openclaw-installer --verbose

# Uninstall
npx @worldje/openclaw-installer --uninstall
```

---

## 📁 After Installation

OpenClaw will be available at:
- **Web UI**: http://localhost:5203
- **Gateway**: ws://localhost:5203
- **Config**: ~/.openclaw/openclaw.json
- **Skills**: ~/.openclaw/.agents/skills/

### Useful Commands

```bash
# Check status
openclaw status

# Start gateway
openclaw gateway start

# Stop gateway
openclaw gateway stop

# Restart gateway
openclaw gateway restart

# Run diagnostics
openclaw doctor

# Install a skill
npx skills add <skill-name>
```

---

## ⚙️ Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| Node.js | 18.0.0 | 20.0.0+ |
| Git | 2.0.0 | Latest |
| Disk Space | 500MB | 2GB |
| RAM | 512MB | 2GB |

---

## 🔧 Troubleshooting

### "Node.js not found"

Install Node.js first:

```bash
# macOS (Homebrew)
brew install node

# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Windows
# Download from https://nodejs.org

# Termux (Android)
pkg install nodejs
```

### "Git not found"

```bash
# macOS
brew install git

# Ubuntu/Debian
sudo apt install git

# Windows
# Download from https://git-scm.com

# Termux
pkg install git
```

### "Permission denied"

```bash
# Linux/macOS
chmod +x ~/openclaw/scripts/install.sh

# Or use sudo
sudo npx @worldje/openclaw-installer
```

### "Port 5203 already in use"

```bash
# Stop existing OpenClaw
openclaw gateway stop

# Or kill the process
# Linux/macOS
lsof -ti:5203 | xargs kill -9

# Windows
netstat -ano | findstr :5203
taskkill /PID <PID> /F
```

### "Installation failed"

1. Check your internet connection
2. Update Node.js to version 18+
3. Clear npm cache: `npm cache clean --force`
4. Try again with `--verbose` flag
5. Contact support at [world.je](https://world.je)

---

## 📦 Files Included

```
openclaw-installer/
├── SKILL.md              # This documentation
├── README.md             # Quick start guide
├── package.json          # npm package config
├── bin/
│   ├── install.js        # Node.js entry point
│   └── welcome.js        # Post-install message
├── scripts/
│   ├── install.sh        # Linux/macOS/Termux installer
│   ├── install.ps1       # Windows PowerShell installer
│   └── uninstall.sh      # Uninstaller
└── templates/
    └── openclaw.json     # Default config template
```

---

## 🆘 Support

### Free Support
- 📖 Documentation: https://docs.openclaw.ai
- 🐛 Issues: https://github.com/worldje/openclaw-installer/issues
- 💬 Community: https://discord.com/invite/clawd

### Paid Support (888 CNY)
- 🏠 On-site installation
- 👨‍🏫 Hands-on teaching
- 📞 30-day technical support
- 🔧 Custom configuration
- 📞 Contact: [world.je](https://world.je)

---

## 📄 License

MIT License - Free to use, modify, and distribute.

Copyright (c) 2026 [world.je](https://world.je)

---

<div align="center">

**Made with ❤️ by [world.je](https://world.je)**

⭐ Star us on GitHub | 📧 Contact us | 🌐 Visit world.je

</div>
