#!/bin/bash

# Agent OS Gemini CLI Setup Script
# This script installs Agent OS commands for Gemini CLI

set -e  # Exit on error

echo "🚀 Agent OS Gemini CLI Setup"
echo "=========================="
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

# Base URL for raw GitHub content
BASE_URL="https://raw.githubusercontent.com/buildermethods/agent-os/main"

# Create directories
echo "📁 Creating directories..."
mkdir -p "$HOME/.gemini/commands"

# Download command files for Gemini CLI
echo ""
echo "📥 Downloading Gemini CLI command files to ~/.gemini/commands/"

# Commands
for cmd in plan-product create-spec execute-tasks analyze-product; do
    if [ -f "$HOME/.gemini/commands/${cmd}.toml" ]; then
        echo "  ⚠️  ~/.gemini/commands/${cmd}.toml already exists - skipping"
    else
        curl -s -o "$HOME/.gemini/commands/${cmd}.toml" "${BASE_URL}/gemini-cli/commands/${cmd}.toml"
        echo "  ✓ ~/.gemini/commands/${cmd}.toml"
    fi
done

# Download Gemini CLI user GEMINI.md
echo ""
echo "📥 Downloading Gemini CLI configuration to ~/.gemini/"

if [ -f "$HOME/.gemini/GEMINI.md" ]; then
    echo "  ⚠️  ~/.gemini/GEMINI.md already exists - skipping"
else
    curl -s -o "$HOME/.gemini/GEMINI.md" "${BASE_URL}/gemini-cli/GEMINI.md"
    echo "  ✓ ~/.gemini/GEMINI.md"
fi

echo ""
echo "✅ Agent OS Gemini CLI installation complete!"
echo ""
echo "📍 Files installed to:"
echo "   ~/.gemini/commands/        - Gemini CLI commands"
echo "   ~/.gemini/GEMINI.md        - Gemini CLI configuration"
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
