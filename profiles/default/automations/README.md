# Agent OS Automations

This directory contains CI/CD automation configurations for Agent OS projects.

## Overview

Agent OS automations enable Claude Code to work seamlessly with your CI/CD platform, providing:

- Automated workflow execution on code events
- State tracking via labels (working-agent, review-agent, errored-agent)
- Integration with Agent OS commands and workflows
- Platform-agnostic design supporting multiple CI/CD systems

## Supported Platforms

### GitHub Actions (Primary)

- **Claude Code**: `.github/workflows/claude.yml` - Official Claude Code action for @claude mentions
- **PR Review**: `.github/workflows/claude-review.yml` - Automated PR reviews with inline comments
- **Setup**: See `setup/github.md` for detailed instructions

Agent OS patterns can be recognized by Claude via natural language requests in issues and PRs.

## Critical Setup Requirements

### Version Control Your .claude/ Directory

**IMPORTANT**: For GitHub Actions to access your custom commands and agents, the `.claude/` directory must be version controlled in your repository.

**What to version control**:
- `.claude/commands/` - Your custom slash commands
- `.claude/agents/` - Your custom agent definitions (multi-agent mode)
- `.claude/CLAUDE.md` - Project-specific instructions (if using)

**Check your .gitignore**:
```bash
# Ensure .claude/ is NOT ignored
# If you see this line, remove it:
# .claude/

# You may want to ignore personal config:
echo ".claude/config.yml" >> .gitignore
```

**Why this matters**:
- GitHub Actions checks out your repository
- Claude receives the checked-out code including `.claude/`
- System prompt tells Claude to look in `.claude/` for patterns
- Without version control, Claude won't see your custom commands/agents

### How Claude Recognizes Patterns

The `claude.yml` workflow includes system instructions telling Claude to:
1. Look in `.claude/commands/` for command patterns
2. Look in `.claude/agents/` for agent definitions
3. Follow the instructions in those files when users mention related patterns

**Example**:
- User: `@claude please implement the feature in spec-123.md`
- Claude checks `.claude/commands/` → finds `implement-spec.md`
- Claude reads and follows the implementation instructions
- Claude executes following the defined workflow

This is **natural language interpretation**, not automatic command execution.

## Architecture

### Workflow Files
Automation files are installed to platform-specific locations:
- GitHub Actions → `.github/workflows/`
- Bitbucket Pipelines → `bitbucket-pipelines.yml`
- GitLab CI → `.gitlab-ci.yml`
- CircleCI → `.circleci/config.yml`

### Setup Scripts
Platform-specific setup scripts (`automations/[platform]/setup.sh`) handle:
- Creating labels/tags
- Validating prerequisites
- Setting up authentication
- Configuring webhooks

Scripts are **idempotent** and can be run multiple times safely.

### Documentation
Setup guides in `agent-os/automations/setup/` provide:
- Platform-specific instructions
- Troubleshooting tips
- Alternative setup methods
- Verification procedures

## Usage

### Triggering Workflows

On GitHub (natural language, Claude interprets based on .claude/ patterns):
```
# In an issue or PR comment:
@claude please create a new specification
@claude implement the feature in spec-1234.md
@claude help me understand this code
```

**Important**: For Claude to recognize your Agent OS patterns, you must:
1. Version control your `.claude/` directory (commands and agents)
2. Use the provided `claude.yml` which includes system instructions
3. Use language that relates to your command/agent names

### Automated PR Reviews

The `claude-review.yml` workflow automatically reviews pull requests:
- Triggers on PR open, synchronize, ready_for_review, reopened
- Provides inline code review comments
- Identifies potential issues and improvements
- Uses the `/review-pr` command

## Installation

Automations are installed automatically when you run:

```bash
~/.agent-os/scripts/project-install.sh
```

You'll be prompted to run setup scripts. Choose "yes" to automatically create labels and configure the platform.

## Manual Setup

To run setup scripts manually:

```bash
# From your project root
PROJECT_ROOT=$(pwd) bash ~/.agent-os/profiles/default/automations/github/setup.sh
```

## Updating Automations

Update automation files:

```bash
~/.agent-os/scripts/project-update.sh --overwrite-automations
```

This will update workflow files and documentation but will NOT overwrite them unless the flag is provided.

## Multi-Platform Support

Projects can use multiple CI/CD platforms simultaneously. For example:
- GitHub Actions for PR automation
- CircleCI for deployment pipelines
- GitLab CI for additional testing

Each platform's files are independent and can be enabled/disabled by including or excluding them from the profile.

## Customization

### Custom Profiles

Create a custom profile that inherits from default:

```yaml
# profiles/my-project/profile-config.yml
inherits_from: default
exclude_inherited_files:
  - automations/bitbucket/*  # Don't include Bitbucket files
```

Then add custom automation files:

```
profiles/my-project/automations/
└── github/workflows/
    └── custom-workflow.yml
```

### Workflow Modifications

To customize workflows:
1. Copy workflow file to your custom profile
2. Modify as needed
3. Reinstall with `--overwrite-automations` flag

## Security

### API Keys
- Store API keys as platform secrets (GitHub Secrets, etc.)
- Never commit API keys to the repository
- Rotate keys periodically

### Permissions
Workflows request minimal permissions:
- `contents: write` - To create commits
- `pull-requests: write` - To comment on PRs
- `issues: write` - To comment on issues
- `id-token: write` - For OIDC authentication

Review and adjust permissions based on your security requirements.

## Troubleshooting

See platform-specific setup guides in `setup/` directory:
- [GitHub Actions Setup](setup/github.md)

Common issues:
- Workflow not triggering → Check permissions and authentication
- Labels not appearing → Run setup script manually
- API key errors → Verify secret is set correctly

## Contributing

To add support for a new platform:
1. Create `automations/newplatform/` directory
2. Add configuration files
3. Create `setup.sh` script
4. Write `setup/newplatform.md` documentation
5. Update main README with platform details
