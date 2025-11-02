# WhoisUser - Professional OSINT Investigation Tool

```
    ╦ ╦╦ ╦╔═╗╦╔═╗╦ ╦╔═╗╔═╗╦═╗
    ║║║╠═╣║ ║║╚═╗║ ║╚═╗║╣ ╠╦╝
    ╚╩╝╩ ╩╚═╝╩╚═╝╚═╝╚═╝╚═╝╩╚═
         OSINT TOOLKIT
```

[![Version](https://img.shields.io/badge/version-2.7%20OPTIMIZED-blue.svg)](https://github.com/anubhavmohandas/whoisuser)
[![Python](https://img.shields.io/badge/python-3.8+-green.svg)](https://www.python.org/downloads/)
[![License](https://img.shields.io/badge/license-Educational-orange.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20Kali%20%7C%20Ubuntu-red.svg)](https://github.com/anubhavmohandas/whoisuser)

> **Professional Username Enumeration & OSINT Investigation Framework**  
> Automated username discovery across 100+ platforms with integrated forensic tools

---

## 📋 Overview

**WhoisUser** is a comprehensive OSINT toolkit for username enumeration and digital footprint analysis. It automates the discovery of user profiles across 100+ platforms with intelligent result merging from multiple OSINT tools.

### Key Features

- ✅ Scans **100+ platforms** (social media, developer sites, gaming, forums, etc.)
- ✅ **Multi-tool integration** (Sherlock, Maigret, Holehe, Blackbird) with automatic deduplication
- ✅ **Automated screenshot capture** with ChromeDriver reuse
- ✅ **Enhanced validation** - Platform-specific checks reduce false positives
- ✅ **Comprehensive reports** (TXT, JSON, URL lists)
- ✅ **Configurable performance** - Adjust thread count (default: 15 workers)
- ✅ **Cross-platform support** - Kali, Ubuntu, Debian, Parrot OS, Arch, Fedora, RHEL

---

## 🚀 Installation

### Quick Install

```bash
# Clone the repository
git clone https://github.com/anubhavmohandas/whoisuser.git
cd whoisuser

# Make installer executable
chmod +x install.sh

# Run installer
sudo bash install.sh        # Global installation (recommended)
# OR
bash install.sh             # User installation (no sudo)
```

The installer will handle all dependencies, Chrome/Chromium, and optional OSINT tools.

### Manual Installation

```bash
# Install dependencies
pip3 install requests colorama selenium webdriver-manager

# Install Chrome/Chromium (for screenshots)
sudo apt install chromium-browser    # Ubuntu/Debian/Kali

# Make executable
chmod +x whoisuser.py
sudo cp whoisuser.py /usr/local/bin/whoisuser
```

### Requirements

- Python 3.8+, pip3, git
- Chrome/Chromium (optional, for screenshots)

---

## 💻 Usage

### Basic Command

```bash
whoisuser <username> [options]
```

### Options

| Option | Description |
|--------|-------------|
| `<username>` | Target username to investigate |
| `--no-screenshots` | Skip screenshot capture (faster) |
| `--no-osint-tools` | Skip external OSINT tools |
| `--workers N` | Set thread count (default: 15) |

### Examples

```bash
# Basic scan (all features)
whoisuser johndoe

# Fast scan without screenshots
whoisuser johndoe --no-screenshots

# Built-in scanner only
whoisuser johndoe --no-osint-tools

# Maximum speed
whoisuser johndoe --no-screenshots --no-osint-tools --workers 25
```

### Output Structure

Results saved to `~/investigations/<username>_<timestamp>/`:

```
investigations/johndoe_20240101_120000/
├── FULL_REPORT.txt          # Complete investigation report
├── report.json              # Machine-readable JSON
├── all_urls.txt             # Found profile URLs
├── screenshots/             # Profile screenshots
└── osint_results/           # External tool outputs
```

---

## 🔧 OSINT Tools Integration

WhoisUser integrates with popular OSINT tools and automatically merges results:

### Integrated Tools

- **Sherlock** - Search 300+ platforms
- **Maigret** - Advanced username OSINT
- **Holehe** - Email account enumeration
- **Blackbird** - Fast username scanning

All results are automatically parsed, deduplicated, and merged into a single comprehensive report showing which tools found each profile.

```bash
# Use all tools (default)
whoisuser johndoe

# Skip external tools (built-in scanner only)
whoisuser johndoe --no-osint-tools
```

---

## 📊 Platform Coverage

WhoisUser scans 100+ platforms across categories:

**Social Media** - Instagram, Twitter/X, Facebook, LinkedIn, TikTok, Snapchat, Reddit, Pinterest, Tumblr, Mastodon

**Developer** - GitHub, GitLab, Bitbucket, StackOverflow, HackerRank, LeetCode, CodePen, Repl.it, Dev.to, Kaggle, HackerOne

**Gaming** - Steam, Xbox, PlayStation, Discord, Roblox, Epic Games, Fortnite, Minecraft

**Professional** - AngelList, Behance, Dribbble, About.me, Gravatar, ResearchGate, Academia

**Music** - Spotify, SoundCloud, Bandcamp, Last.fm, Mixcloud, Audiomack

**Other Categories** - Video platforms, Forums, E-commerce, Blogging, Photography, Messaging, Dating/Adult, Payment, Learning, Entertainment, Sports

*Full platform list available in code*

---

## ⚙️ Performance Optimization

### Thread Configuration

| Workers | Speed | Use Case |
|---------|-------|----------|
| `5` | Slow | Stealth mode |
| `15` | Balanced | **Default - recommended** |
| `25` | Fast | Quick scans |

```bash
whoisuser johndoe --workers 15    # Default
whoisuser johndoe --workers 25    # Fast
```

### Performance Features

- Connection pooling & session reuse
- Per-domain rate limiting (prevents blocks)
- ChromeDriver reuse for screenshots
- Concurrent processing with thread pools
- Automatic resource cleanup

---

## 🔍 Output Files

### FULL_REPORT.txt
Human-readable investigation report with:
- Investigation metadata
- All discovered profiles (merged & deduplicated)
- Breakdown by source (WhoisUser, Sherlock, Maigret, etc.)
- Platform details and verification status

### report.json
Machine-readable format with complete investigation data, source tracking, and metadata.

### all_urls.txt
Simple list of discovered profile URLs (one per line).

---

## 🛠️ Troubleshooting

### Command Not Found
```bash
# Reload shell (user installation)
source ~/.bashrc

# Or use full path
~/.local/bin/whoisuser johndoe
```

### Python Module Errors
```bash
# Reinstall dependencies
pip3 install requests colorama selenium webdriver-manager --user
```

### Screenshot Issues
```bash
# Install Chrome/Chromium
sudo apt install chromium-browser

# Or skip screenshots
whoisuser johndoe --no-screenshots
```

### Permission Denied
```bash
# Fix permissions
sudo chmod +x /usr/local/bin/whoisuser
```

---
## ARM64 Compatibility Note

WhoisUser works perfectly on ARM-based systems (Raspberry Pi, Apple Silicon, ARM servers) with one limitation:

**Screenshot functionality is not available on ARM64** due to ChromeDriver compatibility issues.

**Workaround**: Use the `--no-screenshots` flag (all other features work normally):
```bash
whoisuser <username> --no-screenshots
```

**What you get on ARM64:**
- ✅ Full platform scanning (100+ sites)
- ✅ Profile URL discovery
- ✅ OSINT tool integration (Sherlock, Maigret, Holehe, Blackbird)
- ✅ Complete reports (TXT, JSON, URL lists)
- ✅ Email enumeration
- ❌ Screenshot capture (disabled)

**Performance**: Actually faster without screenshots! ⚡

## ⚖️ Legal Disclaimer

**⚠️ EDUCATIONAL PURPOSE ONLY ⚠️**

WhoisUser is designed exclusively for:
- ✅ Educational and research purposes
- ✅ Authorized security testing
- ✅ Digital forensics with proper authorization
- ✅ OSINT training

**This tool MUST NOT be used for:**
- ❌ Unauthorized access or privacy invasion
- ❌ Harassment or stalking
- ❌ Any illegal activities
- ❌ Violation of platform Terms of Service

By using WhoisUser, you acknowledge that you will use it legally and ethically. The author is not responsible for misuse of this tool.

---

## 👨‍💻 Author

**Anubhav**  
Cybersecurity & Cyber Forensic Researcher

- 🌐 Website: [anubhavmohandas.github.io/portfolio](https://anubhavmohandas.github.io/portfolio/)
- 💼 GitHub: [@anubhavmohandas](https://github.com/anubhavmohandas)
- 💼 LinkedIn: [anubhavmohandas](https://linkedin.com/in/anubhavmohandas)
- 🐦 Twitter: [@anubhavmohandas](https://twitter.com/anubhavmohandas)

---

## 📜 License

Educational Use Only - Copyright (c) 2024 Anubhav

---

## 🙏 Acknowledgments

Sherlock Project, Maigret, Holehe, Blackbird, and the OSINT Community

---

<div align="center">

**Made with ❤️ for the OSINT Community**

⚠️ **Use ethically, legally, and responsibly** ⚠️

⚠️ **Remember: With great power comes great responsibility** ⚠️

</div>
