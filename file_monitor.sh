#!/bin/bash

#############################################################
# File Change Detector
# A Unix utility to monitor files for content changes
# Compatible with Bash 3.2+ (macOS compatible)
# Author: Your Name
# Course: Unix Systems Programming
# Date: November 2025
#############################################################

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default configuration
CHECK_INTERVAL=2  # seconds between checks
LOG_FILE=""

# Arrays for storing file paths and checksums
MONITORED_FILES=()
STORED_CHECKSUMS=()

#############################################################
# Function: display_help
# Description: Shows usage information
#############################################################
display_help() {
    echo "File Change Detector - Monitor files for modifications"
    echo ""
    echo "Usage: $0 [OPTIONS] FILE [FILE2 FILE3 ...]"
    echo ""
    echo "Options:"
    echo "  -i SECONDS    Set check interval (default: 2 seconds)"
    echo "  -l LOGFILE    Log changes to specified file"
    echo "  -h            Display this help message"
    echo ""
    echo "Examples:"
    echo "  $0 config.txt"
    echo "  $0 -i 5 config.txt data.txt"
    echo "  $0 -l monitor.log config.txt"
    echo ""
    exit 0
}

#############################################################
# Function: log_message
# Description: Prints timestamped message to console and log
# Parameters: $1 - message to log
#############################################################
log_message() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local output="[$timestamp] $message"
    
    echo -e "$output"
    
    # Write to log file if specified
    if [ -n "$LOG_FILE" ]; then
        echo "$output" >> "$LOG_FILE"
    fi
}

#############################################################
# Function: calculate_checksum
# Description: Calculates MD5 checksum of a file
# Parameters: $1 - file path
# Returns: checksum string
#############################################################
calculate_checksum() {
    local file="$1"
    
    # Try different checksum commands (macOS uses 'md5', Linux uses 'md5sum')
    if command -v md5 &> /dev/null; then
        md5 -q "$file" 2>/dev/null
    elif command -v md5sum &> /dev/null; then
        md5sum "$file" 2>/dev/null | awk '{print $1}'
    elif command -v shasum &> /dev/null; then
        shasum "$file" 2>/dev/null | awk '{print $1}'
    else
        # Fallback: use file size and modification time
        stat -f "%z-%m" "$file" 2>/dev/null || stat -c "%s-%Y" "$file" 2>/dev/null
    fi
}

#############################################################
# Function: validate_file
# Description: Checks if file exists and is readable
# Parameters: $1 - file path
# Returns: 0 if valid, 1 otherwise
#############################################################
validate_file() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        echo -e "${RED}Error: File '$file' does not exist${NC}" >&2
        return 1
    fi
    
    if [ ! -r "$file" ]; then
        echo -e "${RED}Error: File '$file' is not readable${NC}" >&2
        return 1
    fi
    
    return 0
}

#############################################################
# Function: get_checksum_for_file
# Description: Gets stored checksum for a file by index
# Parameters: $1 - file path
# Returns: checksum or empty string
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
# Description: Updates stored checksum for a file
# Parameters: $1 - file path, $2 - new checksum
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
# Function: initialize_monitoring
# Description: Sets up initial checksums for all files
# Parameters: array of file paths
#############################################################
initialize_monitoring() {
    log_message "${BLUE}Starting file monitor...${NC}"
    
    local index=0
    for file in "$@"; do
        if validate_file "$file"; then
            MONITORED_FILES[$index]="$file"
            STORED_CHECKSUMS[$index]=$(calculate_checksum "$file")
            log_message "${GREEN}Monitoring: $file${NC}"
            index=$((index + 1))
        else
            exit 1
        fi
    done
    
    log_message "${YELLOW}Press Ctrl+C to stop monitoring${NC}"
    echo ""
}

#############################################################
# Function: check_for_changes
# Description: Checks if monitored files have changed
#############################################################
check_for_changes() {
    for file in "${MONITORED_FILES[@]}"; do
        # Check if file still exists
        if [ ! -f "$file" ]; then
            log_message "${RED}Warning: File '$file' no longer exists${NC}"
            continue
        fi
        
        # Calculate current checksum
        local current_checksum=$(calculate_checksum "$file")
        local stored_checksum=$(get_checksum_for_file "$file")
        
        # Compare with stored checksum
        if [ "$current_checksum" != "$stored_checksum" ]; then
            log_message "${RED}File $file has been modified.${NC}"
            
            # Update stored checksum
            update_checksum_for_file "$file" "$current_checksum"
        fi
    done
}

#############################################################
# Function: cleanup
# Description: Cleanup function called on script exit
#############################################################
cleanup() {
    echo ""
    log_message "${YELLOW}Monitoring stopped.${NC}"
    exit 0
}

#############################################################
# Main Script Execution
#############################################################

# Set up trap for clean exit
trap cleanup SIGINT SIGTERM

# Parse command-line options
while getopts "i:l:h" opt; do
    case $opt in
        i)
            CHECK_INTERVAL=$OPTARG
            if ! echo "$CHECK_INTERVAL" | grep -qE '^[0-9]+$'; then
                echo -e "${RED}Error: Check interval must be a positive integer${NC}" >&2
                exit 1
            fi
            ;;
        l)
            LOG_FILE=$OPTARG
            # Create log file directory if it doesn't exist
            mkdir -p "$(dirname "$LOG_FILE")"
            ;;
        h)
            display_help
            ;;
        \?)
            echo -e "${RED}Invalid option: -$OPTARG${NC}" >&2
            echo "Use -h for help"
            exit 1
            ;;
    esac
done

# Shift to get file arguments
shift $((OPTIND-1))

# Check if at least one file is specified
if [ $# -eq 0 ]; then
    echo -e "${RED}Error: No files specified to monitor${NC}" >&2
    echo "Use -h for help"
    exit 1
fi

# Initialize monitoring with all file arguments
initialize_monitoring "$@"

# Main monitoring loop
while true; do
    check_for_changes
    sleep "$CHECK_INTERVAL"
done
