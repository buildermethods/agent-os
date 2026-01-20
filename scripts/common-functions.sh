#!/bin/bash

# =============================================================================
# Agent OS Common Functions
# Shared utilities for Agent OS scripts
# =============================================================================

# Colors for output
RED='\033[38;2;255;32;86m'
GREEN='\033[38;2;0;234;179m'
YELLOW='\033[38;2;255;185;0m'
BLUE='\033[38;2;0;208;255m'
PURPLE='\033[38;2;142;81;255m'
NC='\033[0m' # No Color

# -----------------------------------------------------------------------------
# Output Functions
# -----------------------------------------------------------------------------

# Print colored output
print_color() {
    local color=$1
    shift
    echo -e "${color}$@${NC}"
}

# Print section header
print_section() {
    echo ""
    print_color "$BLUE" "=== $1 ==="
    echo ""
}

# Print status message
print_status() {
    print_color "$BLUE" "$1"
}

# Print success message
print_success() {
    print_color "$GREEN" "✓ $1"
}

# Print warning message
print_warning() {
    print_color "$YELLOW" "⚠️  $1"
}

# Print error message
print_error() {
    print_color "$RED" "✗ $1"
}

# Print verbose message (only in verbose mode)
print_verbose() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo "[VERBOSE] $1" >&2
    fi
}

# -----------------------------------------------------------------------------
# YAML Parsing (Simple)
# -----------------------------------------------------------------------------

# Get a simple value from YAML (key: value format)
get_yaml_value() {
    local file=$1
    local key=$2
    local default=$3

    if [[ ! -f "$file" ]]; then
        echo "$default"
        return
    fi

    local value=$(grep "^${key}:" "$file" | sed "s/^${key}:[[:space:]]*//" | sed 's/[[:space:]]*$//')

    if [[ -n "$value" ]]; then
        echo "$value"
    else
        echo "$default"
    fi
}

# Get inherits_from value for a profile from config.yml
# Returns empty string if profile has no inheritance defined
get_profile_inherits_from() {
    local config_file=$1
    local profile_name=$2

    if [[ ! -f "$config_file" ]]; then
        echo ""
        return
    fi

    # Use awk to find the inherits_from value for the given profile
    # Format:
    # profiles:
    #   profile-name:
    #     inherits_from: parent-profile
    local value=$(awk -v profile="$profile_name" '
        /^profiles:/ { in_profiles=1; next }
        /^[a-zA-Z]/ && !/^[[:space:]]/ { in_profiles=0 }
        in_profiles && $0 ~ "^  "profile":$" { in_target=1; next }
        in_profiles && in_target && /^  [a-zA-Z0-9_-]+:$/ { in_target=0 }
        in_profiles && in_target && /inherits_from:/ {
            sub(/^[[:space:]]*inherits_from:[[:space:]]*/, "")
            gsub(/[[:space:]]*$/, "")
            print
            exit
        }
    ' "$config_file")

    echo "$value"
}

# Build the profile inheritance chain (from base to requested profile)
# Returns newline-separated list of profiles, base first
# Exits with error if circular dependency detected
get_profile_inheritance_chain() {
    local config_file=$1
    local profile_name=$2
    local profiles_dir=$3

    local chain=""
    local visited=""
    local current="$profile_name"

    # Build chain by following inherits_from links
    while [[ -n "$current" ]]; do
        # Check for circular dependency
        if echo "$visited" | grep -q "^${current}$"; then
            # Build the cycle path for error message
            local cycle_path="$current"
            local trace="$profile_name"
            while [[ "$trace" != "$current" ]] || [[ -z "$cycle_path" || "$cycle_path" == "$current" ]]; do
                local parent=$(get_profile_inherits_from "$config_file" "$trace")
                if [[ "$trace" == "$profile_name" ]]; then
                    cycle_path="$trace"
                else
                    cycle_path="$cycle_path → $trace"
                fi
                if [[ "$parent" == "$current" ]]; then
                    cycle_path="$cycle_path → $current"
                    break
                fi
                trace="$parent"
            done
            echo "CIRCULAR:$cycle_path"
            return 1
        fi

        # Check that profile directory exists
        if [[ ! -d "$profiles_dir/$current" ]]; then
            echo "NOTFOUND:$current"
            return 1
        fi

        # Add to visited list
        if [[ -n "$visited" ]]; then
            visited="$visited"$'\n'"$current"
        else
            visited="$current"
        fi

        # Add to chain (prepend so base ends up first)
        if [[ -n "$chain" ]]; then
            chain="$current"$'\n'"$chain"
        else
            chain="$current"
        fi

        # Get parent profile
        current=$(get_profile_inherits_from "$config_file" "$current")
    done

    echo "$chain"
}

# -----------------------------------------------------------------------------
# File Operations
# -----------------------------------------------------------------------------

# Create directory if it doesn't exist
ensure_dir() {
    local dir=$1
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        print_verbose "Created directory: $dir"
    fi
}

# Copy file with directory creation
copy_file() {
    local source=$1
    local dest=$2

    ensure_dir "$(dirname "$dest")"
    cp "$source" "$dest"
    print_verbose "Copied: $source -> $dest"
}

# Copy directory contents recursively (excluding .backups/)
copy_standards() {
    local source_dir=$1
    local dest_dir=$2
    local count=0

    if [[ ! -d "$source_dir" ]]; then
        return 0
    fi

    ensure_dir "$dest_dir"

    # Find all .md files, excluding .backups directory
    while IFS= read -r -d '' file; do
        local relative_path="${file#$source_dir/}"
        local dest_file="$dest_dir/$relative_path"

        ensure_dir "$(dirname "$dest_file")"
        cp "$file" "$dest_file"
        ((count++))
    done < <(find "$source_dir" -name "*.md" -type f ! -path "*/.backups/*" -print0 2>/dev/null)

    echo "$count"
}
