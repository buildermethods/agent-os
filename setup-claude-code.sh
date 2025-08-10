 #!/bin/bash

# Agent OS Claude Code Setup Script
# This script installs Agent OS commands for Claude Code

set -e  # Exit on error

# Flags
USE_LOCAL=false
REPO_PATH=""

# Parse args
while [[ $# -gt 0 ]]; do
  case $1 in
    --local)
      USE_LOCAL=true
      shift
      ;;
    --repo-path)
      REPO_PATH="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [--local] [--repo-path <path>]"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo "🚀 Agent OS Claude Code Setup"
echo "============================="
echo ""

# Check if Agent OS base installation is present
if [ ! -d "$HOME/.agent-os/instructions" ] || [ ! -d "$HOME/.agent-os/standards" ]; then
    echo "⚠️  Agent OS base installation not found!"
    echo ""
    echo "Please install the Agent OS base installation first:"
    echo ""
    echo "Option 1 - Automatic installation:"
    echo "  curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/setup.sh | bash"
    echo ""
    echo "Option 2 - Manual installation:"
    echo "  Follow instructions at https://buildermethods.com/agent-os"
    echo ""
    exit 1
fi

# Determine source
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_URL="https://raw.githubusercontent.com/buildermethods/agent-os/main"
if [ "$USE_LOCAL" = true ]; then
  if [ -z "$REPO_PATH" ]; then
    REPO_PATH="$SCRIPT_DIR"
  fi
  echo "📦 Using local source: $REPO_PATH"
else
  echo "🌐 Using remote source: $BASE_URL"
fi

# Helper to fetch a file from local or remote
fetch_to() {
  local dest="$1"
  local rel="$2"
  if [ "$USE_LOCAL" = true ]; then
    cp "$REPO_PATH/$rel" "$dest"
  else
    curl -s -o "$dest" "${BASE_URL}/$rel"
  fi
}

# Create directories
echo "📁 Creating directories..."
mkdir -p "$HOME/.claude/commands"
mkdir -p "$HOME/.claude/agents"

# Download command files for Claude Code
echo ""
echo "📥 Downloading Claude Code command files to ~/.claude/commands/"

# Commands
for cmd in plan-product create-spec execute-tasks analyze-product; do
    if [ -f "$HOME/.claude/commands/${cmd}.md" ]; then
        echo "  ⚠️  ~/.claude/commands/${cmd}.md already exists - skipping"
    else
        fetch_to "$HOME/.claude/commands/${cmd}.md" "commands/${cmd}.md"
        echo "  ✓ ~/.claude/commands/${cmd}.md"
    fi
done

# Download Claude Code agents
echo ""
echo "📥 Downloading Claude Code subagents to ~/.claude/agents/"

# List of agent files to download
agents=("test-runner" "context-fetcher" "git-workflow" "file-creator" "date-checker")

for agent in "${agents[@]}"; do
    if [ -f "$HOME/.claude/agents/${agent}.md" ]; then
        echo "  ⚠️  ~/.claude/agents/${agent}.md already exists - skipping"
    else
        fetch_to "$HOME/.claude/agents/${agent}.md" "claude-code/agents/${agent}.md"
        echo "  ✓ ~/.claude/agents/${agent}.md"
    fi
done

echo ""
echo "✅ Agent OS Claude Code installation complete!"
echo ""
echo "📍 Files installed to:"
echo "   ~/.claude/commands/        - Claude Code commands"
echo "   ~/.claude/agents/          - Claude Code specialized subagents"
echo ""
echo "Next steps:"
echo ""
echo "Initiate Agent OS in a new product's codebase with:"
echo "  /plan-product"
echo ""
echo "Initiate Agent OS in an existing product's codebase with:"
echo "  /analyze-product"
echo ""
echo "Initiate a new feature with:"
echo "  /create-spec (or simply ask 'what's next?')"
echo ""
echo "Build and ship code with:"
echo "  /execute-task"
echo ""
echo "Learn more at https://buildermethods.com/agent-os"
echo ""
