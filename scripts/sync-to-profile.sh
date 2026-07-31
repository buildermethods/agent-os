#!/usr/bin/env bash

# Sync selected project standards back to a reusable Agent OS profile.

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# shellcheck source=scripts/common-functions.sh
source "$SCRIPT_DIR/common-functions.sh"

export VERBOSE="false"
PROFILE=""
NEW_PROFILE=""
SYNC_ALL="false"
OVERWRITE="false"
DRY_RUN="false"
PROJECT_DIR="$(pwd)"
STAGING_ROOT=""
declare -a STANDARDS_FILES=()
declare -a SELECTED_FILES=()

cleanup() {
    if [[ -n "$STAGING_ROOT" && -d "$STAGING_ROOT" ]]; then
        rm -rf -- "$STAGING_ROOT"
    fi
}
trap cleanup EXIT

show_help() {
    cat <<EOF
Usage: $0 [OPTIONS]

Sync project standards to a reusable profile.

Options:
    --profile <name>       Existing target profile
    --new-profile <name>   Create a new target profile
    --project-dir <path>   Project directory (default: current directory)
    --all                  Select all standards
    --overwrite            Replace conflicts after creating backups
    --dry-run              Validate and display changes without writing
    --verbose              Show detailed output
    -h, --help             Show this help
EOF
}

parse_arguments() {
    while (($#)); do
        case "$1" in
            --profile|--new-profile|--project-dir)
                require_option_value "$1" "${2:-}" || exit 2
                case "$1" in
                    --profile) PROFILE="$2" ;;
                    --new-profile) NEW_PROFILE="$2" ;;
                    --project-dir) PROJECT_DIR="$2" ;;
                esac
                shift 2
                ;;
            --all) SYNC_ALL="true"; shift ;;
            --overwrite) OVERWRITE="true"; shift ;;
            --dry-run) DRY_RUN="true"; shift ;;
            --verbose) VERBOSE="true"; shift ;;
            -h|--help) show_help; exit 0 ;;
            *) print_error "Unknown option: $1"; show_help; exit 2 ;;
        esac
    done
    if [[ -n "$PROFILE" && -n "$NEW_PROFILE" ]]; then
        print_error "Use either --profile or --new-profile, not both."
        exit 2
    fi
}

validate_environment() {
    PROJECT_DIR="$(canonical_path "$PROJECT_DIR")"
    [[ -d "$BASE_DIR/profiles" ]] || {
        print_error "Profiles directory not found in base installation."
        return 1
    }
    [[ -d "$PROJECT_DIR/agent-os/standards" ]] || {
        print_error "Project standards not found: $PROJECT_DIR/agent-os/standards"
        return 1
    }
    require_no_symlink_components "$PROJECT_DIR" "$PROJECT_DIR/agent-os/standards"
}

find_standards_files() {
    local standards_dir="$PROJECT_DIR/agent-os/standards"
    local file relative
    while IFS= read -r -d '' file; do
        [[ "$file" == "$standards_dir/index.yml" ]] && continue
        relative="${file#"$standards_dir/"}"
        STANDARDS_FILES+=("$relative")
    done < <(find "$standards_dir" -type f -name '*.md' \
        ! -path '*/.backups/*' -print0 | sort -z)
    ((${#STANDARDS_FILES[@]})) || {
        print_error "No Markdown standards to sync."
        return 1
    }
}

create_profile() {
    require_profile_name "$PROFILE"
    local profile_dir="$BASE_DIR/profiles/$PROFILE"
    require_path_within "$BASE_DIR/profiles" "$profile_dir"
    require_no_symlink_components "$BASE_DIR/profiles" "$profile_dir"
    print_status "New profile will be created: $PROFILE"
}

select_profile() {
    if [[ -n "$NEW_PROFILE" ]]; then
        PROFILE="$NEW_PROFILE"
        require_profile_name "$PROFILE"
        [[ ! -e "$BASE_DIR/profiles/$PROFILE" ]] || {
            print_error "Profile already exists: $PROFILE"
            return 1
        }
        create_profile
        return
    fi

    if [[ -n "$PROFILE" ]]; then
        require_profile_name "$PROFILE"
        [[ -d "$BASE_DIR/profiles/$PROFILE" ]] || {
            print_error "Profile not found: $PROFILE"
            return 1
        }
        return
    fi

    [[ -t 0 ]] || {
        print_error "Non-interactive use requires --profile or --new-profile."
        return 1
    }
    local -a profiles=()
    local dir choice index=1
    while IFS= read -r -d '' dir; do
        profiles+=("$(basename "$dir")")
    done < <(find "$BASE_DIR/profiles" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
    for dir in "${profiles[@]}"; do
        echo "  $index) $dir"
        ((index+=1))
    done
    read -r -p "Select profile (1-${#profiles[@]}): " choice
    if [[ ! "$choice" =~ ^[0-9]+$ ]] ||
        ((choice < 1 || choice > ${#profiles[@]})); then
        print_error "Invalid profile selection."
        return 1
    fi
    PROFILE="${profiles[$((choice - 1))]}"
}

select_files() {
    if [[ "$SYNC_ALL" == "true" ]]; then
        SELECTED_FILES=("${STANDARDS_FILES[@]}")
        return
    fi
    [[ -t 0 ]] || {
        print_error "Non-interactive use requires --all."
        return 1
    }
    echo "Available standards:"
    local index=1 choice
    for choice in "${STANDARDS_FILES[@]}"; do
        echo "  $index) $choice"
        ((index+=1))
    done
    echo "Enter comma-separated numbers, or 'all'."
    read -r -p "Selection: " choice
    if [[ "$choice" == "all" ]]; then
        SELECTED_FILES=("${STANDARDS_FILES[@]}")
        return
    fi
    local item
    IFS=',' read -r -a choices <<< "$choice"
    for item in "${choices[@]}"; do
        if [[ ! "$item" =~ ^[0-9]+$ ]] ||
            ((item < 1 || item > ${#STANDARDS_FILES[@]})); then
            print_error "Invalid file selection: $item"
            return 1
        fi
        SELECTED_FILES+=("${STANDARDS_FILES[$((item - 1))]}")
    done
}

stage_profile() {
    local profile_dir="$BASE_DIR/profiles/$PROFILE"
    local live="$profile_dir/standards"
    local staged="$STAGING_ROOT/standards"
    local source dest file
    mkdir -p -- "$staged"
    [[ -d "$live" ]] && cp -a -- "$live/." "$staged/"

    for file in "${SELECTED_FILES[@]}"; do
        source="$PROJECT_DIR/agent-os/standards/$file"
        dest="$staged/$file"
        require_path_within "$PROJECT_DIR/agent-os/standards" "$source"
        require_path_within "$staged" "$dest"
        require_no_symlink_components "$staged" "$dest"
        if [[ -e "$live/$file" && "$OVERWRITE" != "true" ]]; then
            if cmp -s -- "$source" "$live/$file"; then
                print_verbose "Unchanged: $file"
                continue
            fi
            print_error "Profile standard differs: $file"
            echo "Review the diff or re-run with --overwrite."
            return 1
        fi
        mkdir -p -- "$(dirname "$dest")"
        cp -- "$source" "$dest"
    done
}

show_diff() {
    local live="$BASE_DIR/profiles/$PROFILE/standards"
    echo ""
    print_status "Profile changes:"
    if [[ -d "$live" ]]; then
        diff -ruN --exclude='.backups' "$live" "$STAGING_ROOT/standards" || true
    else
        find "$STAGING_ROOT/standards" -type f -printf '  add %P\n' | sort
    fi
}

commit_profile() {
    local profile_dir="$BASE_DIR/profiles/$PROFILE"
    local live="$profile_dir/standards"
    local previous="$STAGING_ROOT/previous"
    local backup_root="$profile_dir/.backups"
    local backup_dir
    backup_dir="$backup_root/$(date +'%Y-%m-%d-%H%M%S')-$$"
    require_no_symlink_components "$BASE_DIR/profiles" "$profile_dir"
    mkdir -p -- "$profile_dir"

    if [[ -d "$live" ]]; then
        mv -- "$live" "$previous"
    fi
    if ! mv -- "$STAGING_ROOT/standards" "$live"; then
        [[ -d "$previous" ]] && mv -- "$previous" "$live"
        return 1
    fi
    if [[ -d "$previous" && "$OVERWRITE" == "true" ]]; then
        mkdir -p -- "$backup_root"
        mv -- "$previous" "$backup_dir"
        print_success "Previous profile saved to ${backup_dir#"$BASE_DIR/"}"
    fi
}

main() {
    parse_arguments "$@"
    validate_environment
    find_standards_files
    select_profile
    select_files

    STAGING_ROOT="$(mktemp -d "$BASE_DIR/profiles/.agent-os-sync.XXXXXX")"
    require_path_within "$BASE_DIR/profiles" "$STAGING_ROOT"
    stage_profile
    show_diff

    if [[ "$DRY_RUN" == "true" ]]; then
        print_success "Dry run completed; no standards were changed."
        return
    fi
    commit_profile
    print_success "Synced ${#SELECTED_FILES[@]} standard(s) to profile '$PROFILE'."
}

main "$@"
