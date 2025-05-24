#!/bin/bash

# Logging-Funktionen für REDAXO Multi-Instance Manager

LOG_DIR="$(dirname "$(dirname "${BASH_SOURCE[0]}")")/logs"
mkdir -p "$LOG_DIR"

# Log-Level
LOG_LEVEL_DEBUG=0
LOG_LEVEL_INFO=1
LOG_LEVEL_WARN=2
LOG_LEVEL_ERROR=3

# Aktuelle Log-Level (kann über Environment Variable gesetzt werden)
CURRENT_LOG_LEVEL=${REDAXO_LOG_LEVEL:-$LOG_LEVEL_INFO}

# Logging-Funktionen
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_file="$LOG_DIR/redaxo-$(date '+%Y-%m-%d').log"
    
    if [ $level -ge $CURRENT_LOG_LEVEL ]; then
        echo "[$timestamp] [$level] $message" >> "$log_file"
    fi
}

log_debug() {
    log_message "DEBUG" "$1"
}

log_info() {
    log_message "INFO" "$1"
}

log_warn() {
    log_message "WARN" "$1"
}

log_error() {
    log_message "ERROR" "$1"
}

# Rotate logs (behalte nur die letzten 30 Tage)
rotate_logs() {
    find "$LOG_DIR" -name "redaxo-*.log" -type f -mtime +30 -delete
}
