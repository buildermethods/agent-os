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

# Check if we're in a Git repository
if [ ! -d ".git" ]; then
    echo "⚠️  Not in a Git repository!"
    echo ""
    echo "This script must be run from the root of a Git repository."
    echo "Please navigate to your project's root directory and try again."
    echo ""
    echo "To initialize a new Git repository:"
    echo "  git init"
    echo "  git add ."
    echo "  git commit -m \"Initial commit\""
    echo ""
    exit 1
fi

# Check if .github directory can be created
if [ ! -w "." ]; then
    echo "⚠️  No write permissions in current directory!"
    echo ""
    echo "Please ensure you have write permissions in this directory."
    echo ""
    exit 1
fi

# Base URL for raw GitHub content
BASE_URL="https://raw.githubusercontent.com/buildermethods/agent-os/main"

# Create directories
echo "📁 Creating directories..."
mkdir -p ".github/instructions"

echo "  ✓ .github/instructions/"

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
instructions=("plan-product" "create-spec" "execute-tasks" "analyze-product")

for instruction in "${instructions[@]}"; do
    filename="${instruction}.instruction.md"
    if [ -f ".github/instructions/${filename}" ]; then
        echo "  ⚠️  .github/instructions/${filename} already exists - skipping"
    else
        curl -s -o ".github/instructions/${filename}" "${BASE_URL}/github-copilot/instructions/${filename}"
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
echo "1. Review and customize .github/copilot-instructions.md for your project"
echo "2. Commit these files to your repository"
echo ""
echo "Initiate Agent OS workflows with GitHub Copilot using:"
echo "  @.github/instructions/plan-product.instruction.md"
echo "  @.github/instructions/analyze-product.instruction.md"
echo "  @.github/instructions/create-spec.instruction.md"
echo "  @.github/instructions/execute-tasks.instruction.md"
echo ""
echo "Learn more at https://buildermethods.com/agent-os"
echo ""
