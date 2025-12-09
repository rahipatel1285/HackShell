#!/bin/bash

# HackShell Configuration Script - v1.2 Enhanced
# Created by Team ILLUSION || DK

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Colors
green='\033[1;92m'
yellow='\033[1;93m'
red='\033[1;91m'
blue='\033[1;94m'
cyan='\033[1;96m'
white='\033[1;97m'
purple='\033[1;95m'
reset='\033[0m'

# Default config values
THEME="hacker"
SHOW_SYSINFO="true"
CUSTOM_NAME=""
BANNER_STYLE="default"
WELCOME_SOUND="true"

# Config file path
CONFIG_FILE="$SCRIPT_DIR/config.conf"

# Dependency checker
check_dependencies() {
    local missing_deps=()
    
    # Check for required commands
    local required_commands=("figlet" "lolcat" "mpv")
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    # Check for required directories
    if [ ! -d "$SCRIPT_DIR/themes" ]; then
        echo -e "${red}Error: Themes directory not found!${reset}"
        echo -e "${yellow}Please reinstall HackShell to fix this issue.${reset}"
        exit 1
    fi
    
    # Install missing dependencies if any
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo -e "${yellow}Missing dependencies detected: ${missing_deps[*]}${reset}"
        echo -e "${cyan}Would you like to install them now? (y/n)${reset}"
        read -p "> " install_choice
        
        if [[ "$install_choice" = "y" || "$install_choice" = "Y" ]]; then
            echo -e "${yellow}Installing missing dependencies...${reset}"
            
            for dep in "${missing_deps[@]}"; do
                case "$dep" in
                    "lolcat")
                        gem install lolcat 2>/dev/null || pip install lolcat 2>/dev/null
                        ;;
                    *)
                        pkg install -y "$dep" 2>/dev/null
                        ;;
                esac
            done
            
            echo -e "${green}Dependencies installed successfully!${reset}"
            sleep 2
        else
            echo -e "${yellow}Warning: Some features may not work without required dependencies.${reset}"
            sleep 2
        fi
    fi
}

# Load configuration if exists
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Save configuration
save_config() {
    echo "# HackShell Configuration" > "$CONFIG_FILE"
    echo "THEME=\"$THEME\"" >> "$CONFIG_FILE"
    echo "SHOW_SYSINFO=\"$SHOW_SYSINFO\"" >> "$CONFIG_FILE"
    echo "CUSTOM_NAME=\"$CUSTOM_NAME\"" >> "$CONFIG_FILE"
    echo "BANNER_STYLE=\"$BANNER_STYLE\"" >> "$CONFIG_FILE"
    echo "WELCOME_SOUND=\"$WELCOME_SOUND\"" >> "$CONFIG_FILE"
    echo -e "${green}Configuration saved!${reset}"
    sleep 1
}

# Input validation helper
validate_input() {
    local input="$1"
    local min="$2"
    local max="$3"
    
    # Check if input is a number
    if ! [[ "$input" =~ ^[0-9]+$ ]]; then
        return 1
    fi
    
    # Check if input is within range
    if [ "$input" -lt "$min" ] || [ "$input" -gt "$max" ]; then
        return 1
    fi
    
    return 0
}

# Sanitize user input to prevent command injection
sanitize_input() {
    local input="$1"
    
    # Remove dangerous characters
    echo "$input" | sed 's/[;&|`$()]//g' | sed 's/[<>]//g'
}

# Validate file path to prevent directory traversal
validate_path() {
    local path="$1"
    local base_dir="$2"
    
    # Convert to absolute path
    local abs_path=$(realpath "$path" 2>/dev/null)
    local abs_base=$(realpath "$base_dir" 2>/dev/null)
    
    # Check if path is within base directory
    if [[ "$abs_path" == "$abs_base"* ]]; then
        return 0
    else
        return 1
    fi
}

# Safe read input with validation
safe_read() {
    local prompt="$1"
    local min="$2"
    local max="$3"
    local input
    
    while true; do
        read -p "$prompt" input
        
        if validate_input "$input" "$min" "$max"; then
            echo "$input"
            return 0
        else
            echo -e "${red}Invalid input! Please enter a number between $min and $max.${reset}"
        fi
    done
}

# Progress indicator
show_progress() {
    local message="$1"
    local duration="${2:-3}"
    
    echo -n -e "${yellow}$message${reset}"
    
    for ((i=0; i<duration; i++)); do
        sleep 1
        echo -n "."
    done
    
    echo -e " ${green}Done!${reset}"
}

# Backup system
create_backup() {
    local backup_name="${1:-$(date +%Y%m%d_%H%M%S)}"
    local backup_dir="$SCRIPT_DIR/backups"
    
    # Create backup directory
    mkdir -p "$backup_dir"
    
    show_progress "Creating backup" 2
    
    # Create backup archive
    local backup_file="$backup_dir/hackshell_backup_$backup_name.tar.gz"
    
    cd "$SCRIPT_DIR" || return 1
    
    tar -czf "$backup_file" \
        config.conf \
        themes/ \
        --exclude="themes/marketplace" \
        --exclude="themes/temp" \
        2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${green}✓ Backup created: $backup_file${reset}"
        return 0
    else
        echo -e "${red}✗ Backup failed${reset}"
        return 1
    fi
}

# Restore from backup
restore_backup() {
    local backup_dir="$SCRIPT_DIR/backups"
    
    if [ ! -d "$backup_dir" ] || [ -z "$(ls -A $backup_dir)" ]; then
        echo -e "${red}No backups found!${reset}"
        sleep 2
        return 1
    fi
    
    echo -e "${yellow}Available backups:${reset}"
    echo ""
    
    local backups=($(ls -1 "$backup_dir"/*.tar.gz 2>/dev/null))
    local count=1
    
    for backup in "${backups[@]}"; do
        local backup_name=$(basename "$backup" .tar.gz)
        local backup_date=$(echo "$backup_name" | grep -o '[0-9]\{8\}_[0-9]\{6\}')
        if [ -n "$backup_date" ]; then
            local formatted_date=$(echo "$backup_date" | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)_\([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1-\2-\3 \4:\5:\6/')
            echo -e "${cyan}[$count]${reset} $formatted_date"
        else
            echo -e "${cyan}[$count]${reset} $backup_name"
        fi
        count=$((count+1))
    done
    
    echo -e "${cyan}[0]${reset} Cancel"
    echo ""
    
    local max_option=$((count-1))
    local choice=$(safe_read "Select backup to restore: " 0 $max_option)
    
    if [ "$choice" -eq 0 ]; then
        echo -e "${yellow}Restore cancelled${reset}"
        return 0
    fi
    
    local selected_backup="${backups[$((choice-1))]}"
    
    echo -e "${yellow}This will overwrite your current configuration!${reset}"
    echo -e "${red}Are you sure? (y/N)${reset}"
    read -p "> " confirm
    
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo -e "${yellow}Restore cancelled${reset}"
        return 0
    fi
    
    show_progress "Restoring backup" 3
    
    cd "$SCRIPT_DIR" || return 1
    
    if tar -xzf "$selected_backup"; then
        echo -e "${green}✓ Backup restored successfully!${reset}"
        echo -e "${yellow}Please restart the configuration to apply changes.${reset}"
        sleep 3
        return 0
    else
        echo -e "${red}✗ Restore failed${reset}"
        sleep 2
        return 1
    fi
}

# Display header
display_header() {
    clear
    echo -e "${yellow}===============================================${reset}"
    echo -e "${cyan}            HackShell v1.2 Config              ${reset}"
    echo -e "${yellow}===============================================${reset}"
    echo -e "${green}Created by Team ILLUSION || DK${reset}"
    echo ""
}

# Main menu
main_menu() {
    while true; do
        display_header
        echo -e "Current Configuration:"
        echo -e "${yellow}Theme:${reset} $THEME"
        echo -e "${yellow}System Info:${reset} $SHOW_SYSINFO"
        echo -e "${yellow}Custom Name:${reset} ${CUSTOM_NAME:-"Not set"}"
        echo -e "${yellow}Banner Style:${reset} $BANNER_STYLE"
        echo -e "${yellow}Welcome Sound:${reset} $WELCOME_SOUND"
        echo ""
        echo -e "${cyan}[1]${reset} Change Theme"
        echo -e "${cyan}[2]${reset} Theme Manager"
        echo -e "${cyan}[3]${reset} Create Custom Theme"
        echo -e "${cyan}[4]${reset} Toggle System Info Display"
        echo -e "${cyan}[5]${reset} Set Custom Greeting Name"
        echo -e "${cyan}[6]${reset} Change Banner Style"
        echo -e "${cyan}[7]${reset} Toggle Welcome Sound"
        echo -e "${cyan}[8]${reset} Utility Tools"
        echo -e "${cyan}[9]${reset} Set as Default Shell"
        echo -e "${cyan}[10]${reset} Android Tweaks"
        echo -e "${cyan}[11]${reset} Check for Updates"
        echo -e "${cyan}[12]${reset} Backup Configuration"
        echo -e "${cyan}[13]${reset} Restore Configuration"
        echo -e "${cyan}[14]${reset} Save & Apply"
        echo -e "${cyan}[15]${reset} Save & Exit"
        echo ""
        choice=$(safe_read "Select an option: " 1 15)
        
        case $choice in
            1) change_theme ;;
            2) manage_themes ;;
            3) create_custom_theme ;;
            4) toggle_sysinfo ;;
            5) set_custom_name ;;
            6) change_banner ;;
            7) toggle_sound ;;
            8) launch_tools ;;
            9) set_default_shell ;;
            10) android_tweaks ;;
            11) check_for_updates ;;
            12) create_backup ;;
            13) restore_backup ;;
            14) 
                save_config
                apply_changes
                ;;
            15)
                save_config
                echo -e "${green}Configuration saved. Please restart Termux to apply changes.${reset}"
                exit 0
                ;;
            *)
                echo -e "${red}Invalid option!${reset}"
                sleep 1
                ;;
        esac
    done
}

# Change theme
change_theme() {
    display_header
    echo -e "Available Themes:"
    
    # Get all theme files
    theme_files=("$SCRIPT_DIR/themes"/*.bashrc)
    
    # Built-in themes
    echo -e "${yellow}Built-in Themes:${reset}"
    echo -e "${cyan}[1]${reset} Hacker (Green & Black)"
    echo -e "${cyan}[2]${reset} Matrix (Green variations)"
    echo -e "${cyan}[3]${reset} Cyberpunk (Neon colors)"
    echo -e "${cyan}[4]${reset} Midnight (Blue & Black)"
    echo -e "${cyan}[5]${reset} Blood (Red & Black)"
    echo -e "${cyan}[6]${reset} Preview Themes"
    
    # Custom themes
    if [ ${#theme_files[@]} -gt 5 ]; then
        echo -e "\n${yellow}Custom Themes:${reset}"
        count=7  # Start from 7 since 6 is preview
        for ((i=0; i<${#theme_files[@]}; i++)); do
            theme_file="${theme_files[$i]}"
            theme_basename=$(basename "$theme_file" .bashrc)
            
            # Skip built-in themes
            if [[ "$theme_basename" != "hacker" && "$theme_basename" != "matrix" && \
                 "$theme_basename" != "cyberpunk" && "$theme_basename" != "midnight" && \
                 "$theme_basename" != "blood" ]]; then
                
                # Get theme name from file if available
                theme_name=$(grep "^THEME_NAME=" "$theme_file" 2>/dev/null | cut -d'"' -f2)
                theme_author=$(grep "^THEME_AUTHOR=" "$theme_file" 2>/dev/null | cut -d'"' -f2)
                
                if [ -z "$theme_name" ]; then
                    theme_name="$theme_basename"
                fi
                
                if [ -z "$theme_author" ]; then
                    echo -e "${cyan}[$count]${reset} $theme_name"
                else
                    echo -e "${cyan}[$count]${reset} $theme_name (by $theme_author)"
                fi
                
                count=$((count+1))
            fi
        done
    else
        count=7  # Only built-in themes + preview
    fi
    
    echo ""
    local max_option=$((count-1))
    theme_choice=$(safe_read "Select a theme: " 1 $max_option)
    
    # Built-in themes
    case $theme_choice in
        1) THEME="hacker" ;;
        2) THEME="matrix" ;;
        3) THEME="cyberpunk" ;;
        4) THEME="midnight" ;;
        5) THEME="blood" ;;
        6) 
            preview_themes
            return
            ;;
        *) 
            # Check for custom themes
            if [[ "$theme_choice" -ge 7 && "$theme_choice" -lt $count ]]; then
                custom_count=7
                for ((i=0; i<${#theme_files[@]}; i++)); do
                    theme_file="${theme_files[$i]}"
                    theme_basename=$(basename "$theme_file" .bashrc)
                    
                    # Skip built-in themes
                    if [[ "$theme_basename" != "hacker" && "$theme_basename" != "matrix" && \
                         "$theme_basename" != "cyberpunk" && "$theme_basename" != "midnight" && \
                         "$theme_basename" != "blood" ]]; then
                        
                        if [ $custom_count -eq $theme_choice ]; then
                            THEME="$theme_basename"
                            break
                        fi
                        
                        custom_count=$((custom_count+1))
                    fi
                done
            else
                echo -e "${red}Invalid option! Theme unchanged.${reset}"
                sleep 1
                return
            fi
            ;;
    esac
    
    echo -e "${green}Theme set to $THEME${reset}"
    sleep 1
}

# Preview themes function
preview_themes() {
    display_header
    echo -e "${yellow}Theme Preview System${reset}"
    echo ""
    
    local themes=("hacker" "matrix" "cyberpunk" "midnight" "blood")
    local current_index=0
    
    while true; do
        local theme=${themes[$current_index]}
        
        # Display theme preview
        clear
        echo -e "${yellow}===============================================${reset}"
        echo -e "${cyan}            Theme Preview: $theme              ${reset}"
        echo -e "${yellow}===============================================${reset}"
        echo ""
        
        # Show theme colors based on theme
        case $theme in
            "hacker")
                echo -e "${green}▓▓▓▓▓▓▓▓ HACKER THEME ▓▓▓▓▓▓▓▓${reset}"
                echo -e "${green}$ whoami"
                echo -e "${white}root"
                echo -e "${green}$ ls -la /"
                echo -e "${cyan}drwxr-xr-x  2 root root  4096 Jan  1 00:00 bin"
                echo -e "${green}$ echo 'Welcome to HackShell'"
                echo -e "${yellow}Welcome to HackShell${reset}"
                ;;
            "matrix")
                echo -e "${green}▓▓▓▓▓▓▓▓ MATRIX THEME ▓▓▓▓▓▓▓▓${reset}"
                echo -e "${green}Wake up, Neo..."
                echo -e "${green}The Matrix has you..."
                echo -e "${green}$ follow_white_rabbit"
                echo -e "${green}Knock, knock, Neo.${reset}"
                ;;
            "cyberpunk")
                echo -e "${purple}▓▓▓▓▓▓▓▓ CYBERPUNK THEME ▓▓▓▓▓▓▓▓${reset}"
                echo -e "${purple}> connect_to_grid()"
                echo -e "${cyan}Connection established..."
                echo -e "${yellow}Warning: ICE detected"
                echo -e "${red}> run_ice_breaker.exe"
                echo -e "${green}Access granted${reset}"
                ;;
            "midnight")
                echo -e "${blue}▓▓▓▓▓▓▓▓ MIDNIGHT THEME ▓▓▓▓▓▓▓▓${reset}"
                echo -e "${cyan}$ nmap -sS target.com"
                echo -e "${white}Starting Nmap scan..."
                echo -e "${blue}22/tcp   open  ssh"
                echo -e "${blue}80/tcp   open  http"
                echo -e "${cyan}Scan complete${reset}"
                ;;
            "blood")
                echo -e "${red}▓▓▓▓▓▓▓▓ BLOOD THEME ▓▓▓▓▓▓▓▓${reset}"
                echo -e "${red}$ ./exploit --target system"
                echo -e "${yellow}Payload injected..."
                echo -e "${red}Shell access gained"
                echo -e "${white}# whoami"
                echo -e "${red}root${reset}"
                ;;
        esac
        
        echo ""
        echo -e "${yellow}Navigation:${reset}"
        echo -e "${cyan}[←/h] Previous  [→/l] Next  [Enter] Select  [q] Back${reset}"
        echo ""
        echo -e "Theme $((current_index+1)) of ${#themes[@]}: $theme"
        
        # Read single character input
        read -n 1 -s key
        
        case $key in
            'h'|'H') # h (previous)
                current_index=$(( (current_index - 1 + ${#themes[@]}) % ${#themes[@]} ))
                ;;
            'l'|'L') # l (next)
                current_index=$(( (current_index + 1) % ${#themes[@]} ))
                ;;
            '') # Enter key
                THEME=${themes[$current_index]}
                echo -e "\n${green}Theme '$THEME' selected!${reset}"
                sleep 1
                return
                ;;
            'q'|'Q')
                echo -e "\n${yellow}Preview cancelled.${reset}"
                sleep 1
                return
                ;;
        esac
    done
}

# Auto-update mechanism
check_for_updates() {
    display_header
    echo -e "${yellow}HackShell Update System${reset}"
    echo ""
    
    # Check if git is available
    if ! command -v git &> /dev/null; then
        echo -e "${red}Git is not installed. Installing...${reset}"
        pkg install -y git
        
        if ! command -v git &> /dev/null; then
            echo -e "${red}Failed to install Git. Update cancelled.${reset}"
            sleep 3
            return
        fi
    fi
    
    # Check if we're in a git repository
    cd "$SCRIPT_DIR" || {
        echo -e "${red}HackShell directory not found!${reset}"
        sleep 3
        return
    }
    
    if [ ! -d ".git" ]; then
        echo -e "${yellow}This installation was not installed via Git.${reset}"
        echo -e "${cyan}Would you like to reinitialize with Git? (y/n)${reset}"
        read -p "> " git_choice
        
        if [[ "$git_choice" = "y" || "$git_choice" = "Y" ]]; then
            show_progress "Reinitializing with Git" 3
            git init
            git remote add origin https://github.com/dk1285/HackShell.git
            git fetch origin main
            git reset --hard origin/main
            echo -e "${green}Reinitialization complete!${reset}"
        else
            echo -e "${yellow}Update cancelled.${reset}"
            sleep 2
            return
        fi
    fi
    
    show_progress "Checking for updates" 2
    
    # Fetch latest changes
    git fetch origin main 2>/dev/null
    
    # Check if updates are available
    local current_commit=$(git rev-parse HEAD)
    local latest_commit=$(git rev-parse origin/main)
    
    if [ "$current_commit" = "$latest_commit" ]; then
        echo -e "${green}✓ HackShell is already up to date!${reset}"
        echo -e "${yellow}Current version: $(git log --oneline -1)${reset}"
        sleep 3
        return
    fi
    
    echo -e "${yellow}Updates available!${reset}"
    echo -e "${cyan}Current: ${current_commit:0:7}${reset}"
    echo -e "${cyan}Latest:  ${latest_commit:0:7}${reset}"
    echo ""
    echo -e "${yellow}Changelog:${reset}"
    git log --oneline $current_commit..$latest_commit | head -5
    echo ""
    
    echo -e "${cyan}Would you like to update? (y/n)${reset}"
    read -p "> " update_choice
    
    if [[ "$update_choice" = "y" || "$update_choice" = "Y" ]]; then
        show_progress "Creating backup" 2
        
        # Create backup of current config
        if [ -f "$CONFIG_FILE" ]; then
            cp "$CONFIG_FILE" "$CONFIG_FILE.backup.$(date +%s)"
            echo -e "${green}Configuration backed up.${reset}"
        fi
        
        show_progress "Updating HackShell" 3
        
        # Pull latest changes
        if git pull origin main; then
            echo -e "${green}✓ Update completed successfully!${reset}"
            
            # Make scripts executable
            chmod +x *.sh
            chmod +x themes/*.sh 2>/dev/null
            chmod +x tools/*.sh 2>/dev/null
            
            show_progress "Verifying installation" 2
            
            # Run a quick verification
            if [ -f "install.sh" ] && [ -f "config.sh" ]; then
                echo -e "${green}✓ Installation verified!${reset}"
                echo ""
                echo -e "${cyan}Update completed! Press Enter to restart configuration...${reset}"
                read
                exec "$0"  # Restart the script
            else
                echo -e "${red}✗ Verification failed. Please reinstall HackShell.${reset}"
            fi
        else
            echo -e "${red}✗ Update failed. Restoring from backup...${reset}"
            
            # Attempt to restore
            git reset --hard HEAD
            
            if [ -f "$CONFIG_FILE.backup.$(date +%s)" ]; then
                cp "$CONFIG_FILE.backup.$(date +%s)" "$CONFIG_FILE"
                echo -e "${green}Configuration restored.${reset}"
            fi
            
            echo -e "${yellow}Please try updating again later or reinstall manually.${reset}"
        fi
    else
        echo -e "${yellow}Update cancelled.${reset}"
    fi
    
    sleep 3
}

# Create custom theme
create_custom_theme() {
    if [ -f "$SCRIPT_DIR/tools/theme_wizard.sh" ]; then
        bash "$SCRIPT_DIR/tools/theme_wizard.sh"
    else
        echo -e "${red}Theme wizard not found!${reset}"
        echo -e "${yellow}Creating theme wizard...${reset}"
        # The wizard file should exist, but just in case
        sleep 2
    fi
}

# Manage themes
manage_themes() {
    if [ -f "$SCRIPT_DIR/themes/theme_manager.sh" ]; then
        bash "$SCRIPT_DIR/themes/theme_manager.sh"
    else
        echo -e "${red}Theme manager not found!${reset}"
        sleep 2
    fi
}

# Launch tools
launch_tools() {
    if [ -f "$SCRIPT_DIR/tools/hacktools.sh" ]; then
        bash "$SCRIPT_DIR/tools/hacktools.sh"
    else
        echo -e "${red}Utility tools not found!${reset}"
        echo -e "${yellow}Installing...${reset}"
        
        # Create tools directory if it doesn't exist
        if [ ! -d "$SCRIPT_DIR/tools" ]; then
            mkdir -p "$SCRIPT_DIR/tools"
        fi
        
        # Copy the tools script from the sample directory if available
        if [ -f "$SCRIPT_DIR/samples/hacktools.sh" ]; then
            cp "$SCRIPT_DIR/samples/hacktools.sh" "$SCRIPT_DIR/tools/hacktools.sh"
        fi
        # Download or copy the tools script
        cp "$SCRIPT_DIR/tools/hacktools.sh" "$SCRIPT_DIR/tools/hacktools.sh" 2>/dev/null
        
        if [ -f "$SCRIPT_DIR/tools/hacktools.sh" ]; then
            chmod +x "$SCRIPT_DIR/tools/hacktools.sh"
            bash "$SCRIPT_DIR/tools/hacktools.sh"
        else
            echo -e "${red}Failed to install utility tools!${reset}"
            sleep 2
        fi
    fi
}

# Set HackShell as default shell
set_default_shell() {
    display_header
    echo -e "${yellow}Set HackShell as Default Shell${reset}"
    echo ""
    
    # Check if Termux is being used
    if [ ! -d "/data/data/com.termux" ]; then
        echo -e "${red}This feature only works on Termux.${reset}"
        echo -e "${yellow}HackShell is designed for Android Termux environment.${reset}"
        sleep 3
        return
    fi
    
    echo -e "${cyan}This will set HackShell to launch automatically whenever you open Termux.${reset}"
    echo -e "${yellow}Do you want to continue? (y/n)${reset}"
    read -p "> " confirm
    
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo -e "${yellow}Operation cancelled.${reset}"
        sleep 2
        return
    fi
    
    # Backup existing .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        cp "$HOME/.bashrc" "$HOME/.bashrc.hackshell.bak"
        echo -e "${green}Existing .bashrc backed up to $HOME/.bashrc.hackshell.bak${reset}"
    fi
    
    # Create or modify .bashrc to launch HackShell
    # Since install.sh replaces /data/data/com.termux/files/usr/etc/bash.bashrc,
    # Termux will load HackShell theme by default.
    # This feature might be intended to ensure it loads even if the global config is reset or changed.
    # We will create a start.sh that sources the theme or config.

    # Create start.sh if not exists
    if [ ! -f "$SCRIPT_DIR/start.sh" ]; then
        echo "#!/bin/bash" > "$SCRIPT_DIR/start.sh"
        echo "# HackShell Startup Script" >> "$SCRIPT_DIR/start.sh"
        echo "SCRIPT_DIR=\"\$( cd \"\$( dirname \"\${BASH_SOURCE[0]}\" )\" && pwd )\"" >> "$SCRIPT_DIR/start.sh"
        echo "CONFIG_FILE=\"\$SCRIPT_DIR/config.conf\"" >> "$SCRIPT_DIR/start.sh"
        echo "if [ -f \"\$CONFIG_FILE\" ]; then source \"\$CONFIG_FILE\"; else THEME=\"hacker\"; fi" >> "$SCRIPT_DIR/start.sh"
        echo "THEME_FILE=\"\$SCRIPT_DIR/themes/\$THEME.bashrc\"" >> "$SCRIPT_DIR/start.sh"
        echo "if [ -f \"\$THEME_FILE\" ]; then exec bash --rcfile \"\$THEME_FILE\"; else exec bash; fi" >> "$SCRIPT_DIR/start.sh"
        chmod +x "$SCRIPT_DIR/start.sh"
    fi

    cat > "$HOME/.bashrc" << EOF
#!/bin/bash

# This file was modified by HackShell Installer

# Launch HackShell
if [ -d "$SCRIPT_DIR" ]; then
    cd "$SCRIPT_DIR"
    exec bash start.sh
else
    echo "HackShell not found in $SCRIPT_DIR"
    echo "Please reinstall HackShell"
fi
EOF
    
    chmod +x "$HOME/.bashrc"
    
    # Create script to restore original shell if needed
    cat > "$SCRIPT_DIR/restore_shell.sh" << 'EOF'
#!/bin/bash

# Colors
green='\033[1;92m'
yellow='\033[1;93m'
red='\033[1;91m'
reset='\033[0m'

echo -e "${yellow}HackShell - Restore Original Shell${reset}"
echo ""

if [ -f "$HOME/.bashrc.hackshell.bak" ]; then
    cp "$HOME/.bashrc.hackshell.bak" "$HOME/.bashrc"
    echo -e "${green}Original shell restored!${reset}"
else
    # If no backup exists, create a minimal .bashrc
    cat > "$HOME/.bashrc" << 'END'
#!/bin/bash
# Default .bashrc file
END
    echo -e "${yellow}No backup found. Created a minimal .bashrc file.${reset}"
fi

echo -e "${yellow}Please restart Termux to apply changes.${reset}"
EOF
    
    chmod +x "$SCRIPT_DIR/restore_shell.sh"
    
    echo -e "${green}HackShell has been set as your default shell!${reset}"
    echo -e "${yellow}To restore your original shell, run:${reset}"
    echo -e "${cyan}bash $SCRIPT_DIR/restore_shell.sh${reset}"
    echo ""
    echo -e "${yellow}Please restart Termux to apply changes.${reset}"
    sleep 3
}

# Android Tweaks
android_tweaks() {
    display_header
    echo -e "${yellow}Android Tweaks${reset}"
    echo ""
    
    # Check if Termux is being used
    if [ ! -d "/data/data/com.termux" ]; then
        echo -e "${red}This feature only works on Termux.${reset}"
        echo -e "${yellow}HackShell is designed for Android Termux environment.${reset}"
        sleep 3
        return
    fi
    
    # Check for termux-api package
    if ! command -v termux-toast &> /dev/null; then
        echo -e "${yellow}Termux API not found. Installing...${reset}"
        pkg install -y termux-api
        echo ""
    fi
    
    while true; do
        display_header
        echo -e "${yellow}Android Tweaks Menu${reset}"
        echo ""
        echo -e "${cyan}[1]${reset} Setup Extra Keys Row"
        echo -e "${cyan}[2]${reset} Configure Termux Permissions"
        echo -e "${cyan}[3]${reset} Install Essential Android Tools"
        echo -e "${cyan}[4]${reset} Setup Quick Toggles"
        echo -e "${cyan}[5]${reset} Back to Main Menu"
        echo ""
        read -p "Select an option: " choice
        
        case $choice in
            1) setup_extra_keys ;;
            2) configure_permissions ;;
            3) install_android_tools ;;
            4) setup_quick_toggles ;;
            5) return ;;
            *) 
                echo -e "${red}Invalid option!${reset}"
                sleep 1
                ;;
        esac
    done
}

# Setup Extra Keys Row for Termux
setup_extra_keys() {
    display_header
    echo -e "${yellow}Setup Extra Keys Row${reset}"
    echo ""
    
    # Create the directory if it doesn't exist
    mkdir -p $HOME/.termux
    
    echo -e "${cyan}Select keyboard layout:${reset}"
    echo -e "${cyan}[1]${reset} Hacker Layout (ESC, TAB, CTRL, ALT, -, /, HOME, END, UP, DOWN, LEFT, RIGHT)"
    echo -e "${cyan}[2]${reset} Coder Layout (ESC, TAB, CTRL, ALT, {, }, [, ], <, >, $, |)"
    echo -e "${cyan}[3]${reset} Full Layout (Multiple rows with all special keys)"
    echo -e "${cyan}[4]${reset} Custom Layout (Create your own)"
    echo -e "${cyan}[5]${reset} Cancel"
    echo ""
    read -p "Select an option: " kb_choice
    
    case $kb_choice in
        1)
            cat > $HOME/.termux/termux.properties << 'EOF'
# HackShell Extra Keys Configuration - Hacker Layout
extra-keys = [['ESC','TAB','CTRL','ALT','-','/','HOME','END','UP','DOWN','LEFT','RIGHT']]
EOF
            ;;
        2)
            cat > $HOME/.termux/termux.properties << 'EOF'
# HackShell Extra Keys Configuration - Coder Layout
extra-keys = [['ESC','TAB','CTRL','ALT','{','}','[',']','<','>','$','|']]
EOF
            ;;
        3)
            cat > $HOME/.termux/termux.properties << 'EOF'
# HackShell Extra Keys Configuration - Full Layout
extra-keys = [['ESC','/','-','HOME','UP','END','PGUP'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN']]
extra-keys-style = arrows-only
EOF
            ;;
        4)
            echo -e "${cyan}Creating custom keyboard layout:${reset}"
            echo -e "${yellow}Enter keys for your extra keys row (space-separated):${reset}"
            echo -e "${green}Available keys: ESC, TAB, CTRL, ALT, UP, DOWN, LEFT, RIGHT, HOME, END, PGUP, PGDN${reset}"
            echo -e "${green}You can also use symbols directly: -, /, |, \, {, }, [, ], <, >, $, etc.${reset}"
            read -p "> " custom_keys
            
            # Format the input as an array
            formatted_keys="['"
            formatted_keys+=$(echo $custom_keys | sed "s/ /','/g")
            formatted_keys+="']"
            
            cat > $HOME/.termux/termux.properties << EOF
# HackShell Extra Keys Configuration - Custom Layout
extra-keys = [$formatted_keys]
EOF
            ;;
        5)
            echo -e "${yellow}Operation cancelled.${reset}"
            sleep 2
            return
            ;;
        *)
            echo -e "${red}Invalid option!${reset}"
            sleep 2
            return
            ;;
    esac
    
    echo -e "${green}Extra keys configured successfully!${reset}"
    echo -e "${yellow}Restart Termux to apply changes.${reset}"
    sleep 3
}

# Configure Termux Permissions
configure_permissions() {
    display_header
    echo -e "${yellow}Configure Termux Permissions${reset}"
    echo ""
    
    if ! command -v termux-setup-storage &> /dev/null; then
        echo -e "${red}Termux API not installed.${reset}"
        echo -e "${yellow}Installing Termux API...${reset}"
        pkg install -y termux-api
    fi
    
    echo -e "${cyan}Select permissions to configure:${reset}"
    echo -e "${cyan}[1]${reset} Setup Storage Access"
    echo -e "${cyan}[2]${reset} Configure Camera Access"
    echo -e "${cyan}[3]${reset} Configure Microphone Access"
    echo -e "${cyan}[4]${reset} Configure SMS Access"
    echo -e "${cyan}[5]${reset} Configure Contact Access"
    echo -e "${cyan}[6]${reset} Configure Location Access"
    echo -e "${cyan}[7]${reset} Back"
    echo ""
    read -p "Select an option: " perm_choice
    
    case $perm_choice in
        1)
            echo -e "${yellow}Setting up storage access...${reset}"
            termux-setup-storage
            ;;
        2)
            echo -e "${yellow}Checking camera access...${reset}"
            termux-camera-info
            sleep 3
            ;;
        3)
            echo -e "${yellow}Testing microphone access...${reset}"
            echo -e "${cyan}This will record a 3-second audio clip.${reset}"
            read -p "Press Enter to continue or Ctrl+C to cancel..."
            termux-microphone-record -d 3 -f $HOME/test_recording.mp3
            echo -e "${green}Recording saved to $HOME/test_recording.mp3${reset}"
            sleep 2
            ;;
        4)
            echo -e "${yellow}Testing SMS access...${reset}"
            termux-sms-list -l 1
            sleep 3
            ;;
        5)
            echo -e "${yellow}Testing contacts access...${reset}"
            termux-contact-list
            sleep 3
            ;;
        6)
            echo -e "${yellow}Testing location access...${reset}"
            termux-location
            sleep 3
            ;;
        7)
            return
            ;;
        *)
            echo -e "${red}Invalid option!${reset}"
            sleep 1
            ;;
    esac
    
    echo -e "${green}Done!${reset}"
    sleep 2
}

# Install Essential Android Tools
install_android_tools() {
    display_header
    echo -e "${yellow}Install Essential Android Tools${reset}"
    echo ""
    
    echo -e "${cyan}Select tools to install:${reset}"
    echo -e "${cyan}[1]${reset} Termux API (Integrate with Android)"
    echo -e "${cyan}[2]${reset} ADB & Fastboot Tools (For device debugging)"
    echo -e "${cyan}[3]${reset} Network Tools (nmap, netcat, curl)"
    echo -e "${cyan}[4]${reset} Metasploit Framework"
    echo -e "${cyan}[5]${reset} Termux:Boot (Autostart scripts)"
    echo -e "${cyan}[6]${reset} Termux:Widget (Quick shortcuts)"
    echo -e "${cyan}[7]${reset} Termux:Styling (Additional fonts and colors)"
    echo -e "${cyan}[8]${reset} Back"
    echo ""
    read -p "Select an option: " tool_choice
    
    case $tool_choice in
        1)
            echo -e "${yellow}Installing Termux API...${reset}"
            pkg install -y termux-api
            echo -e "${green}Installed! You also need to install the Termux:API app from Google Play or F-Droid.${reset}"
            ;;
        2)
            echo -e "${yellow}Installing ADB & Fastboot Tools...${reset}"
            pkg install -y android-tools
            echo -e "${green}Installed! Use 'adb devices' to list connected devices.${reset}"
            ;;
        3)
            echo -e "${yellow}Installing Network Tools...${reset}"
            pkg install -y nmap netcat curl wget net-tools
            echo -e "${green}Installed! You can now use nmap, nc, curl, and wget commands.${reset}"
            ;;
        4)
            echo -e "${yellow}Installing Metasploit Framework...${reset}"
            echo -e "${red}Warning: This will take significant storage space and time.${reset}"
            read -p "Continue? (y/n): " confirm
            if [[ "$confirm" = "y" || "$confirm" = "Y" ]]; then
                pkg install -y metasploit
                echo -e "${green}Installed! Start with 'msfconsole' command.${reset}"
            else
                echo -e "${yellow}Installation cancelled.${reset}"
            fi
            ;;
        5)
            echo -e "${yellow}Note: You need to install the Termux:Boot app from Google Play or F-Droid.${reset}"
            read -p "Press Enter to continue..."
            pkg install -y termux-boot
            echo -e "${green}Installed! Create scripts in ~/.termux/boot/ to run at device startup.${reset}"
            ;;
        6)
            echo -e "${yellow}Note: You need to install the Termux:Widget app from Google Play or F-Droid.${reset}"
            read -p "Press Enter to continue..."
            mkdir -p ~/.shortcuts
            mkdir -p ~/.shortcuts/icons
            echo -e "${green}Setup complete! Create scripts in ~/.shortcuts/ for widget access.${reset}"
            ;;
        7)
            echo -e "${yellow}Note: You need to install the Termux:Styling app from Google Play or F-Droid.${reset}"
            read -p "Press Enter to continue..."
            pkg install -y termux-styling
            echo -e "${green}Installed! You can now use additional fonts and colors.${reset}"
            ;;
        8)
            return
            ;;
        *)
            echo -e "${red}Invalid option!${reset}"
            sleep 1
            ;;
    esac
    
    sleep 3
}

# Setup Quick Toggles
setup_quick_toggles() {
    display_header
    echo -e "${yellow}Setup Quick Toggles${reset}"
    echo ""
    
    # Check for termux-api
    if ! command -v termux-toast &> /dev/null; then
        echo -e "${red}Termux API not installed.${reset}"
        echo -e "${yellow}Installing Termux API...${reset}"
        pkg install -y termux-api
        echo ""
    fi
    
    # Create the shortcuts directory if it doesn't exist
    mkdir -p $HOME/.shortcuts
    mkdir -p $HOME/.shortcuts/icons
    
    echo -e "${cyan}Select quick toggles to create:${reset}"
    echo -e "${cyan}[1]${reset} WiFi Toggle"
    echo -e "${cyan}[2]${reset} Bluetooth Toggle"
    echo -e "${cyan}[3]${reset} Flashlight Toggle"
    echo -e "${cyan}[4]${reset} Battery Status"
    echo -e "${cyan}[5]${reset} System Info"
    echo -e "${cyan}[6]${reset} Create All Toggles"
    echo -e "${cyan}[7]${reset} Back"
    echo ""
    read -p "Select an option: " toggle_choice
    
    case $toggle_choice in
        1)
            create_wifi_toggle
            ;;
        2)
            create_bluetooth_toggle
            ;;
        3)
            create_flashlight_toggle
            ;;
        4)
            create_battery_status
            ;;
        5)
            create_system_info
            ;;
        6)
            create_wifi_toggle
            create_bluetooth_toggle
            create_flashlight_toggle
            create_battery_status
            create_system_info
            ;;
        7)
            return
            ;;
        *)
            echo -e "${red}Invalid option!${reset}"
            sleep 1
            return
            ;;
    esac
    
    echo -e "${green}Quick toggles created successfully!${reset}"
    echo -e "${yellow}You can access them using Termux:Widget from your home screen.${reset}"
    echo -e "${yellow}Note: You need to install the Termux:Widget app from Google Play or F-Droid.${reset}"
    sleep 3
}

# Helper functions for quick toggles
create_wifi_toggle() {
    cat > $HOME/.shortcuts/wifi_toggle.sh << 'EOF'
#!/bin/bash
termux-wifi-connectioninfo || termux-wifi-enable
termux-toast "WiFi toggled"
EOF
    chmod +x $HOME/.shortcuts/wifi_toggle.sh
    echo -e "${green}WiFi toggle created!${reset}"
}

create_bluetooth_toggle() {
    cat > $HOME/.shortcuts/bluetooth_toggle.sh << 'EOF'
#!/bin/bash
termux-bluetooth-connectinfo || termux-bluetooth-enable
termux-toast "Bluetooth toggled"
EOF
    chmod +x $HOME/.shortcuts/bluetooth_toggle.sh
    echo -e "${green}Bluetooth toggle created!${reset}"
}

create_flashlight_toggle() {
    cat > $HOME/.shortcuts/flashlight_toggle.sh << 'EOF'
#!/bin/bash
termux-torch on
sleep 1
termux-torch off
termux-toast "Flashlight toggled"
EOF
    chmod +x $HOME/.shortcuts/flashlight_toggle.sh
    echo -e "${green}Flashlight toggle created!${reset}"
}

create_battery_status() {
    cat > $HOME/.shortcuts/battery_status.sh << 'EOF'
#!/bin/bash
BATTERY=$(termux-battery-status)
CHARGING=$(echo $BATTERY | grep -o '"plugged": true' || echo "false")
LEVEL=$(echo $BATTERY | grep -o '"percentage": [0-9]*' | grep -o '[0-9]*')

if [[ "$CHARGING" == *"true"* ]]; then
    STATUS="Charging: $LEVEL%"
else
    STATUS="Battery: $LEVEL%"
fi

termux-toast "$STATUS"
EOF
    chmod +x $HOME/.shortcuts/battery_status.sh
    echo -e "${green}Battery status toggle created!${reset}"
}

create_system_info() {
    cat > $HOME/.shortcuts/system_info.sh << 'EOF'
#!/bin/bash
# Get system info
CPU=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^[ \t]*//')
RAM=$(free -h | grep Mem | awk '{print $3 " / " $2}' | sed 's/G//g')
UPTIME=$(uptime -p | sed 's/up //')
STORAGE=$(df -h $HOME | tail -1 | awk '{print $3 " / " $2}' | sed 's/G//g')

# Display info
INFO="CPU: $CPU\nRAM: $RAM\nUptime: $UPTIME\nStorage: $STORAGE"

termux-toast "$INFO"
EOF
    chmod +x $HOME/.shortcuts/system_info.sh
    echo -e "${green}System info toggle created!${reset}"
}

# Toggle system info
toggle_sysinfo() {
    if [ "$SHOW_SYSINFO" = "true" ]; then
        SHOW_SYSINFO="false"
        echo -e "${yellow}System information display disabled${reset}"
    else
        SHOW_SYSINFO="true"
        echo -e "${green}System information display enabled${reset}"
    fi
    sleep 1
}

# Set custom greeting name
set_custom_name() {
    display_header
    echo -e "Enter your name for custom greeting:"
    echo -e "(Leave empty to remove custom greeting)"
    echo -e "${yellow}Note: Special characters will be filtered for security${reset}"
    echo ""
    read -p "> " custom_name
    
    # Sanitize input
    custom_name=$(sanitize_input "$custom_name")
    
    # Additional validation - only allow alphanumeric and common safe characters
    if [[ "$custom_name" =~ ^[a-zA-Z0-9\ ._-]*$ ]]; then
        CUSTOM_NAME="$custom_name"
        if [ -n "$custom_name" ]; then
            echo -e "${green}Custom name set to: $custom_name${reset}"
        else
            echo -e "${yellow}Custom greeting removed${reset}"
        fi
    else
        echo -e "${red}Invalid characters detected! Name not changed.${reset}"
        echo -e "${yellow}Please use only letters, numbers, spaces, dots, underscores, and dashes.${reset}"
    fi
    sleep 2
}

# Change banner style
change_banner() {
    display_header
    echo -e "Available Banner Styles:"
    echo -e "${cyan}[1]${reset} Default HackShell"
    echo -e "${cyan}[2]${reset} Minimalist"
    echo -e "${cyan}[3]${reset} Cyberpunk"
    echo -e "${cyan}[4]${reset} Matrix"
    echo -e "${cyan}[5]${reset} Skull"
    echo ""
    read -p "Select a banner style: " banner_choice
    
    case $banner_choice in
        1) BANNER_STYLE="default" ;;
        2) BANNER_STYLE="minimal" ;;
        3) BANNER_STYLE="cyberpunk" ;;
        4) BANNER_STYLE="matrix" ;;
        5) BANNER_STYLE="skull" ;;
        *) 
            echo -e "${red}Invalid option! Banner unchanged.${reset}"
            sleep 1
            return
            ;;
    esac
    
    echo -e "${green}Banner style set to $BANNER_STYLE${reset}"
    sleep 1
}

# Toggle welcome sound
toggle_sound() {
    if [ "$WELCOME_SOUND" = "true" ]; then
        WELCOME_SOUND="false"
        echo -e "${yellow}Welcome sound disabled${reset}"
    else
        WELCOME_SOUND="true"
        echo -e "${green}Welcome sound enabled${reset}"
    fi
    sleep 1
}

# Apply changes
apply_changes() {
    show_progress "Applying changes" 2
    # This function would regenerate the bash.bashrc file based on current config
    generate_bashrc
    echo -e "${green}Changes applied! Please restart Termux to see the changes.${reset}"
    sleep 2
}

# Function to generate bash.bashrc based on current config
generate_bashrc() {
    # Copy the appropriate template based on theme
    cp "$SCRIPT_DIR/themes/$THEME.bashrc" "$PREFIX/etc/bash.bashrc"
    
    # Modify bash.bashrc based on other settings
    if [ "$SHOW_SYSINFO" = "false" ]; then
        sed -i 's/^SHOW_SYSINFO=.*/SHOW_SYSINFO=false/' "$PREFIX/etc/bash.bashrc"
    else
        sed -i 's/^SHOW_SYSINFO=.*/SHOW_SYSINFO=true/' "$PREFIX/etc/bash.bashrc"
    fi
    
    if [ -n "$CUSTOM_NAME" ]; then
        sed -i "s/^CUSTOM_NAME=.*/CUSTOM_NAME=\"$CUSTOM_NAME\"/" "$PREFIX/etc/bash.bashrc"
    else
        sed -i 's/^CUSTOM_NAME=.*/CUSTOM_NAME=""/' "$PREFIX/etc/bash.bashrc"
    fi
    
    sed -i "s/^BANNER_STYLE=.*/BANNER_STYLE=\"$BANNER_STYLE\"/" "$PREFIX/etc/bash.bashrc"
    
    if [ "$WELCOME_SOUND" = "false" ]; then
        sed -i 's/^WELCOME_SOUND=.*/WELCOME_SOUND=false/' "$PREFIX/etc/bash.bashrc"
    else
        sed -i 's/^WELCOME_SOUND=.*/WELCOME_SOUND=true/' "$PREFIX/etc/bash.bashrc"
    fi
}

# Check dependencies before starting
check_dependencies

# Run main menu
main_menu
