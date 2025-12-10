#!/bin/bash

# HackShell v1.2 Enhanced Installation Script
# Created By Team ILLUSION || DK

# Get current directory
INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Colors
green='\033[1;92m'
yellow='\033[1;93m'
white='\033[1;97m'
cyan='\033[1;96m'
red='\033[1;91m'
blue='\033[1;94m'
purple='\033[1;95m'
reset='\033[0m'

# Check if running in Termux
if [ -z "$PREFIX" ] && [ ! -d "/data/data/com.termux" ]; then
    echo -e "${yellow}Warning: It seems you are not running this in Termux.${reset}"
    echo -e "${yellow}This tool is designed for Android Termux environment.${reset}"
    read -p "Do you want to continue anyway? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Display header
echo -e "$yellow
=====================================================
Created By Team ILLUSION || DK
====================================================="
echo ""
echo -e "$green
=====================================================
Installing Termux HackShell v1.2 Enhanced
====================================================="
echo ""

# Install required packages
echo -e "$yellow
=====================================================
Installing Required Packages
====================================================="

# Function to install package with error handling
install_package() {
    local package="$1"
    local installer="$2"
    
    echo -e "${cyan}Installing $package...${reset}"
    
    case $installer in
        "pkg")
            if command -v pkg >/dev/null 2>&1; then
                if pkg install "$package" -y; then
                    echo -e "${green}✓ $package installed successfully${reset}"
                    return 0
                else
                    echo -e "${red}✗ Failed to install $package${reset}"
                    return 1
                fi
            else
                echo -e "${yellow}pkg command not found, skipping $package${reset}"
                return 1
            fi
            ;;
        "gem")
            if command -v gem >/dev/null 2>&1; then
                if gem install "$package"; then
                    echo -e "${green}✓ $package installed successfully${reset}"
                    return 0
                fi
            fi

            echo -e "${yellow}Trying alternative installation for $package...${reset}"
            if pip install "$package"; then
                echo -e "${green}✓ $package installed via pip${reset}"
                return 0
            else
                echo -e "${red}✗ Failed to install $package${reset}"
                return 1
            fi
            ;;
        "pip")
            if pip install "$package"; then
                echo -e "${green}✓ $package installed successfully${reset}"
                return 0
            else
                echo -e "${red}✗ Failed to install $package${reset}"
                return 1
            fi
            ;;
    esac
}

# Install packages with error handling
failed_packages=()

install_package "ruby" "pkg" || failed_packages+=("ruby")
install_package "mpv" "pkg" || failed_packages+=("mpv")
install_package "figlet" "pkg" || failed_packages+=("figlet")
install_package "python" "pkg" || failed_packages+=("python")
install_package "lolcat" "gem" || failed_packages+=("lolcat")
install_package "termux-api" "pip" || failed_packages+=("termux-api")

if [ ${#failed_packages[@]} -eq 0 ]; then
    echo -e "$green
=====================================================
Successfully Installed All Packages
====================================================="
else
    echo -e "$yellow
=====================================================
Installation completed with warnings
Failed packages: ${failed_packages[*]}
HackShell will still work but some features may be limited
====================================================="
fi
echo ""

# Create required directories
echo -e "$cyan
=====================================================
Setting Up Configuration
====================================================="

# Define target directory
TARGET_DIR="$HOME/HackShell"

# If we are not already in TARGET_DIR, we might need to copy files
# But usually user clones into TARGET_DIR.
# If INSTALL_DIR is not TARGET_DIR, maybe we should warn or handle it.
if [ "$INSTALL_DIR" != "$TARGET_DIR" ]; then
    echo -e "${yellow}Detected installation from $INSTALL_DIR${reset}"
    echo -e "${yellow}It is recommended to run this from $TARGET_DIR${reset}"

    if [ ! -d "$TARGET_DIR" ]; then
        echo -e "${cyan}Creating $TARGET_DIR...${reset}"
        mkdir -p "$TARGET_DIR"
        cp -r "$INSTALL_DIR"/* "$TARGET_DIR/"
        echo -e "${green}Files copied to $TARGET_DIR${reset}"
    fi
fi

# Ensure themes directory exists
if [ ! -d "$TARGET_DIR/themes" ]; then
    mkdir -p "$TARGET_DIR/themes"
    # Copy themes if they are not there (e.g. if we are running from a partial install)
    if [ -d "$INSTALL_DIR/themes" ]; then
        cp -r "$INSTALL_DIR/themes/"* "$TARGET_DIR/themes/"
    fi
fi

# Make scripts executable
chmod +x "$TARGET_DIR/config.sh"
chmod +x "$TARGET_DIR/themes/"*.bashrc
chmod +x "$TARGET_DIR/tools/"*.sh 2>/dev/null
chmod +x "$TARGET_DIR/rvt.sh"

# Backup original bashrc
echo -e "$blue
=====================================================
Initializing...
====================================================="
if [ -f "$PREFIX/etc/bash.bashrc" ]; then
    if [ ! -d "$TARGET_DIR/Revert" ]; then
        mkdir -p "$TARGET_DIR/Revert"
    fi
    # Check if backup already exists to avoid overwriting original backup with a themed one
    if [ ! -f "$TARGET_DIR/Revert/bash.bashrc" ]; then
        cp "$PREFIX/etc/bash.bashrc" "$TARGET_DIR/Revert/"
        echo -e "${green}Backup of original bash.bashrc created.${reset}"
    fi
fi

# Copy default theme (hacker)
if [ -f "$TARGET_DIR/themes/hacker.bashrc" ]; then
    cp "$TARGET_DIR/themes/hacker.bashrc" "$PREFIX/etc/bash.bashrc"
    echo -e "${green}Default theme applied.${reset}"
else
    echo -e "${red}Error: Default theme not found!${reset}"
fi

# Create default configuration
echo "# HackShell Configuration" > "$TARGET_DIR/config.conf"
echo "THEME=\"hacker\"" >> "$TARGET_DIR/config.conf"
echo "SHOW_SYSINFO=\"true\"" >> "$TARGET_DIR/config.conf"
echo "CUSTOM_NAME=\"\"" >> "$TARGET_DIR/config.conf"
echo "BANNER_STYLE=\"default\"" >> "$TARGET_DIR/config.conf"
echo "WELCOME_SOUND=\"true\"" >> "$TARGET_DIR/config.conf"

# Installation complete
echo -e "$green
=====================================================
All Files Are Done
====================================================="

# Verify installation
echo -e "$cyan
=====================================================
Verifying Installation...
====================================================="

verification_failed=false

# Check if theme files exist
if [ ! -d "$TARGET_DIR/themes" ] || [ -z "$(ls -A "$TARGET_DIR/themes")" ]; then
    echo -e "${red}✗ Theme files not found${reset}"
    verification_failed=true
else
    echo -e "${green}✓ Theme files verified${reset}"
fi

# Check if scripts are executable
for script in config.sh install.sh rvt.sh; do
    if [ -x "$TARGET_DIR/$script" ]; then
        echo -e "${green}✓ $script is executable${reset}"
    else
        echo -e "${yellow}⚠ $script is not executable, fixing...${reset}"
        chmod +x "$TARGET_DIR/$script"
    fi
done

# Check if bash.bashrc was backed up
if [ -f "$TARGET_DIR/Revert/bash.bashrc" ]; then
    echo -e "${green}✓ Original bash.bashrc backed up${reset}"
else
    echo -e "${yellow}⚠ Original bash.bashrc backup not found${reset}"
fi

# Check if new bash.bashrc is in place
# Compare content or just existence? Existence is enough.
if [ -f "$PREFIX/etc/bash.bashrc" ]; then
    echo -e "${green}✓ HackShell theme applied${reset}"
else
    echo -e "${red}✗ Failed to apply HackShell theme${reset}"
    verification_failed=true
fi

if [ "$verification_failed" = true ]; then
    echo -e "$yellow
=====================================================
Installation completed with issues
Please run the installer again or report the problem
====================================================="
else
    echo -e "$green
=====================================================
Installation verified successfully!
====================================================="
fi
clear
echo -e "$yellow
======================================================
HackShell v1.2 Enhanced Successfully Installed!
======================================================"
echo -e "$yellow
GitHub : https://github.com/dk1285
======================================================"
echo ""
echo -e "$cyan
======================================================
What's New in v1.2 Enhanced:
- Interactive Theme Preview
- Theme Creation Wizard
- Advanced System Monitor
- Performance Tracker
- Auto-Update System
- Configuration Backup & Restore
- Enhanced Security & UI
======================================================"
echo ""
echo -e "$green
======================================================
To configure HackShell, run:
cd $TARGET_DIR
bash config.sh

Now Type 'exit' & Restart Termux to see the changes!
======================================================"
echo ""
echo -e "$reset"
