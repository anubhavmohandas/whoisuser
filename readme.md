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

**WhoisUser** is a comprehensive OSINT (Open Source Intelligence) toolkit designed for username enumeration and digital footprint analysis. Built for cybersecurity professionals, penetration testers, and forensic investigators, it automates the discovery of user profiles across 100+ platforms.

### Key Features

- ✅ Scans **100+ platforms** (social media, developer sites, gaming, forums, etc.)
- ✅ **Automated screenshot capture** with ChromeDriver reuse
- ✅ **Multi-tool integration** (Sherlock, Maigret, Holehe, Blackbird)
- ✅ **Comprehensive reports** (TXT, JSON, URL lists)
- ✅ **Enhanced validation** - Platform-specific checks reduce false positives
- ✅ **Configurable performance** - Adjust thread count (default: 15 workers)
- ✅ **Cross-platform support** - Kali, Ubuntu, Debian, Parrot OS, Arch, Fedora, RHEL

---

## 🚀 Installation

### Quick Install (Recommended)

```bash
# Clone the repository
git clone https://github.com/anubhavmohandas/whoisuser.git
cd whoisuser

# Make installer executable
chmod +x install.sh

# Run interactive installer
sudo bash install.sh        # Global installation (recommended)
# OR
bash install.sh             # User installation (no sudo)
```

The installer will:
1. Check system requirements (Python 3.8+, pip3, git)
2. Install Python dependencies (requests, colorama, selenium, webdriver-manager)
3. Install Chrome/Chromium (for screenshots)
4. Install WhoisUser main tool
5. Install additional OSINT tools (optional)
6. Configure PATH environment

### Manual Installation

```bash
# Install dependencies
pip3 install requests colorama selenium webdriver-manager

# Install Chrome/Chromium
sudo apt install chromium-browser    # Ubuntu/Debian/Kali
sudo dnf install chromium             # Fedora
sudo pacman -S chromium               # Arch

# Make executable
chmod +x whoisuser.py
sudo cp whoisuser.py /usr/local/bin/whoisuser
```

### System Requirements

- **Python**: 3.8 or higher
- **pip3**: Latest version
- **git**: For OSINT tool installation
- **Chrome/Chromium**: For screenshot capture (optional)

---

## 💻 Usage

### Basic Command

```bash
whoisuser <username> [options]
```

### Command-Line Options

| Option | Description | Example |
|--------|-------------|---------|
| `<username>` | Target username to investigate | `whoisuser johndoe` |
| `--no-screenshots` | Skip screenshot capture (faster) | `whoisuser johndoe --no-screenshots` |
| `--no-osint-tools` | Skip external OSINT tools | `whoisuser johndoe --no-osint-tools` |
| `--workers N` | Set thread count (default: 15) | `whoisuser johndoe --workers 20` |

### Usage Examples

```bash
# Basic username search (default settings)
whoisuser johndoe

# Fast scan without screenshots
whoisuser johndoe --no-screenshots

# Use only built-in scanner (no Sherlock, Maigret, etc.)
whoisuser johndoe --no-osint-tools

# High-performance scan with 20 threads
whoisuser johndoe --workers 20

# Maximum speed scan
whoisuser johndoe --no-screenshots --no-osint-tools --workers 25
```

### Output Structure

All results are saved to `~/investigations/<username>_<timestamp>/`:

```
investigations/johndoe_20240101_120000/
├── FULL_REPORT.txt          # Complete investigation report
├── report.json              # Machine-readable JSON format
├── all_urls.txt             # List of found profile URLs
├── screenshots/             # Profile screenshots (PNG)
│   ├── Instagram.png
│   ├── GitHub.png
│   └── Twitter_X.png
└── osint_results/           # External tool outputs
    ├── sherlock_results.txt
    ├── maigret/
    ├── holehe_*.txt
    └── blackbird_results.txt
```

---

## 🔧 OSINT Tools Integration

WhoisUser integrates with popular OSINT tools for enhanced results:

### Using Integrated Tools

When running WhoisUser with default settings, these tools execute automatically:

#### 1. Sherlock
```bash
# Runs automatically within WhoisUser
whoisuser johndoe

# Use independently
sherlock johndoe
```
- **Purpose**: Search 300+ platforms
- **Output**: `osint_results/sherlock_results.txt`

#### 2. Maigret
```bash
# Runs automatically within WhoisUser
whoisuser johndoe

# Use independently
maigret johndoe
```
- **Purpose**: Advanced username OSINT
- **Output**: `osint_results/maigret/`

#### 3. Holehe
```bash
# Runs automatically within WhoisUser (tests multiple email variants)
whoisuser johndoe

# Use independently
holehe johndoe@gmail.com
```
- **Purpose**: Email account enumeration
- **Output**: `osint_results/holehe_*.txt`

#### 4. Blackbird
```bash
# Runs automatically within WhoisUser
whoisuser johndoe

# Use independently
blackbird -u johndoe
```
- **Purpose**: Fast username scanning
- **Output**: `osint_results/blackbird_results.txt`

### Skipping External Tools

To use only the built-in 100+ platform scanner:

```bash
whoisuser johndoe --no-osint-tools
```

---

## 📊 Platform Coverage

WhoisUser scans 100+ platforms across categories:

- **Social Media**: Instagram, Twitter/X, Facebook, LinkedIn, TikTok, Snapchat, Reddit, Pinterest, Tumblr, Mastodon
- **Video Platforms**: YouTube, Vimeo, Dailymotion, Twitch, Rumble, BitChute
- **Developer Platforms**: GitHub, GitLab, Bitbucket, StackOverflow, HackerRank, LeetCode, CodePen, Repl.it, Dev.to, Kaggle, HackerOne, CodeChef
- **Gaming**: Steam, Xbox, PlayStation, Discord, Roblox, Epic Games, Fortnite, Minecraft
- **Professional**: AngelList, Behance, Dribbble, About.me, Gravatar, ResearchGate, Academia
- **Music**: Spotify, SoundCloud, Bandcamp, Last.fm, Mixcloud, Audiomack
- **Forums**: HackerNews, ProductHunt, Keybase, Patreon, Ko-fi, BuyMeACoffee
- **International**: VK, OK.ru, Weibo, QQ, Douban
- **Business**: Etsy, eBay, Fiverr, Upwork, Freelancer, PeoplePerHour
- **Blogging**: WordPress, Blogger, Medium, Ghost, Substack
- **Photography**: Flickr, 500px, Unsplash, VSCO, DeviantArt, ArtStation
- **Messaging**: Telegram, Signal, Viber, Line, Kik
- **Dating**: Tinder, Bumble, Badoo, Match, OkCupid, Plenty of Fish, Adult Friend Finder
- **Adult**: OnlyFans, Pornhub, Chaturbate, Fansly, ManyVids, Clips4Sale
- **Payment**: Linktree, Cash App, Venmo, PayPal, Bitcoin
- **Learning**: Quora, Duolingo, Coursera, Udemy
- **Media**: Goodreads, Letterboxd, MyAnimeList, AniList, Crunchyroll, Wattpad, Archive of Our Own
- **Sports**: Strava, Chess.com, Lichess, Untappd, MyFitnessPal

---

## ⚙️ Performance Optimization

### Thread Configuration

Adjust worker threads based on your needs:

| Workers | Speed | Resource Usage | Use Case |
|---------|-------|----------------|----------|
| `5` | Slow | Low | Stealth mode, avoid rate limits |
| `15` | Balanced | Medium | **Default - recommended** |
| `20-25` | Fast | High | Quick scans, good internet |
| `50+` | Very Fast | Very High | May trigger rate limits |

```bash
# Examples
whoisuser johndoe --workers 5    # Slow & safe
whoisuser johndoe --workers 15   # Default
whoisuser johndoe --workers 25   # Fast
```

### Speed vs. Features

| Configuration | Speed | Features | Command |
|---------------|-------|----------|---------|
| **Full Scan** | Slowest | All features | `whoisuser johndoe` |
| **No Screenshots** | 70% faster | No visual evidence | `whoisuser johndoe --no-screenshots` |
| **No External Tools** | Faster | Built-in only | `whoisuser johndoe --no-osint-tools` |
| **Maximum Speed** | Fastest | Minimal | `whoisuser johndoe --no-screenshots --no-osint-tools --workers 25` |

---

## 🔍 Output Files Explained

### 1. FULL_REPORT.txt
```
==========================================
WHOISUSER - COMPREHENSIVE OSINT INVESTIGATION REPORT
==========================================

Investigation Date: 2024-01-01 12:00:00
Target Username: johndoe
Investigation ID: 20240101_120000
Investigator: Anubhav (Cybersecurity & Cyber Forensic Researcher)
Tool Version: 2.7 OPTIMIZED
Total Platforms Scanned: 100+
Profiles Found (Direct): 25
Profiles Found (Sherlock): 15
Total Unique Profiles: 35

==========================================
DISCOVERED PROFILES
==========================================

1. Platform: Instagram
   URL: https://www.instagram.com/johndoe/
   Source: whoisuser
   Status: Active (HTTP 200)
   Discovered At: 2024-01-01T12:05:30
   Evidence: screenshots/Instagram.png

...
```

### 2. report.json
```json
{
  "investigation": {
    "username": "johndoe",
    "timestamp": "20240101_120000",
    "date": "2024-01-01T12:00:00",
    "investigator": "Anubhav",
    "tool_version": "2.7 OPTIMIZED",
    "total_platforms": 100,
    "profiles_found_direct": 25,
    "profiles_found_sherlock": 15,
    "total_unique_profiles": 35
  },
  "profiles": [...],
  "failed_checks": [...]
}
```

### 3. all_urls.txt
```
https://www.instagram.com/johndoe/
https://github.com/johndoe
https://twitter.com/johndoe
https://www.linkedin.com/in/johndoe
...
```

---

## 🛠️ Troubleshooting

### Command Not Found

```bash
# Reload shell configuration
source ~/.bashrc

# Or use full path
~/.local/bin/whoisuser johndoe
```

### Python Module Errors

```bash
# Reinstall dependencies
pip3 install requests colorama selenium webdriver-manager --user

# Or for newer systems
pip3 install requests colorama selenium --break-system-packages
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

## ⚖️ Legal Disclaimer

**⚠️ EDUCATIONAL PURPOSE ONLY ⚠️**

WhoisUser is designed exclusively for:
- ✅ Educational and research purposes
- ✅ Authorized security testing and penetration testing
- ✅ Digital forensics investigations with proper authorization
- ✅ OSINT training and skill development

**This tool MUST NOT be used for:**
- ❌ Unauthorized access to systems or accounts
- ❌ Harassment, stalking, or privacy invasion
- ❌ Any illegal activities or malicious purposes
- ❌ Violation of platform Terms of Service

**Important:**
- Always obtain proper authorization before conducting investigations
- Respect all applicable laws (GDPR, CCPA, local privacy regulations)
- Comply with platform Terms of Service
- The author is not responsible for misuse of this tool

By using WhoisUser, you acknowledge that you understand and agree to use it legally and ethically.

---

## 👨‍💻 Author

**Anubhav**  
Cybersecurity & Cyber Forensic Researcher

- 🌐 Website: [https://anubhavmohandas.github.io/portfolio/](https://anubhavmohandas.github.io/portfolio/)
- 💼 GitHub: [@anubhavmohandas](https://github.com/anubhavmohandas)
- 💼 LinkedIn: [anubhavmohandas](https://linkedin.com/in/anubhavmohandas)
- 🐦 Twitter: [@anubhavmohandas](https://twitter.com/anubhavmohandas)

---

## 📜 License

This project is licensed for **Educational Use Only**.

```
Copyright (c) 2024 Anubhav

Permission is granted for educational and research purposes only.
Commercial use, redistribution, or modification requires explicit permission.
```

---

## 🙏 Acknowledgments

- **Sherlock Project** - Username search methodology
- **Maigret** - Advanced OSINT techniques
- **Holehe** - Email enumeration approach
- **Blackbird** - Fast scanning implementation
- **OSINT Community** - Continuous tool development and knowledge sharing

---

<div align="center">

**Made with ❤️ for the OSINT Community**

⚠️ **Remember: With great power comes great responsibility** ⚠️

Use this tool ethically, legally, and responsibly.

</div>
