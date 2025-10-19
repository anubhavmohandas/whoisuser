#!/bin/bash

# WhoisUser Installation Script with OSINT Tools Integration
# Author: Anubhav
# Description: Automated installation of WhoisUser and popular OSINT tools

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║       WhoisUser - Complete OSINT Toolkit Installer            ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if running as root for global installation
if [ "$EUID" -ne 0 ]; then 
    echo -e "${YELLOW}[!] Not running as root. Will install in user mode.${NC}"
    INSTALL_DIR="$HOME/.local/bin"
    GLOBAL_INSTALL=false
else
    echo -e "${GREEN}[+] Running with root privileges. Will install globally.${NC}"
    INSTALL_DIR="/usr/local/bin"
    GLOBAL_INSTALL=true
fi

# Create installation directory
mkdir -p "$INSTALL_DIR"
export PATH="$PATH:$INSTALL_DIR"

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# ============================================================================
# STEP 1: Check System Requirements
# ============================================================================
echo -e "\n${CYAN}[STEP 1/6] Checking System Requirements...${NC}\n"

# Check Python
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version | cut -d ' ' -f 2)
    echo -e "${GREEN}[✓] Python3 found: $PYTHON_VERSION${NC}"
else
    echo -e "${RED}[✗] Python3 not found. Please install Python 3.8+${NC}"
    exit 1
fi

# Check pip
if command -v pip3 &> /dev/null; then
    echo -e "${GREEN}[✓] pip3 found${NC}"
else
    echo -e "${YELLOW}[!] Installing pip...${NC}"
    python3 -m ensurepip --upgrade
fi

# Check git
if command -v git &> /dev/null; then
    echo -e "${GREEN}[✓] git found${NC}"
else
    echo -e "${RED}[✗] git not found. Installing git...${NC}"
    if [ -f /etc/debian_version ]; then
        sudo apt-get update && sudo apt-get install -y git
    elif [ -f /etc/redhat-release ]; then
        sudo yum install -y git
    else
        echo -e "${RED}[✗] Please install git manually${NC}"
        exit 1
    fi
fi

# ============================================================================
# STEP 2: Install Python Dependencies
# ============================================================================
echo -e "\n${CYAN}[STEP 2/6] Installing Python Dependencies...${NC}\n"

if [ -f "$SCRIPT_DIR/requirements.txt" ]; then
    pip3 install -r "$SCRIPT_DIR/requirements.txt" --upgrade --user
else
    pip3 install requests colorama selenium webdriver-manager urllib3 certifi --upgrade --user
fi
echo -e "${GREEN}[✓] Python dependencies installed${NC}"

# ============================================================================
# STEP 3: Install Chrome/Chromium for Screenshots
# ============================================================================
echo -e "\n${CYAN}[STEP 3/6] Checking Chrome/Chromium...${NC}\n"

if command -v google-chrome &> /dev/null || command -v chromium-browser &> /dev/null || command -v chromium &> /dev/null; then
    echo -e "${GREEN}[✓] Chrome/Chromium found${NC}"
else
    echo -e "${YELLOW}[!] Chrome/Chromium not found${NC}"
    echo -e "${YELLOW}[?] Do you want to install Chromium? (y/n)${NC}"
    read -r install_chrome
    
    if [[ $install_chrome == "y" || $install_chrome == "Y" ]]; then
        if [ -f /etc/debian_version ]; then
            sudo apt-get update && sudo apt-get install -y chromium-browser
        elif [ -f /etc/redhat-release ]; then
            sudo dnf install -y chromium
        elif [ -f /etc/arch-release ]; then
            sudo pacman -S chromium
        fi
        echo -e "${GREEN}[✓] Chromium installed${NC}"
    else
        echo -e "${YELLOW}[!] Skipping Chromium. Screenshots will be disabled.${NC}"
    fi
fi

# ============================================================================
# STEP 4: Install WhoisUser Main Tool
# ============================================================================
echo -e "\n${CYAN}[STEP 4/6] Installing WhoisUser...${NC}\n"

if [ -f "$SCRIPT_DIR/whoisuser.py" ]; then
    cp "$SCRIPT_DIR/whoisuser.py" "$INSTALL_DIR/whoisuser"
    chmod +x "$INSTALL_DIR/whoisuser"
    
    # Add shebang if not present
    if ! grep -q "#!/usr/bin/env python3" "$INSTALL_DIR/whoisuser"; then
        echo "#!/usr/bin/env python3" | cat - "$INSTALL_DIR/whoisuser" > temp && mv temp "$INSTALL_DIR/whoisuser"
        chmod +x "$INSTALL_DIR/whoisuser"
    fi
    
    echo -e "${GREEN}[✓] WhoisUser installed to $INSTALL_DIR${NC}"
else
    echo -e "${RED}[✗] whoisuser.py not found in current directory${NC}"
    exit 1
fi

# ============================================================================
# STEP 5: Install Additional OSINT Tools
# ============================================================================
echo -e "\n${CYAN}[STEP 5/6] Installing Additional OSINT Tools...${NC}\n"
echo -e "${YELLOW}This will install: Sherlock, Maigret, Holehe, Social-Analyzer${NC}"
echo -e "${YELLOW}Continue? (y/n)${NC}"
read -r install_osint

if [[ $install_osint == "y" || $install_osint == "Y" ]]; then
    
    # Create tools directory
    TOOLS_DIR="$HOME/.osint-tools"
    mkdir -p "$TOOLS_DIR"
    cd "$TOOLS_DIR"
    
    # Install Sherlock
    echo -e "\n${CYAN}[*] Installing Sherlock...${NC}"
    if ! command -v sherlock &> /dev/null; then
        git clone https://github.com/sherlock-project/sherlock.git
        cd sherlock
        pip3 install -r requirements.txt --user
        chmod +x sherlock.py
        ln -sf "$TOOLS_DIR/sherlock/sherlock.py" "$INSTALL_DIR/sherlock"
        cd "$TOOLS_DIR"
        echo -e "${GREEN}[✓] Sherlock installed${NC}"
    else
        echo -e "${GREEN}[✓] Sherlock already installed${NC}"
    fi
    
    # Install Maigret
    echo -e "\n${CYAN}[*] Installing Maigret...${NC}"
    if ! command -v maigret &> /dev/null; then
        pip3 install maigret --user
        echo -e "${GREEN}[✓] Maigret installed${NC}"
    else
        echo -e "${GREEN}[✓] Maigret already installed${NC}"
    fi
    
    # Install Holehe
    echo -e "\n${CYAN}[*] Installing Holehe...${NC}"
    if ! command -v holehe &> /dev/null; then
        pip3 install holehe --user
        echo -e "${GREEN}[✓] Holehe installed${NC}"
    else
        echo -e "${GREEN}[✓] Holehe already installed${NC}"
    fi
    
    # Install Social-Analyzer
    echo -e "\n${CYAN}[*] Installing Social-Analyzer...${NC}"
    if ! command -v social-analyzer &> /dev/null; then
        pip3 install social-analyzer --user
        echo -e "${GREEN}[✓] Social-Analyzer installed${NC}"
    else
        echo -e "${GREEN}[✓] Social-Analyzer already installed${NC}"
    fi
    
    # Install Blackbird (optional)
    echo -e "\n${CYAN}[*] Installing Blackbird...${NC}"
    if [ ! -d "$TOOLS_DIR/blackbird" ]; then
        git clone https://github.com/p1ngul1n0/blackbird
        cd blackbird
        pip3 install -r requirements.txt --user
        chmod +x blackbird.py
        ln -sf "$TOOLS_DIR/blackbird/blackbird.py" "$INSTALL_DIR/blackbird"
        cd "$TOOLS_DIR"
        echo -e "${GREEN}[✓] Blackbird installed${NC}"
    else
        echo -e "${GREEN}[✓] Blackbird already installed${NC}"
    fi
    
    cd "$SCRIPT_DIR"
    
else
    echo -e "${YELLOW}[!] Skipping additional OSINT tools${NC}"
fi

# ============================================================================
# STEP 6: Configure PATH
# ============================================================================
echo -e "\n${CYAN}[STEP 6/6] Configuring PATH...${NC}\n"

if [[ ":$PATH:" == *":$INSTALL_DIR:"* ]]; then
    echo -e "${GREEN}[✓] $INSTALL_DIR is in PATH${NC}"
else
    echo -e "${YELLOW}[!] Adding $INSTALL_DIR to PATH${NC}"
    
    if [ "$GLOBAL_INSTALL" = false ]; then
        SHELL_RC=""
        if [ -n "$BASH_VERSION" ]; then
            SHELL_RC="$HOME/.bashrc"
        elif [ -n "$ZSH_VERSION" ]; then
            SHELL_RC="$HOME/.zshrc"
        else
            if [ -f "$HOME/.bashrc" ]; then
                SHELL_RC="$HOME/.bashrc"
            elif [ -f "$HOME/.zshrc" ]; then
                SHELL_RC="$HOME/.zshrc"
            fi
        fi
        
        if [ -n "$SHELL_RC" ]; then
            if ! grep -q "$INSTALL_DIR" "$SHELL_RC" 2>/dev/null; then
                echo "" >> "$SHELL_RC"
                echo "# WhoisUser OSINT Tool" >> "$SHELL_RC"
                echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$SHELL_RC"
                echo -e "${GREEN}[✓] Added $INSTALL_DIR to PATH in $SHELL_RC${NC}"
            fi
        fi
    fi
fi

# Create investigations directory
mkdir -p "$HOME/investigations"

# ============================================================================
# Installation Complete
# ============================================================================
echo -e "\n${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                               ║${NC}"
echo -e "${GREEN}║              Installation Complete! ✓                         ║${NC}"
echo -e "${GREEN}║                                                               ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}\n"

echo -e "${CYAN}Installed Tools:${NC}"
echo -e "  ${GREEN}✓${NC} WhoisUser (Main Tool)"

# Check which OSINT tools are installed
if command -v sherlock &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Sherlock"
fi
if command -v maigret &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Maigret"
fi
if command -v holehe &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Holehe"
fi
if command -v social-analyzer &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Social-Analyzer"
fi
if command -v blackbird &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Blackbird"
fi

echo -e "\n${CYAN}Usage:${NC}"
echo -e "  ${YELLOW}whoisuser <username>${NC}                    - Full investigation"
echo -e "  ${YELLOW}whoisuser <username> --no-screenshots${NC}   - Skip screenshots"
echo -e "  ${YELLOW}whoisuser <username> --no-osint-tools${NC}   - Skip external OSINT tools"
echo -e ""
echo -e "${CYAN}Examples:${NC}"
echo -e "  ${YELLOW}whoisuser johndoe${NC}"
echo -e "  ${YELLOW}whoisuser hacker123 --no-screenshots${NC}"
echo -e "  ${YELLOW}whoisuser target_user --no-osint-tools${NC}"
echo -e ""
echo -e "${CYAN}Output Location:${NC}"
echo -e "  ${YELLOW}~/investigations/<username>_<timestamp>/${NC}"
echo -e "    ├── FULL_REPORT.txt       (Complete investigation report)"
echo -e "    ├── report.json           (JSON format for parsing)"
echo -e "    ├── all_urls.txt          (All discovered URLs)"
echo -e "    ├── screenshots/          (Profile screenshots)"
echo -e "    └── osint_results/        (External tool results)"
echo -e ""
echo -e "${GREEN}[+] Happy Hunting! 🔍${NC}\n"

# Reload PATH message
if [ "$GLOBAL_INSTALL" = false ] && [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo -e "${YELLOW}[!] To use commands immediately, run:${NC}"
    echo -e "${YELLOW}    source ~/.bashrc${NC}  ${CYAN}(or source ~/.zshrc)${NC}"
    echo -e "${YELLOW}    OR restart your terminal${NC}\n"
fi

echo -e "${CYAN}Tip: WhoisUser automatically detects and uses installed OSINT tools${NC}"
echo -e "${CYAN}     for enhanced username enumeration across 100+ platforms!${NC}\n"
