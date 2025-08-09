# Agent OS Setup Guide

## Overview

This guide helps you properly install and configure Agent OS for your development workflow. Agent OS transforms AI coding agents from confused interns into productive developers by providing structured workflows, standards, and specifications.

## Installation Methods

### Method 1: Global Installation (Recommended)

Install Agent OS globally so it can be used across all your projects:

```bash
# Clone Agent OS to a global location
git clone https://github.com/buildermethods/agent-os ~/.agent-os

# Install dependencies (if using lifecycle management features)
cd ~/.agent-os && npm install
```

### Method 2: Project-Specific Installation

Install Agent OS directly in your project:

```bash
# In your project directory
git clone https://github.com/buildermethods/agent-os .agent-os
cd .agent-os && npm install
```

## Quick Start

### 1. Analyze Your Project

For existing projects, start by analyzing your codebase:

```
@~/.agent-os/instructions/core/analyze-product.md
```

For new projects, use the planning instruction:

```
@~/.agent-os/instructions/core/plan-product.md
```

### 2. Create Your First Spec

Once your project is analyzed, create specifications for features:

```
@~/.agent-os/instructions/core/create-spec.md
```

### 3. Test Lifecycle Management

Test and set up the lifecycle management system:

```
@~/.agent-os/instructions/core/test-lifecycle.md
```

## Available Commands

Agent OS provides several core commands for different workflows:

- `@~/.agent-os/instructions/core/analyze-product.md` - Analyze existing projects
- `@~/.agent-os/instructions/core/plan-product.md` - Plan new projects
- `@~/.agent-os/instructions/core/create-spec.md` - Create feature specifications
- `@~/.agent-os/instructions/core/execute-tasks.md [SPEC_PATH]` - Execute spec tasks
- `@~/.agent-os/instructions/core/test-lifecycle.md` - Test lifecycle management

## Lifecycle Management Commands

If you've installed the lifecycle management features:

```bash
# Test and setup lifecycle management
npm run test:lifecycle

# Generate specs dashboard
npm run dashboard

# Generate global dashboard (from Agent OS directory)
npm run dashboard:global
```

## Project Structure

Agent OS expects your project to have:

```
your-project/
├── .agent-os/
│   ├── specs/           # Feature specifications
│   └── product/         # Product context (optional)
│       ├── mission.md
│       ├── roadmap.md
│       └── tech-stack.md
├── package.json         # With lifecycle scripts (if using)
└── scripts/             # Dashboard generators (if using)
```

## Troubleshooting

### "No such file or directory" Error

If you get an error when running `@~/.agent-os/instructions/...`, ensure:

1. Agent OS is installed in `~/.agent-os`
2. You're using the `@` syntax in an AI chat interface (not terminal)
3. The file path is correct

### Missing Product Directory

If instructions reference `.agent-os/product/` but it doesn't exist:

1. Run `@~/.agent-os/instructions/core/analyze-product.md`
2. Complete the product context gathering step
3. The directory will be created automatically

### Lifecycle Management Not Working

If dashboard generation fails:

1. Ensure `package.json` exists with the lifecycle scripts
2. Run `npm install` in your project directory
3. Run `npm run test:lifecycle` to set up missing components

## Best Practices

1. **Start with Analysis**: Always run `analyze-product.md` for existing projects
2. **Use Specs**: Break down features into specifications before coding
3. **Follow Naming**: Use the recommended folder naming conventions
4. **Update Regularly**: Keep your specs and dashboards up to date
5. **Branch Management**: Create feature branches for each spec implementation

## Support

For issues and questions:
- Check the [GitHub Issues](https://github.com/buildermethods/agent-os/issues)
- Review the existing documentation
- Join the community discussions

## Next Steps

1. Complete the setup for your project
2. Create your first specification
3. Test the lifecycle management features
4. Start building with AI agents!