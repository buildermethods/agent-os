#!/usr/bin/env bash

# Install Agent OS standards and agent-specific command adapters into a project.

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# shellcheck source=scripts/common-functions.sh
source "$SCRIPT_DIR/common-functions.sh"

export VERBOSE="false"
PROFILE=""
COMMANDS_ONLY="false"
DRY_RUN="false"
ASSUME_YES="false"
FORCE="false"
PROJECT_DIR="$(pwd)"
TARGETS="claude"
STAGING_ROOT=""

cleanup() {
    if [[ -n "$STAGING_ROOT" && -d "$STAGING_ROOT" ]]; then
        rm -rf -- "$STAGING_ROOT"
    fi
}
trap cleanup EXIT

show_help() {
    cat <<EOF
Usage: $0 [OPTIONS]

Install Agent OS into a project.

Options:
    --profile <name>       Profile to install (default: config.yml)
    --project-dir <path>   Project directory (default: current directory)
    --target <list>        Comma-separated adapters: claude,codex,cursor,antigravity
    --commands-only        Update command adapters without changing standards
    --dry-run              Validate and show planned changes without writing
    --yes                  Confirm safe replacement of managed files
    --force                Replace locally modified managed standards
    --verbose              Show detailed output
    -h, --help             Show this help
EOF
}

parse_arguments() {
    while (($#)); do
        case "$1" in
            --profile|--project-dir|--target)
                require_option_value "$1" "${2:-}" || exit 2
                case "$1" in
                    --profile) PROFILE="$2" ;;
                    --project-dir) PROJECT_DIR="$2" ;;
                    --target) TARGETS="$2" ;;
                esac
                shift 2
                ;;
            --commands-only) COMMANDS_ONLY="true"; shift ;;
            --dry-run) DRY_RUN="true"; shift ;;
            --yes) ASSUME_YES="true"; shift ;;
            --force) FORCE="true"; shift ;;
            --verbose) VERBOSE="true"; shift ;;
            -h|--help) show_help; exit 0 ;;
            *) print_error "Unknown option: $1"; show_help; exit 2 ;;
        esac
    done
}

validate_target_list() {
    local target
    local -A seen=()
    IFS=',' read -r -a requested_targets <<< "$TARGETS"
    ((${#requested_targets[@]})) || {
        print_error "At least one --target is required."
        return 1
    }
    for target in "${requested_targets[@]}"; do
        case "$target" in
            claude|codex|cursor|antigravity) ;;
            *) print_error "Unsupported target: $target"; return 1 ;;
        esac
        if [[ -n "${seen[$target]:-}" ]]; then
            print_error "Duplicate target: $target"
            return 1
        fi
        seen[$target]=1
    done
}

load_configuration() {
    local default_profile
    default_profile="$(get_yaml_value "$BASE_DIR/config.yml" default_profile default)"
    EFFECTIVE_PROFILE="${PROFILE:-$default_profile}"
    require_profile_name "$EFFECTIVE_PROFILE"

    if [[ ! -d "$BASE_DIR/profiles/$EFFECTIVE_PROFILE" ]]; then
        print_error "Profile not found: $EFFECTIVE_PROFILE"
        return 1
    fi

    local chain_result
    if ! chain_result="$(get_profile_inheritance_chain \
        "$BASE_DIR/config.yml" "$EFFECTIVE_PROFILE" "$BASE_DIR/profiles")"; then
        case "$chain_result" in
            CIRCULAR:*) print_error "Circular profile inheritance: ${chain_result#CIRCULAR:}" ;;
            NOTFOUND:*) print_error "Inherited profile not found: ${chain_result#NOTFOUND:}" ;;
            *) print_error "Unable to resolve profile inheritance." ;;
        esac
        return 1
    fi
    INHERITANCE_CHAIN="$chain_result"
}

validate_environment() {
    [[ -f "$BASE_DIR/config.yml" ]] || {
        print_error "Base installation config.yml not found."
        return 1
    }
    PROJECT_DIR="$(canonical_path "$PROJECT_DIR")"
    [[ "$PROJECT_DIR" != "$(canonical_path "$BASE_DIR")" ]] || {
        print_error "Cannot install into the Agent OS source directory."
        return 1
    }
    [[ -d "$PROJECT_DIR" ]] || {
        print_error "Project directory does not exist: $PROJECT_DIR"
        return 1
    }
    validate_target_list
    load_configuration
}

manifest_hash_for() {
    local manifest="$1"
    local path="$2"
    [[ -f "$manifest" ]] || return 1
    awk -F '\t' -v path="$path" '$1 == "standard" && $2 == path { print $4; exit }' "$manifest"
}

stage_standards() {
    local project_agent_os="$PROJECT_DIR/agent-os"
    local existing="$project_agent_os/standards"
    local old_manifest="$project_agent_os/install-manifest.tsv"
    local staged="$STAGING_ROOT/standards"
    local staged_manifest="$STAGING_ROOT/install-manifest.tsv"
    local sources="$STAGING_ROOT/sources.tsv"
    local profile_name profile_standards file relative dest old_hash current_hash

    mkdir -p -- "$staged"
    if [[ -d "$existing" ]]; then
        require_no_symlink_components "$PROJECT_DIR" "$existing"
        cp -a -- "$existing/." "$staged/"
    fi
    : > "$sources"

    while IFS= read -r profile_name; do
        [[ -n "$profile_name" ]] || continue
        require_profile_name "$profile_name"
        profile_standards="$BASE_DIR/profiles/$profile_name/standards"
        [[ -d "$profile_standards" ]] || continue
        while IFS= read -r -d '' file; do
            relative="${file#"$profile_standards/"}"
            require_path_within "$profile_standards" "$file"
            dest="$staged/$relative"
            require_no_symlink_components "$staged" "$dest"

            if [[ -f "$existing/$relative" ]]; then
                old_hash="$(manifest_hash_for "$old_manifest" "$relative" || true)"
                current_hash="$(sha256sum "$existing/$relative" | awk '{print $1}')"
                if [[ -z "$old_hash" && "$FORCE" != "true" ]] &&
                    ! cmp -s -- "$file" "$existing/$relative"; then
                    print_error "Existing standard is not manifest-managed: $relative"
                    echo "Move it, merge it into the profile, or re-run with --force."
                    return 1
                fi
                if [[ -n "$old_hash" && "$old_hash" != "$current_hash" && "$FORCE" != "true" ]]; then
                    print_error "Managed standard has local changes: $relative"
                    echo "Re-run with --force to replace it, or move the local changes first."
                    return 1
                fi
            fi

            mkdir -p -- "$(dirname "$dest")"
            cp -- "$file" "$dest"
            awk -F '\t' -v path="$relative" '$1 != path' "$sources" > "$sources.tmp"
            mv -- "$sources.tmp" "$sources"
            printf '%s\t%s\n' "$relative" "$profile_name" >> "$sources"
        done < <(find "$profile_standards" -type f -name '*.md' \
            ! -path '*/.backups/*' -print0 | sort -z)
    done <<< "$INHERITANCE_CHAIN"

    # Remove files that an earlier Agent OS install managed but no profile manages now.
    if [[ -f "$old_manifest" ]]; then
        # shellcheck disable=SC2094 # Nested reads do not modify old_manifest.
        while IFS=$'\t' read -r kind path _; do
            [[ "$kind" == "standard" ]] || continue
            if ! awk -F '\t' -v path="$path" '$1 == path { found=1 } END { exit !found }' "$sources"; then
                old_hash="$(manifest_hash_for "$old_manifest" "$path" || true)"
                if [[ -f "$existing/$path" && -n "$old_hash" && "$FORCE" != "true" ]]; then
                    current_hash="$(sha256sum "$existing/$path" | awk '{print $1}')"
                    if [[ "$old_hash" != "$current_hash" ]]; then
                        print_error "Retired managed standard has local changes: $path"
                        echo "Move it or re-run with --force before removing it."
                        return 1
                    fi
                fi
                rm -f -- "$staged/$path"
            fi
        done < "$old_manifest"
    fi

    generate_index "$staged"
    {
        printf '# kind\tpath\tsource\tsha256\n'
        while IFS=$'\t' read -r path source; do
            printf 'standard\t%s\t%s\t%s\n' \
                "$path" "$source" "$(sha256sum "$staged/$path" | awk '{print $1}')"
        done < <(sort -t $'\t' -k1,1 "$sources")
    } > "$staged_manifest"
}

generate_index() {
    local standards_dir="$1"
    local index_file="$standards_dir/index.yml"
    local temp_file="$standards_dir/.index.yml.tmp"
    local file relative title
    {
        echo "# Generated by Agent OS. Run /agent-os-index-standards to refine descriptions."
        echo "version: 1"
        echo "standards:"
        while IFS= read -r -d '' file; do
            [[ "$file" == "$index_file" ]] && continue
            relative="${file#"$standards_dir/"}"
            title="$(awk '
                /^#[[:space:]]+/ {
                    sub(/^#[[:space:]]+/, "")
                    print
                    exit
                }
            ' "$file")"
            [[ -n "$title" ]] || title="${relative%.md}"
            printf '  - path: %s\n' "$(yaml_quote "$relative")"
            printf '    description: %s\n' "$(yaml_quote "$title")"
        done < <(find "$standards_dir" -type f -name '*.md' \
            ! -path '*/.backups/*' -print0 | sort -z)
    } > "$temp_file"
    mv -- "$temp_file" "$index_file"
}

command_destination() {
    case "$1" in
        claude) echo ".claude/commands/agent-os" ;;
        cursor) echo ".cursor/commands/agent-os" ;;
        antigravity) echo ".agent/workflows/agent-os" ;;
        codex) echo ".agents/skills" ;;
    esac
}

stage_commands() {
    local target="$1"
    local source="$BASE_DIR/commands/agent-os"
    local staged="$STAGING_ROOT/commands/$target"
    local file slug description
    mkdir -p -- "$staged"

    if [[ "$target" == "codex" ]]; then
        for file in "$source"/*.md; do
            slug="agent-os-$(basename "$file" .md)"
            description="$(awk '/^# / { sub(/^# /, ""); print; exit }' "$file")"
            mkdir -p -- "$staged/$slug"
            {
                echo "---"
                printf 'name: "%s"\n' "$slug"
                printf 'description: "Use Agent OS to %s."\n' "${description,,}"
                echo "---"
                echo
                cat "$file"
            } > "$staged/$slug/SKILL.md"
        done
    else
        cp -- "$source"/*.md "$staged/"
    fi
}

show_plan() {
    print_status "Installation plan:"
    echo "  Project: $PROJECT_DIR"
    echo "  Profile: $EFFECTIVE_PROFILE"
    echo "  Targets: $TARGETS"
    echo "  Commands only: $COMMANDS_ONLY"
    echo "  Dry run: $DRY_RUN"
}

confirm_install() {
    [[ "$DRY_RUN" == "true" || "$ASSUME_YES" == "true" || ! -e "$PROJECT_DIR/agent-os" ]] && return 0
    [[ -t 0 ]] || {
        print_error "Existing Agent OS installation requires --yes in non-interactive mode."
        return 1
    }
    read -r -p "Update the existing Agent OS installation? (y/N) " reply
    [[ "$reply" =~ ^[Yy]$ ]]
}

commit_standards() {
    local project_agent_os="$PROJECT_DIR/agent-os"
    local live="$project_agent_os/standards"
    local manifest="$project_agent_os/install-manifest.tsv"
    local previous="$STAGING_ROOT/previous-standards"
    local previous_manifest="$STAGING_ROOT/previous-manifest.tsv"
    local failed_new="$STAGING_ROOT/failed-new-standards"
    mkdir -p -- "$project_agent_os"
    require_no_symlink_components "$PROJECT_DIR" "$project_agent_os"
    if [[ -e "$live" ]]; then
        mv -- "$live" "$previous"
    fi
    if [[ -e "$manifest" ]]; then
        mv -- "$manifest" "$previous_manifest"
    fi
    if ! mv -- "$STAGING_ROOT/standards" "$live"; then
        [[ -e "$previous" ]] && mv -- "$previous" "$live"
        [[ -e "$previous_manifest" ]] && mv -- "$previous_manifest" "$manifest"
        return 1
    fi
    if ! mv -- "$STAGING_ROOT/install-manifest.tsv" "$manifest"; then
        mv -- "$live" "$failed_new"
        [[ -e "$previous" ]] && mv -- "$previous" "$live"
        [[ -e "$previous_manifest" ]] && mv -- "$previous_manifest" "$manifest"
        return 1
    fi
}

commit_commands() {
    local target dest staged previous
    for target in "${requested_targets[@]}"; do
        dest="$PROJECT_DIR/$(command_destination "$target")"
        staged="$STAGING_ROOT/commands/$target"
        require_no_symlink_components "$PROJECT_DIR" "$dest"
        mkdir -p -- "$(dirname "$dest")"
        if [[ "$target" == "codex" ]]; then
            mkdir -p -- "$dest"
            find "$dest" -mindepth 1 -maxdepth 1 -type d \
                -name 'agent-os-*' -exec rm -rf -- {} +
            local skill
            while IFS= read -r -d '' skill; do
                mv -- "$skill" "$dest/"
            done < <(find "$staged" -mindepth 1 -maxdepth 1 -type d -print0)
        else
            previous="$STAGING_ROOT/previous-command-$target"
            [[ -e "$dest" ]] && mv -- "$dest" "$previous"
            if ! mv -- "$staged" "$dest"; then
                [[ -e "$previous" ]] && mv -- "$previous" "$dest"
                return 1
            fi
        fi
        print_success "Installed $target adapter to ${dest#"$PROJECT_DIR/"}"
    done
}

main() {
    parse_arguments "$@"
    validate_environment
    show_plan
    confirm_install

    STAGING_ROOT="$(mktemp -d "$PROJECT_DIR/.agent-os-install.XXXXXX")"
    require_path_within "$PROJECT_DIR" "$STAGING_ROOT"
    if [[ "$COMMANDS_ONLY" != "true" ]]; then
        stage_standards
    fi
    local target
    for target in "${requested_targets[@]}"; do
        stage_commands "$target"
    done

    if [[ "$DRY_RUN" == "true" ]]; then
        print_success "Validation completed; no files were changed."
        return
    fi

    if [[ "$COMMANDS_ONLY" != "true" ]]; then
        commit_standards
        print_success "Installed standards from profile '$EFFECTIVE_PROFILE'."
    fi
    commit_commands
    print_success "Agent OS installation completed."
}

main "$@"
