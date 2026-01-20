#!/bin/bash

# =============================================================================
# Agent OS Sync to Profile Script
# Syncs project standards back to a base profile for reuse
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
NEW_PROFILE=""
SYNC_ALL="false"
OVERWRITE="false"

# Arrays for file handling
declare -a STANDARDS_FILES
declare -a SELECTED_FILES

# -----------------------------------------------------------------------------
# Help Function
# -----------------------------------------------------------------------------

show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Sync project standards back to a base profile for reuse.

Options:
    --profile <name>       Target profile (skips selection prompt)
    --new-profile <name>   Create a new profile with these standards
    --all                  Sync all standards (skips file selection)
    --overwrite            Overwrite existing files without prompting
    --verbose              Show detailed output
    -h, --help             Show this help message

Examples:
    $0
    $0 --profile rails
    $0 --all --overwrite
    $0 --new-profile nextjs --all

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
            --new-profile)
                NEW_PROFILE="$2"
                shift 2
                ;;
            --all)
                SYNC_ALL="true"
                shift
                ;;
            --overwrite)
                OVERWRITE="true"
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

    if [[ ! -d "$BASE_DIR/profiles" ]]; then
        print_error "No profiles directory in base installation"
        exit 1
    fi
}

validate_project_standards() {
    local standards_dir="$PROJECT_DIR/agent-os/standards"

    if [[ ! -d "$standards_dir" ]]; then
        print_error "No standards directory found at agent-os/standards/"
        echo ""
        echo "Run project-install.sh first to set up Agent OS in this project."
        exit 1
    fi
}

# -----------------------------------------------------------------------------
# Standards Discovery
# -----------------------------------------------------------------------------

find_standards_files() {
    local standards_dir="$PROJECT_DIR/agent-os/standards"
    STANDARDS_FILES=()

    # Find all .md files, excluding .backups directory
    while IFS= read -r -d '' file; do
        local relative_path="${file#$standards_dir/}"
        STANDARDS_FILES+=("$relative_path")
    done < <(find "$standards_dir" -name "*.md" -type f ! -path "*/.backups/*" -print0 2>/dev/null | sort -z)

    if [[ ${#STANDARDS_FILES[@]} -eq 0 ]]; then
        print_error "No standards to sync."
        echo ""
        echo "Create standards first using /discover-standards or manually."
        exit 1
    fi

    print_verbose "Found ${#STANDARDS_FILES[@]} standards files"
}

# -----------------------------------------------------------------------------
# Profile Selection
# -----------------------------------------------------------------------------

list_existing_profiles() {
    local profiles=()
    for dir in "$BASE_DIR/profiles"/*/; do
        if [[ -d "$dir" ]]; then
            local name=$(basename "$dir")
            profiles+=("$name")
        fi
    done
    echo "${profiles[@]}"
}

select_profile() {
    # If --new-profile was specified, use that
    if [[ -n "$NEW_PROFILE" ]]; then
        PROFILE="$NEW_PROFILE"
        create_profile_if_needed
        return
    fi

    # If --profile was specified, validate it
    if [[ -n "$PROFILE" ]]; then
        if [[ ! -d "$BASE_DIR/profiles/$PROFILE" ]]; then
            echo ""
            read -p "Profile '$PROFILE' doesn't exist. Create it? (y/n): " create_choice
            if [[ "$create_choice" =~ ^[Yy] ]]; then
                create_new_profile "$PROFILE"
            else
                print_error "Cancelled."
                exit 1
            fi
        fi
        return
    fi

    # Interactive profile selection
    echo ""
    print_status "Available profiles:"
    echo ""

    local profiles=($(list_existing_profiles))
    local i=1

    for profile in "${profiles[@]}"; do
        echo "  $i) $profile"
        ((i++))
    done
    echo "  $i) [Create new profile]"
    echo ""

    local max_choice=$i
    local choice

    while true; do
        read -p "Select profile (1-$max_choice): " choice

        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le "$max_choice" ]]; then
            break
        fi
        echo "Invalid choice. Please enter a number between 1 and $max_choice."
    done

    if [[ "$choice" -eq "$max_choice" ]]; then
        # Create new profile
        echo ""
        read -p "Enter new profile name: " PROFILE
        if [[ -z "$PROFILE" ]]; then
            print_error "Profile name cannot be empty."
            exit 1
        fi
        create_new_profile "$PROFILE"
    else
        PROFILE="${profiles[$((choice-1))]}"
    fi

    print_verbose "Selected profile: $PROFILE"
}

create_profile_if_needed() {
    if [[ ! -d "$BASE_DIR/profiles/$PROFILE" ]]; then
        create_new_profile "$PROFILE"
    fi
}

create_new_profile() {
    local name="$1"
    local profile_dir="$BASE_DIR/profiles/$name"

    mkdir -p "$profile_dir/standards"
    print_success "Created new profile: $name"
}

# -----------------------------------------------------------------------------
# File Selection
# -----------------------------------------------------------------------------

select_files() {
    # If --all was specified, select all files
    if [[ "$SYNC_ALL" == "true" ]]; then
        SELECTED_FILES=("${STANDARDS_FILES[@]}")
        print_verbose "Selected all ${#SELECTED_FILES[@]} files"
        return
    fi

    # Initialize selection array (all selected by default)
    local selected=()
    for ((i=0; i<${#STANDARDS_FILES[@]}; i++)); do
        selected[$i]=1
    done

    # Calculate lines to clear (files + 5 for header/footer)
    local lines_to_clear=$((${#STANDARDS_FILES[@]} + 7))

    display_file_selection() {
        echo ""
        print_status "Select standards to sync:"
        echo ""
        local i=1
        for file in "${STANDARDS_FILES[@]}"; do
            if [[ ${selected[$((i-1))]} -eq 1 ]]; then
                echo "  $i) [x] $file"
            else
                echo "  $i) [ ] $file"
            fi
            ((i++))
        done
        echo ""
        echo ""
        echo "  Enter number to toggle   a) All   n) None   d) Done"
        echo ""
    }

    clear_display() {
        # Move cursor up and clear lines
        for ((i=0; i<lines_to_clear; i++)); do
            tput cuu1 2>/dev/null || echo -ne "\033[1A"
            tput el 2>/dev/null || echo -ne "\033[2K"
        done
    }

    local first_display=true

    while true; do
        if [[ "$first_display" == "true" ]]; then
            first_display=false
        else
            clear_display
        fi

        display_file_selection
        read -p "Toggle (1-${#STANDARDS_FILES[@]}), a, n, or d: " choice

        case "$choice" in
            a|A)
                for ((i=0; i<${#STANDARDS_FILES[@]}; i++)); do
                    selected[$i]=1
                done
                ;;
            n|N)
                for ((i=0; i<${#STANDARDS_FILES[@]}; i++)); do
                    selected[$i]=0
                done
                ;;
            d|D)
                break
                ;;
            *)
                if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le ${#STANDARDS_FILES[@]} ]]; then
                    local idx=$((choice-1))
                    if [[ ${selected[$idx]} -eq 1 ]]; then
                        selected[$idx]=0
                    else
                        selected[$idx]=1
                    fi
                fi
                # Invalid input just redisplays
                ;;
        esac
    done

    # Build selected files array
    SELECTED_FILES=()
    for ((i=0; i<${#STANDARDS_FILES[@]}; i++)); do
        if [[ ${selected[$i]} -eq 1 ]]; then
            SELECTED_FILES+=("${STANDARDS_FILES[$i]}")
        fi
    done

    if [[ ${#SELECTED_FILES[@]} -eq 0 ]]; then
        print_error "No files selected."
        exit 1
    fi

    print_verbose "Selected ${#SELECTED_FILES[@]} files"
}

# -----------------------------------------------------------------------------
# Conflict Detection
# -----------------------------------------------------------------------------

check_conflicts() {
    local profile_standards="$BASE_DIR/profiles/$PROFILE/standards"
    local conflicts=()

    for file in "${SELECTED_FILES[@]}"; do
        if [[ -f "$profile_standards/$file" ]]; then
            conflicts+=("$file")
        fi
    done

    if [[ ${#conflicts[@]} -eq 0 ]]; then
        return 0
    fi

    # If --overwrite specified, just backup and continue
    if [[ "$OVERWRITE" == "true" ]]; then
        backup_files "${conflicts[@]}"
        return 0
    fi

    # Prompt user
    echo ""
    print_warning "${#conflicts[@]} file(s) already exist in profile '$PROFILE':"
    for file in "${conflicts[@]}"; do
        echo "    - $file"
    done
    echo ""

    while true; do
        echo "What do you want to do?"
        echo "  1) Overwrite all (with backup)"
        echo "  2) Skip existing files"
        echo "  3) Cancel"
        echo ""
        read -p "Choice (1-3): " conflict_choice

        case "$conflict_choice" in
            1)
                backup_files "${conflicts[@]}"
                return 0
                ;;
            2)
                # Remove conflicts from selected files
                local new_selected=()
                for file in "${SELECTED_FILES[@]}"; do
                    local is_conflict=false
                    for conflict in "${conflicts[@]}"; do
                        if [[ "$file" == "$conflict" ]]; then
                            is_conflict=true
                            break
                        fi
                    done
                    if [[ "$is_conflict" == "false" ]]; then
                        new_selected+=("$file")
                    fi
                done
                SELECTED_FILES=("${new_selected[@]}")

                if [[ ${#SELECTED_FILES[@]} -eq 0 ]]; then
                    print_warning "No files left to sync after skipping conflicts."
                    exit 0
                fi
                return 0
                ;;
            3)
                print_error "Cancelled."
                exit 1
                ;;
            *)
                echo "Invalid choice."
                ;;
        esac
    done
}

# -----------------------------------------------------------------------------
# Backup Functions
# -----------------------------------------------------------------------------

backup_files() {
    local files=("$@")

    if [[ ${#files[@]} -eq 0 ]]; then
        return
    fi

    local profile_standards="$BASE_DIR/profiles/$PROFILE/standards"
    local timestamp=$(date +"%Y-%m-%d-%H%M")
    local backup_dir="$profile_standards/.backups/$timestamp"

    mkdir -p "$backup_dir"

    local backup_count=0
    for file in "${files[@]}"; do
        local source_file="$profile_standards/$file"
        local backup_file="$backup_dir/$file"

        if [[ -f "$source_file" ]]; then
            mkdir -p "$(dirname "$backup_file")"
            cp "$source_file" "$backup_file"
            ((backup_count++))
            print_verbose "Backed up: $file"
        fi
    done

    if [[ "$backup_count" -gt 0 ]]; then
        print_success "Backed up $backup_count file(s) to .backups/$timestamp/"
    fi
}

# -----------------------------------------------------------------------------
# Sync Execution
# -----------------------------------------------------------------------------

execute_sync() {
    local project_standards="$PROJECT_DIR/agent-os/standards"
    local profile_standards="$BASE_DIR/profiles/$PROFILE/standards"

    local sync_count=0
    for file in "${SELECTED_FILES[@]}"; do
        local source_file="$project_standards/$file"
        local dest_file="$profile_standards/$file"

        # Create directory if needed
        mkdir -p "$(dirname "$dest_file")"

        # Copy the file
        cp "$source_file" "$dest_file"
        ((sync_count++))
        print_verbose "Synced: $file"
    done

    echo ""
    print_success "Synced $sync_count file(s) to profile '$PROFILE'"
}

# -----------------------------------------------------------------------------
# Main Execution
# -----------------------------------------------------------------------------

main() {
    print_section "Agent OS Sync to Profile"

    # Parse arguments
    parse_arguments "$@"

    # Validations
    validate_base_installation
    validate_project_standards

    # Find standards files
    find_standards_files

    # Select target profile
    select_profile

    # Select files to sync
    select_files

    # Show summary
    echo ""
    print_status "Sync summary:"
    echo "  Profile: $PROFILE"
    echo "  Files to sync: ${#SELECTED_FILES[@]}"
    echo ""

    # Check for conflicts and handle them
    check_conflicts

    # Execute sync
    execute_sync

    echo ""
}

# Run main function
main "$@"
