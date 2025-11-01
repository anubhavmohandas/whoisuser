#!/bin/bash

# ============================================================================
# WhoisUser - Interactive OSINT Toolkit Installer
# Author: Anubhav
# Version: 2.7 OPTIMIZED - Cross-Platform Compatible
# Purpose: Educational OSINT & Forensic Research
# Compatible: Ubuntu, Debian, Kali Linux, Parrot OS, Arch, Fedora, RHEL
# ============================================================================

set -e

# ============================================================================
# COLORS & STYLING
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'

BRED='\033[1;31m'
BGREEN='\033[1;32m'
BYELLOW='\033[1;33m'
BBLUE='\033[1;34m'
BMAGENTA='\033[1;35m'
BCYAN='\033[1;36m'

BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ============================================================================
# GLOBAL VARIABLES
# ============================================================================

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
INSTALL_MODE=""
INSTALL_DIR=""
TOOLS_DIR=""
USER_BIN="$HOME/.local/bin"
GLOBAL_BIN="/usr/local/bin"
IS_ROOT=false
PIP_FLAGS=""
SKIP_OSINT=false
SKIP_CHROME=false
INSTALL_COUNT=0
OS_TYPE=""
PKG_MANAGER=""

# ============================================================================
# DISPLAY FUNCTIONS
# ============================================================================

clear_screen() {
    clear
    echo ""
}

print_banner() {
    clear_screen
    echo -e "${BCYAN}"
    cat << 'EOF'
    ╦ ╦╦ ╦╔═╗╦╔═╗╦ ╦╔═╗╔═╗╦═╗
    ║║║╠═╣║ ║║╚═╗║ ║╚═╗║╣ ╠╦╝
    ╚╩╝╩ ╩╚═╝╩╚═╝╚═╝╚═╝╚═╝╩╚═
         OSINT TOOLKIT
EOF
    echo -e "${NC}"
    echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}     Professional Username Investigation Tool${NC}"
    echo -e "${GRAY}     Version 2.7 OPTIMIZED | Educational Purpose Only${NC}"
    echo -e "${GRAY}     Author: Anubhav | Cyber Forensic Research${NC}"
    echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_success() {
    echo -e "${BGREEN}  ✓${NC} ${WHITE}$1${NC}"
}

print_error() {
    echo -e "${BRED}  ✗${NC} ${WHITE}$1${NC}"
}

print_warning() {
    echo -e "${BYELLOW}  ⚠${NC} ${WHITE}$1${NC}"
}

print_info() {
    echo -e "${BCYAN}  ➜${NC} ${WHITE}$1${NC}"
}

print_question() {
    echo -ne "${BMAGENTA}  ?${NC} ${WHITE}$1${NC} "
}

print_step() {
    echo ""
    echo -e "${BCYAN}╭─────────────────────────────────────────────────────────╮${NC}"
    echo -e "${BCYAN}│${NC} ${BGREEN}[$1]${NC} ${WHITE}$2${NC}"
    echo -e "${BCYAN}╰─────────────────────────────────────────────────────────╯${NC}"
    echo ""
}

print_box() {
    local title="$1"
    echo -e "${BCYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BCYAN}║${NC}  ${WHITE}${BOLD}$title${NC}"
    echo -e "${BCYAN}╚══════════════════════════════════════════════════════════╝${NC}"
}

loading_animation() {
    local duration=$1
    local msg=$2
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local end=$((SECONDS + duration))
    
    while [ $SECONDS -lt $end ]; do
        for frame in "${frames[@]}"; do
            echo -ne "\r${BCYAN}  $frame${NC} ${WHITE}$msg${NC}"
            sleep 0.1
            [ $SECONDS -ge $end ] && break
        done
    done
    echo -ne "\r${BGREEN}  ✓${NC} ${WHITE}$msg${NC}\n"
}

# ============================================================================
# SYSTEM DETECTION
# ============================================================================

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

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_TYPE=$ID
        
        case $OS_TYPE in
            ubuntu|debian|kali|parrot)
                PKG_MANAGER="apt"
                ;;
            fedora|rhel|centos)
                PKG_MANAGER="dnf"
                [ ! -x "$(command -v dnf)" ] && PKG_MANAGER="yum"
                ;;
            arch|manjaro)
                PKG_MANAGER="pacman"
                ;;
            *)
                PKG_MANAGER="apt"
                ;;
        esac
    else
        OS_TYPE="unknown"
        PKG_MANAGER="apt"
    fi
}

# ============================================================================
# WELCOME SCREEN
# ============================================================================

show_welcome() {
    print_banner
    
    echo -e "${BMAGENTA}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BMAGENTA}║${NC}  ${WHITE}${BOLD}Welcome to WhoisUser Installation Wizard${NC}            ${BMAGENTA}║${NC}"
    echo -e "${BMAGENTA}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}This installer will set up:${NC}"
    echo ""
    echo -e "${BGREEN}  ✓${NC} WhoisUser Core Tool       ${GRAY}(100+ platform scanner)${NC}"
    echo -e "${BGREEN}  ✓${NC} Python Dependencies       ${GRAY}(requests, colorama, selenium)${NC}"
    echo -e "${BGREEN}  ✓${NC} Chrome/Chromium           ${GRAY}(Screenshot capture)${NC}"
    echo -e "${BGREEN}  ✓${NC} OSINT Tools Suite         ${GRAY}(Sherlock, Maigret, Holehe, Blackbird)${NC}"
    echo ""
    echo -e "${BYELLOW}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BYELLOW}║${NC}  ${BRED}⚠  EDUCATIONAL PURPOSE ONLY${NC}                          ${BYELLOW}║${NC}"
    echo -e "${BYELLOW}║${NC}     ${WHITE}For authorized security research & forensics${NC}       ${BYELLOW}║${NC}"
    echo -e "${BYELLOW}║${NC}     ${WHITE}Always obtain proper authorization${NC}                ${BYELLOW}║${NC}"
    echo -e "${BYELLOW}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    print_question "Ready to begin installation? (y/n):"
    read -r response
    
    if [[ ! $response =~ ^[Yy]$ ]]; then
        echo ""
        print_warning "Installation cancelled by user"
        exit 0
    fi
}

# ============================================================================
# INSTALLATION MODE SELECTION
# ============================================================================

select_install_mode() {
    print_banner
    print_box "INSTALLATION MODE"
    echo ""
    
    detect_os
    print_info "Detected OS: ${BCYAN}$OS_TYPE${NC} | Package Manager: ${BCYAN}$PKG_MANAGER${NC}"
    echo ""
    
    if check_root; then
        print_success "Running with sudo/root privileges"
        echo ""
        echo -e "${WHITE}Choose installation type:${NC}"
        echo ""
        echo -e "${BGREEN}  [1]${NC} ${WHITE}Global Installation${NC} ${GRAY}(recommended)${NC}"
        echo -e "      ${GRAY}→ Install to /usr/local/bin${NC}"
        echo -e "      ${GRAY}→ Available to all users${NC}"
        echo -e "      ${GRAY}→ Type 'whoisuser' from anywhere${NC}"
        echo ""
        echo -e "${BYELLOW}  [2]${NC} ${WHITE}User Installation${NC}"
        echo -e "      ${GRAY}→ Install to ~/.local/bin${NC}"
        echo -e "      ${GRAY}→ Only for current user${NC}"
        echo ""
        
        while true; do
            print_question "Enter choice [1-2] (default: 1):"
            read -r choice
            
            case ${choice:-1} in
                1)
                    INSTALL_MODE="global"
                    INSTALL_DIR="$GLOBAL_BIN"
                    TOOLS_DIR="/opt/osint-tools"
                    print_success "Selected: Global Installation"
                    break
                    ;;
                2)
                    INSTALL_MODE="user"
                    INSTALL_DIR="$USER_BIN"
                    TOOLS_DIR="$HOME/.osint-tools"
                    PIP_FLAGS="--user"
                    print_success "Selected: User Installation"
                    break
                    ;;
                *)
                    print_error "Invalid choice. Please enter 1 or 2."
                    ;;
            esac
        done
    else
        print_warning "Not running as root - using User Installation"
        INSTALL_MODE="user"
        INSTALL_DIR="$USER_BIN"
        TOOLS_DIR="$HOME/.osint-tools"
        PIP_FLAGS="--user"
        echo ""
        print_info "For global installation, run: ${BCYAN}sudo bash install.sh${NC}"
    fi
    
    sleep 1
}

# ============================================================================
# CHECK SYSTEM REQUIREMENTS
# ============================================================================

check_requirements() {
    print_banner
    print_step "1/6" "Checking System Requirements"
    
    local all_good=true
    
    # Python
    echo -e "${WHITE}Checking Python...${NC}"
    if command_exists python3; then
        local version=$(python3 --version 2>&1 | awk '{print $2}')
        local major=$(echo $version | cut -d. -f1)
        local minor=$(echo $version | cut -d. -f2)
        
        if [ "$major" -ge 3 ] && [ "$minor" -ge 8 ]; then
            print_success "Python3 ${GRAY}$version${NC} ✓"
        else
            print_error "Python 3.8+ required, found: $version"
            all_good=false
        fi
    else
        print_error "Python3 not found"
        all_good=false
    fi
    
    # pip
    echo -e "${WHITE}Checking pip...${NC}"
    if command_exists pip3; then
        local version=$(pip3 --version 2>&1 | awk '{print $2}')
        print_success "pip3 ${GRAY}$version${NC} ✓"
    else
        print_error "pip3 not found"
        all_good=false
    fi
    
    # git
    echo -e "${WHITE}Checking git...${NC}"
    if command_exists git; then
        local version=$(git --version 2>&1 | awk '{print $3}')
        print_success "git ${GRAY}$version${NC} ✓"
    else
        print_warning "git not found (needed for OSINT tools)"
        
        if [ "$IS_ROOT" = true ]; then
            echo ""
            print_question "Install git now? (y/n) [default: y]:"
            read -r response
            
            if [[ ! $response =~ ^[Nn]$ ]]; then
                case $PKG_MANAGER in
                    apt)
                        apt-get update -qq && apt-get install -y git -qq
                        ;;
                    dnf)
                        dnf install -y git -q
                        ;;
                    yum)
                        yum install -y git -q
                        ;;
                    pacman)
                        pacman -S --noconfirm git
                        ;;
                esac
                print_success "git installed"
            fi
        fi
    fi
    
    if [ "$all_good" = false ]; then
        echo ""
        print_error "Missing critical requirements!"
        echo ""
        echo -e "${WHITE}Install with:${NC}"
        case $PKG_MANAGER in
            apt)
                echo -e "${BCYAN}  sudo apt update && sudo apt install python3 python3-pip git${NC}"
                ;;
            dnf|yum)
                echo -e "${BCYAN}  sudo $PKG_MANAGER install python3 python3-pip git${NC}"
                ;;
            pacman)
                echo -e "${BCYAN}  sudo pacman -S python python-pip git${NC}"
                ;;
        esac
        exit 1
    fi
    
    echo ""
    print_success "All requirements satisfied!"
    sleep 2
}

# ============================================================================
# INSTALL PYTHON DEPENDENCIES
# ============================================================================

install_python_deps() {
    print_banner
    print_step "2/6" "Installing Python Dependencies"
    
    # Core packages from whoisuser.py requirements
    local packages=("requests" "colorama" "selenium" "webdriver-manager")
    
    echo -e "${WHITE}Installing core packages...${NC}"
    echo ""
    
    for pkg in "${packages[@]}"; do
        echo -ne "${BCYAN}  ⟳${NC} Installing ${WHITE}$pkg${NC}..."
        
        # Try install without breaking system packages first
        if pip3 install "$pkg" $PIP_FLAGS --quiet 2>&1 | grep -q "Successfully installed\|already satisfied"; then
            echo -e "\r${BGREEN}  ✓${NC} Installed  ${WHITE}$pkg${NC}    "
            ((INSTALL_COUNT++))
        # If that fails on newer systems, try with --break-system-packages
        elif pip3 install "$pkg" --break-system-packages --quiet 2>&1 | grep -q "Successfully installed\|already satisfied"; then
            echo -e "\r${BGREEN}  ✓${NC} Installed  ${WHITE}$pkg${NC}    "
            ((INSTALL_COUNT++))
        else
            echo -e "\r${BYELLOW}  ⚠${NC} ${WHITE}$pkg${NC} may have issues"
        fi
        sleep 0.3
    done
    
    echo ""
    
    # Verify critical imports
    echo -e "${WHITE}Verifying installations...${NC}"
    
    if python3 -c "import requests" 2>/dev/null; then
        print_success "requests module working"
    else
        print_warning "requests may not be working"
    fi
    
    if python3 -c "import colorama" 2>/dev/null; then
        print_success "colorama module working"
    else
        print_warning "colorama may not be working"
    fi
    
    if python3 -c "import selenium" 2>/dev/null; then
        print_success "selenium module working"
    else
        print_warning "selenium may not be working"
    fi
    
    echo ""
    print_success "Python dependencies installation complete!"
    sleep 2
}

# ============================================================================
# INSTALL CHROME/CHROMIUM
# ============================================================================

install_chrome() {
    print_banner
    print_step "3/6" "Chrome/Chromium Setup (Screenshot Support)"
    
    # Check if already installed
    if command_exists google-chrome || command_exists chromium-browser || command_exists chromium; then
        local version=$(google-chrome --version 2>/dev/null || chromium-browser --version 2>/dev/null || chromium --version 2>/dev/null || echo "Unknown")
        print_success "Chrome/Chromium detected"
        echo -e "      ${GRAY}$version${NC}"
        
        # Check ChromeDriver
        if command_exists chromedriver; then
            local driver_ver=$(chromedriver --version 2>/dev/null | awk '{print $2}')
            print_success "ChromeDriver detected ${GRAY}$driver_ver${NC}"
        else
            print_info "ChromeDriver will be auto-managed by webdriver-manager"
        fi
        
        sleep 2
        return
    fi
    
    echo ""
    print_warning "Chrome/Chromium not found"
    echo ""
    echo -e "${WHITE}Chrome is needed for automatic screenshot capture${NC}"
    echo -e "${GRAY}(You can skip this and use --no-screenshots flag)${NC}"
    echo ""
    
    if [ "$IS_ROOT" = true ]; then
        print_question "Install Chromium now? (y/n) [default: y]:"
        read -r response
        
        if [[ ! $response =~ ^[Nn]$ ]]; then
            echo ""
            
            case $PKG_MANAGER in
                apt)
                    loading_animation 1 "Updating package list..."
                    apt-get update -qq 2>&1 | grep -v "Reading\|Building" || true
                    
                    echo ""
                    loading_animation 2 "Installing Chromium..."
                    
                    # Try chromium-browser first (Kali, Ubuntu, Debian)
                    if apt-get install -y chromium-browser -qq 2>&1 | grep -q "Setting up"; then
                        print_success "Chromium installed successfully!"
                    # Try chromium package (newer Debian/Ubuntu)
                    elif apt-get install -y chromium -qq 2>&1 | grep -q "Setting up"; then
                        print_success "Chromium installed successfully!"
                    else
                        print_warning "Chromium installation may have failed"
                        SKIP_CHROME=true
                    fi
                    
                    # Try to install chromedriver
                    apt-get install -y chromium-chromedriver chromium-driver -qq 2>/dev/null || true
                    ;;
                    
                dnf)
                    loading_animation 2 "Installing Chromium..."
                    dnf install -y chromium -q 2>&1 | grep -v "Running\|Complete" || true
                    
                    if command_exists chromium; then
                        print_success "Chromium installed successfully!"
                    else
                        print_warning "Chromium installation may have failed"
                        SKIP_CHROME=true
                    fi
                    ;;
                    
                yum)
                    loading_animation 2 "Installing Chromium..."
                    yum install -y chromium -q 2>&1 | grep -v "Running\|Complete" || true
                    
                    if command_exists chromium; then
                        print_success "Chromium installed successfully!"
                    else
                        print_warning "Chromium installation may have failed"
                        SKIP_CHROME=true
                    fi
                    ;;
                    
                pacman)
                    loading_animation 2 "Installing Chromium..."
                    pacman -S --noconfirm chromium 2>&1 | grep -v "checking\|loading" || true
                    
                    if command_exists chromium; then
                        print_success "Chromium installed successfully!"
                    else
                        print_warning "Chromium installation may have failed"
                        SKIP_CHROME=true
                    fi
                    ;;
            esac
        else
            print_warning "Skipping Chromium installation"
            print_info "Use ${BCYAN}whoisuser <username> --no-screenshots${NC} to skip screenshots"
            SKIP_CHROME=true
        fi
    else
        print_error "Root privileges required to install Chromium"
        echo ""
        echo -e "${WHITE}Install manually with:${NC}"
        case $PKG_MANAGER in
            apt)
                echo -e "${BCYAN}  sudo apt install chromium-browser${NC}"
                ;;
            dnf|yum)
                echo -e "${BCYAN}  sudo $PKG_MANAGER install chromium${NC}"
                ;;
            pacman)
                echo -e "${BCYAN}  sudo pacman -S chromium${NC}"
                ;;
        esac
        SKIP_CHROME=true
    fi
    
    echo ""
    if [ "$SKIP_CHROME" = false ]; then
        print_success "Chrome/Chromium setup complete!"
    else
        print_warning "Screenshots will be disabled"
    fi
    
    sleep 2
}

# ============================================================================
# INSTALL WHOISUSER MAIN TOOL
# ============================================================================

install_whoisuser() {
    print_banner
    print_step "4/6" "Installing WhoisUser Main Tool"
    
    if [ ! -f "$SCRIPT_DIR/whoisuser.py" ]; then
        print_error "whoisuser.py not found in $SCRIPT_DIR"
        echo ""
        print_info "Ensure whoisuser.py and install.sh are in the same directory"
        exit 1
    fi
    
    echo -e "${WHITE}Installing WhoisUser...${NC}"
    echo ""
    
    # Create directories
    if [ "$INSTALL_MODE" = "global" ]; then
        mkdir -p "$INSTALL_DIR" 2>/dev/null || true
        mkdir -p "$TOOLS_DIR" 2>/dev/null || true
    else
        mkdir -p "$INSTALL_DIR"
        mkdir -p "$TOOLS_DIR"
    fi
    
    # Create investigations directory
    mkdir -p "$HOME/investigations"
    print_success "Created investigations directory: ${GRAY}~/investigations/${NC}"
    
    # Copy and setup executable
    loading_animation 1 "Copying files..."
    
    if [ "$INSTALL_MODE" = "global" ]; then
        cp "$SCRIPT_DIR/whoisuser.py" "$INSTALL_DIR/whoisuser"
        chmod +x "$INSTALL_DIR/whoisuser"
        
        # Create symlink for convenience
        ln -sf "$INSTALL_DIR/whoisuser" "$INSTALL_DIR/whois" 2>/dev/null || true
    else
        cp "$SCRIPT_DIR/whoisuser.py" "$INSTALL_DIR/whoisuser"
        chmod +x "$INSTALL_DIR/whoisuser"
    fi
    
    # Ensure proper shebang
    if ! head -n 1 "$INSTALL_DIR/whoisuser" | grep -q "^#!/"; then
        echo "#!/usr/bin/env python3" | cat - "$INSTALL_DIR/whoisuser" > "$INSTALL_DIR/whoisuser.tmp"
        mv "$INSTALL_DIR/whoisuser.tmp" "$INSTALL_DIR/whoisuser"
        chmod +x "$INSTALL_DIR/whoisuser"
    fi
    
    # Verify
    if [ -f "$INSTALL_DIR/whoisuser" ] && [ -x "$INSTALL_DIR/whoisuser" ]; then
        print_success "WhoisUser installed: ${BCYAN}$INSTALL_DIR/whoisuser${NC}"
        
        if [ "$INSTALL_MODE" = "global" ] && [ -f "$INSTALL_DIR/whois" ]; then
            print_success "Alias created: ${BCYAN}whois${NC} → ${BCYAN}whoisuser${NC}"
        fi
    else
        print_error "WhoisUser installation failed"
        exit 1
    fi
    
    echo ""
    print_success "WhoisUser core tool installed successfully!"
    sleep 2
}

# ============================================================================
# INSTALL OSINT TOOLS
# ============================================================================

install_osint_tools() {
    print_banner
    print_step "5/6" "Installing Additional OSINT Tools"
    
    echo -e "${WHITE}Additional OSINT tools enhance username enumeration:${NC}"
    echo ""
    echo -e "${BCYAN}  • Sherlock${NC}    ${GRAY}- Search 300+ platforms${NC}"
    echo -e "${BCYAN}  • Maigret${NC}     ${GRAY}- Advanced username OSINT${NC}"
    echo -e "${BCYAN}  • Holehe${NC}      ${GRAY}- Email account enumeration${NC}"
    echo -e "${BCYAN}  • Blackbird${NC}   ${GRAY}- Fast username scanning${NC}"
    echo ""
    
    print_question "Install OSINT tools? (y/n) [default: y]:"
    read -r response
    
    if [[ $response =~ ^[Nn]$ ]]; then
        print_warning "Skipping OSINT tools - WhoisUser will use built-in scanner only"
        SKIP_OSINT=true
        sleep 2
        return
    fi
    
    echo ""
    
    # Create tools directory
    mkdir -p "$TOOLS_DIR"
    cd "$TOOLS_DIR"
    
    # Install Sherlock
    echo -e "${WHITE}Installing Sherlock...${NC}"
    if command_exists sherlock; then
        print_success "Sherlock already installed"
    else
        if [ -d "$TOOLS_DIR/sherlock" ]; then
            cd "$TOOLS_DIR/sherlock"
            git pull -q origin master 2>&1 | grep -v "Already" || true
            cd "$TOOLS_DIR"
            print_success "Sherlock updated"
        else
            git clone -q https://github.com/sherlock-project/sherlock.git 2>&1 | grep -v "Cloning" || true
            
            if [ -d "$TOOLS_DIR/sherlock" ]; then
                cd sherlock
                pip3 install -r requirements.txt $PIP_FLAGS --quiet 2>/dev/null || \
                pip3 install -r requirements.txt --break-system-packages --quiet 2>/dev/null || true
                chmod +x sherlock.py 2>/dev/null || chmod +x sherlock 2>/dev/null || true
                cd "$TOOLS_DIR"
                
                # Create wrapper
                cat > "$INSTALL_DIR/sherlock" << 'EOF'
#!/bin/bash
python3 "TOOLS_DIR_PLACEHOLDER/sherlock/sherlock.py" "$@"
EOF
                sed -i "s|TOOLS_DIR_PLACEHOLDER|$TOOLS_DIR|g" "$INSTALL_DIR/sherlock"
                chmod +x "$INSTALL_DIR/sherlock"
                
                print_success "Sherlock installed"
            else
                print_warning "Sherlock installation failed"
            fi
        fi
    fi
    
    # Install Maigret
    echo ""
    echo -e "${WHITE}Installing Maigret...${NC}"
    if command_exists maigret; then
        print_success "Maigret already installed"
    else
        pip3 install maigret $PIP_FLAGS --quiet 2>/dev/null || \
        pip3 install maigret --break-system-packages --quiet 2>/dev/null || true
        
        if command_exists maigret || [ -f "$HOME/.local/bin/maigret" ]; then
            print_success "Maigret installed"
        else
            print_warning "Maigret installation failed"
        fi
    fi
    
    # Install Holehe
    echo ""
    echo -e "${WHITE}Installing Holehe...${NC}"
    if command_exists holehe; then
        print_success "Holehe already installed"
    else
        pip3 install holehe $PIP_FLAGS --quiet 2>/dev/null || \
        pip3 install holehe --break-system-packages --quiet 2>/dev/null || true
        
        if command_exists holehe || [ -f "$HOME/.local/bin/holehe" ]; then
            print_success "Holehe installed"
        else
            print_warning "Holehe installation failed"
        fi
    fi
    
    # Install Blackbird
    echo ""
    echo -e "${WHITE}Installing Blackbird...${NC}"
    if [ -d "$TOOLS_DIR/blackbird" ]; then
        cd "$TOOLS_DIR/blackbird"
        git pull -q origin main 2>&1 | grep -v "Already" || true
        cd "$TOOLS_DIR"
        print_success "Blackbird updated"
    else
        git clone -q https://github.com/p1ngul1n0/blackbird.git 2>&1 | grep -v "Cloning" || true
        
        if [ -d "$TOOLS_DIR/blackbird" ]; then
            cd blackbird
            pip3 install -r requirements.txt $PIP_FLAGS --quiet 2>/dev/null || \
            pip3 install -r requirements.txt --break-system-packages --quiet 2>/dev/null || true
            chmod +x blackbird.py
            cd "$TOOLS_DIR"
            
            # Create wrapper
            cat > "$INSTALL_DIR/blackbird" << 'EOF'
#!/bin/bash
python3 "TOOLS_DIR_PLACEHOLDER/blackbird/blackbird.py" "$@"
EOF
            sed -i "s|TOOLS_DIR_PLACEHOLDER|$TOOLS_DIR|g" "$INSTALL_DIR/blackbird"
            chmod +x "$INSTALL_DIR/blackbird"
            
            print_success "Blackbird installed"
        else
            print_warning "Blackbird installation failed"
        fi
    fi
    
    cd "$SCRIPT_DIR"
    
    echo ""
    print_success "OSINT tools installation complete!"
    sleep 2
}

# ============================================================================
# CONFIGURE PATH
# ============================================================================

configure_path() {
    print_banner
    print_step "6/6" "Configuring PATH Environment"
    
    if [ "$INSTALL_MODE" = "global" ]; then
        print_success "Global installation - commands available system-wide"
        sleep 2
        return
    fi
    
    # User mode - configure PATH
    echo -e "${WHITE}Checking PATH configuration...${NC}"
    echo ""
    
    if [[ ":$PATH:" == *":$INSTALL_DIR:"* ]]; then
        print_success "$INSTALL_DIR already in PATH"
    else
        print_warning "$INSTALL_DIR not in PATH - configuring..."
        echo ""
        
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
                fi
                ;;
        esac
        
        if [ -n "$SHELL_RC" ]; then
            # Backup
            cp "$SHELL_RC" "$SHELL_RC.backup_$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
            
            # Add to PATH if not present
            if ! grep -q "$INSTALL_DIR" "$SHELL_RC" 2>/dev/null; then
                echo "" >> "$SHELL_RC"
                echo "# WhoisUser OSINT Tool - Added $(date +%Y-%m-%d)" >> "$SHELL_RC"
                echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$SHELL_RC"
                
                if [[ "$INSTALL_DIR" == *".local/bin"* ]] && ! grep -q "\$HOME/.local/bin" "$SHELL_RC"; then
                    echo "export PATH=\"\$PATH:\$HOME/.local/bin\"" >> "$SHELL_RC"
                fi
                
                print_success "PATH configured in ${BCYAN}$(basename $SHELL_RC)${NC}"
            else
                print_info "PATH already configured in $(basename $SHELL_RC)"
            fi
        else
            print_warning "Could not detect shell config file"
            print_info "Add manually: ${BCYAN}export PATH=\"\$PATH:$INSTALL_DIR\"${NC}"
        fi
    fi
    
    # Export for current session
    export PATH="$PATH:$INSTALL_DIR"
    export PATH="$PATH:$HOME/.local/bin"
    
    echo ""
    print_success "PATH configuration complete!"
    sleep 2
}

# ============================================================================
# VERIFY INSTALLATION
# ============================================================================

verify_installation() {
    print_banner
    echo -e "${BCYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BCYAN}║${NC}  ${WHITE}${BOLD}Verifying Installation${NC}"
    echo -e "${BCYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    local issues=0
    
    # Test WhoisUser
    echo -e "${WHITE}Testing WhoisUser...${NC}"
    if [ -x "$INSTALL_DIR/whoisuser" ]; then
        print_success "WhoisUser executable found"
    else
        print_error "WhoisUser not properly installed"
        ((issues++))
    fi
    
    # Test Python dependencies
    echo ""
    echo -e "${WHITE}Testing Python dependencies...${NC}"
    
    if python3 -c "import requests, colorama, selenium" 2>/dev/null; then
        print_success "All Python dependencies working"
    else
        print_warning "Some Python dependencies may be missing"
        ((issues++))
    fi
    
    # Test Chrome
    echo ""
    echo -e "${WHITE}Testing Chrome/Chromium...${NC}"
    if command_exists google-chrome || command_exists chromium-browser || command_exists chromium; then
        print_success "Chrome/Chromium available"
    else
        print_warning "Chrome/Chromium not found - screenshots disabled"
    fi
    
    # Count OSINT tools
    echo ""
    echo -e "${WHITE}Checking OSINT tools...${NC}"
    local osint_count=0
    
    if command_exists sherlock || [ -x "$INSTALL_DIR/sherlock" ]; then
        print_success "Sherlock"
        ((osint_count++))
    fi
    
    if command_exists maigret; then
        print_success "Maigret"
        ((osint_count++))
    fi
    
    if command_exists holehe; then
        print_success "Holehe"
        ((osint_count++))
    fi
    
    if command_exists blackbird || [ -x "$INSTALL_DIR/blackbird" ]; then
        print_success "Blackbird"
        ((osint_count++))
    fi
    
    if [ $osint_count -eq 0 ]; then
        print_info "No additional OSINT tools (using built-in scanner only)"
    fi
    
    echo ""
    
    if [ $issues -eq 0 ]; then
        print_success "All verification checks passed! ✓"
    else
        print_warning "$issues issue(s) detected"
    fi
    
    sleep 2
}

# ============================================================================
# SHOW FINAL INSTRUCTIONS
# ============================================================================

show_final_instructions() {
    print_banner
    
    echo -e "${BGREEN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BGREEN}║${NC}                                                            ${BGREEN}║${NC}"
    echo -e "${BGREEN}║${NC}        ${WHITE}${BOLD}Installation Complete! 🎉${NC}                        ${BGREEN}║${NC}"
    echo -e "${BGREEN}║${NC}                                                            ${BGREEN}║${NC}"
    echo -e "${BGREEN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${WHITE}${BOLD}Installation Summary:${NC}"
    echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${BCYAN}Mode:${NC}           $INSTALL_MODE"
    echo -e "  ${BCYAN}Location:${NC}       $INSTALL_DIR"
    echo -e "  ${BCYAN}OSINT Tools:${NC}    $TOOLS_DIR"
    echo -e "  ${BCYAN}Output:${NC}         ~/investigations/"
    echo ""
    
    if [ "$INSTALL_MODE" = "user" ]; then
        echo -e "${BYELLOW}${BOLD}⚠ Important: Reload Your Shell!${NC}"
        echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        
        SHELL_NAME=$(basename "$SHELL")
        case "$SHELL_NAME" in
            bash)
                echo -e "  Run: ${BCYAN}source ~/.bashrc${NC}"
                ;;
            zsh)
                echo -e "  Run: ${BCYAN}source ~/.zshrc${NC}"
                ;;
            fish)
                echo -e "  Run: ${BCYAN}source ~/.config/fish/config.fish${NC}"
                ;;
            *)
                echo -e "  Run: ${BCYAN}source ~/.bashrc${NC} or restart terminal"
                ;;
        esac
        echo ""
        echo -e "  ${GRAY}Or simply close and reopen your terminal${NC}"
        echo ""
    fi
    
    echo -e "${BGREEN}${BOLD}Quick Start Guide:${NC}"
    echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${BCYAN}# Basic username search${NC}"
    echo -e "  ${WHITE}whoisuser johndoe${NC}"
    echo ""
    echo -e "  ${BCYAN}# Skip screenshots (faster)${NC}"
    echo -e "  ${WHITE}whoisuser johndoe --no-screenshots${NC}"
    echo ""
    echo -e "  ${BCYAN}# Skip external OSINT tools${NC}"
    echo -e "  ${WHITE}whoisuser johndoe --no-osint-tools${NC}"
    echo ""
    echo -e "  ${BCYAN}# Adjust thread count for speed${NC}"
    echo -e "  ${WHITE}whoisuser johndoe --workers 20${NC}"
    echo ""
    echo -e "  ${BCYAN}# Fast scan (no screenshots, no external tools)${NC}"
    echo -e "  ${WHITE}whoisuser johndoe --no-screenshots --no-osint-tools${NC}"
    echo ""
    
    if [ "$SKIP_OSINT" = false ]; then
        echo -e "${BCYAN}${BOLD}Additional OSINT Tools:${NC}"
        echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        
        if command_exists sherlock || [ -x "$INSTALL_DIR/sherlock" ]; then
            echo -e "  ${WHITE}sherlock johndoe${NC}              ${GRAY}- Search 300+ sites${NC}"
        fi
        
        if command_exists maigret; then
            echo -e "  ${WHITE}maigret johndoe${NC}               ${GRAY}- Advanced OSINT${NC}"
        fi
        
        if command_exists holehe; then
            echo -e "  ${WHITE}holehe johndoe@email.com${NC}      ${GRAY}- Email enumeration${NC}"
        fi
        
        if command_exists blackbird || [ -x "$INSTALL_DIR/blackbird" ]; then
            echo -e "  ${WHITE}blackbird -u johndoe${NC}          ${GRAY}- Fast scanning${NC}"
        fi
        echo ""
    fi
    
    echo -e "${BMAGENTA}${BOLD}Features Overview:${NC}"
    echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${BGREEN}✓${NC} Scans 100+ platforms (social media, gaming, dev sites)"
    echo -e "  ${BGREEN}✓${NC} Automated screenshot capture with ChromeDriver reuse"
    echo -e "  ${BGREEN}✓${NC} Integrates Sherlock, Maigret, Holehe, Blackbird"
    echo -e "  ${BGREEN}✓${NC} Comprehensive TXT and JSON reports"
    echo -e "  ${BGREEN}✓${NC} Enhanced validation (reduced false positives)"
    echo -e "  ${BGREEN}✓${NC} Configurable thread count (default: 15)"
    echo -e "  ${BGREEN}✓${NC} Proper resource cleanup and timeout handling"
    echo ""
    
    echo -e "${BYELLOW}${BOLD}Output Files:${NC}"
    echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${WHITE}FULL_REPORT.txt${NC}    ${GRAY}- Complete investigation report${NC}"
    echo -e "  ${WHITE}report.json${NC}         ${GRAY}- Machine-readable JSON data${NC}"
    echo -e "  ${WHITE}all_urls.txt${NC}        ${GRAY}- List of found profile URLs${NC}"
    echo -e "  ${WHITE}screenshots/${NC}        ${GRAY}- Profile screenshots (if enabled)${NC}"
    echo -e "  ${WHITE}osint_results/${NC}      ${GRAY}- External tool outputs${NC}"
    echo ""
    
    if [ "$SKIP_CHROME" = true ]; then
        echo -e "${BYELLOW}${BOLD}⚠ Note:${NC}"
        echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "  Chrome/Chromium not installed - screenshots disabled"
        echo -e "  Use ${BCYAN}--no-screenshots${NC} flag or install Chrome later"
        echo ""
    fi
    
    echo -e "${BRED}${BOLD}⚖ Legal & Ethical Use:${NC}"
    echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${BRED}⚠${NC}  This tool is for ${BOLD}educational purposes only${NC}"
    echo -e "  ${BRED}⚠${NC}  For authorized security research & forensics"
    echo -e "  ${BRED}⚠${NC}  Always respect privacy laws and ToS"
    echo -e "  ${BRED}⚠${NC}  Obtain proper authorization before investigations"
    echo -e "  ${BRED}⚠${NC}  Author is not responsible for misuse"
    echo ""
    
    echo -e "${BBLUE}${BOLD}Troubleshooting:${NC}"
    echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${WHITE}Command not found?${NC}"
    
    if [ "$INSTALL_MODE" = "user" ]; then
        echo -e "    → Reload shell: ${BCYAN}source ~/.bashrc${NC}"
        echo -e "    → Or use full path: ${BCYAN}$INSTALL_DIR/whoisuser${NC}"
    else
        echo -e "    → Ensure /usr/local/bin is in PATH"
    fi
    
    echo ""
    echo -e "  ${WHITE}Python errors?${NC}"
    echo -e "    → Reinstall: ${BCYAN}pip3 install requests colorama selenium --user${NC}"
    echo ""
    echo -e "  ${WHITE}Permission denied?${NC}"
    echo -e "    → Fix: ${BCYAN}chmod +x $INSTALL_DIR/whoisuser${NC}"
    echo ""
    echo -e "  ${WHITE}Screenshots not working?${NC}"
    echo -e "    → Install Chrome: ${BCYAN}sudo apt install chromium-browser${NC}"
    echo -e "    → Or use: ${BCYAN}whoisuser <username> --no-screenshots${NC}"
    echo ""
    
    echo -e "${BCYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BCYAN}║${NC}                                                            ${BCYAN}║${NC}"
    echo -e "${BCYAN}║${NC}     ${WHITE}${BOLD}Happy Investigating! Stay Legal & Ethical! 🔍${NC}       ${BCYAN}║${NC}"
    echo -e "${BCYAN}║${NC}                                                            ${BCYAN}║${NC}"
    echo -e "${BCYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ============================================================================
# ERROR CLEANUP
# ============================================================================

cleanup_on_error() {
    echo ""
    print_error "Installation failed!"
    echo ""
    print_info "Check the error messages above"
    
    if [ -f "$INSTALL_DIR/whoisuser" ]; then
        rm -f "$INSTALL_DIR/whoisuser" 2>/dev/null || true
    fi
    
    echo ""
    exit 1
}

# ============================================================================
# MAIN INSTALLATION FLOW
# ============================================================================

main() {
    trap cleanup_on_error ERR
    
    show_welcome
    select_install_mode
    check_requirements
    install_python_deps
    install_chrome
    install_whoisuser
    install_osint_tools
    configure_path
    verify_installation
    show_final_instructions
}

# ============================================================================
# ENTRY POINT
# ============================================================================

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
else
    echo "This script should be executed, not sourced"
    echo "Run: bash install.sh"
fi
