#!/bin/bash

# ============================================================================
# WhoisUser - Complete OSINT Toolkit Installer
# Author: Anubhav
# Version: 2.6
# Description: Unified installation script for WhoisUser and all OSINT tools
# ============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Banner
clear
echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║       WhoisUser - Complete OSINT Toolkit Installer            ║
║          Professional Username Investigation Tool             ║
║                                                               ║
║                     Version 2.6 - Fixed                       ║
║                   Author: Anubhav                             ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}\n"

# ============================================================================
# CONFIGURATION
# ============================================================================

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
INSTALL_MODE=""
INSTALL_DIR=""
TOOLS_DIR=""
USER_BIN="$HOME/.local/bin"
GLOBAL_BIN="/usr/local/bin"
SKIP_OSINT=false
SKIP_CHROME=false
IS_ROOT=false
PIP_FLAGS=""

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

print_step() {
    echo -e "\n${CYAN}${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║ STEP $1: $2${NC}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════╝${NC}\n"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[*]${NC} $1"
}

print_question() {
    echo -e "${MAGENTA}[?]${NC} $1"
}

command_exists() {
    command -v "$1" &> /dev/null
}

check_root() {
    if [ "$EUID" -eq 0 ]; then
        IS_ROOT=true
        return 0
    else
        IS_ROOT=false
        return 1
    fi
}

# ============================================================================
# DETECT OS AND PACKAGE MANAGER
# ============================================================================

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        OS_VERSION=$VERSION_ID
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS=$DISTRIB_ID
        OS_VERSION=$DISTRIB_RELEASE
    else
        OS=$(uname -s)
        OS_VERSION=$(uname -r)
    fi
    
    print_info "Detected OS: ${BOLD}$OS $OS_VERSION${NC}"
}

# ============================================================================
# CHECK ROOT AND DETERMINE INSTALL MODE
# ============================================================================

setup_install_mode() {
    if check_root; then
        print_warning "Running with root/sudo privileges"
        echo ""
        echo -e "${YELLOW}${BOLD}Choose installation mode:${NC}"
        echo "  ${GREEN}1)${NC} Global installation (recommended) - /usr/local/bin"
        echo "     • Available to all users"
        echo "     • Can install system packages"
        echo "     • Type 'whoisuser' from anywhere"
        echo ""
        echo "  ${GREEN}2)${NC} User installation - ~/.local/bin"
        echo "     • Only for current user"
        echo "     • No system package installation"
        echo ""
        echo -ne "${MAGENTA}Enter choice [1/2] (default: 1):${NC} "
        read -r install_choice
        
        case $install_choice in
            2)
                INSTALL_MODE="user"
                INSTALL_DIR="$USER_BIN"
                TOOLS_DIR="$HOME/.osint-tools"
                PIP_FLAGS="--user"
                print_info "Selected: ${BOLD}User installation${NC}"
                ;;
            *)
                INSTALL_MODE="global"
                INSTALL_DIR="$GLOBAL_BIN"
                TOOLS_DIR="/opt/osint-tools"
                PIP_FLAGS="--break-system-packages"
                print_info "Selected: ${BOLD}Global installation${NC}"
                ;;
        esac
    else
        print_warning "Not running as root - installing in user mode"
        INSTALL_MODE="user"
        INSTALL_DIR="$USER_BIN"
        TOOLS_DIR="$HOME/.osint-tools"
        PIP_FLAGS="--user"
        print_info "Installation directory: ${BOLD}$INSTALL_DIR${NC}"
        echo ""
        print_warning "For global installation with 'whoisuser' command everywhere:"
        echo "  ${YELLOW}Run with sudo:${NC} sudo bash install.sh"
    fi
}

# ============================================================================
# CREATE DIRECTORIES
# ============================================================================

create_directories() {
    print_info "Creating installation directories..."
    mkdir -p "$INSTALL_DIR" 2>/dev/null || sudo mkdir -p "$INSTALL_DIR"
    mkdir -p "$TOOLS_DIR" 2>/dev/null || sudo mkdir -p "$TOOLS_DIR"
    mkdir -p "$HOME/investigations"
    print_success "Directories created"
}

# ============================================================================
# STEP 1: CHECK SYSTEM REQUIREMENTS
# ============================================================================

check_system_requirements() {
    print_step "1/8" "Checking System Requirements"
    
    detect_os
    
    # Check Python
    if command_exists python3; then
        PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
        PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
        PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)
        
        if [ "$PYTHON_MAJOR" -ge 3 ] && [ "$PYTHON_MINOR" -ge 8 ]; then
            print_success "Python3: ${BOLD}$PYTHON_VERSION${NC} ✓"
        else
            print_error "Python 3.8+ required, found: $PYTHON_VERSION"
            echo ""
            print_info "Install Python 3.8+ from: https://www.python.org/downloads/"
            exit 1
        fi
    else
        print_error "Python3 not found"
        echo ""
        echo -e "${YELLOW}Install Python 3.8+ with:${NC}"
        echo "  Ubuntu/Debian: ${CYAN}sudo apt-get install python3 python3-pip${NC}"
        echo "  RHEL/CentOS:   ${CYAN}sudo yum install python3 python3-pip${NC}"
        echo "  Fedora:        ${CYAN}sudo dnf install python3 python3-pip${NC}"
        echo "  Arch:          ${CYAN}sudo pacman -S python python-pip${NC}"
        exit 1
    fi
    
    # Check pip
    if command_exists pip3; then
        PIP_VERSION=$(pip3 --version | awk '{print $2}')
        print_success "pip3: ${BOLD}$PIP_VERSION${NC} ✓"
    else
        print_warning "pip3 not found - installing..."
        python3 -m ensurepip --upgrade 2>/dev/null || {
            if [ "$IS_ROOT" = true ]; then
                apt-get install -y python3-pip 2>/dev/null || \
                yum install -y python3-pip 2>/dev/null || \
                dnf install -y python3-pip 2>/dev/null
            else
                print_error "Cannot install pip3 without root. Please install manually."
                exit 1
            fi
        }
        print_success "pip3 installed"
    fi
    
    # Check git
    if command_exists git; then
        GIT_VERSION=$(git --version | awk '{print $3}')
        print_success "git: ${BOLD}$GIT_VERSION${NC} ✓"
    else
        print_warning "git not found - installing..."
        if [ "$IS_ROOT" = true ]; then
            if [ -f /etc/debian_version ]; then
                apt-get update -qq && apt-get install -y git
            elif [ -f /etc/redhat-release ]; then
                yum install -y git 2>/dev/null || dnf install -y git
            elif [ -f /etc/arch-release ]; then
                pacman -S --noconfirm git
            fi
            print_success "git installed"
        else
            print_error "Cannot install git without root"
            echo "  Install with: ${CYAN}sudo apt-get install git${NC}"
            exit 1
        fi
    fi
    
    # Check curl/wget
    if command_exists curl; then
        print_success "curl: ${BOLD}installed${NC} ✓"
    elif command_exists wget; then
        print_success "wget: ${BOLD}installed${NC} ✓"
    else
        print_warning "curl/wget not found - recommended for downloads"
    fi
    
    echo ""
    print_success "All system requirements satisfied!"
}

# ============================================================================
# STEP 2: INSTALL PYTHON DEPENDENCIES
# ============================================================================

install_python_dependencies() {
    print_step "2/8" "Installing Python Dependencies"
    
    print_info "Installing core dependencies..."
    
    # Core packages
    PACKAGES="requests colorama selenium webdriver-manager urllib3 certifi idna"
    
    if [ -f "$SCRIPT_DIR/requirements.txt" ]; then
        print_info "Using requirements.txt..."
        pip3 install -r "$SCRIPT_DIR/requirements.txt" --upgrade $PIP_FLAGS 2>&1 | \
            grep -E "Successfully installed|Requirement already satisfied|Installing collected packages" || true
    else
        print_info "Installing packages individually..."
        for pkg in $PACKAGES; do
            echo -ne "  Installing ${CYAN}$pkg${NC}..."
            pip3 install $pkg --upgrade $PIP_FLAGS --quiet && echo -e " ${GREEN}✓${NC}" || echo -e " ${YELLOW}⚠${NC}"
        done
    fi
    
    echo ""
    
    # Verify installations
    print_info "Verifying Python packages..."
    python3 -c "import requests; print('  ✓ requests')" 2>/dev/null && print_success "requests" || print_error "requests failed"
    python3 -c "import colorama; print('  ✓ colorama')" 2>/dev/null && print_success "colorama" || print_error "colorama failed"
    python3 -c "import selenium; print('  ✓ selenium')" 2>/dev/null && print_success "selenium" || print_error "selenium failed"
    
    echo ""
    print_success "Python dependencies installed successfully!"
}

# ============================================================================
# STEP 3: INSTALL CHROME/CHROMIUM FOR SCREENSHOTS
# ============================================================================

install_chrome() {
    print_step "3/8" "Checking Chrome/Chromium for Screenshots"
    
    if command_exists google-chrome || command_exists chromium-browser || command_exists chromium; then
        CHROME_VERSION=$(google-chrome --version 2>/dev/null || chromium-browser --version 2>/dev/null || chromium --version 2>/dev/null || echo "Unknown")
        print_success "Chrome/Chromium: ${BOLD}$CHROME_VERSION${NC} ✓"
        
        # Check ChromeDriver
        if command_exists chromedriver; then
            DRIVER_VERSION=$(chromedriver --version 2>/dev/null | awk '{print $2}' || echo "Unknown")
            print_success "ChromeDriver: ${BOLD}$DRIVER_VERSION${NC} ✓"
        else
            print_info "ChromeDriver will be auto-downloaded by webdriver-manager"
        fi
    else
        echo ""
        print_warning "Chrome/Chromium not found"
        echo -e "${YELLOW}Chrome is required for automatic screenshot capture${NC}"
        echo ""
        echo -ne "${MAGENTA}Install Chromium now? (y/n) [default: y]:${NC} "
        read -r install_chrome_choice
        
        if [[ $install_chrome_choice != "n" && $install_chrome_choice != "N" ]]; then
            if [ "$IS_ROOT" = true ]; then
                print_info "Installing Chromium..."
                if [ -f /etc/debian_version ]; then
                    apt-get update -qq && apt-get install -y chromium-browser chromium-chromedriver 2>/dev/null || \
                    apt-get install -y chromium chromium-driver 2>/dev/null
                elif [ -f /etc/redhat-release ]; then
                    dnf install -y chromium chromedriver 2>/dev/null || \
                    yum install -y chromium chromedriver 2>/dev/null
                elif [ -f /etc/arch-release ]; then
                    pacman -S --noconfirm chromium
                fi
                
                if command_exists chromium-browser || command_exists chromium; then
                    print_success "Chromium installed successfully!"
                else
                    print_warning "Chromium installation may have failed"
                    SKIP_CHROME=true
                fi
            else
                print_error "Root privileges required to install Chromium"
                echo ""
                print_info "Install manually with:"
                echo "  Ubuntu/Debian: ${CYAN}sudo apt-get install chromium-browser${NC}"
                echo "  Fedora/RHEL:   ${CYAN}sudo dnf install chromium${NC}"
                echo "  Arch:          ${CYAN}sudo pacman -S chromium${NC}"
                SKIP_CHROME=true
            fi
        else
            print_warning "Skipping Chromium installation"
            print_info "Screenshots will be disabled"
            SKIP_CHROME=true
        fi
    fi
    
    echo ""
    if [ "$SKIP_CHROME" = false ]; then
        print_success "Chrome/Chromium setup complete!"
    else
        print_warning "Screenshots disabled - install Chrome to enable"
    fi
}

# ============================================================================
# STEP 4: INSTALL WHOISUSER MAIN TOOL
# ============================================================================

install_whoisuser() {
    print_step "4/8" "Installing WhoisUser Main Tool"
    
    if [ ! -f "$SCRIPT_DIR/whoisuser.py" ]; then
        print_error "whoisuser.py not found in $SCRIPT_DIR"
        echo ""
        print_info "Please ensure whoisuser.py is in the same directory as install.sh"
        exit 1
    fi
    
    print_info "Installing WhoisUser to ${BOLD}$INSTALL_DIR${NC}..."
    
    # Copy and setup
    if [ "$IS_ROOT" = true ] && [ "$INSTALL_MODE" = "global" ]; then
        cp "$SCRIPT_DIR/whoisuser.py" "$INSTALL_DIR/whoisuser"
        chmod +x "$INSTALL_DIR/whoisuser"
    else
        mkdir -p "$INSTALL_DIR"
        cp "$SCRIPT_DIR/whoisuser.py" "$INSTALL_DIR/whoisuser"
        chmod +x "$INSTALL_DIR/whoisuser"
    fi
    
    # Ensure proper shebang
    if ! head -n 1 "$INSTALL_DIR/whoisuser" | grep -q "^#!/"; then
        echo "#!/usr/bin/env python3" | cat - "$INSTALL_DIR/whoisuser" > "$INSTALL_DIR/whoisuser.tmp"
        mv "$INSTALL_DIR/whoisuser.tmp" "$INSTALL_DIR/whoisuser"
        chmod +x "$INSTALL_DIR/whoisuser"
    fi
    
    # Verify installation
    if [ -f "$INSTALL_DIR/whoisuser" ] && [ -x "$INSTALL_DIR/whoisuser" ]; then
        print_success "WhoisUser installed: ${BOLD}$INSTALL_DIR/whoisuser${NC}"
        
        # Create symlink for 'whois' command if root
        if [ "$IS_ROOT" = true ] && [ "$INSTALL_MODE" = "global" ]; then
            if [ ! -f "$INSTALL_DIR/whois" ]; then
                ln -sf "$INSTALL_DIR/whoisuser" "$INSTALL_DIR/whois"
                print_success "Created alias: ${BOLD}whois${NC} → ${BOLD}whoisuser${NC}"
            fi
        fi
    else
        print_error "WhoisUser installation failed"
        exit 1
    fi
    
    echo ""
    print_success "WhoisUser main tool installed successfully!"
}

# ============================================================================
# STEP 5: INSTALL OSINT TOOLS
# ============================================================================

install_osint_tools() {
    print_step "5/8" "Installing Additional OSINT Tools"
    
    echo -e "${YELLOW}Additional OSINT tools enhance username enumeration:${NC}"
    echo "  • Sherlock    - Username search across 300+ sites"
    echo "  • Maigret     - Advanced username OSINT"
    echo "  • Holehe      - Email account enumeration"
    echo "  • Blackbird   - Fast username search"
    echo ""
    echo -ne "${MAGENTA}Install OSINT tools? (y/n) [default: y]:${NC} "
    read -r install_osint_choice
    
    if [[ $install_osint_choice == "n" || $install_osint_choice == "N" ]]; then
        print_warning "Skipping OSINT tools installation"
        SKIP_OSINT=true
        return
    fi
    
    # Create tools directory
    if [ "$IS_ROOT" = true ] && [ "$INSTALL_MODE" = "global" ]; then
        mkdir -p "$TOOLS_DIR"
    else
        mkdir -p "$TOOLS_DIR"
    fi
    
    cd "$TOOLS_DIR"
    
    echo ""
    
    # ========================================
    # Install Sherlock
    # ========================================
    print_info "Installing ${BOLD}Sherlock${NC}..."
    if command_exists sherlock && [ -x "$(command -v sherlock)" ]; then
        print_success "Sherlock already installed"
    else
        if [ -d "$TOOLS_DIR/sherlock" ]; then
            print_info "Updating existing Sherlock..."
            cd "$TOOLS_DIR/sherlock"
            git pull -q origin master 2>&1 | grep -v "Already up to date" || true
            cd "$TOOLS_DIR"
        else
            git clone -q https://github.com/sherlock-project/sherlock.git 2>&1 | grep -v "Cloning" || true
            cd sherlock
            pip3 install -r requirements.txt $PIP_FLAGS --quiet 2>&1 | grep -v "Requirement already satisfied" || true
            chmod +x sherlock.py
            cd "$TOOLS_DIR"
        fi
        
        # Create executable wrapper
        cat > "$INSTALL_DIR/sherlock" << 'SHERLOCK_EOF'
#!/bin/bash
SHERLOCK_DIR="TOOLS_DIR_PLACEHOLDER/sherlock"
python3 "$SHERLOCK_DIR/sherlock.py" "$@"
SHERLOCK_EOF
        
        sed -i "s|TOOLS_DIR_PLACEHOLDER|$TOOLS_DIR|g" "$INSTALL_DIR/sherlock"
        chmod +x "$INSTALL_DIR/sherlock"
        
        if [ -x "$INSTALL_DIR/sherlock" ]; then
            print_success "Sherlock installed: ${BOLD}sherlock${NC} command available"
        else
            print_warning "Sherlock installed but may need PATH update"
        fi
    fi
    
    # ========================================
    # Install Maigret
    # ========================================
    echo ""
    print_info "Installing ${BOLD}Maigret${NC}..."
    if command_exists maigret; then
        print_success "Maigret already installed"
    else
        pip3 install maigret $PIP_FLAGS --quiet 2>&1 | grep -v "Requirement already satisfied" || true
        
        if command_exists maigret || [ -f "$HOME/.local/bin/maigret" ]; then
            print_success "Maigret installed: ${BOLD}maigret${NC} command available"
        else
            print_warning "Maigret installed but may need PATH update"
        fi
    fi
    
    # ========================================
    # Install Holehe
    # ========================================
    echo ""
    print_info "Installing ${BOLD}Holehe${NC}..."
    if command_exists holehe; then
        print_success "Holehe already installed"
    else
        pip3 install holehe $PIP_FLAGS --quiet 2>&1 | grep -v "Requirement already satisfied" || true
        
        if command_exists holehe || [ -f "$HOME/.local/bin/holehe" ]; then
            print_success "Holehe installed: ${BOLD}holehe${NC} command available"
        else
            print_warning "Holehe installed but may need PATH update"
        fi
    fi
    
    # ========================================
    # Install Blackbird
    # ========================================
    echo ""
    print_info "Installing ${BOLD}Blackbird${NC}..."
    if [ -d "$TOOLS_DIR/blackbird" ]; then
        print_info "Updating existing Blackbird..."
        cd "$TOOLS_DIR/blackbird"
        git pull -q origin main 2>&1 | grep -v "Already up to date" || true
        cd "$TOOLS_DIR"
    else
        git clone -q https://github.com/p1ngul1n0/blackbird.git 2>&1 | grep -v "Cloning" || true
        cd blackbird
        pip3 install -r requirements.txt $PIP_FLAGS --quiet 2>&1 | grep -v "Requirement already satisfied" || true
        chmod +x blackbird.py
        cd "$TOOLS_DIR"
    fi
    
    # Create executable wrapper
    cat > "$INSTALL_DIR/blackbird" << 'BLACKBIRD_EOF'
#!/bin/bash
BLACKBIRD_DIR="TOOLS_DIR_PLACEHOLDER/blackbird"
python3 "$BLACKBIRD_DIR/blackbird.py" "$@"
BLACKBIRD_EOF
    
    sed -i "s|TOOLS_DIR_PLACEHOLDER|$TOOLS_DIR|g" "$INSTALL_DIR/blackbird"
    chmod +x "$INSTALL_DIR/blackbird"
    
    if [ -x "$INSTALL_DIR/blackbird" ]; then
        print_success "Blackbird installed: ${BOLD}blackbird${NC} command available"
    else
        print_warning "Blackbird installed but may need PATH update"
    fi
    
    # ========================================
    # Optional: Social-Analyzer
    # ========================================
    echo ""
    echo -ne "${MAGENTA}Install Social-Analyzer? (larger tool) (y/n) [default: n]:${NC} "
    read -r install_social_choice
    
    if [[ $install_social_choice == "y" || $install_social_choice == "Y" ]]; then
        print_info "Installing ${BOLD}Social-Analyzer${NC}..."
        pip3 install social-analyzer $PIP_FLAGS --quiet 2>&1 | grep -v "Requirement already satisfied" || true
        
        if command_exists social-analyzer; then
            print_success "Social-Analyzer installed"
        fi
    fi
    
    cd "$SCRIPT_DIR"
    
    echo ""
    print_success "OSINT tools installation complete!"
}

# ============================================================================
# STEP 6: CONFIGURE PATH
# ============================================================================

configure_path() {
    print_step "6/8" "Configuring PATH Environment"
    
    if [ "$INSTALL_MODE" = "global" ]; then
        print_success "Global installation - commands available system-wide"
        return
    fi
    
    # User mode - need to configure PATH
    print_info "Checking PATH configuration..."
    
    if [[ ":$PATH:" == *":$INSTALL_DIR:"* ]]; then
        print_success "$INSTALL_DIR is already in PATH"
    else
        print_warning "$INSTALL_DIR not in PATH - configuring..."
        
        # Detect shell
        SHELL_RC=""
        SHELL_NAME=$(basename "$SHELL")
        
        case "$SHELL_NAME" in
            bash)
                SHELL_RC="$HOME/.bashrc"
                ;;
            zsh)
                SHELL_RC="$HOME/.zshrc"
                ;;
            fish)
                SHELL_RC="$HOME/.config/fish/config.fish"
                ;;
            *)
                if [ -f "$HOME/.bashrc" ]; then
                    SHELL_RC="$HOME/.bashrc"
                elif [ -f "$HOME/.zshrc" ]; then
                    SHELL_RC="$HOME/.zshrc"
                elif [ -f "$HOME/.profile" ]; then
                    SHELL_RC="$HOME/.profile"
                fi
                ;;
        esac
        
        if [ -n "$SHELL_RC" ]; then
            # Backup shell config
            cp "$SHELL_RC" "$SHELL_RC.backup_$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
            
            # Check if already configured
            if ! grep -q "$INSTALL_DIR" "$SHELL_RC" 2>/dev/null; then
                echo "" >> "$SHELL_RC"
                echo "# WhoisUser OSINT Tool - Added by installer $(date +%Y-%m-%d)" >> "$SHELL_RC"
                echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$SHELL_RC"
                
                # Also add .local/bin if not present
                if [[ "$INSTALL_DIR" == *".local/bin"* ]] && ! grep -q "\$HOME/.local/bin" "$SHELL_RC"; then
                    echo "export PATH=\"\$PATH:\$HOME/.local/bin\"" >> "$SHELL_RC"
                fi
                
                print_success "PATH configured in $SHELL_RC"
            else
                print_info "PATH already configured in $SHELL_RC"
            fi
        else
            print_warning "Could not detect shell configuration file"
            print_info "Manually add to your shell RC file:"
            echo "  ${CYAN}export PATH=\"\$PATH:$INSTALL_DIR\"${NC}"
        fi
    fi
    
    # Export for current session
    export PATH="$PATH:$INSTALL_DIR"
    export PATH="$PATH:$HOME/.local/bin"
    
    echo ""
    print_success "PATH configuration complete!"
}

# ============================================================================
# STEP 7: CREATE DESKTOP SHORTCUT (Optional)
# ============================================================================

create_desktop_entry() {
    print_step "7/8" "Creating Desktop Integration"
    
    if [ "$INSTALL_MODE" != "global" ]; then
        print_info "Desktop integration only for global installations"
        return
    fi
    
    echo -ne "${MAGENTA}Create desktop application entry? (y/n) [default: n]:${NC} "
    read -r create_desktop
    
    if [[ $create_desktop != "y" && $create_desktop != "Y" ]]; then
        print_info "Skipping desktop integration"
        return
    fi
    
    DESKTOP_FILE="/usr/share/applications/whoisuser.desktop"
    
    cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=WhoisUser
Comment=Professional Username OSINT Investigation Tool
Exec=x-terminal-emulator -e whoisuser %u
Icon=utilities-terminal
Terminal=true
Type=Application
Categories=System;Security;Network;
Keywords=osint;investigation;username;forensics;
EOF
    
    chmod 644 "$DESKTOP_FILE"
    print_success "Desktop entry created: Applications → WhoisUser"
}

# ============================================================================
# STEP 8: VERIFY INSTALLATION
# ============================================================================

verify_installation() {
    print_step "8/8" "Verifying Installation"
    
    ISSUES=0
    
    # Test WhoisUser
    print_info "Testing WhoisUser..."
    if [ -x "$INSTALL_DIR/whoisuser" ]; then
        print_success "WhoisUser executable: ${BOLD}✓${NC}"
    else
        print_error "WhoisUser not properly installed"
        ((ISSUES++))
    fi
    
    # Test Python dependencies
    print_info "Testing Python dependencies..."
    if python3 -c "import requests, colorama, selenium" 2>/dev/null; then
        print_success "Python dependencies: ${BOLD}✓${NC}"
    else
        print_warning "Some Python dependencies may be missing"
        ((ISSUES++))
    fi
    
    # Test PATH
    print_info "Testing PATH configuration..."
    if command_exists whoisuser || [ -x "$INSTALL_DIR/whoisuser" ]; then
        print_success "WhoisUser in PATH: ${BOLD}✓${NC}"
    else
        print_warning "WhoisUser may not be in PATH"
    fi
    
    # Count OSINT tools
    echo ""
    print_info "Installed OSINT Tools:"
    OSINT_COUNT=0
    
    if command_exists sherlock || [ -x "$INSTALL_DIR/sherlock" ]; then
        echo "  ${GREEN}✓${NC} Sherlock"
        ((OSINT_COUNT++))
    fi
    if command_exists maigret; then
        echo "  ${GREEN}✓${NC} Maigret"
        ((OSINT_COUNT++))
    fi
    if command_exists holehe; then
        echo "  ${GREEN}✓${NC} Holehe"
        ((OSINT_COUNT++))
    fi
    if command_exists blackbird || [ -x "$INSTALL_DIR/blackbird" ]; then
        echo "  ${GREEN}✓${NC} Blackbird"
        ((OSINT_COUNT++))
    fi
    if command_exists social-analyzer; then
        echo "  ${GREEN}✓${NC} Social-Analyzer"
        ((OSINT_COUNT++))
    fi
    
    if [ $OSINT_COUNT -eq 0 ]; then
        echo "  ${YELLOW}⚠${NC} None installed - WhoisUser will use built-in scanner only"
    fi
    
    echo ""
    
    if [ $ISSUES -eq 0 ]; then
        print_success "All verification checks passed! ${BOLD}✓${NC}"
    else
        print_warning "$ISSUES issue(s) detected - see above"
    fi
}

# ============================================================================
# DISPLAY FINAL INSTRUCTIONS
# ============================================================================

show_final_instructions() {
    echo ""
    echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║                                                            ║${NC}"
    echo -e "${CYAN}${BOLD}║              Installation Complete! 🎉                     ║${NC}"
    echo -e "${CYAN}${BOLD}║                                                            ║${NC}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${GREEN}${BOLD}Installation Summary:${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${BOLD}Installation Mode:${NC}    $INSTALL_MODE"
    echo -e "  ${BOLD}Installation Path:${NC}    $INSTALL_DIR"
    echo -e "  ${BOLD}Tools Directory:${NC}      $TOOLS_DIR"
    echo ""
    
    if [ "$INSTALL_MODE" = "global" ]; then
        echo -e "${GREEN}${BOLD}Quick Start (Global Installation):${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "  ${CYAN}whoisuser <username>${NC}          - Basic username search"
        echo -e "  ${CYAN}whoisuser <username> -v${NC}       - Verbose output"
        echo -e "  ${CYAN}whoisuser <username> -s${NC}       - Save screenshots"
        echo -e "  ${CYAN}whoisuser <username> -o report${NC} - Save to custom file"
        echo -e "  ${CYAN}whoisuser --help${NC}              - Show all options"
        echo ""
    else
        echo -e "${YELLOW}${BOLD}Important: Reload your shell configuration!${NC}"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "  Run one of these commands to use WhoisUser immediately:"
        echo ""
        
        SHELL_NAME=$(basename "$SHELL")
        case "$SHELL_NAME" in
            bash)
                echo -e "    ${CYAN}source ~/.bashrc${NC}"
                ;;
            zsh)
                echo -e "    ${CYAN}source ~/.zshrc${NC}"
                ;;
            fish)
                echo -e "    ${CYAN}source ~/.config/fish/config.fish${NC}"
                ;;
            *)
                echo -e "    ${CYAN}source ~/.bashrc${NC}  or  ${CYAN}source ~/.zshrc${NC}"
                ;;
        esac
        
        echo ""
        echo -e "  ${YELLOW}Or simply close and reopen your terminal${NC}"
        echo ""
        echo -e "${GREEN}${BOLD}Quick Start (After Reload):${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "  ${CYAN}whoisuser <username>${NC}          - Basic username search"
        echo -e "  ${CYAN}whoisuser <username> -v${NC}       - Verbose output"
        echo -e "  ${CYAN}whoisuser <username> -s${NC}       - Save screenshots"
        echo -e "  ${CYAN}whoisuser <username> -o report${NC} - Save to custom file"
        echo ""
    fi
    
    echo -e "${BLUE}${BOLD}Additional OSINT Tools:${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    if [ "$SKIP_OSINT" = false ]; then
        if command_exists sherlock || [ -x "$INSTALL_DIR/sherlock" ]; then
            echo -e "  ${CYAN}sherlock <username>${NC}        - Search 300+ platforms"
        fi
        if command_exists maigret; then
            echo -e "  ${CYAN}maigret <username>${NC}         - Advanced OSINT collection"
        fi
        if command_exists holehe; then
            echo -e "  ${CYAN}holehe <email>${NC}             - Email account enumeration"
        fi
        if command_exists blackbird || [ -x "$INSTALL_DIR/blackbird" ]; then
            echo -e "  ${CYAN}blackbird -u <username>${NC}    - Fast username scanning"
        fi
        if command_exists social-analyzer; then
            echo -e "  ${CYAN}social-analyzer${NC}            - Social media analysis"
        fi
    else
        echo -e "  ${YELLOW}No additional tools installed${NC}"
        echo -e "  ${YELLOW}Re-run installer to add OSINT tools${NC}"
    fi
    
    echo ""
    echo -e "${MAGENTA}${BOLD}Usage Examples:${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${GREEN}# Basic search${NC}"
    echo -e "  ${CYAN}whoisuser john_doe${NC}"
    echo ""
    echo -e "  ${GREEN}# Detailed scan with screenshots${NC}"
    echo -e "  ${CYAN}whoisuser john_doe -v -s${NC}"
    echo ""
    echo -e "  ${GREEN}# Search multiple platforms${NC}"
    echo -e "  ${CYAN}whoisuser john_doe --platforms github,twitter,instagram${NC}"
    echo ""
    echo -e "  ${GREEN}# Export results${NC}"
    echo -e "  ${CYAN}whoisuser john_doe -o investigation_report.txt${NC}"
    echo ""
    echo -e "  ${GREEN}# Batch investigation${NC}"
    echo -e "  ${CYAN}whoisuser -f usernames.txt -o batch_results${NC}"
    echo ""
    
    echo -e "${YELLOW}${BOLD}Files & Directories:${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${BOLD}Executable:${NC}           $INSTALL_DIR/whoisuser"
    echo -e "  ${BOLD}Tools:${NC}                $TOOLS_DIR/"
    echo -e "  ${BOLD}Output:${NC}               ~/investigations/"
    echo -e "  ${BOLD}Screenshots:${NC}          ~/investigations/screenshots/"
    echo ""
    
    if [ "$SKIP_CHROME" = true ]; then
        echo -e "${YELLOW}${BOLD}⚠ Note:${NC}"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "  Chrome/Chromium not installed - screenshots disabled"
        echo -e "  Install Chrome to enable automatic screenshot capture"
        echo ""
    fi
    
    # echo -e "${CYAN}${BOLD}Documentation & Support:${NC}"
    # echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    # echo ""
    # echo -e "  ${BOLD}Help:${NC}                 ${CYAN}whoisuser --help${NC}"
    # echo -e "  ${BOLD}Version:${NC}              ${CYAN}whoisuser --version${NC}"
    # echo -e "  ${BOLD}List Platforms:${NC}       ${CYAN}whoisuser --list-platforms${NC}"
    echo ""
    
    echo -e "${GREEN}${BOLD}Legal & Ethical Use:${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${YELLOW}⚠${NC}  This tool is for ${BOLD}legal OSINT investigations only${NC}"
    echo -e "  ${YELLOW}⚠${NC}  Always respect privacy laws and terms of service"
    echo -e "  ${YELLOW}⚠${NC}  Obtain proper authorization for investigations"
    echo -e "  ${YELLOW}⚠${NC}  The author is not responsible for misuse"
    echo ""
    
    echo -e "${BLUE}${BOLD}Troubleshooting:${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${BOLD}Command not found?${NC}"
    
    if [ "$INSTALL_MODE" = "user" ]; then
        SHELL_NAME=$(basename "$SHELL")
        case "$SHELL_NAME" in
            bash)
                echo -e "    Run: ${CYAN}source ~/.bashrc${NC}"
                ;;
            zsh)
                echo -e "    Run: ${CYAN}source ~/.zshrc${NC}"
                ;;
            *)
                echo -e "    Reload your shell or restart terminal"
                ;;
        esac
    else
        echo -e "    Ensure ${CYAN}/usr/local/bin${NC} is in your PATH"
    fi
    
    echo ""
    echo -e "  ${BOLD}Python errors?${NC}"
    echo -e "    Reinstall dependencies: ${CYAN}pip3 install -r requirements.txt${NC}"
    echo ""
    echo -e "  ${BOLD}Permission denied?${NC}"
    echo -e "    Check executable: ${CYAN}chmod +x $INSTALL_DIR/whoisuser${NC}"
    echo ""
    
    echo -e "${MAGENTA}${BOLD}Updates & Uninstall:${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${BOLD}Update WhoisUser:${NC}"
    echo -e "    Re-run: ${CYAN}sudo bash install.sh${NC} (or ${CYAN}bash install.sh${NC} for user mode)"
    echo ""
    echo -e "  ${BOLD}Uninstall:${NC}"
    if [ "$INSTALL_MODE" = "global" ]; then
        echo -e "    ${CYAN}sudo rm -f $INSTALL_DIR/whoisuser $INSTALL_DIR/whois${NC}"
        echo -e "    ${CYAN}sudo rm -rf $TOOLS_DIR${NC}"
    else
        echo -e "    ${CYAN}rm -f $INSTALL_DIR/whoisuser${NC}"
        echo -e "    ${CYAN}rm -rf $TOOLS_DIR${NC}"
    fi
    echo ""
    
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                            ║${NC}"
    echo -e "${CYAN}║         ${BOLD}Happy Investigating! Stay Legal! 🔍${NC}${CYAN}              ║${NC}"
    echo -e "${CYAN}║                                                            ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ============================================================================
# CLEANUP FUNCTION
# ============================================================================

cleanup_on_error() {
    echo ""
    print_error "Installation failed!"
    echo ""
    print_info "Cleaning up partial installation..."
    
    # Don't remove directories if they existed before
    if [ -f "$INSTALL_DIR/whoisuser" ]; then
        rm -f "$INSTALL_DIR/whoisuser" 2>/dev/null
    fi
    
    echo ""
    print_info "Please check the error messages above and try again"
    print_info "For support, ensure you have:"
    echo "  • Python 3.8+"
    echo "  • pip3"
    echo "  • git"
    echo "  • Internet connection"
    echo ""
    exit 1
}

# ============================================================================
# MAIN INSTALLATION FLOW
# ============================================================================

main() {
    # Set up error handling
    trap cleanup_on_error ERR
    
    # Introduction
    echo -e "${BOLD}Welcome to WhoisUser OSINT Toolkit Installer${NC}"
    echo ""
    echo -e "This installer will set up:"
    echo "  ${GREEN}✓${NC} WhoisUser - Professional username investigation tool"
    echo "  ${GREEN}✓${NC} Python dependencies (requests, selenium, etc.)"
    echo "  ${GREEN}✓${NC} Optional: Chrome/Chromium for screenshots"
    echo "  ${GREEN}✓${NC} Optional: Additional OSINT tools (Sherlock, Maigret, etc.)"
    echo ""
    
    # Check and setup installation mode
    setup_install_mode
    echo ""
    
    # Create directories
    create_directories
    
    # Run installation steps
    check_system_requirements
    install_python_dependencies
    install_chrome
    install_whoisuser
    install_osint_tools
    configure_path
    create_desktop_entry
    verify_installation
    
    # Show final instructions
    show_final_instructions
}

# ============================================================================
# SCRIPT ENTRY POINT
# ============================================================================

# Check if script is being sourced or executed
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
else
    echo "This script should be executed, not sourced"
    echo "Run: bash install.sh"
fi
