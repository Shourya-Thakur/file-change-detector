#!/bin/bash

#############################################################
# File Change Detector - Menu Driven Version
# A Unix utility to monitor files for content changes
# Compatible with Bash 3.2+ (macOS compatible)
# Author: Shourya Thakur
# Course: Unix Systems Programming
# Date: November 2025
#############################################################

# Configuration
CHECK_INTERVAL=2
LOG_FILE=""
MONITORED_FILES=()
STORED_CHECKSUMS=()
MONITORING_ACTIVE=false

#############################################################
# Function: print_menu
#############################################################
print_menu() {
    clear
    echo "================================"
    echo "  File Change Detector"
    echo "================================"
    echo ""
    echo "1. Monitor Single File"
    echo "2. Monitor Multiple Files"
    echo "3. Set Check Interval"
    echo "4. Exit"
    echo ""
    echo "Current interval: ${CHECK_INTERVAL} seconds"
    echo ""
    printf "Enter choice [1-4]: "
}

#############################################################
# Function: calculate_checksum
#############################################################
calculate_checksum() {
    local file="$1"
    
    if command -v md5 &> /dev/null; then
        md5 -q "$file" 2>/dev/null
    elif command -v md5sum &> /dev/null; then
        md5sum "$file" 2>/dev/null | awk '{print $1}'
    elif command -v shasum &> /dev/null; then
        shasum "$file" 2>/dev/null | awk '{print $1}'
    else
        stat -f "%z-%m" "$file" 2>/dev/null || stat -c "%s-%Y" "$file" 2>/dev/null
    fi
}

#############################################################
# Function: validate_file
#############################################################
validate_file() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        echo "Error: File '$file' does not exist"
        return 1
    fi
    
    if [ ! -r "$file" ]; then
        echo "Error: File '$file' is not readable"
        return 1
    fi
    
    return 0
}

#############################################################
# Function: log_message
#############################################################
log_message() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local output="[$timestamp] $message"
    
    echo "$output"
    
    if [ -n "$LOG_FILE" ]; then
        echo "$output" >> "$LOG_FILE"
    fi
}

#############################################################
# Function: get_checksum_for_file
#############################################################
get_checksum_for_file() {
    local target_file="$1"
    local index=0
    
    for file in "${MONITORED_FILES[@]}"; do
        if [ "$file" = "$target_file" ]; then
            echo "${STORED_CHECKSUMS[$index]}"
            return 0
        fi
        index=$((index + 1))
    done
    echo ""
}

#############################################################
# Function: update_checksum_for_file
#############################################################
update_checksum_for_file() {
    local target_file="$1"
    local new_checksum="$2"
    local index=0
    
    for file in "${MONITORED_FILES[@]}"; do
        if [ "$file" = "$target_file" ]; then
            STORED_CHECKSUMS[$index]="$new_checksum"
            return 0
        fi
        index=$((index + 1))
    done
}

#############################################################
# Function: handle_interrupt
#############################################################
handle_interrupt() {
    MONITORING_ACTIVE=false
}

#############################################################
# Function: start_monitoring
#############################################################
start_monitoring() {
    local files=("$@")
    
    clear
    echo "Starting Monitor..."
    echo ""
    
    local index=0
    for file in "${files[@]}"; do
        if validate_file "$file"; then
            MONITORED_FILES[$index]="$file"
            STORED_CHECKSUMS[$index]=$(calculate_checksum "$file")
            log_message "Monitoring: $file"
            index=$((index + 1))
        else
            echo ""
            echo "Returning to menu in 2 seconds..."
            sleep 2
            return 1
        fi
    done
    
    echo ""
    log_message "Press Ctrl+C to stop"
    echo ""
    
    # Set monitoring flag
    MONITORING_ACTIVE=true
    
    # Set up signal trap
    trap handle_interrupt SIGINT SIGTERM
    
    # Monitoring loop
    while $MONITORING_ACTIVE; do
        for file in "${MONITORED_FILES[@]}"; do
            if [ ! -f "$file" ]; then
                log_message "Warning: File '$file' no longer exists"
                continue
            fi
            
            local current_checksum=$(calculate_checksum "$file")
            local stored_checksum=$(get_checksum_for_file "$file")
            
            if [ "$current_checksum" != "$stored_checksum" ]; then
                log_message "File $file has been modified."
                update_checksum_for_file "$file" "$current_checksum"
            fi
        done
        sleep "$CHECK_INTERVAL"
    done
    
    # After loop exits
    echo ""
    echo ""
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Monitoring stopped."
    echo ""
    echo "Returning to menu in 2 seconds..."
    sleep 2
    
    # Reset trap
    trap - SIGINT SIGTERM
    
    # Clean up
    MONITORED_FILES=()
    STORED_CHECKSUMS=()
    LOG_FILE=""
}

#############################################################
# Function: option_single_file
#############################################################
option_single_file() {
    clear
    echo "Monitor Single File"
    echo "-------------------"
    echo ""
    printf "Enter file path: "
    read -r filepath
    
    if [ -z "$filepath" ]; then
        echo "No file specified!"
        sleep 2
        return
    fi
    
    start_monitoring "$filepath"
}

#############################################################
# Function: option_multiple_files
#############################################################
option_multiple_files() {
    clear
    echo "Monitor Multiple Files"
    echo "----------------------"
    echo ""
    echo "Enter file paths separated by spaces:"
    printf "Files: "
    read -r -a filepaths
    
    if [ ${#filepaths[@]} -eq 0 ]; then
        echo "No files specified!"
        sleep 2
        return
    fi
    
    start_monitoring "${filepaths[@]}"
}

#############################################################
# Function: option_set_interval
#############################################################
option_set_interval() {
    clear
    echo "Set Check Interval"
    echo "------------------"
    echo ""
    echo "Current interval: ${CHECK_INTERVAL} seconds"
    echo ""
    echo "How often should the program check for changes?"
    echo "  - Lower value (1-2) = Faster detection, more CPU usage"
    echo "  - Higher value (5-10) = Slower detection, less CPU usage"
    echo ""
    printf "Enter new interval in seconds: "
    read -r interval
    
    if [ -z "$interval" ]; then
        echo "Keeping current interval: ${CHECK_INTERVAL} seconds"
        sleep 2
        return
    fi
    
    if echo "$interval" | grep -qE '^[0-9]+$'; then
        CHECK_INTERVAL=$interval
        echo "Interval updated to ${CHECK_INTERVAL} seconds"
    else
        echo "Invalid input! Interval must be a number"
    fi
    
    sleep 2
}

#############################################################
# Main Program Loop
#############################################################
main() {
    while true; do
        print_menu
        read -r choice
        
        case $choice in
            1)
                option_single_file
                ;;
            2)
                option_multiple_files
                ;;
            3)
                option_set_interval
                ;;
            4)
                clear
                echo "Thank you for using File Change Detector!"
                echo ""
                exit 0
                ;;
            *)
                echo "Invalid choice! Please enter 1-4"
                sleep 1
                ;;
        esac
    done
}

# Run the main program
main
