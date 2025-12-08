#!/bin/bash

# Agent OS Project Installation Script
# This script installs Agent OS in a project directory with embedded instructions

set -e  # Exit on error

# Version information
AGENT_OS_VERSION="1.7.0"
AGENT_OS_RELEASE_DATE="2025-12-08"

# Track installation progress for cleanup
INSTALL_STARTED=false
DIRECTORIES_CREATED=()
FILES_CREATED=()

# Cleanup function for failed installations
cleanup_on_failure() {
    local exit_code=$?

    # Only cleanup if installation actually started and failed
    if [ "$INSTALL_STARTED" = true ] && [ $exit_code -ne 0 ]; then
        echo ""
        echo "⚠️  Installation failed! Cleaning up partial installation..."
        echo ""

        # Remove created files (in reverse order)
        for ((i=${#FILES_CREATED[@]}-1; i>=0; i--)); do
            if [ -f "${FILES_CREATED[$i]}" ]; then
                rm -f "${FILES_CREATED[$i]}" 2>/dev/null || true
                echo "   Removed: ${FILES_CREATED[$i]}"
            fi
        done

        # Remove created directories (in reverse order, only if empty)
        for ((i=${#DIRECTORIES_CREATED[@]}-1; i>=0; i--)); do
            if [ -d "${DIRECTORIES_CREATED[$i]}" ]; then
                rmdir "${DIRECTORIES_CREATED[$i]}" 2>/dev/null || true
            fi
        done

        echo ""
        echo "❌ Installation was rolled back. Please check the error above and try again."
        echo ""
        echo "If this problem persists, please report it at:"
        echo "https://github.com/buildermethods/agent-os/issues"
        echo ""
    fi

    # Clean up temp files if any
    rm -f /tmp/agent-os-functions-$$.sh 2>/dev/null || true
}

# Set trap to cleanup on error, interrupt, or termination
trap cleanup_on_failure EXIT INT TERM

# Helper function to track created directories
create_tracked_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        DIRECTORIES_CREATED+=("$dir")
    fi
}

# Helper function to track created files
track_file() {
    local file="$1"
    FILES_CREATED+=("$file")
}

# Initialize flags
NO_BASE=false
OVERWRITE_INSTRUCTIONS=false
OVERWRITE_STANDARDS=false
CLAUDE_CODE=false
CURSOR=false
PROJECT_TYPE=""
WITH_HOOKS=false
FULL_SKILLS=false
UPGRADE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-base)
            NO_BASE=true
            shift
            ;;
        --overwrite-instructions)
            OVERWRITE_INSTRUCTIONS=true
            shift
            ;;
        --overwrite-standards)
            OVERWRITE_STANDARDS=true
            shift
            ;;
        --claude-code|--claude|--claude_code)
            CLAUDE_CODE=true
            shift
            ;;
        --cursor|--cursor-cli)
            CURSOR=true
            shift
            ;;
        --with-hooks)
            WITH_HOOKS=true
            shift
            ;;
        --full-skills)
            FULL_SKILLS=true
            shift
            ;;
        --upgrade)
            UPGRADE=true
            OVERWRITE_INSTRUCTIONS=true
            OVERWRITE_STANDARDS=true
            shift
            ;;
        --project-type=*)
            PROJECT_TYPE="${1#*=}"
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --claude-code               Add Claude Code support (with embedded instructions)"
            echo "  --cursor                    Add Cursor support"
            echo "  --full-skills               Install all skills including optional Tier 2 skills"
            echo "  --upgrade                   Upgrade existing installation (overwrites all commands, agents, skills, standards)"
            echo "  --with-hooks                Add optional validation hooks for state management"
            echo "  --project-type=TYPE         Use specific project type for installation"
            echo "  --no-base                   Install from GitHub (not from a base installation)"
            echo "  --overwrite-instructions    Overwrite existing instruction files only"
            echo "  --overwrite-standards       Overwrite existing standards files only"
            echo "  -h, --help                  Show this help message"
            echo ""
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo ""
echo "🚀 Agent OS Project Installation"
echo "================================"
echo ""

# Get project directory info
CURRENT_DIR=$(pwd)
PROJECT_NAME=$(basename "$CURRENT_DIR")
INSTALL_DIR="./.agent-os"

echo "📍 Installing Agent OS to this project's root directory ($PROJECT_NAME)"
echo ""

# Determine if running from base installation or GitHub
if [ "$NO_BASE" = true ]; then
    IS_FROM_BASE=false
    echo "📦 Installing directly from GitHub (no base installation)"
    # Set BASE_URL for GitHub downloads
    BASE_URL="https://raw.githubusercontent.com/buildermethods/agent-os/main"
    # Download and source functions when running from GitHub
    TEMP_FUNCTIONS="/tmp/agent-os-functions-$$.sh"
    curl -sSL "${BASE_URL}/setup/functions.sh" -o "$TEMP_FUNCTIONS"
    source "$TEMP_FUNCTIONS"
    rm "$TEMP_FUNCTIONS"
else
    IS_FROM_BASE=true
    # Get the base Agent OS directory
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    BASE_AGENT_OS="$(dirname "$SCRIPT_DIR")"
    echo "✓ Using Agent OS base installation at $BASE_AGENT_OS"
    # Source shared functions from base installation
    source "$SCRIPT_DIR/functions.sh"
fi

echo ""
echo "📁 Creating project directories..."
echo ""

# Mark installation as started for cleanup tracking
INSTALL_STARTED=true

# Create directories with tracking for rollback
create_tracked_dir "$INSTALL_DIR"
create_tracked_dir "$INSTALL_DIR/state"
create_tracked_dir "$INSTALL_DIR/state/recovery"
create_tracked_dir "$INSTALL_DIR/standards"
create_tracked_dir "$INSTALL_DIR/progress"
create_tracked_dir "$INSTALL_DIR/progress/archive"

# Configure tools and project type based on installation type
if [ "$IS_FROM_BASE" = true ]; then
    # Auto-enable tools based on base config if no flags provided
    if [ "$CLAUDE_CODE" = false ]; then
        # Check if claude_code is enabled in base config
        if grep -q "claude_code:" "$BASE_AGENT_OS/config.yml" && \
           grep -A1 "claude_code:" "$BASE_AGENT_OS/config.yml" | grep -q "enabled: true"; then
            CLAUDE_CODE=true
            echo "  ✓ Auto-enabling Claude Code support (from Agent OS config)"
        fi
    fi

    if [ "$CURSOR" = false ]; then
        # Check if cursor is enabled in base config
        if grep -q "cursor:" "$BASE_AGENT_OS/config.yml" && \
           grep -A1 "cursor:" "$BASE_AGENT_OS/config.yml" | grep -q "enabled: true"; then
            CURSOR=true
            echo "  ✓ Auto-enabling Cursor support (from Agent OS config)"
        fi
    fi

    # Read project type from config or use flag
    if [ -z "$PROJECT_TYPE" ] && [ -f "$BASE_AGENT_OS/config.yml" ]; then
        # Try to read default_project_type from config
        PROJECT_TYPE=$(grep "^default_project_type:" "$BASE_AGENT_OS/config.yml" | cut -d' ' -f2 | tr -d ' ')
        if [ -z "$PROJECT_TYPE" ]; then
            PROJECT_TYPE="default"
        fi
    elif [ -z "$PROJECT_TYPE" ]; then
        PROJECT_TYPE="default"
    fi

    echo ""
    echo "📦 Using project type: $PROJECT_TYPE"

    # Determine source paths based on project type
    INSTRUCTIONS_SOURCE=""
    STANDARDS_SOURCE=""

    if [ "$PROJECT_TYPE" = "default" ]; then
        INSTRUCTIONS_SOURCE="$BASE_AGENT_OS/instructions"
        STANDARDS_SOURCE="$BASE_AGENT_OS/standards"
    else
        # Look up project type in config
        if grep -q "^  $PROJECT_TYPE:" "$BASE_AGENT_OS/config.yml"; then
            # Extract paths for this project type
            INSTRUCTIONS_PATH=$(awk "/^  $PROJECT_TYPE:/{f=1} f&&/instructions:/{print \$2; exit}" "$BASE_AGENT_OS/config.yml")
            STANDARDS_PATH=$(awk "/^  $PROJECT_TYPE:/{f=1} f&&/standards:/{print \$2; exit}" "$BASE_AGENT_OS/config.yml")

            # Expand tilde in paths
            INSTRUCTIONS_SOURCE=$(eval echo "$INSTRUCTIONS_PATH")
            STANDARDS_SOURCE=$(eval echo "$STANDARDS_PATH")

            # Check if paths exist
            if [ ! -d "$INSTRUCTIONS_SOURCE" ] || [ ! -d "$STANDARDS_SOURCE" ]; then
                echo "  ⚠️  Project type '$PROJECT_TYPE' paths not found, falling back to default instructions and standards"
                INSTRUCTIONS_SOURCE="$BASE_AGENT_OS/instructions"
                STANDARDS_SOURCE="$BASE_AGENT_OS/standards"
            fi
        else
            echo "  ⚠️  Project type '$PROJECT_TYPE' not found in config, using default instructions and standards"
            INSTRUCTIONS_SOURCE="$BASE_AGENT_OS/instructions"
            STANDARDS_SOURCE="$BASE_AGENT_OS/standards"
        fi
    fi

    # Copy only standards from determined sources (instructions are now embedded in commands)
    echo ""
    echo "📥 Installing standards files to $INSTALL_DIR/standards/"
    copy_directory "$STANDARDS_SOURCE" "$INSTALL_DIR/standards" "$OVERWRITE_STANDARDS"
    
    # Note: Instructions are now embedded in commands, no need to copy separately
else
    # Running directly from GitHub - download from GitHub
    if [ -z "$PROJECT_TYPE" ]; then
        PROJECT_TYPE="default"
    fi

    echo "📦 Using project type: $PROJECT_TYPE (default when installing from GitHub)"

    # Install instructions and standards from GitHub (no commands folder needed)
    install_from_github "$INSTALL_DIR" "$OVERWRITE_INSTRUCTIONS" "$OVERWRITE_STANDARDS" false
fi

# Handle Claude Code installation for project
if [ "$CLAUDE_CODE" = true ]; then
    echo ""
    if [ "$UPGRADE" = true ]; then
        echo "📥 Upgrading Claude Code support..."
    else
        echo "📥 Installing Claude Code support..."
    fi
    create_tracked_dir "./.claude"
    create_tracked_dir "./.claude/commands"
    create_tracked_dir "./.claude/agents"
    create_tracked_dir "./.claude/skills"

    # Determine overwrite setting for Claude Code files
    OVERWRITE_CLAUDE="false"
    if [ "$UPGRADE" = true ]; then
        OVERWRITE_CLAUDE="true"
    fi

    if [ "$IS_FROM_BASE" = true ]; then
        # Copy from base installation
        echo "  📂 Commands:"
        for cmd in plan-product create-spec create-tasks execute-tasks analyze-product index-codebase debug; do
            if [ -f "$BASE_AGENT_OS/commands/${cmd}.md" ]; then
                copy_file "$BASE_AGENT_OS/commands/${cmd}.md" "./.claude/commands/${cmd}.md" "$OVERWRITE_CLAUDE" "commands/${cmd}.md"
            else
                echo "  ⚠️  Warning: ${cmd}.md not found in base installation"
            fi
        done

        echo ""
        echo "  📂 Agents:"
        for agent in git-workflow project-manager codebase-indexer; do
            if [ -f "$BASE_AGENT_OS/claude-code/agents/${agent}.md" ]; then
                copy_file "$BASE_AGENT_OS/claude-code/agents/${agent}.md" "./.claude/agents/${agent}.md" "$OVERWRITE_CLAUDE" "agents/${agent}.md"
            else
                echo "  ⚠️  Warning: ${agent}.md not found in base installation"
            fi
        done

        echo ""
        echo "  📂 Shared Modules:"
        create_tracked_dir "./.agent-os/shared"
        for shared in error-recovery state-patterns progress-log task-json; do
            if [ -f "$BASE_AGENT_OS/shared/${shared}.md" ]; then
                copy_file "$BASE_AGENT_OS/shared/${shared}.md" "./.agent-os/shared/${shared}.md" "$OVERWRITE_CLAUDE" "shared/${shared}.md"
            else
                echo "  ⚠️  Warning: ${shared}.md not found in base installation"
            fi
        done

        echo ""
        echo "  📂 Skills (Tier 1 - Default):"
        for skill in build-check test-check codebase-names systematic-debugging tdd brainstorming writing-plans session-startup; do
            if [ -f "$BASE_AGENT_OS/claude-code/skills/${skill}.md" ]; then
                copy_file "$BASE_AGENT_OS/claude-code/skills/${skill}.md" "./.claude/skills/${skill}.md" "$OVERWRITE_CLAUDE" "skills/${skill}.md"
            else
                echo "  ⚠️  Warning: ${skill}.md not found in base installation"
            fi
        done

        # Install optional Tier 2 skills if --full-skills flag is set
        if [ "$FULL_SKILLS" = true ]; then
            echo ""
            echo "  📂 Skills (Tier 2 - Optional):"
            create_tracked_dir "./.claude/skills/optional"
            for skill in code-review verification skill-creator mcp-builder; do
                if [ -f "$BASE_AGENT_OS/claude-code/skills/optional/${skill}.md" ]; then
                    copy_file "$BASE_AGENT_OS/claude-code/skills/optional/${skill}.md" "./.claude/skills/optional/${skill}.md" "$OVERWRITE_CLAUDE" "skills/optional/${skill}.md"
                else
                    echo "  ⚠️  Warning: ${skill}.md not found in base installation"
                fi
            done
        fi
    else
        # Download from GitHub when using --no-base
        echo "  Downloading Claude Code files from GitHub..."
        echo ""
        echo "  📂 Commands:"
        for cmd in plan-product create-spec create-tasks execute-tasks analyze-product index-codebase debug; do
            download_file "${BASE_URL}/commands/${cmd}.md" \
                "./.claude/commands/${cmd}.md" \
                "$OVERWRITE_CLAUDE" \
                "commands/${cmd}.md"
        done

        echo ""
        echo "  📂 Agents:"
        for agent in git-workflow project-manager codebase-indexer; do
            download_file "${BASE_URL}/claude-code/agents/${agent}.md" \
                "./.claude/agents/${agent}.md" \
                "$OVERWRITE_CLAUDE" \
                "agents/${agent}.md"
        done

        echo ""
        echo "  📂 Shared Modules:"
        create_tracked_dir "./.agent-os/shared"
        for shared in error-recovery state-patterns progress-log task-json; do
            download_file "${BASE_URL}/shared/${shared}.md" \
                "./.agent-os/shared/${shared}.md" \
                "$OVERWRITE_CLAUDE" \
                "shared/${shared}.md"
        done

        echo ""
        echo "  📂 Skills (Tier 1 - Default):"
        for skill in build-check test-check codebase-names systematic-debugging tdd brainstorming writing-plans session-startup; do
            download_file "${BASE_URL}/claude-code/skills/${skill}.md" \
                "./.claude/skills/${skill}.md" \
                "$OVERWRITE_CLAUDE" \
                "skills/${skill}.md"
        done

        # Install optional Tier 2 skills if --full-skills flag is set
        if [ "$FULL_SKILLS" = true ]; then
            echo ""
            echo "  📂 Skills (Tier 2 - Optional):"
            create_tracked_dir "./.claude/skills/optional"
            for skill in code-review verification skill-creator mcp-builder; do
                download_file "${BASE_URL}/claude-code/skills/optional/${skill}.md" \
                    "./.claude/skills/optional/${skill}.md" \
                    "$OVERWRITE_CLAUDE" \
                    "skills/optional/${skill}.md"
            done
        fi
    fi
fi

# Initialize state management
echo ""
echo "📥 Initializing state management..."
cat > "$INSTALL_DIR/state/workflow.json" << 'EOF'
{
  "state_version": "1.0.0",
  "current_workflow": null,
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

# Initialize progress log (persistent cross-session memory)
echo ""
echo "📥 Initializing progress log..."
if [ ! -f "$INSTALL_DIR/progress/progress.json" ]; then
    PROGRESS_TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    cat > "$INSTALL_DIR/progress/progress.json" << EOF
{
  "version": "1.0",
  "project": "$PROJECT_NAME",
  "entries": [
    {
      "id": "entry-init-001",
      "timestamp": "$PROGRESS_TIMESTAMP",
      "type": "milestone_reached",
      "data": {
        "description": "Agent OS installed",
        "notes": "Progress logging initialized for cross-session memory"
      }
    }
  ],
  "metadata": {
    "total_entries": 1,
    "oldest_entry": "$PROGRESS_TIMESTAMP",
    "last_updated": "$PROGRESS_TIMESTAMP",
    "archived_through": null
  }
}
EOF
    echo "  ✓ Created progress log (progress.json)"

    # Generate initial markdown
    cat > "$INSTALL_DIR/progress/progress.md" << EOF
# Agent OS Progress Log

*Project: $PROJECT_NAME*
*Total entries: 1*

---

## $(date +%Y-%m-%d)

### $(date +%H:%M) - 🎯 Agent OS installed
- **Details**: Progress logging initialized for cross-session memory

---
EOF
    echo "  ✓ Created progress log (progress.md)"
else
    echo "  ✓ Progress log already exists (preserved)"
fi

# Create version tracking file
echo ""
echo "📥 Creating version tracking..."

# Determine features installed
FEATURES_ARRAY="[]"
if [ "$CLAUDE_CODE" = true ] && [ "$CURSOR" = true ]; then
    if [ "$WITH_HOOKS" = true ]; then
        FEATURES_ARRAY='["claude-code", "cursor", "hooks"]'
    else
        FEATURES_ARRAY='["claude-code", "cursor"]'
    fi
elif [ "$CLAUDE_CODE" = true ]; then
    if [ "$WITH_HOOKS" = true ]; then
        FEATURES_ARRAY='["claude-code", "hooks"]'
    else
        FEATURES_ARRAY='["claude-code"]'
    fi
elif [ "$CURSOR" = true ]; then
    FEATURES_ARRAY='["cursor"]'
fi

# Determine skills tier
SKILLS_TIER="default"
if [ "$FULL_SKILLS" = true ]; then
    SKILLS_TIER="full"
fi

# Get installation timestamp
INSTALL_TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

cat > "$INSTALL_DIR/version.json" << EOF
{
  "agent_os_version": "$AGENT_OS_VERSION",
  "release_date": "$AGENT_OS_RELEASE_DATE",
  "installed_at": "$INSTALL_TIMESTAMP",
  "project_type": "$PROJECT_TYPE",
  "skills_tier": "$SKILLS_TIER",
  "features": $FEATURES_ARRAY,
  "installation_source": "$([ "$IS_FROM_BASE" = true ] && echo "base" || echo "github")",
  "upgrade_info": {
    "last_checked": null,
    "available_version": null,
    "breaking_changes": false
  }
}
EOF
echo "  ✓ Created version tracking file (v$AGENT_OS_VERSION)"

# Handle optional hooks installation
if [ "$WITH_HOOKS" = true ]; then
    echo ""
    echo "📥 Installing validation hooks..."
    create_tracked_dir "./.claude/hooks"
    
    # Pre-write hook for JSON validation
    cat > "./.claude/hooks/pre-write.sh" << 'EOF'
#!/bin/bash
# Validates JSON state files before writing
if [[ "$1" == *".agent-os/state/"*.json ]]; then
    jq empty "$1" 2>/dev/null || {
        echo "ERROR: Invalid JSON in state file"
        exit 1
    }
fi
EOF
    
    # Post-command hook for cache cleanup
    cat > "./.claude/hooks/post-command.sh" << 'EOF'
#!/bin/bash
# Clean expired caches after command execution
find .agent-os/state -name "session-cache.json" -mmin +60 \
    -exec rm {} \; 2>/dev/null
EOF
    
    chmod +x ./.claude/hooks/*.sh
    echo "  ✓ Installed pre-write validation hook"
    echo "  ✓ Installed post-command cleanup hook"
fi

# Update .gitignore for state and cache files
# NOTE: .agent-os/progress/ is NOT in gitignore - progress logs should be version controlled
if [ -f .gitignore ]; then
    # Check if Agent-OS section already exists
    if ! grep -q "# Agent-OS cache and state files" .gitignore; then
        echo "" >> .gitignore
        echo "# Agent-OS cache and state files (excludes progress/ which is version controlled)" >> .gitignore
        echo ".agent-os/state/session-cache.json" >> .gitignore
        echo ".agent-os/state/command-state.json" >> .gitignore
        echo ".agent-os/state/recovery/" >> .gitignore
        echo ".agent-os/state/.lock" >> .gitignore
        echo ".agent-os/cache/" >> .gitignore
        echo ".agent-os/debugging/" >> .gitignore
        echo ".agent-os/**/*.cache" >> .gitignore
        echo ".agent-os/**/*.tmp" >> .gitignore
        echo "  ✓ Updated .gitignore with state exclusions"
        echo "  ℹ️  Note: .agent-os/progress/ is version controlled (cross-session memory)"
    fi
else
    # Create new .gitignore with Agent-OS entries
    cat > .gitignore << 'EOF'
# Agent-OS cache and state files (excludes progress/ which is version controlled)
.agent-os/state/session-cache.json
.agent-os/state/command-state.json
.agent-os/state/recovery/
.agent-os/state/.lock
.agent-os/cache/
.agent-os/debugging/
.agent-os/**/*.cache
.agent-os/**/*.tmp
EOF
    echo "  ✓ Created .gitignore with state exclusions"
    echo "  ℹ️  Note: .agent-os/progress/ is version controlled (cross-session memory)"
fi

# Handle Cursor installation for project
if [ "$CURSOR" = true ]; then
    echo ""
    echo "📥 Installing Cursor support..."
    create_tracked_dir "./.cursor"
    create_tracked_dir "./.cursor/rules"

    echo "  📂 Rules:"

    if [ "$IS_FROM_BASE" = true ]; then
        # Convert commands from base installation to Cursor rules
        for cmd in plan-product create-spec create-tasks execute-tasks analyze-product; do
            if [ -f "$BASE_AGENT_OS/commands/${cmd}.md" ]; then
                convert_to_cursor_rule "$BASE_AGENT_OS/commands/${cmd}.md" "./.cursor/rules/${cmd}.mdc"
            else
                echo "  ⚠️  Warning: ${cmd}.md not found in base installation"
            fi
        done
    else
        # Download from GitHub and convert when using --no-base
        echo "  Downloading and converting from GitHub..."
        for cmd in plan-product create-spec create-tasks execute-tasks analyze-product; do
            TEMP_FILE="/tmp/${cmd}.md"
            curl -s -o "$TEMP_FILE" "${BASE_URL}/commands/${cmd}.md"
            if [ -f "$TEMP_FILE" ]; then
                convert_to_cursor_rule "$TEMP_FILE" "./.cursor/rules/${cmd}.mdc"
                rm "$TEMP_FILE"
            fi
        done
    fi
fi

# Verify installation
echo ""
echo "🔍 Verifying installation..."

VERIFICATION_PASSED=true

# Check critical files exist
if [ ! -f "$INSTALL_DIR/version.json" ]; then
    echo "  ⚠️  Warning: version.json not created"
    VERIFICATION_PASSED=false
fi

if [ ! -f "$INSTALL_DIR/state/workflow.json" ]; then
    echo "  ⚠️  Warning: workflow.json not created"
    VERIFICATION_PASSED=false
fi

if [ "$CLAUDE_CODE" = true ]; then
    # Verify at least one command exists
    if [ ! -f "./.claude/commands/execute-tasks.md" ]; then
        echo "  ⚠️  Warning: Claude Code commands not fully installed"
        VERIFICATION_PASSED=false
    fi
fi

if [ "$VERIFICATION_PASSED" = true ]; then
    echo "  ✓ All critical files verified"
fi

# Mark installation as complete (prevents cleanup on exit)
INSTALL_STARTED=false

# Success message
echo ""
echo "✅ Agent OS v$AGENT_OS_VERSION has been installed in your project ($PROJECT_NAME)!"
echo ""
echo "📍 Project-level files installed to:"
echo "   .agent-os/version.json     - Installation version and metadata"
echo "   .agent-os/standards/       - Development standards"
echo "   .agent-os/state/           - State management and caching"
echo "   .agent-os/progress/        - Persistent progress log (cross-session memory)"
echo "   .agent-os/shared/          - Shared modules (error recovery, state patterns, progress log)"

if [ "$CLAUDE_CODE" = true ]; then
    echo "   .claude/commands/          - Claude Code commands (with embedded instructions)"
    echo "   .claude/agents/            - Claude Code specialized subagents"
    echo "   .claude/skills/            - Claude Code skills (8 default skills)"
    if [ "$FULL_SKILLS" = true ]; then
        echo "   .claude/skills/optional/   - Optional Tier 2 skills (4 additional)"
    fi
fi

if [ "$WITH_HOOKS" = true ]; then
    echo "   .claude/hooks/             - Validation and cleanup hooks"
fi

if [ "$CURSOR" = true ]; then
    echo "   .cursor/rules/             - Cursor command rules"
fi

echo ""
echo "--------------------------------"
echo ""
echo "Next steps:"
echo ""

if [ "$CLAUDE_CODE" = true ]; then
    echo "Claude Code useage:"
    echo "  /plan-product    - Set the mission & roadmap for a new product"
    echo "  /analyze-product - Set up the mission and roadmap for an existing product"
    echo "  /create-spec     - Create a spec for a new feature"
    echo "  /execute-tasks   - Build and ship code for a new feature"
    echo ""
fi

if [ "$CURSOR" = true ]; then
    echo "Cursor useage:"
    echo "  @plan-product    - Set the mission & roadmap for a new product"
    echo "  @analyze-product - Set up the mission and roadmap for an existing product"
    echo "  @create-spec     - Create a spec for a new feature"
    echo "  @execute-tasks   - Build and ship code for a new feature"
    echo ""
fi

echo "--------------------------------"
echo ""
echo "Refer to the official Agent OS docs at:"
echo "https://buildermethods.com/agent-os"
echo ""
echo "Keep building! 🚀"
echo ""
