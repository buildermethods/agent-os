#!/usr/bin/env bash
# GitHub Automations Setup Script
# Based on: https://github.com/anthropics/claude-code-action/blob/main/docs/setup.md
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"

echo "================================================"
echo "  GitHub Claude Code Automations Setup"
echo "================================================"
echo ""

# Check prerequisites
if ! command -v gh &> /dev/null; then
    echo "⚠️  GitHub CLI (gh) not found."
    echo "   Install: https://cli.github.com/"
    echo ""
    echo "Skipping automated setup. See agent-os/automations/setup/github.md for manual instructions."
    exit 0
fi

# Verify we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "⚠️  Not in a git repository. Skipping GitHub setup."
    exit 0
fi

# Verify GitHub authentication
if ! gh auth status &> /dev/null; then
    echo "⚠️  Not authenticated with GitHub CLI."
    echo "   Run: gh auth login"
    exit 0
fi

# Get repository info
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")
if [[ -z "$REPO" ]]; then
    echo "⚠️  Could not determine GitHub repository."
    echo "   Make sure you're in a repository with a GitHub remote."
    exit 0
fi

echo "Repository: $REPO"
echo ""

# Check repository permissions
echo "Checking repository permissions..."
HAS_ADMIN=$(gh repo view --json viewerPermission -q '.viewerPermission' 2>/dev/null || echo "")
if [[ "$HAS_ADMIN" == "ADMIN" ]]; then
    echo "✓ You have admin access to this repository"
    CAN_SET_SECRETS="true"
else
    echo "⚠️  You do not have admin access (current permission: ${HAS_ADMIN:-unknown})"
    echo "   You'll need admin access to configure secrets"
    CAN_SET_SECRETS="false"
fi
echo ""

# Check for existing secrets
echo "Checking authentication setup..."
echo ""

HAS_API_KEY=$(gh secret list --json name -q '.[] | select(.name == "ANTHROPIC_API_KEY") | .name' 2>/dev/null || echo "")
HAS_OAUTH=$(gh secret list --json name -q '.[] | select(.name == "CLAUDE_CODE_OAUTH_TOKEN") | .name' 2>/dev/null || echo "")

if [[ -n "$HAS_API_KEY" ]]; then
    echo "✓ ANTHROPIC_API_KEY secret already configured"
    AUTH_CONFIGURED="true"
elif [[ -n "$HAS_OAUTH" ]]; then
    echo "✓ CLAUDE_CODE_OAUTH_TOKEN secret already configured"
    AUTH_CONFIGURED="true"
else
    echo "⚠️  No authentication secrets found"
    AUTH_CONFIGURED="false"
fi

echo ""
echo "================================================"
echo "  Required Setup Steps"
echo "================================================"
echo ""

if [[ "$AUTH_CONFIGURED" != "true" ]]; then
    echo "⚠️  AUTHENTICATION REQUIRED"
    echo ""

    if [[ "$CAN_SET_SECRETS" == "true" ]]; then
        echo "You have admin access. Would you like to set up authentication now?"
        echo ""
        echo "Choose ONE of the following authentication methods:"
        echo ""
        echo "  1) API Key (Recommended for simplicity)"
        echo "  2) OAuth Token (For Claude Pro/Max users)"
        echo "  3) Install GitHub App (For organizations)"
        echo "  4) Skip (configure manually later)"
        echo ""

        if [[ -t 0 ]]; then
            read -p "Enter your choice (1-4): " -n 1 -r choice
            echo ""
            echo ""

            case "$choice" in
                1)
                    echo "Setting up API Key authentication..."
                    echo ""
                    echo "Get your Anthropic API key from: https://console.anthropic.com/settings/keys"
                    echo ""
                    if gh secret set ANTHROPIC_API_KEY; then
                        echo ""
                        echo "✓ ANTHROPIC_API_KEY secret configured successfully"
                        AUTH_CONFIGURED="true"
                    else
                        echo ""
                        echo "⚠️  Failed to set secret. You can try again manually:"
                        echo "   gh secret set ANTHROPIC_API_KEY"
                    fi
                    ;;
                2)
                    echo "Setting up OAuth Token authentication..."
                    echo ""
                    echo "Get your OAuth token from Claude account settings"
                    echo ""
                    if gh secret set CLAUDE_CODE_OAUTH_TOKEN; then
                        echo ""
                        echo "✓ CLAUDE_CODE_OAUTH_TOKEN secret configured successfully"
                        AUTH_CONFIGURED="true"
                    else
                        echo ""
                        echo "⚠️  Failed to set secret. You can try again manually:"
                        echo "   gh secret set CLAUDE_CODE_OAUTH_TOKEN"
                    fi
                    ;;
                3)
                    echo "To install the Claude GitHub App:"
                    echo ""
                    echo "  1. Visit: https://github.com/apps/claude"
                    echo "  2. Click 'Install'"
                    echo "  3. Select this repository: $REPO"
                    echo "  4. Grant the requested permissions"
                    echo ""
                    echo "The app will handle authentication automatically."
                    echo "No secrets configuration needed!"
                    echo ""
                    read -p "Press Enter when you've installed the app..."
                    echo ""
                    echo "✓ GitHub App setup initiated"
                    ;;
                4)
                    echo "Skipping authentication setup."
                    ;;
                *)
                    echo "Invalid choice. Skipping authentication setup."
                    ;;
            esac
        fi
    else
        echo "You need admin access to configure secrets."
        echo ""
        echo "Please ask a repository admin to:"
        echo ""
        echo "Option 1: API Key (Recommended for simplicity)"
        echo "  1. Get Anthropic API key from: https://console.anthropic.com/settings/keys"
        echo "  2. Set as repository secret:"
        echo "     gh secret set ANTHROPIC_API_KEY"
        echo ""
        echo "Option 2: OAuth Token (For Claude Pro/Max users)"
        echo "  1. Get OAuth token from Claude account settings"
        echo "  2. Set as repository secret:"
        echo "     gh secret set CLAUDE_CODE_OAUTH_TOKEN"
        echo ""
        echo "Option 3: GitHub App (Alternative authentication)"
        echo "  1. Install Claude GitHub App: https://github.com/apps/claude"
        echo "  2. Grant access to this repository"
        echo ""
    fi

    if [[ "$AUTH_CONFIGURED" != "true" ]]; then
        echo ""
        echo "Manual setup commands:"
        echo "  API Key:     gh secret set ANTHROPIC_API_KEY"
        echo "  OAuth Token: gh secret set CLAUDE_CODE_OAUTH_TOKEN"
        echo "  GitHub App:  Visit https://github.com/apps/claude"
        echo ""
    fi
fi

echo "📚 COMPLETE SETUP GUIDE"
echo ""
echo "  See: agent-os/automations/setup/github.md"
echo "  Or:  https://github.com/anthropics/claude-code-action/blob/main/docs/setup.md"
echo ""

echo "🚀 NEXT STEPS"
echo ""
if [[ "$AUTH_CONFIGURED" == "true" ]]; then
    echo "  ✓ Authentication configured"
    echo "  1. Commit and push .github/workflows/ files"
    echo "  2. Test by mentioning @claude in an issue or PR"
    echo "  3. Check Actions tab to see workflow runs"
else
    echo "  1. Set up authentication (see options above)"
    echo "  2. Commit and push .github/workflows/ files"
    echo "  3. Test by mentioning @claude in an issue or PR"
fi

echo ""
echo "================================================"
