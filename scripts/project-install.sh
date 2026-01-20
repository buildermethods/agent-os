#!/bin/bash

# =============================================================================
# Agent OS Project Installation Script
# Installs Agent OS into a project's codebase
# =============================================================================

set -e

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_DIR="$(pwd)"

# Source common functions
source "$SCRIPT_DIR/common-functions.sh"

# -----------------------------------------------------------------------------
# Default Values
# -----------------------------------------------------------------------------

VERBOSE="false"
PROFILE=""
COMMANDS_ONLY="false"

# -----------------------------------------------------------------------------
# Help Function
# -----------------------------------------------------------------------------

show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Install Agent OS into the current project directory.

Options:
    --profile <name>     Use specified profile (default: from config.yml)
    --commands-only      Only update commands, preserve existing standards
    --verbose            Show detailed output
    -h, --help           Show this help message

Examples:
    $0
    $0 --profile rails
    $0 --commands-only

EOF
    exit 0
}

# -----------------------------------------------------------------------------
# Parse Command Line Arguments
# -----------------------------------------------------------------------------

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --profile)
                PROFILE="$2"
                shift 2
                ;;
            --commands-only)
                COMMANDS_ONLY="true"
                shift
                ;;
            --verbose)
                VERBOSE="true"
                shift
                ;;
            -h|--help)
                show_help
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                ;;
        esac
    done
}

# -----------------------------------------------------------------------------
# Validation Functions
# -----------------------------------------------------------------------------

validate_base_installation() {
    if [[ ! -d "$BASE_DIR" ]]; then
        print_error "Agent OS base installation not found"
        exit 1
    fi

    if [[ ! -f "$BASE_DIR/config.yml" ]]; then
        print_error "Base installation config.yml not found"
        exit 1
    fi
}

validate_not_in_base() {
    if [[ "$PROJECT_DIR" == "$BASE_DIR" ]]; then
        print_error "Cannot install Agent OS in the base installation directory"
        echo ""
        echo "Navigate to your project directory first:"
        echo "  cd /path/to/your/project"
        echo ""
        exit 1
    fi
}

# -----------------------------------------------------------------------------
# Configuration Functions
# -----------------------------------------------------------------------------

load_configuration() {
    local config_file="$BASE_DIR/config.yml"

    # Get default profile from config
    local default_profile=$(get_yaml_value "$config_file" "default_profile" "default")

    # Use command line profile or default
    EFFECTIVE_PROFILE="${PROFILE:-$default_profile}"

    # Validate profile exists
    if [[ ! -d "$BASE_DIR/profiles/$EFFECTIVE_PROFILE" ]]; then
        print_error "Profile not found: $EFFECTIVE_PROFILE"
        exit 1
    fi

    # Build inheritance chain
    local chain_result=$(get_profile_inheritance_chain "$config_file" "$EFFECTIVE_PROFILE" "$BASE_DIR/profiles")

    # Check for errors
    if [[ "$chain_result" == CIRCULAR:* ]]; then
        local cycle_path="${chain_result#CIRCULAR:}"
        echo ""
        print_error "Circular dependency detected in profile inheritance chain:"
        echo "  $cycle_path"
        echo ""
        echo "Please fix the inheritance configuration in:"
        echo "  $config_file"
        echo ""
        echo "The 'profiles' section contains a circular reference that must be resolved."
        exit 1
    fi

    if [[ "$chain_result" == NOTFOUND:* ]]; then
        local missing_profile="${chain_result#NOTFOUND:}"
        print_error "Profile not found: $missing_profile"
        echo ""
        echo "This profile is referenced in the inheritance chain but doesn't exist."
        echo "Check the 'profiles' section in: $config_file"
        exit 1
    fi

    # Store the inheritance chain (newline-separated, base first)
    INHERITANCE_CHAIN="$chain_result"

    print_verbose "Using profile: $EFFECTIVE_PROFILE"
    print_verbose "Inheritance chain: $(echo "$INHERITANCE_CHAIN" | tr '\n' ' ')"
}

# -----------------------------------------------------------------------------
# Confirmation Functions
# -----------------------------------------------------------------------------

confirm_standards_overwrite() {
    if [[ "$COMMANDS_ONLY" == "true" ]]; then
        return 0
    fi

    local existing_standards="$PROJECT_DIR/agent-os/standards"

    if [[ -d "$existing_standards" ]]; then
        echo ""
        print_warning "Existing standards folder detected at: $existing_standards"
        echo ""
        echo "This will overwrite your existing standards with standards from the '$EFFECTIVE_PROFILE' profile."
        echo ""
        read -p "Do you want to continue? (y/N) " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo ""
            echo "Installation cancelled."
            echo ""
            echo "To update only commands without touching standards, use:"
            echo "  $0 --commands-only"
            echo ""
            exit 0
        fi
    fi
}

# -----------------------------------------------------------------------------
# Installation Functions
# -----------------------------------------------------------------------------

create_project_structure() {
    print_status "Creating project structure..."

    ensure_dir "$PROJECT_DIR/agent-os"
    ensure_dir "$PROJECT_DIR/agent-os/standards"

    print_success "Created agent-os/ directory structure"
}

install_standards() {
    if [[ "$COMMANDS_ONLY" == "true" ]]; then
        print_status "Skipping standards (--commands-only)"
        return
    fi

    echo ""
    print_status "Installing standards..."

    local project_standards="$PROJECT_DIR/agent-os/standards"
    local profiles_used=0

    # Temp file to track file sources (format: relative_path|profile_name)
    local sources_file=$(mktemp)
    trap "rm -f $sources_file" EXIT

    # Process each profile in the inheritance chain (base first, so later ones override)
    while IFS= read -r profile_name; do
        [[ -z "$profile_name" ]] && continue

        local profile_standards="$BASE_DIR/profiles/$profile_name/standards"

        if [[ ! -d "$profile_standards" ]]; then
            continue
        fi

        local profile_file_count=0

        # Find all .md files in this profile, excluding .backups
        while IFS= read -r -d '' file; do
            local relative_path="${file#$profile_standards/}"
            local dest_file="$project_standards/$relative_path"

            ensure_dir "$(dirname "$dest_file")"
            cp "$file" "$dest_file"

            # Track the source - remove old entry if exists, add new one
            grep -v "^${relative_path}|" "$sources_file" > "${sources_file}.tmp" 2>/dev/null || true
            mv "${sources_file}.tmp" "$sources_file"
            echo "${relative_path}|${profile_name}" >> "$sources_file"
            ((profile_file_count++))
        done < <(find "$profile_standards" -name "*.md" -type f ! -path "*/.backups/*" -print0 2>/dev/null)

        if [[ "$profile_file_count" -gt 0 ]]; then
            ((profiles_used++))
        fi
    done <<< "$INHERITANCE_CHAIN"

    # Count profiles in chain to determine if we show sources
    local chain_count=$(echo "$INHERITANCE_CHAIN" | grep -c .)

    # Count and display
    local total_count=$(wc -l < "$sources_file" | tr -d ' ')

    if [[ "$total_count" -gt 0 ]]; then
        # Sort and display files - only show source if inheritance is present
        sort "$sources_file" | while IFS='|' read -r filepath profile; do
            if [[ "$chain_count" -gt 1 ]]; then
                echo "  $filepath (from $profile)"
            else
                echo "  $filepath"
            fi
        done

        if [[ "$profiles_used" -gt 1 ]]; then
            print_success "Installed $total_count standards files (from $profiles_used profiles)"
        else
            print_success "Installed $total_count standards files"
        fi
    else
        print_success "No standards to install (profile is empty)"
    fi
}

create_index() {
    echo ""
    print_status "Updating standards index..."

    local standards_dir="$PROJECT_DIR/agent-os/standards"
    local index_file="$standards_dir/index.yml"
    local temp_file="$standards_dir/.index_temp.yml"
    local old_index=""

    # Save existing index content for description lookup
    if [[ -f "$index_file" ]]; then
        old_index=$(cat "$index_file")
    fi

    local entry_count=0
    local new_count=0

    # Start fresh
    echo "# Agent OS Standards Index" > "$temp_file"
    echo "" >> "$temp_file"

    # Helper to get existing description from old index
    # Looks for pattern: folder:\n  filename:\n    description: ...
    get_existing_description() {
        local folder="$1"
        local filename="$2"

        if [[ -z "$old_index" ]]; then
            return 1
        fi

        # Use awk to find the description for this folder/file combo
        local desc=$(echo "$old_index" | awk -v folder="$folder" -v file="$filename" '
            $0 ~ "^"folder":$" { in_folder=1; next }
            /^[a-zA-Z0-9_-]+:$/ { in_folder=0 }
            in_folder && $0 ~ "^  "file":$" { in_file=1; next }
            in_folder && /^  [a-zA-Z0-9_-]+:$/ { in_file=0 }
            in_folder && in_file && /description:/ {
                sub(/^[[:space:]]*description:[[:space:]]*/, "")
                print
                exit
            }
        ')

        if [[ -n "$desc" && "$desc" != "Needs description - run /index-standards" ]]; then
            echo "$desc"
            return 0
        fi
        return 1
    }

    # First, handle root-level .md files (not in subfolders)
    local root_files=$(find "$standards_dir" -maxdepth 1 -name "*.md" -type f 2>/dev/null | sort)
    if [[ -n "$root_files" ]]; then
        echo "root:" >> "$temp_file"
        while IFS= read -r file; do
            local filename=$(basename "$file" .md)
            local desc=$(get_existing_description "root" "$filename")
            if [[ -z "$desc" ]]; then
                desc="Needs description - run /index-standards"
                ((new_count++))
            fi
            echo "  $filename:" >> "$temp_file"
            echo "    description: $desc" >> "$temp_file"
            ((entry_count++))
        done <<< "$root_files"
        echo "" >> "$temp_file"
    fi

    # Then handle files in subfolders
    local folders=$(find "$standards_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)
    for folder in $folders; do
        local folder_name=$(basename "$folder")
        local md_files=$(find "$folder" -name "*.md" -type f 2>/dev/null | sort)

        if [[ -n "$md_files" ]]; then
            echo "$folder_name:" >> "$temp_file"
            while IFS= read -r file; do
                local filename=$(basename "$file" .md)
                local desc=$(get_existing_description "$folder_name" "$filename")
                if [[ -z "$desc" ]]; then
                    desc="Needs description - run /index-standards"
                    ((new_count++))
                fi
                echo "  $filename:" >> "$temp_file"
                echo "    description: $desc" >> "$temp_file"
                ((entry_count++))
            done <<< "$md_files"
            echo "" >> "$temp_file"
        fi
    done

    # Move temp file to final location
    mv "$temp_file" "$index_file"

    if [[ "$entry_count" -gt 0 ]]; then
        if [[ "$new_count" -gt 0 ]]; then
            print_success "Updated index.yml ($entry_count entries, $new_count new)"
        else
            print_success "Updated index.yml ($entry_count entries)"
        fi
    else
        print_success "Created index.yml (no standards to index)"
    fi
}

install_commands() {
    echo ""
    print_status "Installing commands..."

    local commands_source="$BASE_DIR/commands/agent-os"
    local commands_dest="$PROJECT_DIR/.claude/commands/agent-os"

    if [[ ! -d "$commands_source" ]]; then
        print_warning "No commands found in base installation"
        return
    fi

    ensure_dir "$commands_dest"

    local count=0
    for file in "$commands_source"/*.md; do
        if [[ -f "$file" ]]; then
            cp "$file" "$commands_dest/"
            ((count++))
        fi
    done

    if [[ "$count" -gt 0 ]]; then
        print_success "Installed $count commands to .claude/commands/agent-os/"
    else
        print_warning "No command files found"
    fi
}

# -----------------------------------------------------------------------------
# Main Execution
# -----------------------------------------------------------------------------

main() {
    print_section "Agent OS Project Installation"

    # Parse arguments
    parse_arguments "$@"

    # Validations
    validate_not_in_base
    validate_base_installation

    # Load configuration
    load_configuration

    # Show configuration
    echo ""
    print_status "Configuration:"

    # Display inheritance chain
    local chain_depth=0
    local chain_display=""
    # Read chain in reverse order (from requested profile back to base) for display
    local reversed_chain=$(echo "$INHERITANCE_CHAIN" | tac)
    while IFS= read -r profile_name; do
        [[ -z "$profile_name" ]] && continue
        if [[ "$chain_depth" -eq 0 ]]; then
            chain_display="  Profile: $profile_name"
        else
            local indent=""
            for ((i=0; i<chain_depth; i++)); do
                indent="$indent  "
            done
            chain_display="$chain_display"$'\n'"$indent  ↳ inherits from: $profile_name"
        fi
        ((chain_depth++))
    done <<< "$reversed_chain"
    echo "$chain_display"

    echo "  Commands only: $COMMANDS_ONLY"

    # Confirm overwrite if standards folder exists
    confirm_standards_overwrite

    echo ""

    # Install
    create_project_structure
    install_standards
    create_index
    install_commands

    echo ""
    print_success "Agent OS installed successfully!"
    echo ""
    echo "Next steps:"
    echo "  1. Run /discover-standards to extract patterns from your codebase"
    echo "  2. Run /inject-standards to inject standards into your context"
    echo ""
}

# Run main function
main "$@"
