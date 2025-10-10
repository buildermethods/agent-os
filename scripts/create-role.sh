#!/bin/bash

# =============================================================================
# Agent OS Create Role Script
# Creates a new role entry in roles/implementers.yml or roles/verifiers.yml
# =============================================================================

set -e  # Exit on error

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$HOME/agent-os"
PROFILES_DIR="$BASE_DIR/profiles"

# Source common functions
source "$SCRIPT_DIR/common-functions.sh"

# -----------------------------------------------------------------------------
# Default Values
# -----------------------------------------------------------------------------

SELECTED_PROFILE=""
ROLE_TYPE=""
ROLE_ID=""
ROLE_DESCRIPTION=""
ROLE_TEXT=""
ROLE_TOOLS=""
ROLE_MODEL=""
ROLE_COLOR=""
ROLE_AREAS=()
ROLE_OUT_OF_SCOPE=()
ROLE_STANDARDS=()
ROLE_VERIFIERS=()

# -----------------------------------------------------------------------------
# Validation Functions
# -----------------------------------------------------------------------------

validate_installation() {
    # Check base installation
    validate_base_installation

    if [[ ! -d "$PROFILES_DIR" ]]; then
        print_error "Profiles directory not found at $PROFILES_DIR"
        exit 1
    fi
}

# -----------------------------------------------------------------------------
# Profile Selection Functions
# -----------------------------------------------------------------------------

get_available_profiles() {
    local profiles=()

    # Find all directories in profiles/
    for dir in "$PROFILES_DIR"/*; do
        if [[ -d "$dir" ]]; then
            profiles+=("$(basename "$dir")")
        fi
    done

    echo "${profiles[@]}"
}

get_profile_inheritance() {
    local profile=$1
    local config_file="$PROFILES_DIR/$profile/profile-config.yml"

    if [[ -f "$config_file" ]]; then
        local inherits=$(grep "^inherits_from:" "$config_file" 2>/dev/null | sed 's/inherits_from: *//' | tr -d '\r\n')
        if [[ -n "$inherits" ]]; then
            echo "$inherits"
        fi
    fi
}

select_profile() {
    local profiles=($(get_available_profiles))

    if [[ ${#profiles[@]} -eq 0 ]]; then
        print_error "No profiles found in $PROFILES_DIR"
        exit 1
    elif [[ ${#profiles[@]} -eq 1 ]]; then
        # Only one profile, use it automatically
        SELECTED_PROFILE="${profiles[0]}"
        print_status "Using profile: $SELECTED_PROFILE"
    else
        # Multiple profiles, ask user to select
        echo ""
        print_status "Choose a profile:"
        echo ""

        local index=1
        for profile in "${profiles[@]}"; do
            local inheritance=$(get_profile_inheritance "$profile")
            if [[ -n "$inheritance" ]]; then
                echo "  $index) $profile - inherits from '$inheritance'"
            else
                echo "  $index) $profile"
            fi
            ((index++))
        done

        echo ""
        read -p "$(echo -e "${BLUE}Enter selection (1-${#profiles[@]}): ${NC}")" selection

        if [[ "$selection" =~ ^[0-9]+$ ]] && [[ "$selection" -ge 1 ]] && [[ "$selection" -le ${#profiles[@]} ]]; then
            SELECTED_PROFILE="${profiles[$((selection-1))]}"
            print_success "Selected profile: $SELECTED_PROFILE"
        else
            print_error "Invalid selection"
            exit 1
        fi
    fi
}

# -----------------------------------------------------------------------------
# Role Type Selection
# -----------------------------------------------------------------------------

select_role_type() {
    echo ""
    echo ""
    echo ""
    print_status "What type of role do you wish to create?"
    echo ""
    echo "Implementers are specialized agents that write code for specific areas."
    echo "Verifiers review and validate the work of implementers."
    echo ""
    echo "  1) Implementer"
    echo "  2) Verifier"
    echo ""

    read -p "$(echo -e "${BLUE}Enter selection (1-2): ${NC}")" selection

    case $selection in
        1)
            ROLE_TYPE="implementer"
            print_success "Creating implementer role"
            ;;
        2)
            ROLE_TYPE="verifier"
            print_success "Creating verifier role"
            ;;
        *)
            print_error "Invalid selection"
            exit 1
            ;;
    esac
}

# -----------------------------------------------------------------------------
# Role Configuration Functions
# -----------------------------------------------------------------------------

get_role_id() {
    echo ""
    echo ""
    echo ""
    print_status "Enter an ID for this role:"
    echo "This should be like a job title (e.g., 'backend-developer', 'api-specialist', 'ui-engineer')"
    echo ""

    read -p "$(echo -e "${BLUE}Role ID: ${NC}")" role_input

    # Normalize the ID using common function
    ROLE_ID=$(normalize_name "$role_input")

    if [[ -z "$ROLE_ID" ]]; then
        print_error "Role ID cannot be empty"
        exit 1
    fi

    print_success "Role ID set to: $ROLE_ID"
}

get_role_description() {
    echo ""
    echo ""
    echo ""
    print_status "Enter a description for this role:"
    echo "Example: 'Specializes in backend API development and database design'"
    echo ""

    read -p "$(echo -e "${BLUE}Description: ${NC}")" ROLE_DESCRIPTION

    if [[ -z "$ROLE_DESCRIPTION" ]]; then
        print_error "Description cannot be empty"
        exit 1
    fi
}

get_role_text() {
    echo ""
    echo ""
    echo ""
    print_status "Enter text that informs the agent what their role is:"
    echo "Example: 'You are a backend specialist focused on API design, database optimization, and server-side logic'"
    echo ""

    read -p "$(echo -e "${BLUE}Role text: ${NC}")" ROLE_TEXT

    if [[ -z "$ROLE_TEXT" ]]; then
        print_error "Role text cannot be empty"
        exit 1
    fi
}

# -----------------------------------------------------------------------------
# Tools Configuration
# -----------------------------------------------------------------------------

configure_tools() {
    echo ""
    echo ""
    echo ""
    print_status "Configure tools for this agent (applies in multi-agent mode with Claude Code)"
    echo "Standard tools include: Glob, Grep, Write, Read, Bash, WebFetch"
    echo ""

    local tools="Glob, Grep, Write, Read, Bash, WebFetch"

    read -p "$(echo -e "${BLUE}Add tools beyond the standard set? (y/n): ${NC}")" add_more

    if [[ "$add_more" == "y" ]] || [[ "$add_more" == "Y" ]]; then
        echo ""
        read -p "$(echo -e "${BLUE}Add Playwright tool for browser interaction? (y/n): ${NC}")" add_playwright

        if [[ "$add_playwright" == "y" ]] || [[ "$add_playwright" == "Y" ]]; then
            tools="$tools, Playwright"
            echo "Note: Requires Playwright MCP to be installed"
        fi

        echo ""
        read -p "$(echo -e "${BLUE}Add any additional tools? (y/n): ${NC}")" add_additional

        if [[ "$add_additional" == "y" ]] || [[ "$add_additional" == "Y" ]]; then
            echo ""
            echo "Enter tool names separated by commas (e.g., 'WebSearch, MultiEdit, SlashCommand')"
            read -p "$(echo -e "${BLUE}Additional tools: ${NC}")" additional_tools

            if [[ -n "$additional_tools" ]]; then
                # Normalize: capitalize and ensure proper spacing
                additional_tools=$(echo "$additional_tools" | sed 's/,/, /g' | sed 's/  */ /g')
                tools="$tools, $additional_tools"
            fi
        fi
    fi

    # Normalize final tools list
    ROLE_TOOLS=$(echo "$tools" | sed 's/,/, /g' | sed 's/  */ /g')
    print_success "Tools configured: $ROLE_TOOLS"
}

# -----------------------------------------------------------------------------
# Model and Color Selection
# -----------------------------------------------------------------------------

select_model() {
    echo ""
    echo ""
    echo ""
    print_status "Select the model for this agent (applies in multi-agent mode with Claude Code):"
    echo ""
    echo "  1) Sonnet"
    echo "  2) Opus"
    echo "  3) Inherit your current Claude Code model setting"
    echo ""

    read -p "$(echo -e "${BLUE}Enter selection (1-3): ${NC}")" selection

    case $selection in
        1)
            ROLE_MODEL="sonnet"
            print_success "Selected model: Sonnet"
            ;;
        2)
            ROLE_MODEL="opus"
            print_success "Selected model: Opus"
            ;;
        3)
            ROLE_MODEL="inherit"
            print_success "Selected model: Inherit from Claude Code"
            ;;
        *)
            print_error "Invalid selection"
            exit 1
            ;;
    esac
}

select_color() {
    echo ""
    echo ""
    echo ""
    print_status "Select a color for this agent (applies in multi-agent mode with Claude Code):"
    echo ""
    echo "  1) red"
    echo "  2) blue"
    echo "  3) green"
    echo "  4) purple"
    echo "  5) pink"
    echo "  6) orange"
    echo "  7) cyan"
    echo "  8) yellow"
    echo ""

    read -p "$(echo -e "${BLUE}Enter selection (1-8): ${NC}")" selection

    case $selection in
        1) ROLE_COLOR="red" ;;
        2) ROLE_COLOR="blue" ;;
        3) ROLE_COLOR="green" ;;
        4) ROLE_COLOR="purple" ;;
        5) ROLE_COLOR="pink" ;;
        6) ROLE_COLOR="orange" ;;
        7) ROLE_COLOR="cyan" ;;
        8) ROLE_COLOR="yellow" ;;
        *)
            print_error "Invalid selection"
            exit 1
            ;;
    esac

    print_success "Selected color: $ROLE_COLOR"
}

# -----------------------------------------------------------------------------
# Areas of Responsibility
# -----------------------------------------------------------------------------

get_areas_of_responsibility() {
    echo ""
    echo ""
    echo ""
    print_status "Define areas of responsibility:"
    echo "Enter each area on a new line. Press Enter twice when done."
    echo "Example areas: 'API endpoint development', 'Database schema design', 'Authentication systems'"
    echo ""

    local area
    while true; do
        read -p "$(echo -e "${BLUE}Area (or press Enter to finish): ${NC}")" area
        if [[ -z "$area" ]]; then
            break
        fi
        ROLE_AREAS+=("$area")
    done

    if [[ ${#ROLE_AREAS[@]} -eq 0 ]]; then
        print_warning "No areas of responsibility defined"
    else
        print_success "Added ${#ROLE_AREAS[@]} areas of responsibility"
    fi
}

get_out_of_scope_areas() {
    echo ""
    echo ""
    echo ""
    print_status "Define areas outside of responsibility:"
    echo "Enter each area on a new line. Press Enter twice when done."
    echo "Example: 'Frontend UI components', 'Mobile app development', 'DevOps infrastructure'"
    echo ""

    local area
    while true; do
        read -p "$(echo -e "${BLUE}Out of scope area (or press Enter to finish): ${NC}")" area
        if [[ -z "$area" ]]; then
            break
        fi
        ROLE_OUT_OF_SCOPE+=("$area")
    done

    if [[ ${#ROLE_OUT_OF_SCOPE[@]} -eq 0 ]]; then
        print_warning "No out-of-scope areas defined"
    else
        print_success "Added ${#ROLE_OUT_OF_SCOPE[@]} out-of-scope areas"
    fi
}

# -----------------------------------------------------------------------------
# Standards Selection
# -----------------------------------------------------------------------------

# Flexible standards selection - works with any subfolder structure
select_standards() {
    echo ""
    echo ""
    echo ""
    print_status "Define the standards that this role should follow:"
    echo ""
    echo "Standards can be organized in any folder structure you want."
    echo "You can select individual files or entire folders using wildcards (*)."
    echo ""
    echo "  1) Select from available standards folders/files"
    echo "  2) Skip - no standards for this role"
    echo ""

    read -p "$(echo -e "${BLUE}Enter selection (1-2): ${NC}")" selection

    case $selection in
        1)
            # Find all standards directories and files
            local standards_dir="$BASE_DIR/profiles/$SELECTED_PROFILE/standards"

            if [[ ! -d "$standards_dir" ]]; then
                print_warning "No standards directory found for this profile"
                return
            fi

            # Collect available items (folders and files)
            local items=()
            local index=1

            echo ""
            echo "Available standards:"
            echo ""

            # Find all subdirectories (at any level) and offer them with /*
            while IFS= read -r -d '' dir; do
                local relative_dir="${dir#$standards_dir/}"
                items+=("${relative_dir}/*")
                echo "  $index) ${relative_dir}/*"
                ((index++))
            done < <(find "$standards_dir" -type d -mindepth 1 -print0 | sort -z)

            # Find all files
            shopt -s nullglob
            while IFS= read -r -d '' file; do
                local relative_file="${file#$standards_dir/}"
                items+=("$relative_file")
                echo "  $index) $relative_file"
                ((index++))
            done < <(find "$standards_dir" -type f \( -name "*.md" -o -name "*.yml" -o -name "*.yaml" \) -print0 | sort -z)
            shopt -u nullglob

            if [[ ${#items[@]} -eq 0 ]]; then
                print_warning "No standards found"
                return
            fi

            echo ""
            echo "Enter numbers separated by spaces or commas (e.g., '1 3 5' or '1,3,5')"
            echo "Or enter 'all' to include all standards"
            read -p "$(echo -e "${BLUE}Select items: ${NC}")" selections

            if [[ "$selections" == "all" ]]; then
                # Add all top-level folders with wildcard
                while IFS= read -r -d '' dir; do
                    local relative_dir="${dir#$standards_dir/}"
                    # Only add top-level directories
                    if [[ ! "$relative_dir" =~ / ]]; then
                        ROLE_STANDARDS+=("${relative_dir}/*")
                    fi
                done < <(find "$standards_dir" -maxdepth 1 -type d -mindepth 1 -print0)
                print_success "Selected all standards"
            else
                # Parse selections
                IFS=', ' read -ra ADDR <<< "$selections"
                for i in "${ADDR[@]}"; do
                    if [[ "$i" =~ ^[0-9]+$ ]] && [[ "$i" -ge 1 ]] && [[ "$i" -le ${#items[@]} ]]; then
                        ROLE_STANDARDS+=("${items[$((i-1))]}")
                    fi
                done

                if [[ ${#ROLE_STANDARDS[@]} -gt 0 ]]; then
                    print_success "Selected ${#ROLE_STANDARDS[@]} standards items"
                else
                    print_warning "No standards items selected"
                fi
            fi
            ;;
        2)
            print_success "No standards selected for this role"
            ;;
        *)
            print_error "Invalid selection"
            exit 1
            ;;
    esac
}

# -----------------------------------------------------------------------------
# Verifier Selection
# -----------------------------------------------------------------------------

select_verifiers() {
    # Only for implementer roles
    if [[ "$ROLE_TYPE" != "implementer" ]]; then
        return
    fi

    local verifiers_file="$(get_profile_file "$SELECTED_PROFILE" "roles/verifiers.yml" "$BASE_DIR")"

    if [[ ! -f "$verifiers_file" ]]; then
        print_verbose "No verifiers.yml file found, skipping verifier selection"
        return
    fi

    # Extract verifier IDs
    local verifier_ids=($(awk '/^  - id:/ {print $3}' "$verifiers_file"))

    if [[ ${#verifier_ids[@]} -eq 0 ]]; then
        print_verbose "No verifiers defined, skipping verifier selection"
        return
    fi

    echo ""
    echo ""
    echo ""
    print_status "Select verifiers responsible for checking this implementer's work:"
    echo ""

    local index=1
    for vid in "${verifier_ids[@]}"; do
        echo "  $index) $vid"
        ((index++))
    done

    echo ""
    echo "Enter numbers separated by spaces or commas (e.g., '1 3' or '1,3')"
    echo "Press Enter to skip if no verifiers needed"
    read -p "$(echo -e "${BLUE}Select verifiers: ${NC}")" selections

    if [[ -n "$selections" ]]; then
        # Parse selections
        IFS=', ' read -ra ADDR <<< "$selections"
        for i in "${ADDR[@]}"; do
            if [[ "$i" =~ ^[0-9]+$ ]] && [[ "$i" -ge 1 ]] && [[ "$i" -le ${#verifier_ids[@]} ]]; then
                ROLE_VERIFIERS+=("${verifier_ids[$((i-1))]}")
            fi
        done

        if [[ ${#ROLE_VERIFIERS[@]} -gt 0 ]]; then
            print_success "Selected ${#ROLE_VERIFIERS[@]} verifier(s)"
        fi
    else
        echo "No verifiers selected"
    fi
}

# -----------------------------------------------------------------------------
# YAML Writing Functions
# -----------------------------------------------------------------------------

write_role_to_yaml() {
    local target_file=""

    if [[ "$ROLE_TYPE" == "implementer" ]]; then
        target_file="$PROFILES_DIR/$SELECTED_PROFILE/roles/implementers.yml"
    else
        target_file="$PROFILES_DIR/$SELECTED_PROFILE/roles/verifiers.yml"
    fi

    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$target_file")"

    # Check if file exists and has content
    local add_header=false
    if [[ ! -f "$target_file" ]] || [[ ! -s "$target_file" ]]; then
        add_header=true
    fi

    # Start building the YAML content
    local yaml_content=""

    if [[ "$add_header" == true ]]; then
        if [[ "$ROLE_TYPE" == "implementer" ]]; then
            yaml_content="implementers:\n"
        else
            yaml_content="verifiers:\n"
        fi
    else
        # Add spacing before new entry
        yaml_content="\n"
    fi

    # Add the role entry
    yaml_content+="  - id: $ROLE_ID\n"
    yaml_content+="    description: $ROLE_DESCRIPTION\n"
    yaml_content+="    your_role: $ROLE_TEXT\n"
    yaml_content+="    tools: $ROLE_TOOLS\n"
    yaml_content+="    model: $ROLE_MODEL\n"
    yaml_content+="    color: $ROLE_COLOR\n"

    # Add areas of responsibility
    if [[ ${#ROLE_AREAS[@]} -gt 0 ]]; then
        yaml_content+="    areas_of_responsibility:\n"
        for area in "${ROLE_AREAS[@]}"; do
            yaml_content+="      - $area\n"
        done
    fi

    # Add out of scope areas
    if [[ ${#ROLE_OUT_OF_SCOPE[@]} -gt 0 ]]; then
        yaml_content+="    example_areas_outside_of_responsibility:\n"
        for area in "${ROLE_OUT_OF_SCOPE[@]}"; do
            yaml_content+="      - $area\n"
        done
    fi

    # Add standards section (flat list format)
    if [[ ${#ROLE_STANDARDS[@]} -gt 0 ]]; then
        yaml_content+="    standards:\n"
        for item in "${ROLE_STANDARDS[@]}"; do
            yaml_content+="      - $item\n"
        done
    fi

    # Add verifiers (only for implementers)
    if [[ "$ROLE_TYPE" == "implementer" ]] && [[ ${#ROLE_VERIFIERS[@]} -gt 0 ]]; then
        yaml_content+="    verified_by:\n"
        for verifier in "${ROLE_VERIFIERS[@]}"; do
            yaml_content+="      - $verifier\n"
        done
    fi

    # Write to file
    echo -e "$yaml_content" >> "$target_file"

    echo ""
    print_success "Role added to $target_file"
}

# -----------------------------------------------------------------------------
# Main Execution
# -----------------------------------------------------------------------------

main() {
    clear
    echo ""
    echo -e "${BLUE}=== Agent OS - Create Role Utility ===${NC}"
    echo ""

    # Validate installation
    validate_installation

    # Check for base installation updates
    check_for_base_updates

    # Profile selection
    select_profile

    # Role type selection
    select_role_type

    # Get role configuration
    get_role_id
    get_role_description
    get_role_text

    # Configure tools
    configure_tools

    # Select model and color
    select_model
    select_color

    # Define areas of responsibility
    get_areas_of_responsibility
    get_out_of_scope_areas

    # Select standards
    select_standards

    # Select verifiers (for implementers only)
    select_verifiers

    # Write the role to YAML
    write_role_to_yaml

    # Success message
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════${NC}"
    echo ""
    print_success "Role '$ROLE_ID' has been successfully created!"
    echo ""

    local file_type="implementers"
    if [[ "$ROLE_TYPE" == "verifier" ]]; then
        file_type="verifiers"
    fi

    print_status "Location: $PROFILES_DIR/$SELECTED_PROFILE/roles/${file_type}.yml"
    echo ""
    echo "To apply this role to your project, run:"
    echo -e "${BLUE}  ~/agent-os/scripts/project-update.sh${NC}"
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════${NC}"
    echo ""
}

# Run main function
main "$@"
