#!/bin/bash

# State Management Helpers for Agent-OS (Bash version)
# These functions will be embedded in bash-based commands

# Initialize state directories
init_state_dirs() {
    local base_dir="${1:-.agent-os}"
    mkdir -p "$base_dir/state/recovery"
    
    # Create default workflow.json if it doesn't exist
    local workflow_file="$base_dir/state/workflow.json"
    if [ ! -f "$workflow_file" ]; then
        cat > "$workflow_file" << EOF
{
  "state_version": "1.0.0",
  "current_workflow": null,
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
    fi
}

# Acquire file lock with timeout
acquire_lock() {
    local lockfile="${1:-.agent-os/state/.lock}"
    local timeout="${2:-30}"
    local elapsed=0
    
    # Wait for lock with timeout
    while [ -f "$lockfile" ] && [ $elapsed -lt $timeout ]; do
        sleep 1
        elapsed=$((elapsed + 1))
    done
    
    if [ $elapsed -ge $timeout ]; then
        echo "WARNING: Lock timeout exceeded, forcing acquisition" >&2
    fi
    
    # Create lock with process info
    mkdir -p "$(dirname "$lockfile")"
    echo "$$:$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$lockfile"
}

# Release file lock
release_lock() {
    local lockfile="${1:-.agent-os/state/.lock}"
    rm -f "$lockfile"
}

# Create recovery backup
create_recovery_backup() {
    local filepath="$1"
    local recovery_dir="$(dirname "$filepath")/recovery"
    
    # Ensure recovery directory exists
    mkdir -p "$recovery_dir"
    
    if [ -f "$filepath" ]; then
        local timestamp=$(date -u +%Y-%m-%dT%H-%M-%SZ)
        local filename=$(basename "$filepath" .json)
        local backup_path="$recovery_dir/${filename}-${timestamp}.json"
        
        cp "$filepath" "$backup_path" 2>/dev/null || {
            echo "WARNING: Failed to create backup" >&2
            return 1
        }
        
        echo "$backup_path"
    fi
}

# Clean old recovery files (keep most recent 5)
clean_old_recovery_files() {
    local filepath="$1"
    local recovery_dir="$(dirname "$filepath")/recovery"
    local filename=$(basename "$filepath" .json)
    
    if [ -d "$recovery_dir" ]; then
        # List files, sort by modification time, skip first 5, delete rest
        ls -t "$recovery_dir"/${filename}-*.json 2>/dev/null | tail -n +6 | while read -r old_file; do
            rm -f "$old_file"
        done
    fi
}

# Validate JSON file
validate_json() {
    local filepath="$1"
    
    if command -v jq >/dev/null 2>&1; then
        jq empty "$filepath" 2>/dev/null
        return $?
    else
        # Fallback: basic JSON validation using python if available
        if command -v python3 >/dev/null 2>&1; then
            python3 -c "import json; json.load(open('$filepath'))" 2>/dev/null
            return $?
        fi
    fi
    
    # If no validators available, assume valid
    return 0
}

# Save state with atomic operation
save_state() {
    local filepath="$1"
    local data="$2"
    
    # Create backup
    create_recovery_backup "$filepath"
    
    # Ensure directory exists
    mkdir -p "$(dirname "$filepath")"
    
    # Write to temp file first
    local temp_file="${filepath}.tmp"
    echo "$data" > "$temp_file"
    
    # Validate before moving
    if validate_json "$temp_file"; then
        mv "$temp_file" "$filepath"
        clean_old_recovery_files "$filepath"
        return 0
    else
        rm -f "$temp_file"
        echo "ERROR: Invalid JSON data" >&2
        return 1
    fi
}

# Load state with fallback to recovery
load_state() {
    local filepath="$1"
    local default_state="${2:-{}}"
    
    # Check if file exists and is valid
    if [ -f "$filepath" ]; then
        if validate_json "$filepath"; then
            cat "$filepath"
            return 0
        else
            echo "WARNING: State file corrupted, attempting recovery" >&2
            
            # Try to recover from backups
            local recovery_dir="$(dirname "$filepath")/recovery"
            local filename=$(basename "$filepath" .json)
            
            if [ -d "$recovery_dir" ]; then
                for backup in $(ls -t "$recovery_dir"/${filename}-*.json 2>/dev/null); do
                    if validate_json "$backup"; then
                        echo "INFO: Recovered from backup: $backup" >&2
                        cat "$backup"
                        return 0
                    fi
                done
            fi
        fi
    fi
    
    # Return default state
    echo "$default_state"
}

# Check and extend cache
check_and_extend_cache() {
    local cache_file="$1"
    
    if [ ! -f "$cache_file" ]; then
        return 1
    fi
    
    # Use jq for JSON manipulation if available
    if command -v jq >/dev/null 2>&1; then
        local now=$(date -u +%Y-%m-%dT%H:%M:%SZ)
        local expires=$(jq -r '.metadata.expires // empty' "$cache_file" 2>/dev/null)
        
        if [ -n "$expires" ]; then
            # Compare timestamps (basic check - within last minute)
            local expires_epoch=$(date -d "$expires" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$expires" +%s 2>/dev/null)
            local now_epoch=$(date +%s)
            
            if [ $((expires_epoch - now_epoch)) -lt 60 ]; then
                # Extend by 5 minutes
                local new_expires=$(date -u -d "+5 minutes" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v+5M +%Y-%m-%dT%H:%M:%SZ)
                
                # Update cache file
                local updated_cache=$(jq ".metadata.expires = \"$new_expires\" | .metadata.extension_count = ((.metadata.extension_count // 0) + 1) | .metadata.last_accessed = \"$now\"" "$cache_file")
                save_state "$cache_file" "$updated_cache"
                
                return 0
            fi
            
            # Check if still valid
            [ $expires_epoch -gt $now_epoch ]
            return $?
        fi
    fi
    
    return 1
}

# Create session cache
create_session_cache() {
    local cache_file="${1:-.agent-os/state/session-cache.json}"
    local workflow_id="$2"
    
    local now=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    local expires=$(date -u -d "+5 minutes" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v+5M +%Y-%m-%dT%H:%M:%SZ)
    
    cat > "$cache_file" << EOF
{
  "spec_cache": {},
  "context_cache": {},
  "metadata": {
    "timestamp": "$now",
    "expires": "$expires",
    "workflow_id": "$workflow_id",
    "last_accessed": "$now",
    "access_count": 1,
    "auto_extend": true,
    "extension_count": 0,
    "max_extensions": 12,
    "state_version": "1.0.0"
  }
}
EOF
}

# Update workflow state
update_workflow_state() {
    local workflow_file="${1:-.agent-os/state/workflow.json}"
    local workflow_id="$2"
    local status="${3:-active}"
    
    acquire_lock
    
    local current_state=$(load_state "$workflow_file" '{"state_version": "1.0.0"}')
    
    # Update using jq if available
    if command -v jq >/dev/null 2>&1; then
        local updated_state=$(echo "$current_state" | jq ".current_workflow = \"$workflow_id\" | .status = \"$status\" | .updated_at = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"")
        save_state "$workflow_file" "$updated_state"
    else
        # Fallback: simple replacement
        cat > "$workflow_file" << EOF
{
  "state_version": "1.0.0",
  "current_workflow": "$workflow_id",
  "status": "$status",
  "updated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
    fi
    
    release_lock
}

# Export functions for use in other scripts
export -f init_state_dirs
export -f acquire_lock
export -f release_lock
export -f create_recovery_backup
export -f clean_old_recovery_files
export -f validate_json
export -f save_state
export -f load_state
export -f check_and_extend_cache
export -f create_session_cache
export -f update_workflow_state