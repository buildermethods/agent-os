#!/bin/bash

# Agent OS GitHub Copilot Setup Script
# This script installs Agent OS commands for GitHub Copilot

set -e  # Exit on error

echo "🚀 Agent OS GitHub Copilot Setup"
echo "=================================="
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

# Create directories
echo ""
echo "📁 Creating .github/instructions directory..."
mkdir -p ".github/instructions"

# Base URL for raw GitHub content
BASE_URL="https://raw.githubusercontent.com/buildermethods/agent-os/main"

# Download GitHub Copilot configuration file
echo ""
echo "📥 Downloading GitHub Copilot configuration to .github/"

if [ -f ".github/copilot-instructions.md" ]; then
    echo "  ⚠️  .github/copilot-instructions.md already exists - skipping"
else
    curl -s -o ".github/copilot-instructions.md" "${BASE_URL}/github-copilot/copilot-instructions.md"
    echo "  ✓ .github/copilot-instructions.md"
fi

# Download instruction files for GitHub Copilot
echo ""
echo "📥 Downloading GitHub Copilot instruction files to .github/instructions/"

# List of instruction files to download
for instruction in plan-product create-spec execute-tasks analyze-product; do
    filename="${instruction}.instructions.md"
    if [ -f ".github/instructions/${filename}" ]; then
        echo "  ⚠️  .github/instructions/${filename} already exists - skipping"
    else
        curl -s -o ".github/instructions/${filename}" "${BASE_URL}/commands/${instruction}.md"
        echo "  ✓ .github/instructions/${filename}"
    fi
done

echo ""
echo "✅ Agent OS GitHub Copilot installation complete!"
echo ""
echo "📍 Files installed to:"
echo "   .github/copilot-instructions.md    - Main GitHub Copilot configuration"
echo "   .github/instructions/              - GitHub Copilot Agent OS commands"
echo ""
echo "Next steps:"
echo ""
echo "Use Agent OS commands in GitHub Copilot using:"
echo "  #.github/instructions/plan-product.instructions.md"
echo "  #.github/instructions/analyze-product.instructions.md"
echo "  #.github/instructions/create-spec.instructions.md"
echo "  #.github/instructions/execute-tasks.instructions.md"
echo ""
echo "Learn more at https://buildermethods.com/agent-os"
echo ""
