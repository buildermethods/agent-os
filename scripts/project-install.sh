#!/bin/bash

# =============================================================================
# Agent OS Project Installation Script
# Installs Agent OS into a project's codebase
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
OVERWRITE_STANDARDS="false"
OVERWRITE_COMMANDS="false"
OVERWRITE_AGENTS="false"
INSTALLED_FILES=()

# -----------------------------------------------------------------------------
# Help Function
# -----------------------------------------------------------------------------

show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Install Agent OS into the current project directory.

Options:
    --profile PROFILE           Use specified profile (default: from config.yml)
    --multi-agent-mode [BOOL]   Enable/disable multi-agent mode
    --multi-agent-tool TOOL     Specify multi-agent tool
    --single-agent-mode [BOOL]  Enable/disable single-agent mode
    --single-agent-tool TOOL    Specify single-agent tool
    --re-install                Delete and reinstall Agent OS
    --overwrite-all             Overwrite all existing files during update
    --overwrite-standards       Overwrite existing standards during update
    --overwrite-commands        Overwrite existing commands during update
    --overwrite-agents          Overwrite existing agents during update
    --dry-run                   Show what would be done without doing it
    --verbose                   Show detailed output
    -h, --help                  Show this help message

Examples:
    $0
    $0 --profile rails
    $0 --multi-agent-mode true --multi-agent-tool claude-code
    $0 --single-agent-mode --dry-run

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
            --overwrite-standards)
                OVERWRITE_STANDARDS="true"
                shift
                ;;
            --overwrite-commands)
                OVERWRITE_COMMANDS="true"
                shift
                ;;
            --overwrite-agents)
                OVERWRITE_AGENTS="true"
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
# Configuration Functions
# -----------------------------------------------------------------------------

load_configuration() {
    # Load base configuration using common function
    load_base_config

    # Set effective values (command line overrides base config)
    EFFECTIVE_PROFILE="${PROFILE:-$BASE_PROFILE}"
    EFFECTIVE_MULTI_AGENT_MODE="${MULTI_AGENT_MODE:-$BASE_MULTI_AGENT_MODE}"
    EFFECTIVE_MULTI_AGENT_TOOL="${MULTI_AGENT_TOOL:-$BASE_MULTI_AGENT_TOOL}"
    EFFECTIVE_SINGLE_AGENT_MODE="${SINGLE_AGENT_MODE:-$BASE_SINGLE_AGENT_MODE}"
    EFFECTIVE_SINGLE_AGENT_TOOL="${SINGLE_AGENT_TOOL:-$BASE_SINGLE_AGENT_TOOL}"
    EFFECTIVE_VERSION="$BASE_VERSION"

    # Validate configuration using common function
    validate_config "$EFFECTIVE_MULTI_AGENT_MODE" "$EFFECTIVE_SINGLE_AGENT_MODE" "$EFFECTIVE_PROFILE"

    print_verbose "Configuration loaded:"
    print_verbose "  Profile: $EFFECTIVE_PROFILE"
    print_verbose "  Multi-agent mode: $EFFECTIVE_MULTI_AGENT_MODE (tool: $EFFECTIVE_MULTI_AGENT_TOOL)"
    print_verbose "  Single-agent mode: $EFFECTIVE_SINGLE_AGENT_MODE (tool: $EFFECTIVE_SINGLE_AGENT_TOOL)"
}

# -----------------------------------------------------------------------------
# Installation Functions
# -----------------------------------------------------------------------------

# Install standards files
install_standards() {
    if [[ "$DRY_RUN" != "true" ]]; then
        print_status "Installing standards"
    fi

    local standards_count=0

    while read file; do
        if [[ "$file" == standards/* ]]; then
            local source=$(get_profile_file "$EFFECTIVE_PROFILE" "$file" "$BASE_DIR")
            local dest="$PROJECT_DIR/agent-os/$file"

            if [[ -f "$source" ]]; then
                local installed_file=$(copy_file "$source" "$dest")
                if [[ -n "$installed_file" ]]; then
                    INSTALLED_FILES+=("$installed_file")
                    ((standards_count++)) || true
                fi
            fi
        fi
    done < <(get_profile_files "$EFFECTIVE_PROFILE" "$BASE_DIR" "standards")

    if [[ "$DRY_RUN" != "true" ]]; then
        if [[ $standards_count -gt 0 ]]; then
            echo "✓ Installed $standards_count standards in agent-os/standards"
        fi
    fi
}

# Install roles files - Needed for single-agent mode
install_roles() {
    if [[ "$DRY_RUN" != "true" ]]; then
        print_status "Installing roles"
    fi

    local roles_count=0

    while read file; do
        if [[ "$file" == roles/* ]]; then
            local source=$(get_profile_file "$EFFECTIVE_PROFILE" "$file" "$BASE_DIR")
            local dest="$PROJECT_DIR/agent-os/$file"

            if [[ -f "$source" ]]; then
                local installed_file=$(copy_file "$source" "$dest")
                if [[ -n "$installed_file" ]]; then
                    INSTALLED_FILES+=("$installed_file")
                    ((roles_count++)) || true
                fi
            fi
        fi
    done < <(get_profile_files "$EFFECTIVE_PROFILE" "$BASE_DIR" "roles")

    if [[ "$DRY_RUN" != "true" ]]; then
        if [[ $roles_count -gt 0 ]]; then
            echo "✓ Installed $roles_count files in agent-os/roles"
        fi
    fi
}

# Install and compile single-agent mode commands
install_single_agent_commands() {
    if [[ "$DRY_RUN" != "true" ]]; then
        print_status "Installing single-agent mode commands..."
    fi

    local commands_count=0

    while read file; do
        # Include files that are in single-agent folders
        if [[ "$file" == commands/*/single-agent/* ]]; then
            local source=$(get_profile_file "$EFFECTIVE_PROFILE" "$file" "$BASE_DIR")
            if [[ -f "$source" ]]; then
                local dest=""

                # If both modes are enabled, preserve the folder structure (single-agent/ and multi-agent/)
                if [[ "$EFFECTIVE_MULTI_AGENT_MODE" == "true" ]]; then
                    # Keep full path including single-agent subfolder
                    dest="$PROJECT_DIR/agent-os/$file"
                else
                    # Only single-agent mode: strip the single-agent/ subfolder
                    local dest_file=$(echo "$file" | sed 's/\/single-agent//')
                    dest="$PROJECT_DIR/agent-os/$dest_file"
                fi

                local compiled=$(compile_command "$source" "$dest" "$BASE_DIR" "$EFFECTIVE_PROFILE")
                if [[ "$DRY_RUN" == "true" ]]; then
                    INSTALLED_FILES+=("$dest")
                fi
                ((commands_count++)) || true
            fi
        fi
    done < <(get_profile_files "$EFFECTIVE_PROFILE" "$BASE_DIR" "commands")

    # If both modes are enabled, also copy multi-agent commands to agent-os
    if [[ "$EFFECTIVE_MULTI_AGENT_MODE" == "true" ]]; then
        while read file; do
            if [[ "$file" == commands/*/multi-agent/* ]]; then
                local source=$(get_profile_file "$EFFECTIVE_PROFILE" "$file" "$BASE_DIR")
                if [[ -f "$source" ]]; then
                    local dest="$PROJECT_DIR/agent-os/$file"
                    local compiled=$(compile_command "$source" "$dest" "$BASE_DIR" "$EFFECTIVE_PROFILE")
                    if [[ "$DRY_RUN" == "true" ]]; then
                        INSTALLED_FILES+=("$dest")
                    fi
                    ((commands_count++)) || true
                fi
            fi
        done < <(get_profile_files "$EFFECTIVE_PROFILE" "$BASE_DIR" "commands")
    fi

    if [[ "$DRY_RUN" != "true" ]]; then
        if [[ $commands_count -gt 0 ]]; then
            echo "✓ Installed $commands_count single-agent commands"
        fi
    fi
}

# Install and compile multi-agent mode files for Claude Code
install_claude_code_files() {
    if [[ "$DRY_RUN" != "true" ]]; then
        print_status "Installing Claude Code tools"
    fi

    local commands_count=0
    local agents_count=0

    # Install commands to .claude/commands/agent-os/
    while read file; do
        if [[ "$file" == commands/*/multi-agent/* ]]; then
            local source=$(get_profile_file "$EFFECTIVE_PROFILE" "$file" "$BASE_DIR")
            if [[ -f "$source" ]]; then
                # Extract command name from path
                local command_name=$(echo "$file" | sed 's/commands\///' | sed 's/\/multi-agent.*//')
                local dest="$PROJECT_DIR/.claude/commands/agent-os/${command_name}.md"

                local compiled=$(compile_command "$source" "$dest" "$BASE_DIR" "$EFFECTIVE_PROFILE")
                if [[ "$DRY_RUN" == "true" ]]; then
                    INSTALLED_FILES+=("$dest")
                fi
                ((commands_count++)) || true
            fi
        fi
    done < <(get_profile_files "$EFFECTIVE_PROFILE" "$BASE_DIR" "commands")

    if [[ "$DRY_RUN" != "true" ]]; then
        if [[ $commands_count -gt 0 ]]; then
            echo "✓ Installed $commands_count Claude Code commands"
        fi
    fi

    # Install static agents to .claude/agents/agent-os/
    get_profile_files "$EFFECTIVE_PROFILE" "$BASE_DIR" "agents" | while read file; do
        if [[ "$file" == agents/*.md ]] && [[ "$file" != agents/templates/* ]]; then
            local source=$(get_profile_file "$EFFECTIVE_PROFILE" "$file" "$BASE_DIR")
            if [[ -f "$source" ]]; then
                local agent_name=$(basename "$file" .md)
                local dest="$PROJECT_DIR/.claude/agents/agent-os/${agent_name}.md"

                local compiled=$(compile_agent "$source" "$dest" "$BASE_DIR" "$EFFECTIVE_PROFILE" "")
                if [[ "$DRY_RUN" == "true" ]]; then
                    INSTALLED_FILES+=("$dest")
                fi
                ((agents_count++)) || true
            fi
        fi
    done

    # Install specification agents
    get_profile_files "$EFFECTIVE_PROFILE" "$BASE_DIR" "agents/specification" | while read file; do
        if [[ "$file" == agents/specification/*.md ]]; then
            local source=$(get_profile_file "$EFFECTIVE_PROFILE" "$file" "$BASE_DIR")
            if [[ -f "$source" ]]; then
                local agent_name=$(basename "$file" .md)
                local dest="$PROJECT_DIR/.claude/agents/agent-os/${agent_name}.md"

                local compiled=$(compile_agent "$source" "$dest" "$BASE_DIR" "$EFFECTIVE_PROFILE" "")
                if [[ "$DRY_RUN" == "true" ]]; then
                    INSTALLED_FILES+=("$dest")
                fi
                ((agents_count++)) || true
            fi
        fi
    done

    # Generate and install implementer agents
    local implementers_file=$(get_profile_file "$EFFECTIVE_PROFILE" "roles/implementers.yml" "$BASE_DIR")
    if [[ -f "$implementers_file" ]]; then
        local template_file=$(get_profile_file "$EFFECTIVE_PROFILE" "agents/templates/implementer.md" "$BASE_DIR")
        if [[ -f "$template_file" ]]; then
            # Get list of implementer IDs
            local implementer_ids=$(awk '/^  - id:/ {print $3}' "$implementers_file")

            for id in $implementer_ids; do
                print_verbose "Generating implementer agent: $id"

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
                local standards_list=$(process_standards "" "$BASE_DIR" "$EFFECTIVE_PROFILE" "$standards_patterns")
                role_data="${role_data}<<<implementer_standards>>>"$'\n'"$standards_list"$'\n'"<<<END>>>"$'\n'

                # Compile agent
                local dest="$PROJECT_DIR/.claude/agents/agent-os/${id}.md"
                local compiled=$(compile_agent "$template_file" "$dest" "$BASE_DIR" "$EFFECTIVE_PROFILE" "$role_data")
                if [[ "$DRY_RUN" == "true" ]]; then
                    INSTALLED_FILES+=("$dest")
                fi
                ((agents_count++)) || true
            done
        fi
    fi

    # Generate and install area verifier agents
    local verifiers_file=$(get_profile_file "$EFFECTIVE_PROFILE" "roles/verifiers.yml" "$BASE_DIR")
    if [[ -f "$verifiers_file" ]]; then
        local template_file=$(get_profile_file "$EFFECTIVE_PROFILE" "agents/templates/verifier.md" "$BASE_DIR")
        if [[ -f "$template_file" ]]; then
            # Get list of verifier IDs
            local verifier_ids=$(awk '/^  - id:/ {print $3}' "$verifiers_file")

            for id in $verifier_ids; do
                print_verbose "Generating area verifier agent: $id"

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
                local standards_list=$(process_standards "" "$BASE_DIR" "$EFFECTIVE_PROFILE" "$standards_patterns")
                role_data="${role_data}<<<verifier_standards>>>"$'\n'"$standards_list"$'\n'"<<<END>>>"$'\n'

                # Compile agent
                local dest="$PROJECT_DIR/.claude/agents/agent-os/${id}.md"
                local compiled=$(compile_agent "$template_file" "$dest" "$BASE_DIR" "$EFFECTIVE_PROFILE" "$role_data")
                if [[ "$DRY_RUN" == "true" ]]; then
                    INSTALLED_FILES+=("$dest")
                fi
                ((agents_count++)) || true
            done
        fi
    fi

    if [[ "$DRY_RUN" != "true" ]]; then
        if [[ $agents_count -gt 0 ]]; then
            echo "✓ Installed $agents_count Claude Code agents"
        fi
    fi
}


# Create agent-os folder structure
create_agent_os_folder() {
    if [[ "$DRY_RUN" != "true" ]]; then
        print_status "Installing agent-os folder"
    fi

    # Create the main agent-os folder
    ensure_dir "$PROJECT_DIR/agent-os"

    # Create the configuration file
    local config_file=$(write_project_config "$EFFECTIVE_VERSION" "$EFFECTIVE_PROFILE" \
        "$EFFECTIVE_MULTI_AGENT_MODE" "$EFFECTIVE_MULTI_AGENT_TOOL" \
        "$EFFECTIVE_SINGLE_AGENT_MODE" "$EFFECTIVE_SINGLE_AGENT_TOOL")
    if [[ "$DRY_RUN" == "true" && -n "$config_file" ]]; then
        INSTALLED_FILES+=("$config_file")
    fi

    if [[ "$DRY_RUN" != "true" ]]; then
        echo "✓ Created agent-os folder"
        echo "✓ Created agent-os project configuration"
    fi
}

# Perform fresh installation
perform_installation() {
    # Show dry run warning at the top if applicable
    if [[ "$DRY_RUN" == "true" ]]; then
        print_warning "DRY RUN - No files will be actually created"
        echo ""
    fi

    # Display configuration at the top
    echo ""
    print_status "Configuration:"
    echo -e "  Profile: ${YELLOW}$EFFECTIVE_PROFILE${NC}"
    echo -e "  Multi-agent mode: ${YELLOW}$EFFECTIVE_MULTI_AGENT_MODE${NC}"
    if [[ "$EFFECTIVE_MULTI_AGENT_MODE" == "true" ]]; then
        echo -e "  Multi-agent tool: ${YELLOW}$EFFECTIVE_MULTI_AGENT_TOOL${NC}"
    fi
    echo -e "  Single-agent mode: ${YELLOW}$EFFECTIVE_SINGLE_AGENT_MODE${NC}"
    if [[ "$EFFECTIVE_SINGLE_AGENT_MODE" == "true" ]]; then
        echo -e "  Single-agent tool: ${YELLOW}$EFFECTIVE_SINGLE_AGENT_TOOL${NC}"
    fi
    echo ""

    # In dry run mode, just collect files silently
    if [[ "$DRY_RUN" == "true" ]]; then
        # Collect files without output
        create_agent_os_folder
        install_standards
        install_roles
        if [[ "$EFFECTIVE_SINGLE_AGENT_MODE" == "true" ]]; then
            install_single_agent_commands
        fi
        if [[ "$EFFECTIVE_MULTI_AGENT_MODE" == "true" ]] && [[ "$EFFECTIVE_MULTI_AGENT_TOOL" == "claude-code" ]]; then
            install_claude_code_files
        fi

        echo ""
        print_status "The following files would be created:"
        for file in "${INSTALLED_FILES[@]}"; do
            # Make paths relative to project root
            local relative_path="${file#$PROJECT_DIR/}"
            echo "  - $relative_path"
        done
    else
        # Normal installation with output
        create_agent_os_folder
        echo ""

        install_standards
        echo ""

        install_roles
        echo ""

        if [[ "$EFFECTIVE_SINGLE_AGENT_MODE" == "true" ]]; then
            install_single_agent_commands
            echo ""
        fi

        if [[ "$EFFECTIVE_MULTI_AGENT_MODE" == "true" ]] && [[ "$EFFECTIVE_MULTI_AGENT_TOOL" == "claude-code" ]]; then
            install_claude_code_files
            echo ""
        fi
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        echo ""
        read -p "Proceed with actual installation? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            DRY_RUN="false"
            INSTALLED_FILES=()
            perform_installation
        fi
    else
        print_success "Agent OS has been successfully installed in your project!"
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

    if [[ "$DRY_RUN" != "true" ]]; then
        print_status "Removing existing installation..."
        rm -rf "$PROJECT_DIR/agent-os"
        rm -rf "$PROJECT_DIR/.claude/agents/agent-os"
        rm -rf "$PROJECT_DIR/.claude/commands/agent-os"
        echo "✓ Existing installation removed"
        echo ""
    fi

    perform_installation
}

# -----------------------------------------------------------------------------
# Main Execution
# -----------------------------------------------------------------------------

main() {
    print_section "Agent OS Project Installation"

    # Parse command line arguments
    parse_arguments "$@"

    # Check if we're trying to install in the base installation directory
    check_not_base_installation

    # Validate base installation using common function
    validate_base_installation

    # Check for base installation updates
    check_for_base_updates

    # Load configuration
    load_configuration

    # Check if Agent OS is already installed
    if is_agent_os_installed "$PROJECT_DIR"; then
        if [[ "$RE_INSTALL" == "true" ]]; then
            handle_reinstallation
        else
            # Delegate to update script
            print_status "Agent OS is already installed. Running update..."
            exec "$BASE_DIR/scripts/project-update.sh" "$@"
        fi
    else
        # Fresh installation
        perform_installation
    fi
}

# Run main function
main "$@"
