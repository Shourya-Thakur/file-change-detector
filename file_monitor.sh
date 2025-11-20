#!/bin/bash

# Configuration
CHECK_INTERVAL=2
LOG_FILE=""
MONITORED_FILES=()
STORED_CHECKSUMS=()
MONITORING_ACTIVE=false

print_menu() {
    clear
    echo "================================"
    echo "  File Change Detector"
    echo "================================"
    echo ""
    echo "1. Monitor Single File"
    echo "2. Monitor Multiple Files"
    echo "3. Exit"
    echo ""
    printf "Enter choice [1-3]: "
}

# Function: calculate_checksum

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

# Function: validate_file

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

# Function: log_message

log_message() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local output="[$timestamp] $message"
    
    echo "$output"
    
    if [ -n "$LOG_FILE" ]; then
        echo "$output" >> "$LOG_FILE"
    fi
}

# Function: get_checksum_for_file

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

# Function: update_checksum_for_file

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

# Function: handle_interrupt

handle_interrupt() {
    MONITORING_ACTIVE=false
}

# Function: start_monitoring

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
            echo "Returning to menu..."
            sleep 1
            return 1
        fi
    done
    
    echo ""
    log_message "Press Ctrl+C to stop"
    echo ""
    
    MONITORING_ACTIVE=true
    trap handle_interrupt SIGINT SIGTERM
    
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
    
    echo ""
    echo ""
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Monitoring stopped."
    echo ""
    echo "Returning to menu..."
    sleep 1
    
    trap - SIGINT SIGTERM
    
    MONITORED_FILES=()
    STORED_CHECKSUMS=()
    LOG_FILE=""
}

# Function: option_single_file

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

# Function: option_multiple_files

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
                clear
                echo "Thank you for using File Change Detector!"
                echo ""
                exit 0
                ;;
            *)
                echo "Invalid choice! Please enter 1-3"
                sleep 1
                ;;
        esac
    done
}

main

