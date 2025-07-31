# Agent OS for GitHub Copilot

## Purpose

This file directs GitHub Copilot to use Agent OS standards for structured AI-assisted development in this project. Agent OS transforms AI coding from trial-and-error into systematic, spec-driven workflows.

## Project Standards

### Development Standards

- **Tech Stack Guidelines:** Reference `~/.agent-os/standards/tech-stack.md` for technology defaults
- **Code Style Preferences:** Follow `~/.agent-os/standards/code-style.md` for formatting and structure
- **Best Practices:** Apply principles from `~/.agent-os/standards/best-practices.md`

### Agent OS Instructions

- **Initialize Products:** Use `@.github/instructions/plan-product.instructions.md` for new product setup
- **Plan Features:** Use `@.github/instructions/create-spec.instructions.md` for feature specifications
- **Execute Tasks:** Use `@.github/instructions/execute-tasks.instructions.md` for implementation
- **Analyze Existing Code:** Use `@.github/instructions/analyze-product.instructions.md` for codebase analysis

## How Agent OS Works

Agent OS provides four core workflows for systematic development:

1. **Plan Product** - Define product vision, tech stack, and roadmap for new projects
2. **Analyze Product** - Understand and document existing codebase structure and progress
3. **Create Spec** - Write detailed feature specifications with task breakdowns
4. **Execute Tasks** - Implement features systematically with testing and git workflow

## Using Agent OS with GitHub Copilot

Reference the appropriate instruction file based on your current need:

- **Starting a new project:** `@.github/instructions/plan-product.instructions.md`
- **Working with existing code:** `@.github/instructions/analyze-product.instructions.md`  
- **Planning a new feature:** `@.github/instructions/create-spec.instructions.md`
- **Building and shipping code:** `@.github/instructions/execute-tasks.instructions.md`## Project Context

When generating code or suggestions:

- **Follow the spec-driven approach**: Always create detailed specifications before coding
- **Reference project standards**: Check existing patterns and established practices
- **Break down work systematically**: Use clear, atomic tasks with time estimates
- **Maintain quality**: Ensure comprehensive testing and clean, documented code
- **Update documentation**: Keep specs, roadmaps, and decisions current

## Important Notes

- These standards define how development should proceed in this project
- Agent OS instruction files contain detailed workflows - reference them fully
- Project-specific files in `@.agent-os/product/` contain mission, roadmap, and decisions
- Always follow the established git workflow with feature branches and pull requests

---

_This project uses Agent OS for structured AI-assisted development. Learn more at [buildermethods.com/agent-os](https://buildermethods.com/agent-os)_
