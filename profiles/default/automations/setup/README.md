# Agent OS Automations Setup

This directory contains setup instructions for various CI/CD platforms.

## Available Platforms

- [GitHub Actions](./github.md) - Primary platform with Claude Code integration

## General Setup Process

1. **Installation**: Run `~/.agent-os/scripts/project-install.sh`
2. **Setup Scripts**: When prompted, choose whether to run platform-specific setup scripts
3. **Manual Configuration**: Follow platform-specific guides for additional setup
4. **Verification**: Test workflows by triggering them manually

## Setup Script Behavior

Setup scripts are **idempotent** and **safe to run multiple times**:
- Check for existing resources before creating
- Skip creation if resources already exist
- Provide clear output about what was created/skipped

## Common Prerequisites

- CI/CD platform CLI tools (gh, etc.)
- API keys/tokens for Claude Code
- Repository access and permissions

## Troubleshooting

If setup scripts fail:
1. Check prerequisites (CLI tools, authentication)
2. Run scripts manually with verbose output
3. Verify repository permissions
4. Check platform-specific documentation
