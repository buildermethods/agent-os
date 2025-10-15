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
# Global Variables (set by scripts that source this file)
# -----------------------------------------------------------------------------
# These should be set by the calling script:
# BASE_DIR, PROJECT_DIR, DRY_RUN, VERBOSE

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
# String Normalization Functions
# -----------------------------------------------------------------------------

# Normalize input to lowercase, replace spaces/underscores with hyphens, remove punctuation
normalize_name() {
    local input=$1
    echo "$input" | tr '[:upper:]' '[:lower:]' | sed 's/[ _]/-/g' | sed 's/[^a-z0-9-]//g'
}

# -----------------------------------------------------------------------------
# Improved YAML Parsing Functions (More Robust)
# -----------------------------------------------------------------------------

# Normalize YAML line (handle tabs, trim spaces, etc.)
normalize_yaml_line() {
    echo "$1" | sed 's/\t/    /g' | sed 's/[[:space:]]*$//'
}

# Get indentation level (counts spaces/tabs at beginning)
get_indent_level() {
    local line="$1"
    local normalized=$(echo "$line" | sed 's/\t/    /g')
    local spaces=$(echo "$normalized" | sed 's/[^ ].*//')
    echo "${#spaces}"
}

# Get a simple value from YAML (handles key: value format)
# More robust: handles quotes, different spacing, tabs
get_yaml_value() {
    local file=$1
    local key=$2
    local default=$3

    if [[ ! -f "$file" ]]; then
        echo "$default"
        return
    fi

    # Look for the key with flexible spacing and handle quotes
    local value=$(awk -v key="$key" '
        BEGIN { found=0 }
        {
            # Normalize tabs to spaces
            gsub(/\t/, "    ")
            # Remove leading/trailing spaces
            gsub(/^[[:space:]]+/, "")
            gsub(/[[:space:]]+$/, "")
        }
        # Match key: value (with or without spaces around colon)
        $0 ~ "^" key "[[:space:]]*:" {
            # Extract value after colon
            sub("^" key "[[:space:]]*:[[:space:]]*", "")
            # Remove quotes if present
            gsub(/^["'\'']/, "")
            gsub(/["'\'']$/, "")
            # Handle empty value
            if (length($0) > 0) {
                print $0
                found=1
                exit
            }
        }
        END { if (!found) exit 1 }
    ' "$file" 2>/dev/null)

    if [[ $? -eq 0 && -n "$value" ]]; then
        echo "$value"
    else
        echo "$default"
    fi
}

# Get array values from YAML (handles - item format under a key)
# More robust: handles variable indentation
get_yaml_array() {
    local file=$1
    local key=$2

    if [[ ! -f "$file" ]]; then
        return
    fi

    awk -v key="$key" '
        BEGIN {
            found=0
            key_indent=-1
            array_indent=-1
        }
        {
            # Normalize tabs to spaces
            gsub(/\t/, "    ")

            # Get current line indentation
            indent = match($0, /[^ ]/)
            if (indent == 0) indent = length($0) + 1
            indent = indent - 1

            # Store original line for processing
            line = $0
            # Remove leading spaces for pattern matching
            gsub(/^[[:space:]]+/, "")
        }

        # Found the key
        !found && $0 ~ "^" key "[[:space:]]*:" {
            found = 1
            key_indent = indent
            next
        }

        # Process array items under the key
        found {
            # If we hit a line with same or less indentation as key, stop
            if (indent <= key_indent && $0 != "" && $0 !~ /^[[:space:]]*$/) {
                exit
            }

            # Look for array items (- item)
            if ($0 ~ /^-[[:space:]]/) {
                # Set array indent from first item
                if (array_indent == -1) {
                    array_indent = indent
                }

                # Only process items at the expected indentation
                if (indent == array_indent) {
                    sub(/^-[[:space:]]*/, "")
                    # Remove quotes if present
                    gsub(/^["'\'']/, "")
                    gsub(/["'\'']$/, "")
                    print
                }
            }
        }
    ' "$file"
}

# Parse role data from YAML with robust handling
parse_role_yaml() {
    local yaml_file=$1
    local role_type=$2  # "implementers" or "verifiers"
    local role_id=$3
    local field=$4

    if [[ ! -f "$yaml_file" ]]; then
        return
    fi

    awk -v role_type="$role_type" -v role_id="$role_id" -v field="$field" '
        BEGIN {
            in_roles=0
            in_role=0
            in_field=0
            is_array=0
            roles_indent=-1
            role_indent=-1
            field_indent=-1
            array_indent=-1
        }
        {
            # Normalize tabs to spaces
            gsub(/\t/, "    ")

            # Calculate indentation
            indent = match($0, /[^ ]/)
            if (indent == 0) indent = length($0) + 1
            indent = indent - 1

            # Store trimmed line
            trimmed = $0
            gsub(/^[[:space:]]+/, "", trimmed)
            gsub(/[[:space:]]+$/, "", trimmed)
        }

        # Find role type section
        !in_roles && trimmed ~ "^" role_type "[[:space:]]*:" {
            in_roles = 1
            roles_indent = indent
            next
        }

        # Exit roles section if we hit something at same or lesser indent
        in_roles && !in_role && indent <= roles_indent && trimmed != "" {
            in_roles = 0
        }

        # Find specific role by id
        in_roles && trimmed ~ /^-[[:space:]]+id:[[:space:]]*/ {
            id_value = trimmed
            sub(/^-[[:space:]]+id:[[:space:]]*/, "", id_value)
            gsub(/^["'\'']/, "", id_value)
            gsub(/["'\'']$/, "", id_value)

            if (id_value == role_id) {
                in_role = 1
                role_indent = indent
            } else {
                in_role = 0
            }
            next
        }

        # Exit current role if we hit another role or leave roles section
        in_role && trimmed ~ /^-[[:space:]]+/ && indent == role_indent {
            in_role = 0
        }

        # Look for the field we want
        in_role && trimmed ~ "^" field "[[:space:]]*:" {
            in_field = 1
            field_indent = indent

            # Check if value is on same line
            value = trimmed
            sub("^" field "[[:space:]]*:[[:space:]]*", "", value)

            if (value != "") {
                # Single line value
                gsub(/^["'\'']/, "", value)
                gsub(/["'\'']$/, "", value)
                print value
                in_field = 0
            } else {
                # Multi-line array expected
                is_array = 1
            }
            next
        }

        # Process array items
        in_field && is_array {
            # Stop if we hit something at field level or less
            if (indent <= field_indent && trimmed != "") {
                in_field = 0
                is_array = 0
                next
            }

            # Process array items
            if (trimmed ~ /^-[[:space:]]/) {
                if (array_indent == -1) {
                    array_indent = indent
                }

                if (indent == array_indent) {
                    item = trimmed
                    sub(/^-[[:space:]]*/, "", item)
                    gsub(/^["'\'']/, "", item)
                    gsub(/["'\'']$/, "", item)
                    # Add bullet point formatting for lists
                    if (field == "areas_of_responsibility" || field == "example_areas_outside_of_responsibility") {
                        print "- " item
                    } else {
                        print item
                    }
                }
            }
        }
    ' "$yaml_file"
}

# Get standards configuration for a role with robust parsing
# Now supports flexible flat list format instead of hardcoded global/capabilities/patterns
get_role_standards() {
    local yaml_file=$1
    local role_type=$2
    local role_id=$3

    if [[ ! -f "$yaml_file" ]]; then
        return
    fi

    awk -v role_type="$role_type" -v role_id="$role_id" '
        BEGIN {
            in_roles=0
            in_role=0
            in_standards=0
            roles_indent=-1
            role_indent=-1
            standards_indent=-1
        }
        {
            # Normalize tabs to spaces
            gsub(/\t/, "    ")

            # Calculate indentation
            indent = match($0, /[^ ]/)
            if (indent == 0) indent = length($0) + 1
            indent = indent - 1

            # Store trimmed line
            trimmed = $0
            gsub(/^[[:space:]]+/, "", trimmed)
            gsub(/[[:space:]]+$/, "", trimmed)
        }

        # Find role type section
        !in_roles && trimmed ~ "^" role_type "[[:space:]]*:" {
            in_roles = 1
            roles_indent = indent
            next
        }

        # Exit roles section
        in_roles && !in_role && indent <= roles_indent && trimmed != "" {
            in_roles = 0
        }

        # Find specific role
        in_roles && trimmed ~ /^-[[:space:]]+id:[[:space:]]*/ {
            id_value = trimmed
            sub(/^-[[:space:]]+id:[[:space:]]*/, "", id_value)
            gsub(/["'\'']/, "", id_value)

            if (id_value == role_id) {
                in_role = 1
                role_indent = indent
            } else {
                in_role = 0
                in_standards = 0
            }
            next
        }

        # Exit role if we hit another role
        in_role && trimmed ~ /^-[[:space:]]+/ && indent == role_indent {
            in_role = 0
            in_standards = 0
        }

        # Find standards section
        in_role && trimmed ~ /^standards[[:space:]]*:/ {
            in_standards = 1
            standards_indent = indent
            next
        }

        # Exit standards section if we hit something at same or lesser indent
        in_standards && indent <= standards_indent && trimmed != "" && trimmed !~ /^-/ {
            in_standards = 0
        }

        # Process standards entries - now just a simple flat list
        in_standards && trimmed ~ /^-[[:space:]]/ {
            item = trimmed
            sub(/^-[[:space:]]*/, "", item)
            gsub(/^["'\'']/, "", item)
            gsub(/["'\'']$/, "", item)
            if (item != "") {
                print item
            }
            next
        }
    ' "$yaml_file"
}

# -----------------------------------------------------------------------------
# File Operations Functions
# -----------------------------------------------------------------------------

# Create directory if it doesn't exist (unless in dry-run mode)
ensure_dir() {
    local dir=$1

    if [[ "$DRY_RUN" == "true" ]]; then
        if [[ ! -d "$dir" ]]; then
            print_verbose "Would create directory: $dir"
        fi
    else
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            print_verbose "Created directory: $dir"
        fi
    fi
}

# Copy file with dry-run support
copy_file() {
    local source=$1
    local dest=$2

    if [[ "$DRY_RUN" == "true" ]]; then
        echo "$dest"
    else
        ensure_dir "$(dirname "$dest")"
        cp "$source" "$dest"
        print_verbose "Copied: $source -> $dest"
        echo "$dest"
    fi
}

# Write content to file with dry-run support
write_file() {
    local content=$1
    local dest=$2

    if [[ "$DRY_RUN" == "true" ]]; then
        echo "$dest"
    else
        ensure_dir "$(dirname "$dest")"
        echo "$content" > "$dest"
        print_verbose "Wrote file: $dest"
    fi
}

# Check if file should be skipped during update
should_skip_file() {
    local file=$1
    local overwrite_all=$2
    local overwrite_type=$3
    local file_type=$4

    if [[ "$overwrite_all" == "true" ]]; then
        return 1  # Don't skip
    fi

    if [[ ! -f "$file" ]]; then
        return 1  # Don't skip - file doesn't exist
    fi

    # Check specific overwrite flags
    case "$file_type" in
        "agent")
            [[ "$overwrite_type" == "true" ]] && return 1
            ;;
        "command")
            [[ "$overwrite_type" == "true" ]] && return 1
            ;;
        "standard")
            [[ "$overwrite_type" == "true" ]] && return 1
            ;;
    esac

    return 0  # Skip file
}

# -----------------------------------------------------------------------------
# Profile Functions
# -----------------------------------------------------------------------------

# Get the effective profile path considering inheritance
get_profile_file() {
    local profile=$1
    local file_path=$2
    local base_dir=$3

    local current_profile=$profile
    local visited_profiles=""

    while true; do
        # Check for circular inheritance
        if [[ " $visited_profiles " == *" $current_profile "* ]]; then
            print_verbose "Circular inheritance detected at profile: $current_profile"
            echo ""
            return
        fi
        visited_profiles="$visited_profiles $current_profile"

        local profile_dir="$base_dir/profiles/$current_profile"
        local full_path="$profile_dir/$file_path"

        # Check if file exists in current profile
        if [[ -f "$full_path" ]]; then
            echo "$full_path"
            return
        fi

        # Check for inheritance
        local profile_config="$profile_dir/profile-config.yml"
        if [[ ! -f "$profile_config" ]]; then
            # No profile config means this is likely the default profile
            echo ""
            return
        fi

        local inherits_from=$(get_yaml_value "$profile_config" "inherits_from" "default")

        if [[ "$inherits_from" == "false" || -z "$inherits_from" ]]; then
            echo ""
            return
        fi

        # Check if file is excluded
        local excluded=$(get_yaml_array "$profile_config" "exclude_inherited_files" | while read pattern; do
            if match_pattern "$file_path" "$pattern"; then
                echo "yes"
                break
            fi
        done)

        if [[ "$excluded" == "yes" ]]; then
            echo ""
            return
        fi

        current_profile=$inherits_from
    done
}

# Get all files from profile considering inheritance
get_profile_files() {
    local profile=$1
    local base_dir=$2
    local subdir=$3

    local current_profile=$profile
    local visited_profiles=""
    local all_files=""
    local excluded_patterns=""

    # First, collect exclusion patterns and file overrides
    while true; do
        if [[ " $visited_profiles " == *" $current_profile "* ]]; then
            break
        fi
        visited_profiles="$visited_profiles $current_profile"

        local profile_dir="$base_dir/profiles/$current_profile"
        local profile_config="$profile_dir/profile-config.yml"

        # Add exclusion patterns from this profile
        if [[ -f "$profile_config" ]]; then
            local patterns=$(get_yaml_array "$profile_config" "exclude_inherited_files")
            if [[ -n "$patterns" ]]; then
                excluded_patterns="$excluded_patterns"$'\n'"$patterns"
            fi

            local inherits_from=$(get_yaml_value "$profile_config" "inherits_from" "default")
            if [[ "$inherits_from" == "false" || -z "$inherits_from" ]]; then
                break
            fi
            current_profile=$inherits_from
        else
            break
        fi
    done

    # Now collect files starting from the base profile
    local profiles_to_process=""
    current_profile=$profile
    visited_profiles=""

    while true; do
        if [[ " $visited_profiles " == *" $current_profile "* ]]; then
            break
        fi
        visited_profiles="$visited_profiles $current_profile"
        profiles_to_process="$current_profile $profiles_to_process"

        local profile_dir="$base_dir/profiles/$current_profile"
        local profile_config="$profile_dir/profile-config.yml"

        if [[ -f "$profile_config" ]]; then
            local inherits_from=$(get_yaml_value "$profile_config" "inherits_from" "default")
            if [[ "$inherits_from" == "false" || -z "$inherits_from" ]]; then
                break
            fi
            current_profile=$inherits_from
        else
            break
        fi
    done

    # Process profiles from base to specific
    for proc_profile in $profiles_to_process; do
        local profile_dir="$base_dir/profiles/$proc_profile"
        local search_dir="$profile_dir"

        if [[ -n "$subdir" ]]; then
            search_dir="$profile_dir/$subdir"
        fi

        if [[ -d "$search_dir" ]]; then
            find "$search_dir" -type f \( -name "*.md" -o -name "*.yml" -o -name "*.yaml" \) 2>/dev/null | while read file; do
                relative_path="${file#$profile_dir/}"

                # Check if excluded
                excluded="false"
                echo "$excluded_patterns" | while read pattern; do
                    if [[ -n "$pattern" ]] && match_pattern "$relative_path" "$pattern"; then
                        excluded="true"
                        break
                    fi
                done

                if [[ "$excluded" != "true" ]]; then
                    # Check if already in list (override scenario)
                    if [[ ! " $all_files " == *" $relative_path "* ]]; then
                        echo "$relative_path"
                    fi
                fi
            done
        fi
    done | sort -u
}

# Match file path against pattern (supports wildcards)
match_pattern() {
    local path=$1
    local pattern=$2

    # Convert pattern to regex
    local regex=$(echo "$pattern" | sed 's/\*/[^\/]*/g' | sed 's/\*\*/.**/g')

    if [[ "$path" =~ ^${regex}$ ]]; then
        return 0
    else
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Template Processing Functions
# -----------------------------------------------------------------------------

# Replace Playwright tool with expanded tool list
replace_playwright_tools() {
    local tools=$1

    local playwright_tools="mcp__playwright__browser_close, mcp__playwright__browser_console_messages, mcp__playwright__browser_handle_dialog, mcp__playwright__browser_evaluate, mcp__playwright__browser_file_upload, mcp__playwright__browser_fill_form, mcp__playwright__browser_install, mcp__playwright__browser_press_key, mcp__playwright__browser_type, mcp__playwright__browser_navigate, mcp__playwright__browser_navigate_back, mcp__playwright__browser_network_requests, mcp__playwright__browser_take_screenshot, mcp__playwright__browser_snapshot, mcp__playwright__browser_click, mcp__playwright__browser_drag, mcp__playwright__browser_hover, mcp__playwright__browser_select_option, mcp__playwright__browser_tabs, mcp__playwright__browser_wait_for, mcp__ide__getDiagnostics, mcp__ide__executeCode, mcp__playwright__browser_resize"

    echo "$tools" | sed "s/Playwright/$playwright_tools/g"
}

# Process workflow replacements recursively
process_workflows() {
    local content=$1
    local base_dir=$2
    local profile=$3
    local processed_files=$4

    # Process each workflow reference
    local workflow_refs=$(echo "$content" | grep -o '{{workflows/[^}]*}}' | sort -u)

    while IFS= read -r workflow_ref; do
        if [[ -z "$workflow_ref" ]]; then
            continue
        fi

        local workflow_path=$(echo "$workflow_ref" | sed 's/{{workflows\///' | sed 's/}}//')

        # Avoid infinite recursion
        if [[ " $processed_files " == *" $workflow_path "* ]]; then
            print_warning "Circular workflow reference detected: $workflow_path"
            continue
        fi

        # Get workflow file
        local workflow_file=$(get_profile_file "$profile" "workflows/${workflow_path}.md" "$base_dir")

        if [[ -f "$workflow_file" ]]; then
            local workflow_content=$(cat "$workflow_file")

            # Recursively process nested workflows
            workflow_content=$(process_workflows "$workflow_content" "$base_dir" "$profile" "$processed_files $workflow_path")

            # Create temp files for safe replacement
            local temp_content=$(mktemp)
            local temp_replacement=$(mktemp)
            echo "$content" > "$temp_content"
            echo "$workflow_content" > "$temp_replacement"

            # Use perl to do the replacement without escaping newlines
            content=$(perl -e '
                use strict;
                use warnings;

                my $ref = $ARGV[0];
                my $replacement_file = $ARGV[1];
                my $content_file = $ARGV[2];

                # Read replacement content
                open(my $fh, "<", $replacement_file) or die $!;
                my $replacement = do { local $/; <$fh> };
                close($fh);

                # Read main content
                open($fh, "<", $content_file) or die $!;
                my $content = do { local $/; <$fh> };
                close($fh);

                # Do the replacement - use quotemeta on entire reference
                my $pattern = quotemeta($ref);
                $content =~ s/$pattern/$replacement/g;

                print $content;
            ' "$workflow_ref" "$temp_replacement" "$temp_content")

            rm -f "$temp_content" "$temp_replacement"
        else
            # Instead of printing warning to stderr, insert it into the content
            local warning_msg="⚠️ This workflow file was not found in your Agent OS base installation at ~/agent-os/profiles/$profile/workflows/${workflow_path}.md"
            # Use perl for safer replacement with special characters
            local temp_content=$(mktemp)
            echo "$content" > "$temp_content"
            content=$(perl -pe "s|\Q$workflow_ref\E|$workflow_ref\n$warning_msg|g" "$temp_content")
            rm -f "$temp_content"
        fi
    done <<< "$workflow_refs"

    echo "$content"
}

# Process standards replacements
process_standards() {
    local content=$1
    local base_dir=$2
    local profile=$3
    local standards_patterns=$4

    local standards_list=""

    echo "$standards_patterns" | while read pattern; do
        if [[ -z "$pattern" ]]; then
            continue
        fi

        local base_path=$(echo "$pattern" | sed 's/\*//')

        if [[ "$pattern" == *"*"* ]]; then
            # Wildcard pattern - find all files
            local search_dir="standards/$base_path"
            get_profile_files "$profile" "$base_dir" "$search_dir" | while read file; do
                if [[ "$file" == standards/* ]] && [[ "$file" == *.md ]]; then
                    echo "@agent-os/$file"
                fi
            done
        else
            # Specific file
            local file_path="standards/${pattern}.md"
            local full_file=$(get_profile_file "$profile" "$file_path" "$base_dir")
            if [[ -f "$full_file" ]]; then
                echo "@agent-os/$file_path"
            fi
        fi
    done | sort -u
}

# Compile agent file with all replacements
compile_agent() {
    local source_file=$1
    local dest_file=$2
    local base_dir=$3
    local profile=$4
    local role_data=$5

    local content=$(cat "$source_file")

    # Process role replacements if provided
    if [[ -n "$role_data" ]]; then
        # Process each role replacement using delimiter-based format
        local temp_role_data=$(mktemp)
        echo "$role_data" > "$temp_role_data"

        # Parse the delimiter-based format
        while IFS= read -r line; do
            if [[ "$line" =~ ^'<<<'(.+)'>>>'$ ]]; then
                local key="${BASH_REMATCH[1]}"
                local value=""

                # Read until we hit <<<END>>>
                while IFS= read -r value_line; do
                    if [[ "$value_line" == "<<<END>>>" ]]; then
                        break
                    fi
                    if [[ -n "$value" ]]; then
                        value="${value}"$'\n'"${value_line}"
                    else
                        value="${value_line}"
                    fi
                done

                if [[ -n "$key" ]]; then
                    # Create temp files for the replacement
                    local temp_content=$(mktemp)
                    local temp_value=$(mktemp)
                    echo "$content" > "$temp_content"
                    echo "$value" > "$temp_value"

                    # Use perl to replace without escaping newlines
                    content=$(perl -e '
                        use strict;
                        use warnings;

                        my $key = $ARGV[0];
                        my $value_file = $ARGV[1];
                        my $content_file = $ARGV[2];

                        # Read value
                        open(my $fh, "<", $value_file) or die $!;
                        my $value = do { local $/; <$fh> };
                        close($fh);
                        chomp $value;

                        # Read content
                        open($fh, "<", $content_file) or die $!;
                        my $content = do { local $/; <$fh> };
                        close($fh);

                        # Do the replacement - use quotemeta on entire pattern (no role. prefix)
                        my $pattern = quotemeta("{{" . $key . "}}");
                        $content =~ s/$pattern/$value/g;

                        print $content;
                    ' "$key" "$temp_value" "$temp_content")

                    rm -f "$temp_content" "$temp_value"
                fi
            fi
        done < "$temp_role_data"

        rm -f "$temp_role_data"
    fi

    # Process workflow replacements
    content=$(process_workflows "$content" "$base_dir" "$profile" "")

    # Process standards replacements
    local standards_refs=$(echo "$content" | grep -o '{{standards/[^}]*}}' | sort -u)

    while IFS= read -r standards_ref; do
        if [[ -z "$standards_ref" ]]; then
            continue
        fi

        local standards_pattern=$(echo "$standards_ref" | sed 's/{{standards\///' | sed 's/}}//')
        local standards_list=$(process_standards "$content" "$base_dir" "$profile" "$standards_pattern")

        # Create temp files for the replacement
        local temp_content=$(mktemp)
        local temp_standards=$(mktemp)
        echo "$content" > "$temp_content"
        echo "$standards_list" > "$temp_standards"

        # Use perl to replace without escaping newlines
        content=$(perl -e '
            use strict;
            use warnings;

            my $ref = $ARGV[0];
            my $standards_file = $ARGV[1];
            my $content_file = $ARGV[2];

            # Read standards list
            open(my $fh, "<", $standards_file) or die $!;
            my $standards = do { local $/; <$fh> };
            close($fh);
            chomp $standards;

            # Read content
            open($fh, "<", $content_file) or die $!;
            my $content = do { local $/; <$fh> };
            close($fh);

            # Do the replacement - use quotemeta on entire reference
            my $pattern = quotemeta($ref);
            $content =~ s/$pattern/$standards/g;

            print $content;
        ' "$standards_ref" "$temp_standards" "$temp_content")

        rm -f "$temp_content" "$temp_standards"
    done <<< "$standards_refs"

    # Replace Playwright in tools
    if echo "$content" | grep -q "^tools:.*Playwright"; then
        local tools_line=$(echo "$content" | grep "^tools:")
        local new_tools_line=$(replace_playwright_tools "$tools_line")
        # Simple replacement since this is a single line
        content=$(echo "$content" | sed "s|^tools:.*$|$new_tools_line|")
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        echo "$dest_file"
    else
        ensure_dir "$(dirname "$dest_file")"
        echo "$content" > "$dest_file"
        print_verbose "Compiled agent: $dest_file"
    fi
}

# Compile command file with all replacements
compile_command() {
    local source_file=$1
    local dest_file=$2
    local base_dir=$3
    local profile=$4

    compile_agent "$source_file" "$dest_file" "$base_dir" "$profile" ""
}

# -----------------------------------------------------------------------------
# Version Functions
# -----------------------------------------------------------------------------

# Detect repository URL from git remote or use default
detect_repo_url() {
    # If REPO_URL is already set via environment, use it
    if [[ -n "${REPO_URL:-}" ]]; then
        echo "$REPO_URL"
        return
    fi

    # Try to detect from git remote in base directory
    local base_dir=${BASE_DIR:-"$HOME/agent-os"}
    if [[ -d "$base_dir/.git" ]]; then
        local git_url=$(cd "$base_dir" && git remote get-url origin 2>/dev/null || echo "")
        if [[ -n "$git_url" ]]; then
            # Convert git URL to https URL and remove .git suffix
            git_url=$(echo "$git_url" | sed 's|^git@github.com:|https://github.com/|' | sed 's|\.git$||')
            echo "$git_url"
            return
        fi
    fi

    # Fall back to default
    echo "https://github.com/buildermethods/agent-os"
}

# Compare versions (returns 0 if compatible, 1 if not)
check_version_compatibility() {
    local base_version=$1
    local project_version=$2

    # Extract major version
    local base_major=$(echo "$base_version" | cut -d'.' -f1)
    local project_major=$(echo "$project_version" | cut -d'.' -f1)

    if [[ "$base_major" != "$project_major" ]]; then
        return 1
    fi

    return 0
}

# Get latest version from GitHub
get_latest_version() {
    local repo_url=$(detect_repo_url)
    local config_url="${repo_url}/raw/main/config.yml"
    curl -sL "$config_url" 2>/dev/null | grep "^version:" | sed 's/version: *//' | tr -d '\r\n'
}

# Check for base installation updates
# Returns: 0 if update available, 1 if up to date or check failed
check_for_base_updates() {
    local base_dir=${BASE_DIR:-"$HOME/agent-os"}
    local skip_prompt=${1:-false}

    # Only check if base installation exists
    if [[ ! -f "$base_dir/config.yml" ]]; then
        return 1
    fi

    # Get current version
    local current_version=$(get_yaml_value "$base_dir/config.yml" "version" "")
    if [[ -z "$current_version" ]]; then
        return 1
    fi

    # Detect repo URL for version check and potential update
    local repo_url=$(detect_repo_url)

    # Get latest version from GitHub
    local latest_version=$(get_latest_version)
    if [[ -z "$latest_version" ]]; then
        print_verbose "Could not fetch latest version from GitHub"
        return 1
    fi

    print_verbose "Current version: $current_version, Latest version: $latest_version"

    # Compare versions
    if [[ "$current_version" == "$latest_version" ]]; then
        return 1  # Up to date
    fi

    # Update available
    if [[ "$skip_prompt" == "true" ]]; then
        return 0  # Just return that update is available
    fi

    # Prompt user
    echo ""
    print_warning "Agent OS Update Available"
    echo ""
    echo "  Current version: $current_version"
    echo "  Latest version:  $latest_version"
    echo ""
    echo "It is recommended to update your base installation before continuing."
    echo ""
    echo "Would you like to update now?"
    echo ""
    echo "1) Yes, update now"
    echo "2) No, continue without updating"
    echo ""

    read -p "Enter your choice (1-2): " choice < /dev/tty

    case $choice in
        1)
            echo ""
            print_status "Updating Agent OS..."

            # Run base-install.sh to update (use detected repo URL)
            local update_url="${repo_url}/raw/main/scripts/base-install.sh"
            if curl -sSL "$update_url" 2>/dev/null | bash; then
                echo ""
                print_success "Agent OS has been updated to version $latest_version"
                echo ""
                print_status "Please re-run your command to continue"
                exit 0
            else
                echo ""
                print_error "Update failed. Continuing with current version..."
                echo ""
                return 1
            fi
            ;;
        2)
            echo ""
            print_status "Continuing with current version..."
            echo ""
            return 1
            ;;
        *)
            echo ""
            print_warning "Invalid choice. Continuing with current version..."
            echo ""
            return 1
            ;;
    esac
}

# -----------------------------------------------------------------------------
# Installation Check Functions
# -----------------------------------------------------------------------------

# Check if Agent OS is installed in project
is_agent_os_installed() {
    local project_dir=$1

    if [[ -f "$project_dir/agent-os/config.yml" ]]; then
        return 0
    else
        return 1
    fi
}

# Get project installation config
get_project_config() {
    local project_dir=$1
    local key=$2

    get_yaml_value "$project_dir/agent-os/config.yml" "$key" ""
}

# -----------------------------------------------------------------------------
# Validation Functions (Common to both scripts)
# -----------------------------------------------------------------------------

# Validate base installation exists
validate_base_installation() {
    if [[ ! -d "$BASE_DIR" ]]; then
        print_error "Agent OS base installation not found at ~/agent-os/"
        echo ""
        print_status "Please run the base installation first:"
        echo "  curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/scripts/base-install.sh | bash"
        echo ""
        exit 1
    fi

    if [[ ! -f "$BASE_DIR/config.yml" ]]; then
        print_error "Base installation config.yml not found"
        exit 1
    fi

    print_verbose "Base installation found at: $BASE_DIR"
}

# Check if current directory is the base installation directory
check_not_base_installation() {
    if [[ -f "$PROJECT_DIR/agent-os/config.yml" ]]; then
        if grep -q "base_install: true" "$PROJECT_DIR/agent-os/config.yml"; then
            echo ""
            print_error "Cannot install Agent OS in base installation directory"
            echo ""
            echo "It appears you are in the location of your Agent OS base installation (your home directory)."
            echo "To install Agent OS in a project, move to your project's root folder:"
            echo ""
            echo "  cd path/to/project"
            echo ""
            echo "And then run:"
            echo ""
            echo "  ~/agent-os/scripts/project-install.sh"
            echo ""
            exit 1
        fi
    fi
}

# -----------------------------------------------------------------------------
# Argument Parsing Helpers
# -----------------------------------------------------------------------------

# Parse boolean flag value
# Outputs: "value shift_count" (e.g., "true 1" or "false 2")
parse_bool_flag() {
    local current_value=$1
    local next_value=$2

    if [[ "$next_value" == "true" ]] || [[ "$next_value" == "false" ]]; then
        echo "$next_value 2"
    else
        echo "true 1"
    fi
    return 0
}

# -----------------------------------------------------------------------------
# Configuration Loading Helpers
# -----------------------------------------------------------------------------

# Load base installation configuration
load_base_config() {
    BASE_VERSION=$(get_yaml_value "$BASE_DIR/config.yml" "version" "2.0.0")
    BASE_PROFILE=$(get_yaml_value "$BASE_DIR/config.yml" "profile" "default")
    BASE_MULTI_AGENT_MODE=$(get_yaml_value "$BASE_DIR/config.yml" "multi_agent_mode" "true")
    BASE_MULTI_AGENT_TOOL=$(get_yaml_value "$BASE_DIR/config.yml" "multi_agent_tool" "claude-code")
    BASE_SINGLE_AGENT_MODE=$(get_yaml_value "$BASE_DIR/config.yml" "single_agent_mode" "false")
    BASE_SINGLE_AGENT_TOOL=$(get_yaml_value "$BASE_DIR/config.yml" "single_agent_tool" "generic")
}

# Load project installation configuration
load_project_config() {
    PROJECT_VERSION=$(get_project_config "$PROJECT_DIR" "version")
    PROJECT_PROFILE=$(get_project_config "$PROJECT_DIR" "profile")
    PROJECT_MULTI_AGENT_MODE=$(get_project_config "$PROJECT_DIR" "multi_agent_mode")
    PROJECT_MULTI_AGENT_TOOL=$(get_project_config "$PROJECT_DIR" "multi_agent_tool")
    PROJECT_SINGLE_AGENT_MODE=$(get_project_config "$PROJECT_DIR" "single_agent_mode")
    PROJECT_SINGLE_AGENT_TOOL=$(get_project_config "$PROJECT_DIR" "single_agent_tool")
}

# Validate configuration
validate_config() {
    local multi_agent_mode=$1
    local single_agent_mode=$2
    local profile=$3

    # Validate at least one mode is enabled
    if [[ "$multi_agent_mode" != "true" ]] && [[ "$single_agent_mode" != "true" ]]; then
        print_error "At least one mode (single-agent or multi-agent) must be enabled"
        exit 1
    fi

    # Validate profile exists
    if [[ ! -d "$BASE_DIR/profiles/$profile" ]]; then
        print_error "Profile not found: $profile"
        exit 1
    fi
}

# Create or update project config.yml
write_project_config() {
    local version=$1
    local profile=$2
    local multi_agent_mode=$3
    local multi_agent_tool=$4
    local single_agent_mode=$5
    local single_agent_tool=$6
    local dest="$PROJECT_DIR/agent-os/config.yml"

    local config_content="version: $version
last_compiled: $(date '+%Y-%m-%d %H:%M:%S')
profile: $profile
multi_agent_mode: $multi_agent_mode"

    if [[ "$multi_agent_mode" == "true" ]]; then
        config_content="$config_content
multi_agent_tool: $multi_agent_tool"
    fi

    config_content="$config_content
single_agent_mode: $single_agent_mode"

    if [[ "$single_agent_mode" == "true" ]]; then
        config_content="$config_content
single_agent_tool: $single_agent_tool"
    fi

    local result=$(write_file "$config_content" "$dest")
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "$dest"
    fi
}
