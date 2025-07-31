# Agent OS for GitHub Copilot

This project uses **Agent OS** - a structured workflow system for AI-driven development. Agent OS transforms AI coding agents from confused interns into productive developers through spec-driven development with clear standards and workflows.

## How Agent OS Works

Agent OS provides four core workflows for systematic development:

1. **Plan Product** (`@.github/instructions/plan-product.instruction.md`) - Define product vision and roadmap
2. **Analyze Product** (`@.github/instructions/analyze-product.instruction.md`) - Understand existing codebase structure  
3. **Create Spec** (`@.github/instructions/create-spec.instruction.md`) - Write detailed feature specifications
4. **Execute Tasks** (`@.github/instructions/execute-tasks.instruction.md`) - Implement features with task breakdowns

## Project Context

When working on this project, always:

- **Follow the spec-driven approach**: Create detailed specs before coding
- **Reference existing standards**: Check `~/.agent-os/standards/` for coding practices
- **Break down work into tasks**: Use clear, atomic tasks in specifications
- **Test thoroughly**: Ensure all tests pass before completing features
- **Document decisions**: Update specs and roadmaps as you learn

## Coding Standards

This project follows Agent OS standards for:

- **Code Style**: Clean, readable, maintainable code
- **Testing**: Comprehensive test coverage for all features
- **Git Workflow**: Feature branches, descriptive commits, pull requests
- **Documentation**: Clear specs, comments, and README updates

## Getting Started with Agent OS

If this is your first time with Agent OS:

1. **New projects**: Start with `@.github/instructions/plan-product.instruction.md`
2. **Existing projects**: Begin with `@.github/instructions/analyze-product.instruction.md`
3. **New features**: Use `@.github/instructions/create-spec.instruction.md`
4. **Implementation**: Execute with `@.github/instructions/execute-tasks.instruction.md`

## Agent OS Resources

- **Documentation**: https://buildermethods.com/agent-os
- **Base Installation**: Ensure `~/.agent-os/` is installed with standards and instructions
- **Community**: Join other developers using Agent OS for systematic AI development

---

When GitHub Copilot suggests code, ensure it aligns with:
- The current spec requirements
- Agent OS coding standards  
- Existing project patterns
- Test coverage expectations

Always reference the appropriate instruction files for guidance on the current workflow phase.
