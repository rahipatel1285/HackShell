#!/bin/bash

# HackShell v1.2 Enhanced - Tools Interface
# Created by Team ILLUSION || DK

# Get script directory (tools/)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Get project root (../)
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
green='\033[1;92m'
yellow='\033[1;93m'
white='\033[1;97m'
cyan='\033[1;96m'
red='\033[1;91m'
blue='\033[1;94m'
purple='\033[1;95m'
reset='\033[0m'

# Tool locations
TOOLS_DIR="$SCRIPT_DIR"
NETWORK_TOOLS="$TOOLS_DIR/network.sh"
SYSTEM_TOOLS="$TOOLS_DIR/system.sh"
PACKAGE_TOOLS="$TOOLS_DIR/packages.sh"
FILE_TOOLS="$TOOLS_DIR/filemanager.sh"

# Display header
display_header() {
    clear
    echo -e "${yellow}===============================================${reset}"
    echo -e "${cyan}            HackShell Tools Suite              ${reset}"
    echo -e "${yellow}===============================================${reset}"
    echo -e "${green}Created by Team ILLUSION || DK${reset}"
    echo ""
}

# Main menu
main_menu() {
    while true; do
        display_header
        echo -e "${cyan}[1]${reset} Network Tools"
        echo -e "${cyan}[2]${reset} System Monitor"
        echo -e "${cyan}[3]${reset} Advanced System Dashboard"
        echo -e "${cyan}[4]${reset} Performance Monitor"
        echo -e "${cyan}[5]${reset} Package Manager"
        echo -e "${cyan}[6]${reset} File Manager"
        echo -e "${cyan}[7]${reset} Return to Shell"
        echo ""
        read -p "Select an option: " choice
        
        case $choice in
            1) 
                if [ -f "$NETWORK_TOOLS" ]; then
                    bash "$NETWORK_TOOLS"
                else
                    echo -e "${red}Network tools not installed yet.${reset}"
                    echo -e "${yellow}Installing...${reset}"
                    install_network_tools
                    bash "$NETWORK_TOOLS"
                fi
                ;;
            2) 
                if [ -f "$SYSTEM_TOOLS" ]; then
                    bash "$SYSTEM_TOOLS"
                else
                    echo -e "${red}System monitor not installed yet.${reset}"
                    echo -e "${yellow}Installing...${reset}"
                    install_system_tools
                    bash "$SYSTEM_TOOLS"
                fi
                ;;
            3) 
                if [ -f "$TOOLS_DIR/system_monitor.sh" ]; then
                    bash "$TOOLS_DIR/system_monitor.sh"
                else
                    echo -e "${red}Advanced system monitor not found!${reset}"
                    sleep 2
                fi
                ;;
            4) 
                if [ -f "$TOOLS_DIR/performance_monitor.sh" ]; then
                    bash "$TOOLS_DIR/performance_monitor.sh"
                else
                    echo -e "${red}Performance monitor not found!${reset}"
                    sleep 2
                fi
                ;;
            5) 
                if [ -f "$PACKAGE_TOOLS" ]; then
                    bash "$PACKAGE_TOOLS"
                else
                    echo -e "${red}Package manager not installed yet.${reset}"
                    echo -e "${yellow}Installing...${reset}"
                    install_package_tools
                    bash "$PACKAGE_TOOLS"
                fi
                ;;
            6) 
                if [ -f "$FILE_TOOLS" ]; then
                    bash "$FILE_TOOLS"
                else
                    echo -e "${red}File manager not installed yet.${reset}"
                    echo -e "${yellow}Installing...${reset}"
                    install_file_tools
                    bash "$FILE_TOOLS"
                fi
                ;;
            7) 
                echo -e "${green}Returning to shell...${reset}"
                exit 0
                ;;
            *) 
                echo -e "${red}Invalid option!${reset}"
                sleep 1
                ;;
        esac
    done
}

# Install network tools
install_network_tools() {
    if command -v pkg >/dev/null 2>&1; then
        pkg install -y speedtest-cli nmap curl wget net-tools iproute2
    fi
    
    # Create network tools script
    cat > "$NETWORK_TOOLS" << 'INNEREOF'
#!/bin/bash

# Colors
green='\033[1;92m'
yellow='\033[1;93m'
white='\033[1;97m'
cyan='\033[1;96m'
red='\033[1;91m'
blue='\033[1;94m'
reset='\033[0m'

# Display header
display_header() {
    clear
    echo -e "${blue}===============================================${reset}"
    echo -e "${cyan}            Network Tools                     ${reset}"
    echo -e "${blue}===============================================${reset}"
    echo ""
}

# Main menu
main_menu() {
    while true; do
        display_header
        echo -e "${cyan}[1]${reset} Speed Test"
        echo -e "${cyan}[2]${reset} IP Information"
        echo -e "${cyan}[3]${reset} Port Scanner"
        echo -e "${cyan}[4]${reset} Network Status"
        echo -e "${cyan}[5]${reset} Back to Main Menu"
        echo ""
        read -p "Select an option: " choice
        
        case $choice in
            1) speed_test ;;
            2) ip_info ;;
            3) port_scan ;;
            4) network_status ;;
            5) 
                echo -e "${green}Returning to main menu...${reset}"
                return
                ;;
            *) 
                echo -e "${red}Invalid option!${reset}"
                sleep 1
                ;;
        esac
    done
}

# Speed test
speed_test() {
    display_header
    echo -e "${yellow}Running speed test...${reset}"
    echo -e "${yellow}This may take a minute...${reset}"
    echo ""
    if command -v speedtest-cli >/dev/null 2>&1; then
        speedtest-cli --simple
    else
        echo -e "${red}speedtest-cli not found. Please install it.${reset}"
    fi
    echo ""
    read -p "Press Enter to continue..."
}

# IP information
ip_info() {
    display_header
    echo -e "${yellow}Fetching IP information...${reset}"
    echo ""
    echo -e "${cyan}Local IP:${reset}"
    if command -v ifconfig >/dev/null 2>&1; then
        ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'
    elif command -v ip >/dev/null 2>&1; then
        ip addr show | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'
    else
        echo "Command not found: ifconfig or ip"
    fi
    echo ""
    echo -e "${cyan}Public IP:${reset}"
    curl -s ifconfig.me
    echo ""
    echo -e "${cyan}IP Details:${reset}"
    curl -s ipinfo.io
    echo ""
    read -p "Press Enter to continue..."
}

# Port scanner
port_scan() {
    display_header
    echo -e "${yellow}Port Scanner${reset}"
    echo ""
    read -p "Enter target IP/hostname: " target
    read -p "Enter port range (e.g. 1-1000): " range
    
    if [[ -z "$target" ]]; then
        echo -e "${red}Target cannot be empty!${reset}"
        sleep 2
        return
    fi
    
    if [[ -z "$range" ]]; then
        range="1-1000"
    fi
    
    echo -e "${yellow}Scanning ports $range on $target...${reset}"
    echo -e "${yellow}This may take a while...${reset}"
    echo ""
    if command -v nmap >/dev/null 2>&1; then
        nmap -p $range $target
    else
        echo -e "${red}nmap not found. Please install it.${reset}"
    fi
    echo ""
    read -p "Press Enter to continue..."
}

# Network status
network_status() {
    display_header
    echo -e "${yellow}Network Status${reset}"
    echo ""
    echo -e "${cyan}Network Interfaces:${reset}"
    if command -v ifconfig >/dev/null 2>&1; then
        ifconfig
    elif command -v ip >/dev/null 2>&1; then
        ip addr show
    else
        echo "Command not found: ifconfig or ip"
    fi
    
    echo ""
    echo -e "${cyan}Routing Table:${reset}"
    if command -v netstat >/dev/null 2>&1; then
        netstat -r
    elif command -v ip >/dev/null 2>&1; then
        ip route
    else
        echo "Command not found: netstat or ip"
    fi
    
    echo ""
    echo -e "${cyan}Active Connections:${reset}"
    if command -v netstat >/dev/null 2>&1; then
        netstat -tunap 2>/dev/null || netstat -tuna
    elif command -v ss >/dev/null 2>&1; then
        ss -tunap
    else
        echo "Command not found: netstat or ss"
    fi
    echo ""
    read -p "Press Enter to continue..."
}

# Run main menu
main_menu
INNEREOF
    
    chmod +x "$NETWORK_TOOLS"
    echo -e "${green}Network tools installed successfully!${reset}"
    sleep 1
}

# Install system tools
install_system_tools() {
    if command -v pkg >/dev/null 2>&1; then
        pkg install -y htop termux-api bc
    fi
    
    # Create system tools script
    cat > "$SYSTEM_TOOLS" << 'INNEREOF'
#!/bin/bash

# Colors
green='\033[1;92m'
yellow='\033[1;93m'
white='\033[1;97m'
cyan='\033[1;96m'
red='\033[1;91m'
blue='\033[1;94m'
reset='\033[0m'

# Display header
display_header() {
    clear
    echo -e "${green}===============================================${reset}"
    echo -e "${cyan}            System Monitor                    ${reset}"
    echo -e "${green}===============================================${reset}"
    echo ""
}

# Main menu
main_menu() {
    while true; do
        display_header
        echo -e "${cyan}[1]${reset} Resource Usage (Real-time)"
        echo -e "${cyan}[2]${reset} Detailed System Info"
        echo -e "${cyan}[3]${reset} Battery Information"
        echo -e "${cyan}[4]${reset} Installed Packages"
        echo -e "${cyan}[5]${reset} Storage Analysis"
        echo -e "${cyan}[6]${reset} Back to Main Menu"
        echo ""
        read -p "Select an option: " choice
        
        case $choice in
            1) resource_usage ;;
            2) system_info ;;
            3) battery_info ;;
            4) installed_packages ;;
            5) storage_analysis ;;
            6) 
                echo -e "${green}Returning to main menu...${reset}"
                return
                ;;
            *) 
                echo -e "${red}Invalid option!${reset}"
                sleep 1
                ;;
        esac
    done
}

# Resource usage
resource_usage() {
    display_header
    echo -e "${yellow}Starting resource monitor...${reset}"
    echo -e "${yellow}Press q to quit${reset}"
    echo ""
    sleep 2
    if command -v htop >/dev/null 2>&1; then
        htop
    else
        top
    fi
}

# System info
system_info() {
    display_header
    echo -e "${yellow}Detailed System Information${reset}"
    echo ""
    
    # CPU info
    echo -e "${cyan}CPU Information:${reset}"
    if [ -f /proc/cpuinfo ]; then
        grep "model name\|processor\|cpu MHz\|cache size\|physical id\|siblings\|core id\|cores" /proc/cpuinfo
    else
        echo "CPU information not available"
    fi
    
    echo ""
    
    # Memory info
    echo -e "${cyan}Memory Information:${reset}"
    if command -v free >/dev/null 2>&1; then
        free -h
    else
        echo "Memory information not available"
    fi
    
    echo ""
    
    # Storage info
    echo -e "${cyan}Storage Information:${reset}"
    if command -v df >/dev/null 2>&1; then
        df -h
    else
        echo "Storage information not available"
    fi
    
    echo ""
    
    # Android info
    echo -e "${cyan}Android Information:${reset}"
    if [ -n "$(command -v getprop)" ]; then
        echo "Android Version: $(getprop ro.build.version.release)"
        echo "SDK Version: $(getprop ro.build.version.sdk)"
        echo "Device: $(getprop ro.product.model) ($(getprop ro.product.device))"
        echo "Manufacturer: $(getprop ro.product.manufacturer)"
    else
        echo "Android information not available"
    fi
    
    echo ""
    
    # Termux info
    echo -e "${cyan}Termux Information:${reset}"
    if [ -n "$(command -v termux-info)" ]; then
        termux-info
    else
        echo "Termux information not available"
    fi
    
    echo ""
    
    # Python info
    echo -e "${cyan}Python Information:${reset}"
    if [ -n "$(command -v python)" ]; then
        echo "Python Version: $(python --version 2>&1)"
        echo ""
        echo "Installed Python Packages:"
        pip list
    else
        echo "Python not installed"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

# Battery info
battery_info() {
    display_header
    echo -e "${yellow}Battery Information${reset}"
    echo ""
    
    if [ -e "/sys/class/power_supply/battery/capacity" ]; then
        BATT_CAPACITY=$(cat /sys/class/power_supply/battery/capacity)
        BATT_STATUS=$(cat /sys/class/power_supply/battery/status)
        BATT_TEMP=$(cat /sys/class/power_supply/battery/temp)
        
        # Check if bc is installed
        if command -v bc >/dev/null 2>&1; then
            BATT_TEMP=$(echo "scale=1; $BATT_TEMP/10" | bc)
        else
            BATT_TEMP="${BATT_TEMP} mC (bc command not available for conversion)"
        fi
        
        echo -e "${cyan}Battery Capacity:${reset} ${BATT_CAPACITY}%"
        echo -e "${cyan}Battery Status:${reset} ${BATT_STATUS}"
        echo -e "${cyan}Battery Temperature:${reset} ${BATT_TEMP}°C"
        
        # Battery health assessment
        echo -e "${cyan}Battery Health Assessment:${reset}"
        if [ -e "/sys/class/power_supply/battery/charge_full" ] && [ -e "/sys/class/power_supply/battery/charge_full_design" ]; then
            CHARGE_FULL=$(cat /sys/class/power_supply/battery/charge_full)
            CHARGE_DESIGN=$(cat /sys/class/power_supply/battery/charge_full_design)
            
            # Check if bc is installed
            if command -v bc >/dev/null 2>&1; then
                HEALTH_PERCENT=$(echo "scale=2; ($CHARGE_FULL/$CHARGE_DESIGN)*100" | bc)

                echo -e "${cyan}Battery Health:${reset} ${HEALTH_PERCENT}%"

                if (( $(echo "$HEALTH_PERCENT > 90" | bc -l) )); then
                    echo -e "${green}Health Status: Excellent${reset}"
                elif (( $(echo "$HEALTH_PERCENT > 80" | bc -l) )); then
                    echo -e "${green}Health Status: Good${reset}"
                elif (( $(echo "$HEALTH_PERCENT > 60" | bc -l) )); then
                    echo -e "${yellow}Health Status: Fair${reset}"
                else
                    echo -e "${red}Health Status: Poor - Consider battery replacement${reset}"
                fi
            else
                echo "Cannot calculate health percentage (bc command not available)"
            fi
        else
            echo "Battery health information not available"
        fi
        
        # Charging suggestions
        echo -e "\n${cyan}Charging Suggestions:${reset}"
        if [ "$BATT_STATUS" = "Charging" ]; then
            if [ "$BATT_CAPACITY" -gt 90 ]; then
                echo -e "${yellow}Tip: Your battery is almost full. Unplugging at 90-95% instead of 100% can extend battery lifespan.${reset}"
            fi
        else
            if [ "$BATT_CAPACITY" -lt 20 ]; then
                echo -e "${red}Warning: Battery level is low. Connect to a charger soon.${reset}"
            elif [ "$BATT_CAPACITY" -lt 10 ]; then
                echo -e "${red}Critical: Battery level is critically low. Connect to a charger immediately to avoid shutdown.${reset}"
            fi
        fi
    else
        echo "Battery information not available"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

# Installed packages
installed_packages() {
    display_header
    echo -e "${yellow}Installed Packages${reset}"
    echo ""
    
    echo -e "${cyan}Termux Packages:${reset}"
    if command -v pkg >/dev/null 2>&1; then
        pkg list-installed
    else
        echo "pkg command not found"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

# Storage analysis
storage_analysis() {
    display_header
    echo -e "${yellow}Storage Analysis${reset}"
    echo ""
    
    echo -e "${cyan}Storage Overview:${reset}"
    df -h
    
    echo -e "\n${cyan}Largest Directories in Home:${reset}"
    du -h -d 1 $HOME 2>/dev/null | sort -hr
    
    echo -e "\n${cyan}Largest Files in Home (Top 10):${reset}"
    find $HOME -type f -exec du -h {} \; 2>/dev/null | sort -hr | head -n 10
    
    echo ""
    read -p "Press Enter to continue..."
}

# Run main menu
main_menu
INNEREOF
    
    chmod +x "$SYSTEM_TOOLS"
    echo -e "${green}System monitor installed successfully!${reset}"
    sleep 1
}

# Install package tools
install_package_tools() {
    # Create package tools script
    cat > "$PACKAGE_TOOLS" << 'INNEREOF'
#!/bin/bash

# Colors
green='\033[1;92m'
yellow='\033[1;93m'
white='\033[1;97m'
cyan='\033[1;96m'
red='\033[1;91m'
blue='\033[1;94m'
reset='\033[0m'

# Display header
display_header() {
    clear
    echo -e "${red}===============================================${reset}"
    echo -e "${cyan}            Package Manager                  ${reset}"
    echo -e "${red}===============================================${reset}"
    echo ""
}

# Main menu
main_menu() {
    while true; do
        display_header
        echo -e "${cyan}[1]${reset} Search Packages"
        echo -e "${cyan}[2]${reset} Install Package"
        echo -e "${cyan}[3]${reset} Remove Package"
        echo -e "${cyan}[4]${reset} Update All Packages"
        echo -e "${cyan}[5]${reset} List Installed Packages"
        echo -e "${cyan}[6]${reset} Back to Main Menu"
        echo ""
        read -p "Select an option: " choice
        
        case $choice in
            1) search_package ;;
            2) install_package ;;
            3) remove_package ;;
            4) update_packages ;;
            5) list_packages ;;
            6) 
                echo -e "${green}Returning to main menu...${reset}"
                return
                ;;
            *) 
                echo -e "${red}Invalid option!${reset}"
                sleep 1
                ;;
        esac
    done
}

# Search package
search_package() {
    display_header
    echo -e "${yellow}Search Packages${reset}"
    echo ""
    read -p "Enter package name to search: " package_name
    
    if [[ -z "$package_name" ]]; then
        echo -e "${red}Package name cannot be empty!${reset}"
        sleep 2
        return
    fi
    
    echo -e "${yellow}Searching for '$package_name'...${reset}"
    echo ""
    pkg search "$package_name"
    echo ""
    read -p "Press Enter to continue..."
}

# Install package
install_package() {
    display_header
    echo -e "${yellow}Install Package${reset}"
    echo ""
    read -p "Enter package name to install: " package_name
    
    if [[ -z "$package_name" ]]; then
        echo -e "${red}Package name cannot be empty!${reset}"
        sleep 2
        return
    fi
    
    echo -e "${yellow}Installing '$package_name'...${reset}"
    echo ""
    pkg install -y "$package_name"
    echo ""
    read -p "Press Enter to continue..."
}

# Remove package
remove_package() {
    display_header
    echo -e "${yellow}Remove Package${reset}"
    echo ""
    read -p "Enter package name to remove: " package_name
    
    if [[ -z "$package_name" ]]; then
        echo -e "${red}Package name cannot be empty!${reset}"
        sleep 2
        return
    fi
    
    echo -e "${yellow}Removing '$package_name'...${reset}"
    echo ""
    pkg uninstall "$package_name"
    echo ""
    read -p "Press Enter to continue..."
}

# Update packages
update_packages() {
    display_header
    echo -e "${yellow}Update All Packages${reset}"
    echo ""
    echo -e "${yellow}Updating package lists...${reset}"
    pkg update -y
    echo ""
    echo -e "${yellow}Upgrading packages...${reset}"
    pkg upgrade -y
    echo ""
    read -p "Press Enter to continue..."
}

# List packages
list_packages() {
    display_header
    echo -e "${yellow}Installed Packages${reset}"
    echo ""
    pkg list-installed
    echo ""
    read -p "Press Enter to continue..."
}

# Run main menu
main_menu
INNEREOF
    
    chmod +x "$PACKAGE_TOOLS"
    echo -e "${green}Package manager installed successfully!${reset}"
    sleep 1
}

# Install file tools
install_file_tools() {
    if command -v pkg >/dev/null 2>&1; then
        pkg install -y ncdu ranger
    fi
    
    # Create file tools script
    cat > "$FILE_TOOLS" << 'INNEREOF'
#!/bin/bash

# Colors
green='\033[1;92m'
yellow='\033[1;93m'
white='\033[1;97m'
cyan='\033[1;96m'
red='\033[1;91m'
blue='\033[1;94m'
purple='\033[1;95m'
reset='\033[0m'

# Display header
display_header() {
    clear
    echo -e "${purple}===============================================${reset}"
    echo -e "${cyan}            File Manager                     ${reset}"
    echo -e "${purple}===============================================${reset}"
    echo ""
}

# Main menu
main_menu() {
    while true; do
        display_header
        echo -e "${cyan}[1]${reset} Interactive File Browser (ranger)"
        echo -e "${cyan}[2]${reset} Disk Usage Analyzer (ncdu)"
        echo -e "${cyan}[3]${reset} Search Files"
        echo -e "${cyan}[4]${reset} File Operations"
        echo -e "${cyan}[5]${reset} Back to Main Menu"
        echo ""
        read -p "Select an option: " choice
        
        case $choice in
            1) file_browser ;;
            2) disk_usage ;;
            3) search_files ;;
            4) file_operations ;;
            5) 
                echo -e "${green}Returning to main menu...${reset}"
                return
                ;;
            *) 
                echo -e "${red}Invalid option!${reset}"
                sleep 1
                ;;
        esac
    done
}

# File browser
file_browser() {
    display_header
    echo -e "${yellow}Starting file browser...${reset}"
    echo -e "${yellow}Use arrow keys to navigate, q to quit${reset}"
    echo ""
    sleep 1
    ranger
}

# Disk usage analyzer
disk_usage() {
    display_header
    echo -e "${yellow}Starting disk usage analyzer...${reset}"
    echo -e "${yellow}Use arrow keys to navigate, q to quit${reset}"
    echo ""
    sleep 1
    ncdu $HOME
}

# Search files
search_files() {
    display_header
    echo -e "${yellow}Search Files${reset}"
    echo ""
    read -p "Enter search path (default: $HOME): " search_path
    read -p "Enter filename pattern (e.g. *.txt): " pattern
    
    if [[ -z "$search_path" ]]; then
        search_path="$HOME"
    fi
    
    if [[ -z "$pattern" ]]; then
        echo -e "${red}Search pattern cannot be empty!${reset}"
        sleep 2
        return
    fi
    
    echo -e "${yellow}Searching for '$pattern' in '$search_path'...${reset}"
    echo ""
    find "$search_path" -name "$pattern" -type f 2>/dev/null
    echo ""
    read -p "Press Enter to continue..."
}

# File operations
file_operations() {
    while true; do
        display_header
        echo -e "${yellow}File Operations${reset}"
        echo ""
        echo -e "${cyan}[1]${reset} Copy File/Directory"
        echo -e "${cyan}[2]${reset} Move/Rename File/Directory"
        echo -e "${cyan}[3]${reset} Delete File/Directory"
        echo -e "${cyan}[4]${reset} Create Directory"
        echo -e "${cyan}[5]${reset} Back"
        echo ""
        read -p "Select an option: " choice
        
        case $choice in
            1) 
                echo ""
                read -p "Enter source path: " src
                read -p "Enter destination path: " dest
                
                if [[ -z "$src" || -z "$dest" ]]; then
                    echo -e "${red}Source and destination cannot be empty!${reset}"
                    sleep 2
                    continue
                fi
                
                cp -r "$src" "$dest"
                echo -e "${green}Copied successfully!${reset}"
                sleep 1
                ;;
            2) 
                echo ""
                read -p "Enter source path: " src
                read -p "Enter destination path: " dest
                
                if [[ -z "$src" || -z "$dest" ]]; then
                    echo -e "${red}Source and destination cannot be empty!${reset}"
                    sleep 2
                    continue
                fi
                
                mv "$src" "$dest"
                echo -e "${green}Moved/renamed successfully!${reset}"
                sleep 1
                ;;
            3) 
                echo ""
                read -p "Enter path to delete: " path
                
                if [[ -z "$path" ]]; then
                    echo -e "${red}Path cannot be empty!${reset}"
                    sleep 2
                    continue
                fi
                
                read -p "Are you sure you want to delete '$path'? (y/n): " confirm
                
                if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                    rm -rf "$path"
                    echo -e "${green}Deleted successfully!${reset}"
                else
                    echo -e "${yellow}Deletion cancelled.${reset}"
                fi
                
                sleep 1
                ;;
            4) 
                echo ""
                read -p "Enter directory path to create: " path
                
                if [[ -z "$path" ]]; then
                    echo -e "${red}Path cannot be empty!${reset}"
                    sleep 2
                    continue
                fi
                
                mkdir -p "$path"
                echo -e "${green}Directory created successfully!${reset}"
                sleep 1
                ;;
            5) return ;;
            *) 
                echo -e "${red}Invalid option!${reset}"
                sleep 1
                ;;
        esac
    done
}

# Run main menu
main_menu
INNEREOF
    
    chmod +x "$FILE_TOOLS"
    echo -e "${green}File manager installed successfully!${reset}"
    sleep 1
}

# Run main menu
main_menu
