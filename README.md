<img width="1280" height="640" alt="agent-os-og" src="https://github.com/user-attachments/assets/f70671a2-66e8-4c80-8998-d4318af55d10" />

## Your system for spec-driven agentic development.

[Agent OS](https://buildermethods.com/agent-os) transforms AI coding agents from confused interns into productive developers. With structured workflows that capture your standards, your stack, and the unique details of your codebase, Agent OS gives your agents the specs they need to ship quality code on the first try—not the fifth.

Use it with:

✅ Claude Code, Cursor, or any other AI coding tool.

✅ New products or established codebases.

✅ Big features, small fixes, or anything in between.

✅ Any language or framework.

---

### Documentation & Installation

Docs, installation, useage, & best practices 👉 [It's all here](https://buildermethods.com/agent-os)

---

### Created by Brian Casel @ Builder Methods

Created by Brian Casel, the creator of [Builder Methods](https://buildermethods.com), where Brian helps professional software developers and teams build with AI.

Get Brian's free resources on building with AI:
- [Builder Briefing newsletter](https://buildermethods.com)
- [YouTube](https://youtube.com/@briancasel)

---

### Fork Enhancements

This fork extends Agent OS with enhanced project type capabilities:

#### Dynamic Project Types
- **Custom Commands**: Each project type can define its own set of commands beyond the defaults
- **Custom Claude Code Agents**: Project types can include specialized agents tailored to specific workflows
- **Flexible Configuration**: New fields in `config.yml` for commands and claude_code_agents paths per project type
- **Automatic Discovery**: Installers dynamically detect and copy all `.md` files from project type directories

#### Example Configuration
```yaml
project_types:
  webapp:
    instructions: ~/.agent-os/project_types/webapp/instructions
    standards: ~/.agent-os/project_types/webapp/standards
    commands: ~/.agent-os/project_types/webapp/commands
    claude_code_agents: ~/.agent-os/project_types/webapp/claude-code/agents
```

#### Benefits
- Create domain-specific workflows (e.g., webapp, mobile, API, data-science project types)
- Add custom agents for specialized tasks without modifying core Agent OS
- Override default commands while maintaining fallback to standard ones
- Seamless integration with existing Agent OS installation process

