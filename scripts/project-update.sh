#!/bin/bash

# =============================================================================
# Agent OS Project Update Script
# Updates Agent OS installation in a project
# =============================================================================

set -e  # Exit on error

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$HOME/agent-os"
PROJECT_DIR="$(pwd)"

# Source common functions
source "$SCRIPT_DIR/common-functions.sh"

# -----------------------------------------------------------------------------
# Default Values
# -----------------------------------------------------------------------------

DRY_RUN="false"
VERBOSE="false"
PROFILE=""
MULTI_AGENT_MODE=""
MULTI_AGENT_TOOL=""
SINGLE_AGENT_MODE=""
SINGLE_AGENT_TOOL=""
RE_INSTALL="false"
OVERWRITE_ALL="false"
OVERWRITE_AGENTS="false"
OVERWRITE_COMMANDS="false"
OVERWRITE_STANDARDS="false"
SKIPPED_FILES=()
UPDATED_FILES=()
NEW_FILES=()

# -----------------------------------------------------------------------------
# Help Function
# -----------------------------------------------------------------------------

show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Update Agent OS installation in the current project directory.

Options:
    --profile PROFILE           Use specified profile (default: from project config)
    --multi-agent-mode [BOOL]   Enable/disable multi-agent mode
    --multi-agent-tool TOOL     Specify multi-agent tool
    --single-agent-mode [BOOL]  Enable/disable single-agent mode
    --single-agent-tool TOOL    Specify single-agent tool
    --re-install                Delete and reinstall Agent OS
    --overwrite-all             Overwrite all existing files
    --overwrite-agents          Overwrite existing agent files
    --overwrite-commands        Overwrite existing command files
    --overwrite-standards       Overwrite existing standards files
    --dry-run                   Show what would be done without doing it
    --verbose                   Show detailed output
    -h, --help                  Show this help message

Examples:
    $0
    $0 --overwrite-agents
    $0 --multi-agent-mode true --multi-agent-tool claude-code
    $0 --dry-run --verbose

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
            --multi-agent-mode)
                read MULTI_AGENT_MODE shift_count <<< "$(parse_bool_flag "$MULTI_AGENT_MODE" "$2")"
                shift $shift_count
                ;;
            --multi-agent-tool)
                MULTI_AGENT_TOOL="$2"
                shift 2
                ;;
            --single-agent-mode)
                read SINGLE_AGENT_MODE shift_count <<< "$(parse_bool_flag "$SINGLE_AGENT_MODE" "$2")"
                shift $shift_count
                ;;
            --single-agent-tool)
                SINGLE_AGENT_TOOL="$2"
                shift 2
                ;;
            --re-install)
                RE_INSTALL="true"
                shift
                ;;
            --overwrite-all)
                OVERWRITE_ALL="true"
                shift
                ;;
            --overwrite-agents)
                OVERWRITE_AGENTS="true"
                shift
                ;;
            --overwrite-commands)
                OVERWRITE_COMMANDS="true"
                shift
                ;;
            --overwrite-standards)
                OVERWRITE_STANDARDS="true"
                shift
                ;;
            --dry-run)
                DRY_RUN="true"
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

validate_installations() {
    # Check base installation using common function
    validate_base_installation

    # Check project installation
    if [[ ! -f "$PROJECT_DIR/agent-os/config.yml" ]]; then
        print_error "Agent OS not installed in this project"
        echo ""
        print_status "Please run project-install.sh first"
        exit 1
    fi

    print_verbose "Project installation found at: $PROJECT_DIR/agent-os"
}

# -----------------------------------------------------------------------------
# Configuration Functions
# -----------------------------------------------------------------------------

load_configurations() {
    # Load base and project configurations using common functions
    load_base_config
    load_project_config

    # Set effective values
    # For update, project config takes precedence unless overridden by command line
    EFFECTIVE_PROFILE="${PROFILE:-${PROJECT_PROFILE:-$BASE_PROFILE}}"
    EFFECTIVE_MULTI_AGENT_MODE="${MULTI_AGENT_MODE:-${PROJECT_MULTI_AGENT_MODE:-$BASE_MULTI_AGENT_MODE}}"
    EFFECTIVE_MULTI_AGENT_TOOL="${MULTI_AGENT_TOOL:-${PROJECT_MULTI_AGENT_TOOL:-$BASE_MULTI_AGENT_TOOL}}"
    EFFECTIVE_SINGLE_AGENT_MODE="${SINGLE_AGENT_MODE:-${PROJECT_SINGLE_AGENT_MODE:-$BASE_SINGLE_AGENT_MODE}}"
    EFFECTIVE_SINGLE_AGENT_TOOL="${SINGLE_AGENT_TOOL:-${PROJECT_SINGLE_AGENT_TOOL:-$BASE_SINGLE_AGENT_TOOL}}"
    EFFECTIVE_VERSION="$BASE_VERSION"

    print_verbose "Base configuration:"
    print_verbose "  Version: $BASE_VERSION"
    print_verbose "  Profile: $BASE_PROFILE"
    print_verbose "  Multi-agent: $BASE_MULTI_AGENT_MODE (tool: $BASE_MULTI_AGENT_TOOL)"
    print_verbose "  Single-agent: $BASE_SINGLE_AGENT_MODE (tool: $BASE_SINGLE_AGENT_TOOL)"

    print_verbose "Project configuration:"
    print_verbose "  Version: $PROJECT_VERSION"
    print_verbose "  Profile: $PROJECT_PROFILE"
    print_verbose "  Multi-agent: $PROJECT_MULTI_AGENT_MODE (tool: $PROJECT_MULTI_AGENT_TOOL)"
    print_verbose "  Single-agent: $PROJECT_SINGLE_AGENT_MODE (tool: $PROJECT_SINGLE_AGENT_TOOL)"

    print_verbose "Effective configuration:"
    print_verbose "  Profile: $EFFECTIVE_PROFILE"
    print_verbose "  Multi-agent: $EFFECTIVE_MULTI_AGENT_MODE (tool: $EFFECTIVE_MULTI_AGENT_TOOL)"
    print_verbose "  Single-agent: $EFFECTIVE_SINGLE_AGENT_MODE (tool: $EFFECTIVE_SINGLE_AGENT_TOOL)"
}

# -----------------------------------------------------------------------------
# Version Compatibility Check
# -----------------------------------------------------------------------------

check_compatibility() {
    if [[ -z "$PROJECT_VERSION" ]] || [[ "$PROJECT_VERSION" == "" ]]; then
        print_warning "Project installation has no version number"
        print_status "This appears to be a pre-2.x installation"
        return 1
    fi

    if ! check_version_compatibility "$BASE_VERSION" "$PROJECT_VERSION"; then
        print_warning "Version incompatibility detected"
        print_status "Base version: $BASE_VERSION"
        print_status "Project version: $PROJECT_VERSION"
        return 1
    fi

    return 0
}

# -----------------------------------------------------------------------------
# Configuration Matching
# -----------------------------------------------------------------------------

check_config_match() {
    # Check if configurations match
    local match="true"

    # Check multi-agent mode
    if [[ "$EFFECTIVE_MULTI_AGENT_MODE" != "$PROJECT_MULTI_AGENT_MODE" ]]; then
        match="false"
    fi

    # Check multi-agent tool (only if mode is enabled)
    if [[ "$EFFECTIVE_MULTI_AGENT_MODE" == "true" ]] && [[ "$PROJECT_MULTI_AGENT_MODE" == "true" ]]; then
        if [[ "$EFFECTIVE_MULTI_AGENT_TOOL" != "$PROJECT_MULTI_AGENT_TOOL" ]]; then
            match="false"
        fi
    fi

    # Check single-agent mode
    if [[ "$EFFECTIVE_SINGLE_AGENT_MODE" != "$PROJECT_SINGLE_AGENT_MODE" ]]; then
        match="false"
    fi

    # Check single-agent tool (only if mode is enabled)
    if [[ "$EFFECTIVE_SINGLE_AGENT_MODE" == "true" ]] && [[ "$PROJECT_SINGLE_AGENT_MODE" == "true" ]]; then
        if [[ "$EFFECTIVE_SINGLE_AGENT_TOOL" != "$PROJECT_SINGLE_AGENT_TOOL" ]]; then
            match="false"
        fi
    fi

    if [[ "$match" == "false" ]]; then
        return 1
    else
        return 0
    fi
}

# -----------------------------------------------------------------------------
# User Prompts
# -----------------------------------------------------------------------------

prompt_config_mismatch() {
    local scenario=$1

    echo ""
    echo -e "${YELLOW}=== ⚠️  Configuration Mismatch ===${NC}"
    echo ""

    if [[ "$scenario" == "user_flags" ]]; then
        echo "Your project's agent-os config is using the following settings:"
        echo ""
        echo "  Profile: $PROJECT_PROFILE"
        echo "  Multi-agent mode: $PROJECT_MULTI_AGENT_MODE"
        [[ "$PROJECT_MULTI_AGENT_MODE" == "true" ]] && echo "  Multi-agent tool: $PROJECT_MULTI_AGENT_TOOL"
        echo "  Single-agent mode: $PROJECT_SINGLE_AGENT_MODE"
        [[ "$PROJECT_SINGLE_AGENT_MODE" == "true" ]] && echo "  Single-agent tool: $PROJECT_SINGLE_AGENT_TOOL"
        echo ""
        echo "But you've specified you want to re-install Agent OS with these settings:"
        echo ""
        echo "  Profile: $EFFECTIVE_PROFILE"
        echo "  Multi-agent mode: $EFFECTIVE_MULTI_AGENT_MODE"
        [[ "$EFFECTIVE_MULTI_AGENT_MODE" == "true" ]] && echo "  Multi-agent tool: $EFFECTIVE_MULTI_AGENT_TOOL"
        echo "  Single-agent mode: $EFFECTIVE_SINGLE_AGENT_MODE"
        [[ "$EFFECTIVE_SINGLE_AGENT_MODE" == "true" ]] && echo "  Single-agent tool: $EFFECTIVE_SINGLE_AGENT_TOOL"
    else
        echo "Your project's agent-os config is using the following settings:"
        echo ""
        echo "  Profile: $PROJECT_PROFILE"
        echo "  Multi-agent mode: $PROJECT_MULTI_AGENT_MODE"
        [[ "$PROJECT_MULTI_AGENT_MODE" == "true" ]] && echo "  Multi-agent tool: $PROJECT_MULTI_AGENT_TOOL"
        echo "  Single-agent mode: $PROJECT_SINGLE_AGENT_MODE"
        [[ "$PROJECT_SINGLE_AGENT_MODE" == "true" ]] && echo "  Single-agent tool: $PROJECT_SINGLE_AGENT_TOOL"
        echo ""
        echo "But your base Agent OS config defaults specify the following:"
        echo ""
        echo "  Profile: $BASE_PROFILE"
        echo "  Multi-agent mode: $BASE_MULTI_AGENT_MODE"
        [[ "$BASE_MULTI_AGENT_MODE" == "true" ]] && echo "  Multi-agent tool: $BASE_MULTI_AGENT_TOOL"
        echo "  Single-agent mode: $BASE_SINGLE_AGENT_MODE"
        [[ "$BASE_SINGLE_AGENT_MODE" == "true" ]] && echo "  Single-agent tool: $BASE_SINGLE_AGENT_TOOL"
    fi

    echo ""
    print_status "What would you like to do?"
    echo ""
    echo "1) DELETE your current agent-os/ folder and re-install a fresh installation using the settings you've specified today."
    echo -e "   ${RED}⚠️ WARNING: This will delete all of your current agent-os files in this project and re-install them.${NC}"
    echo ""
    echo "2) Update your current agent-os/ installation using your project's current config settings"
    echo "   (will not overwrite files unless directed to do so with --overwrite flag)."
    echo ""
    read -p "Enter 1 or 2: " choice

    case $choice in
        1)
            return 1  # Re-install
            ;;
        2)
            return 0  # Update with project settings
            ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac
}

# -----------------------------------------------------------------------------
# Update Functions
# -----------------------------------------------------------------------------

# Update standards files
update_standards() {
    print_status "Updating standards"

    local standards_updated=0
    local standards_skipped=0
    local standards_new=0

    while read file; do
        if [[ "$file" == standards/* ]]; then
            local source=$(get_profile_file "$PROJECT_PROFILE" "$file" "$BASE_DIR")
            local dest="$PROJECT_DIR/agent-os/$file"

            if [[ -f "$source" ]]; then
                if should_skip_file "$dest" "$OVERWRITE_ALL" "$OVERWRITE_STANDARDS" "standard"; then
                    SKIPPED_FILES+=("$dest")
                    ((standards_skipped++)) || true
                    print_verbose "Skipped: $dest"
                else
                    if [[ -f "$dest" ]]; then
                        UPDATED_FILES+=("$dest")
                        ((standards_updated++)) || true
                        print_verbose "Updated: $dest"
                    else
                        NEW_FILES+=("$dest")
                        ((standards_new++)) || true
                        print_verbose "New file: $dest"
                    fi
                    if [[ "$DRY_RUN" != "true" ]]; then
                        copy_file "$source" "$dest" > /dev/null
                    fi
                fi
            fi
        fi
    done < <(get_profile_files "$PROJECT_PROFILE" "$BASE_DIR" "standards")

    if [[ "$DRY_RUN" != "true" ]]; then
        if [[ $standards_new -gt 0 ]]; then
            echo "✓ Added $standards_new standards in agent-os/standards"
        fi
        if [[ $standards_updated -gt 0 ]]; then
            echo "✓ Updated $standards_updated standards in agent-os/standards"
        fi
        if [[ $standards_skipped -gt 0 ]]; then
            echo -e "${YELLOW}$standards_skipped files in agent-os/standards were not updated and overwritten. To update and overwrite these, re-run with --overwrite-standards flag.${NC}"
        fi
    fi
}

# Update roles files
update_roles() {
    print_status "Updating roles"

    local roles_updated=0
    local roles_skipped=0
    local roles_new=0

    while read file; do
        if [[ "$file" == roles/* ]]; then
            local source=$(get_profile_file "$PROJECT_PROFILE" "$file" "$BASE_DIR")
            local dest="$PROJECT_DIR/agent-os/$file"

            if [[ -f "$source" ]]; then
                if should_skip_file "$dest" "$OVERWRITE_ALL" "false" "role"; then
                    SKIPPED_FILES+=("$dest")
                    ((roles_skipped++)) || true
                    print_verbose "Skipped: $dest"
                else
                    if [[ -f "$dest" ]]; then
                        UPDATED_FILES+=("$dest")
                        ((roles_updated++)) || true
                        print_verbose "Updated: $dest"
                    else
                        NEW_FILES+=("$dest")
                        ((roles_new++)) || true
                        print_verbose "New file: $dest"
                    fi
                    if [[ "$DRY_RUN" != "true" ]]; then
                        copy_file "$source" "$dest" > /dev/null
                    fi
                fi
            fi
        fi
    done < <(get_profile_files "$PROJECT_PROFILE" "$BASE_DIR" "roles")

    if [[ "$DRY_RUN" != "true" ]]; then
        if [[ $roles_new -gt 0 ]]; then
            echo "✓ Added $roles_new files in agent-os/roles"
        fi
        if [[ $roles_updated -gt 0 ]]; then
            echo "✓ Updated $roles_updated files in agent-os/roles"
        fi
        if [[ $roles_skipped -gt 0 ]]; then
            echo -e "${YELLOW}$roles_skipped files in agent-os/roles were not updated and overwritten.${NC}"
        fi
    fi
}

# Update single-agent commands
update_single_agent_commands() {
    print_status "Updating single-agent commands..."
    local commands_updated=0
    local commands_skipped=0
    local commands_new=0

    while read file; do
        if [[ "$file" == commands/*/single-agent/* ]]; then
            local source=$(get_profile_file "$PROJECT_PROFILE" "$file" "$BASE_DIR")
            if [[ -f "$source" ]]; then
                local dest=""

                # If both modes are enabled, preserve the folder structure (single-agent/ and multi-agent/)
                if [[ "$PROJECT_MULTI_AGENT_MODE" == "true" ]]; then
                    # Keep full path including single-agent subfolder
                    dest="$PROJECT_DIR/agent-os/$file"
                else
                    # Only single-agent mode: strip the single-agent/ subfolder
                    local dest_file=$(echo "$file" | sed 's/\/single-agent//')
                    dest="$PROJECT_DIR/agent-os/$dest_file"
                fi

                if should_skip_file "$dest" "$OVERWRITE_ALL" "$OVERWRITE_COMMANDS" "command"; then
                    SKIPPED_FILES+=("$dest")
                    ((commands_skipped++)) || true
                    print_verbose "Skipped: $dest"
                else
                    if [[ -f "$dest" ]]; then
                        UPDATED_FILES+=("$dest")
                        ((commands_updated++)) || true
                        print_verbose "Updated: $dest"
                    else
                        NEW_FILES+=("$dest")
                        ((commands_new++)) || true
                        print_verbose "New file: $dest"
                    fi
                    if [[ "$DRY_RUN" != "true" ]]; then
                        compile_command "$source" "$dest" "$BASE_DIR" "$PROJECT_PROFILE"
                    fi
                fi
            fi
        fi
    done < <(get_profile_files "$PROJECT_PROFILE" "$BASE_DIR" "commands")

    # If both modes are enabled, also update multi-agent commands
    if [[ "$PROJECT_MULTI_AGENT_MODE" == "true" ]]; then
        while read file; do
            if [[ "$file" == commands/*/multi-agent/* ]]; then
                local source=$(get_profile_file "$PROJECT_PROFILE" "$file" "$BASE_DIR")
                if [[ -f "$source" ]]; then
                    local dest="$PROJECT_DIR/agent-os/$file"

                    if should_skip_file "$dest" "$OVERWRITE_ALL" "$OVERWRITE_COMMANDS" "command"; then
                        SKIPPED_FILES+=("$dest")
                        ((commands_skipped++)) || true
                        print_verbose "Skipped: $dest"
                    else
                        if [[ -f "$dest" ]]; then
                            UPDATED_FILES+=("$dest")
                            ((commands_updated++)) || true
                            print_verbose "Updated: $dest"
                        else
                            NEW_FILES+=("$dest")
                            ((commands_new++)) || true
                            print_verbose "New file: $dest"
                        fi
                        if [[ "$DRY_RUN" != "true" ]]; then
                            compile_command "$source" "$dest" "$BASE_DIR" "$PROJECT_PROFILE"
                        fi
                    fi
                fi
            fi
        done < <(get_profile_files "$PROJECT_PROFILE" "$BASE_DIR" "commands")
    fi

    if [[ "$DRY_RUN" != "true" ]]; then
        if [[ $commands_new -gt 0 ]]; then
            echo "✓ Added $commands_new single-agent commands"
        fi
        if [[ $commands_updated -gt 0 ]]; then
            echo "✓ Updated $commands_updated single-agent commands"
        fi
        if [[ $commands_skipped -gt 0 ]]; then
            echo -e "${YELLOW}$commands_skipped commands were not updated and overwritten. To update and overwrite these, re-run with --overwrite-commands flag.${NC}"
        fi
    fi
}

# Update Claude Code agents and commands
update_claude_code_files() {
    print_status "Updating Claude Code tools"

    local commands_updated=0
    local commands_skipped=0
    local commands_new=0
    local agents_updated=0
    local agents_skipped=0
    local agents_new=0

    # Update commands in .claude/commands/agent-os/
    while read file; do
        if [[ "$file" == commands/*/multi-agent/* ]]; then
            local source=$(get_profile_file "$PROJECT_PROFILE" "$file" "$BASE_DIR")
            if [[ -f "$source" ]]; then
                local command_name=$(echo "$file" | sed 's/commands\///' | sed 's/\/multi-agent.*//')
                local dest="$PROJECT_DIR/.claude/commands/agent-os/${command_name}.md"

                if should_skip_file "$dest" "$OVERWRITE_ALL" "$OVERWRITE_COMMANDS" "command"; then
                    SKIPPED_FILES+=("$dest")
                    ((commands_skipped++)) || true
                    print_verbose "Skipped: $dest"
                else
                    if [[ -f "$dest" ]]; then
                        UPDATED_FILES+=("$dest")
                        ((commands_updated++)) || true
                        print_verbose "Updated: $dest"
                    else
                        NEW_FILES+=("$dest")
                        ((commands_new++)) || true
                        print_verbose "New file: $dest"
                    fi
                    if [[ "$DRY_RUN" != "true" ]]; then
                        compile_command "$source" "$dest" "$BASE_DIR" "$PROJECT_PROFILE"
                    fi
                fi
            fi
        fi
    done < <(get_profile_files "$PROJECT_PROFILE" "$BASE_DIR" "commands")

    # Update static agents
    get_profile_files "$PROJECT_PROFILE" "$BASE_DIR" "agents" | while read file; do
        if [[ "$file" == agents/*.md ]] && [[ "$file" != agents/templates/* ]]; then
            local source=$(get_profile_file "$PROJECT_PROFILE" "$file" "$BASE_DIR")
            if [[ -f "$source" ]]; then
                local agent_name=$(basename "$file" .md)
                local dest="$PROJECT_DIR/.claude/agents/agent-os/${agent_name}.md"

                if should_skip_file "$dest" "$OVERWRITE_ALL" "$OVERWRITE_AGENTS" "agent"; then
                    SKIPPED_FILES+=("$dest")
                    print_verbose "Skipped: $dest"
                else
                    if [[ -f "$dest" ]]; then
                        UPDATED_FILES+=("$dest")
                        print_verbose "Updated: $dest"
                    else
                        NEW_FILES+=("$dest")
                        print_verbose "New file: $dest"
                    fi
                    if [[ "$DRY_RUN" != "true" ]]; then
                        compile_agent "$source" "$dest" "$BASE_DIR" "$PROJECT_PROFILE" ""
                    fi
                fi
            fi
        fi
    done

    # Update specification agents
    get_profile_files "$PROJECT_PROFILE" "$BASE_DIR" "agents/specification" | while read file; do
        if [[ "$file" == agents/specification/*.md ]]; then
            local source=$(get_profile_file "$PROJECT_PROFILE" "$file" "$BASE_DIR")
            if [[ -f "$source" ]]; then
                local agent_name=$(basename "$file" .md)
                local dest="$PROJECT_DIR/.claude/agents/agent-os/${agent_name}.md"

                if should_skip_file "$dest" "$OVERWRITE_ALL" "$OVERWRITE_AGENTS" "agent"; then
                    SKIPPED_FILES+=("$dest")
                    print_verbose "Skipped: $dest"
                else
                    if [[ -f "$dest" ]]; then
                        UPDATED_FILES+=("$dest")
                        print_verbose "Updated: $dest"
                    else
                        NEW_FILES+=("$dest")
                        print_verbose "New file: $dest"
                    fi
                    if [[ "$DRY_RUN" != "true" ]]; then
                        compile_agent "$source" "$dest" "$BASE_DIR" "$PROJECT_PROFILE" ""
                    fi
                fi
            fi
        fi
    done

    # Update implementer agents
    local implementers_file=$(get_profile_file "$PROJECT_PROFILE" "roles/implementers.yml" "$BASE_DIR")
    if [[ -f "$implementers_file" ]]; then
        local template_file=$(get_profile_file "$PROJECT_PROFILE" "agents/templates/implementer.md" "$BASE_DIR")
        if [[ -f "$template_file" ]]; then
            local implementer_ids=$(awk '/^  - id:/ {print $3}' "$implementers_file")

            for id in $implementer_ids; do
                print_verbose "Updating implementer agent: $id"

                local dest="$PROJECT_DIR/.claude/agents/agent-os/${id}.md"

                if should_skip_file "$dest" "$OVERWRITE_ALL" "$OVERWRITE_AGENTS" "agent"; then
                    SKIPPED_FILES+=("$dest")
                    print_verbose "Skipped: $dest"
                else
                    # Build role data with delimiter-based format for multi-line values
                    local role_data=""
                    role_data="${role_data}<<<id>>>"$'\n'"$id"$'\n'"<<<END>>>"$'\n'

                    local description=$(parse_role_yaml "$implementers_file" "implementers" "$id" "description")
                    role_data="${role_data}<<<description>>>"$'\n'"$description"$'\n'"<<<END>>>"$'\n'

                    local your_role=$(parse_role_yaml "$implementers_file" "implementers" "$id" "your_role")
                    role_data="${role_data}<<<your_role>>>"$'\n'"$your_role"$'\n'"<<<END>>>"$'\n'

                    local tools=$(parse_role_yaml "$implementers_file" "implementers" "$id" "tools")
                    role_data="${role_data}<<<tools>>>"$'\n'"$tools"$'\n'"<<<END>>>"$'\n'

                    local model=$(parse_role_yaml "$implementers_file" "implementers" "$id" "model")
                    role_data="${role_data}<<<model>>>"$'\n'"$model"$'\n'"<<<END>>>"$'\n'

                    local color=$(parse_role_yaml "$implementers_file" "implementers" "$id" "color")
                    role_data="${role_data}<<<color>>>"$'\n'"$color"$'\n'"<<<END>>>"$'\n'

                    # Get areas of responsibility
                    local areas=$(parse_role_yaml "$implementers_file" "implementers" "$id" "areas_of_responsibility")
                    role_data="${role_data}<<<areas_of_responsibility>>>"$'\n'"$areas"$'\n'"<<<END>>>"$'\n'

                    # Get example areas outside of responsibility
                    local example_areas_outside=$(parse_role_yaml "$implementers_file" "implementers" "$id" "example_areas_outside_of_responsibility")
                    role_data="${role_data}<<<example_areas_outside_of_responsibility>>>"$'\n'"$example_areas_outside"$'\n'"<<<END>>>"$'\n'

                    # Get standards
                    local standards_patterns=$(get_role_standards "$implementers_file" "implementers" "$id")
                    local standards_list=$(process_standards "" "$BASE_DIR" "$PROJECT_PROFILE" "$standards_patterns")
                    role_data="${role_data}<<<implementer_standards>>>"$'\n'"$standards_list"$'\n'"<<<END>>>"$'\n'

                    if [[ -f "$dest" ]]; then
                        UPDATED_FILES+=("$dest")
                        print_verbose "Updated: $dest"
                    else
                        NEW_FILES+=("$dest")
                        print_verbose "New file: $dest"
                    fi

                    if [[ "$DRY_RUN" != "true" ]]; then
                        compile_agent "$template_file" "$dest" "$BASE_DIR" "$PROJECT_PROFILE" "$role_data"
                    fi
                fi
            done
        fi
    fi

    # Update area verifier agents
    local verifiers_file=$(get_profile_file "$PROJECT_PROFILE" "roles/verifiers.yml" "$BASE_DIR")
    if [[ -f "$verifiers_file" ]]; then
        local template_file=$(get_profile_file "$PROJECT_PROFILE" "agents/templates/verifier.md" "$BASE_DIR")
        if [[ -f "$template_file" ]]; then
            local verifier_ids=$(awk '/^  - id:/ {print $3}' "$verifiers_file")

            for id in $verifier_ids; do
                print_verbose "Updating area verifier agent: $id"

                local dest="$PROJECT_DIR/.claude/agents/agent-os/${id}.md"

                if should_skip_file "$dest" "$OVERWRITE_ALL" "$OVERWRITE_AGENTS" "agent"; then
                    SKIPPED_FILES+=("$dest")
                    print_verbose "Skipped: $dest"
                else
                    # Build role data with delimiter-based format for multi-line values
                    local role_data=""
                    role_data="${role_data}<<<id>>>"$'\n'"$id"$'\n'"<<<END>>>"$'\n'

                    local description=$(parse_role_yaml "$verifiers_file" "verifiers" "$id" "description")
                    role_data="${role_data}<<<description>>>"$'\n'"$description"$'\n'"<<<END>>>"$'\n'

                    local your_role=$(parse_role_yaml "$verifiers_file" "verifiers" "$id" "your_role")
                    role_data="${role_data}<<<your_role>>>"$'\n'"$your_role"$'\n'"<<<END>>>"$'\n'

                    local tools=$(parse_role_yaml "$verifiers_file" "verifiers" "$id" "tools")
                    role_data="${role_data}<<<tools>>>"$'\n'"$tools"$'\n'"<<<END>>>"$'\n'

                    local model=$(parse_role_yaml "$verifiers_file" "verifiers" "$id" "model")
                    role_data="${role_data}<<<model>>>"$'\n'"$model"$'\n'"<<<END>>>"$'\n'

                    local color=$(parse_role_yaml "$verifiers_file" "verifiers" "$id" "color")
                    role_data="${role_data}<<<color>>>"$'\n'"$color"$'\n'"<<<END>>>"$'\n'

                    # Get areas of responsibility
                    local areas=$(parse_role_yaml "$verifiers_file" "verifiers" "$id" "areas_of_responsibility")
                    role_data="${role_data}<<<areas_of_responsibility>>>"$'\n'"$areas"$'\n'"<<<END>>>"$'\n'

                    # Get example areas outside of responsibility
                    local example_areas_outside=$(parse_role_yaml "$verifiers_file" "verifiers" "$id" "example_areas_outside_of_responsibility")
                    role_data="${role_data}<<<example_areas_outside_of_responsibility>>>"$'\n'"$example_areas_outside"$'\n'"<<<END>>>"$'\n'

                    # Get standards
                    local standards_patterns=$(get_role_standards "$verifiers_file" "verifiers" "$id")
                    local standards_list=$(process_standards "" "$BASE_DIR" "$PROJECT_PROFILE" "$standards_patterns")
                    role_data="${role_data}<<<verifier_standards>>>"$'\n'"$standards_list"$'\n'"<<<END>>>"$'\n'

                    if [[ -f "$dest" ]]; then
                        UPDATED_FILES+=("$dest")
                        print_verbose "Updated: $dest"
                    else
                        NEW_FILES+=("$dest")
                        print_verbose "New file: $dest"
                    fi

                    if [[ "$DRY_RUN" != "true" ]]; then
                        compile_agent "$template_file" "$dest" "$BASE_DIR" "$PROJECT_PROFILE" "$role_data"
                    fi
                fi
            done
        fi
    fi

    if [[ "$DRY_RUN" != "true" ]]; then
        # Count commands separately
        local command_pattern=".claude/commands/agent-os"
        local commands_actual_updated=0
        local commands_actual_skipped=0
        local commands_actual_new=0

        for file in "${UPDATED_FILES[@]}"; do
            [[ "$file" == *"$command_pattern"* ]] && ((commands_actual_updated++)) || true
        done

        for file in "${NEW_FILES[@]}"; do
            [[ "$file" == *"$command_pattern"* ]] && ((commands_actual_new++)) || true
        done

        for file in "${SKIPPED_FILES[@]}"; do
            [[ "$file" == *"$command_pattern"* ]] && ((commands_actual_skipped++)) || true
        done

        if [[ $commands_actual_new -gt 0 ]]; then
            echo "✓ Added $commands_actual_new Claude Code commands"
        fi
        if [[ $commands_actual_updated -gt 0 ]]; then
            echo "✓ Updated $commands_actual_updated Claude Code commands"
        fi
        if [[ $commands_actual_skipped -gt 0 ]]; then
            echo -e "${YELLOW}$commands_actual_skipped commands were not updated and overwritten. To update and overwrite these, re-run with --overwrite-commands flag.${NC}"
        fi

        # Count agent files by checking SKIPPED_FILES, UPDATED_FILES, NEW_FILES
        local agent_pattern=".claude/agents/agent-os"
        local agents_updated=0
        local agents_skipped=0
        local agents_new=0

        for file in "${UPDATED_FILES[@]}"; do
            [[ "$file" == *"$agent_pattern"* ]] && ((agents_updated++)) || true
        done

        for file in "${NEW_FILES[@]}"; do
            [[ "$file" == *"$agent_pattern"* ]] && ((agents_new++)) || true
        done

        for file in "${SKIPPED_FILES[@]}"; do
            [[ "$file" == *"$agent_pattern"* ]] && ((agents_skipped++)) || true
        done

        if [[ $agents_new -gt 0 ]]; then
            echo "✓ Added $agents_new Claude Code agents"
        fi
        if [[ $agents_updated -gt 0 ]]; then
            echo "✓ Updated $agents_updated Claude Code agents"
        fi
        if [[ $agents_skipped -gt 0 ]]; then
            echo -e "${YELLOW}$agents_skipped agents were not updated and overwritten. To update and overwrite these, re-run with --overwrite-agents flag.${NC}"
        fi
    fi
}

# Update agent-os folder and configuration
update_agent_os_folder() {
    print_status "Updating agent-os folder"

    # Update the configuration file
    write_project_config "$EFFECTIVE_VERSION" "$PROJECT_PROFILE" \
        "$PROJECT_MULTI_AGENT_MODE" "$PROJECT_MULTI_AGENT_TOOL" \
        "$PROJECT_SINGLE_AGENT_MODE" "$PROJECT_SINGLE_AGENT_TOOL"

    if [[ "$DRY_RUN" != "true" ]]; then
        echo "✓ Updated agent-os folder"
        echo "✓ Updated agent-os project configuration"
    fi
}

# Perform update
perform_update() {
    # Display configuration at the top
    echo ""
    print_status "Configuration:"
    echo -e "  Profile: ${YELLOW}$PROJECT_PROFILE${NC}"
    echo -e "  Multi-agent mode: ${YELLOW}$PROJECT_MULTI_AGENT_MODE${NC}"
    if [[ "$PROJECT_MULTI_AGENT_MODE" == "true" ]]; then
        echo -e "  Multi-agent tool: ${YELLOW}$PROJECT_MULTI_AGENT_TOOL${NC}"
    fi
    echo -e "  Single-agent mode: ${YELLOW}$PROJECT_SINGLE_AGENT_MODE${NC}"
    if [[ "$PROJECT_SINGLE_AGENT_MODE" == "true" ]]; then
        echo -e "  Single-agent tool: ${YELLOW}$PROJECT_SINGLE_AGENT_TOOL${NC}"
    fi
    echo ""

    # Update agent-os folder and configuration
    update_agent_os_folder
    echo ""

    # Update components based on enabled modes
    update_standards
    echo ""

    update_roles
    echo ""

    if [[ "$PROJECT_SINGLE_AGENT_MODE" == "true" ]]; then
        update_single_agent_commands
        echo ""
    fi

    if [[ "$PROJECT_MULTI_AGENT_MODE" == "true" ]] && [[ "$PROJECT_MULTI_AGENT_TOOL" == "claude-code" ]]; then
        update_claude_code_files
        echo ""
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        print_warning "DRY RUN - No files were actually modified"
        echo ""

        if [[ ${#NEW_FILES[@]} -gt 0 ]]; then
            print_status "New files that would be added:"
            for file in "${NEW_FILES[@]}"; do
                echo "  + $file"
            done
            echo ""
        fi

        if [[ ${#UPDATED_FILES[@]} -gt 0 ]]; then
            print_status "Files that would be updated:"
            for file in "${UPDATED_FILES[@]}"; do
                echo "  ~ $file"
            done
            echo ""
        fi

        if [[ ${#SKIPPED_FILES[@]} -gt 0 ]]; then
            print_status "Files that would be skipped:"
            for file in "${SKIPPED_FILES[@]}"; do
                echo "  - $file"
            done
            echo ""
        fi

        read -p "Proceed with actual update? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            DRY_RUN="false"
            SKIPPED_FILES=()
            UPDATED_FILES=()
            NEW_FILES=()
            perform_update
        fi
    else
        print_success "Agent OS has been successfully updated!"
        echo ""
        echo -e "${GREEN}Visit the docs for guides on how to use Agent OS: https://buildermethods.com/agent-os${NC}"
        echo ""
    fi
}

# Handle re-installation
handle_reinstallation() {
    print_section "Re-installation"

    print_warning "This will DELETE your current agent-os/ folder and reinstall from scratch."
    echo ""

    # Check for Claude Code files
    if [[ -d "$PROJECT_DIR/.claude/agents/agent-os" ]] || [[ -d "$PROJECT_DIR/.claude/commands/agent-os" ]]; then
        print_warning "This will also DELETE:"
        [[ -d "$PROJECT_DIR/.claude/agents/agent-os" ]] && echo "  - .claude/agents/agent-os/"
        [[ -d "$PROJECT_DIR/.claude/commands/agent-os" ]] && echo "  - .claude/commands/agent-os/"
        echo ""
    fi

    read -p "Are you sure you want to proceed? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Re-installation cancelled"
        exit 0
    fi

    # Pass control to project-install.sh with --re-install flag
    exec "$BASE_DIR/scripts/project-install.sh" --re-install "$@"
}

# -----------------------------------------------------------------------------
# Main Execution
# -----------------------------------------------------------------------------

main() {
    # Parse command line arguments
    parse_arguments "$@"

    # Check if we're trying to update in the base installation directory
    check_not_base_installation

    # Validate installations
    validate_installations

    # Check for base installation updates
    check_for_base_updates

    # Load configurations
    load_configurations

    # Check if re-install was requested
    if [[ "$RE_INSTALL" == "true" ]]; then
        handle_reinstallation "$@"
        exit 0
    fi

    # Check version compatibility
    if ! check_compatibility; then
        print_warning "Due to version incompatibility, a fresh installation is required."
        handle_reinstallation "$@"
        exit 0
    fi

    # Determine if configuration matches
    local config_matches="true"
    local scenario=""

    # Check if user provided mode/tool flags
    if [[ -n "$MULTI_AGENT_MODE" ]] || [[ -n "$MULTI_AGENT_TOOL" ]] || \
       [[ -n "$SINGLE_AGENT_MODE" ]] || [[ -n "$SINGLE_AGENT_TOOL" ]]; then
        # User provided flags - check if they match project config
        if ! check_config_match; then
            config_matches="false"
            scenario="user_flags"
        fi
    else
        # No user flags - check if base config matches project config
        EFFECTIVE_MULTI_AGENT_MODE="$BASE_MULTI_AGENT_MODE"
        EFFECTIVE_MULTI_AGENT_TOOL="$BASE_MULTI_AGENT_TOOL"
        EFFECTIVE_SINGLE_AGENT_MODE="$BASE_SINGLE_AGENT_MODE"
        EFFECTIVE_SINGLE_AGENT_TOOL="$BASE_SINGLE_AGENT_TOOL"

        if ! check_config_match; then
            config_matches="false"
            scenario="base_defaults"
        fi
    fi

    # Handle config mismatch
    if [[ "$config_matches" == "false" ]]; then
        if prompt_config_mismatch "$scenario"; then
            # User chose to update with project settings
            EFFECTIVE_MULTI_AGENT_MODE="$PROJECT_MULTI_AGENT_MODE"
            EFFECTIVE_MULTI_AGENT_TOOL="$PROJECT_MULTI_AGENT_TOOL"
            EFFECTIVE_SINGLE_AGENT_MODE="$PROJECT_SINGLE_AGENT_MODE"
            EFFECTIVE_SINGLE_AGENT_TOOL="$PROJECT_SINGLE_AGENT_TOOL"
            perform_update
        else
            # User chose to re-install
            handle_reinstallation "$@"
        fi
    else
        # Config matches - proceed with update
        perform_update
    fi
}

# Run main function
main "$@"
