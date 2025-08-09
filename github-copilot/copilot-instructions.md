# Agent OS for GitHub Copilot

## Purpose

This file directs GitHub Copilot to use Agent OS standards for structured AI-assisted development in this project. These project-specific standards define how development should proceed using Agent OS workflows.

## Project Standards

### Development Standards

- **Tech Stack Guidelines:** @~/.agent-os/standards/tech-stack.md
- **Code Style Preferences:** @~/.agent-os/standards/code-style.md
- **Best Practices Philosophy:** @~/.agent-os/standards/best-practices.md

### Agent OS Instructions

- **Initialize Products:** @~/.agent-os/instructions/plan-product.md
- **Plan Features:** @~/.agent-os/instructions/create-spec.md
- **Execute Tasks:** @~/.agent-os/instructions/execute-tasks.md
- **Analyze Existing Code:** @~/.agent-os/instructions/analyze-product.md

## How These Work Together

1. **Standards** define your universal preferences that apply to all projects
2. **Instructions** guide the agent through Agent OS workflows
3. **Project-specific files** (if present) override these global defaults

## Using Agent OS with GitHub Copilot

Reference the appropriate instruction file based on your current need:

- **Starting a new project:** @.github/instructions/plan-product.instructions.md
- **Working with existing code:** @.github/instructions/analyze-product.instructions.md
- **Planning a new feature:** @.github/instructions/create-spec.instructions.md
- **Building and shipping code:** @.github/instructions/execute-tasks.instructions.md

## Important Notes

- These are YOUR standards - customize them to match your preferences
- Project-specific standards in `.agent-os/product/` override these globals
- Update these files as you discover new patterns and preferences

---

_Using Agent OS for structured AI-assisted development. Learn more at [buildermethods.com/agent-os](https://buildermethods.com/agent-os)_
