<img width="1200" height="675" alt="Agent OS" src="https://github.com/user-attachments/assets/97ad4491-d199-4b9b-9482-ae710291dfb4" />

## Agents that build the way you would

[Agent OS](https://buildermethods.com/agent-os) helps you shape better specs, keeps agents aligned in a lightweight system that fits how you already build.

Ships as a plugin for **Claude Code**, **OpenAI Codex**, and **pi** from one set of files, and works alongside Cursor, Antigravity, and other AI tools. Any language, any framework.

**Core capabilities:**

- **Discover Standards** — Extract patterns and conventions from your codebase into documented standards
- **Deploy Standards** — Intelligently inject relevant standards based on what you're building
- **Shape Spec** — Create better plans that lead to better builds
- **Index Standards** — Keep your standards organized and discoverable

---

### Install as a plugin

Agent OS installs from a marketplace in all three harnesses. Nothing is copied into your home directory — each one loads the skills and commands from the plugin itself.

**Claude Code**

```
/plugin marketplace add slurpyb/agent-os
/plugin install agent-os@agent-os
```

**OpenAI Codex**

```
/plugin marketplace add slurpyb/agent-os
/plugin install agent-os
```

**pi**

```bash
pi install git:github.com/slurpyb/agent-os
```

Then run `/agent-os:shape-spec`, `/agent-os:discover-standards`, and the rest — or just describe the task and let the agent load the matching skill.

Every harness reads and writes the same `agent-os/` folder in your project, so a spec shaped in one is picked up by the next. Layout, per-harness details, and how to contribute to the workflows are in [docs/plugin.md](docs/plugin.md).

---

### Documentation & Installation

Docs, installation, usage, & best practices 👉 [It's all here](https://buildermethods.com/agent-os)

---

### Follow updates & releases

Read the [changelog](CHANGELOG.md)

[Subscribe to be notified of major new releases of Agent OS](https://buildermethods.com/agent-os)

---

### Created by Brian Casel @ Builder Methods

Created by Brian Casel, the creator of [Builder Methods](https://buildermethods.com), where Brian helps professional software developers and teams build with AI.

Get Brian's free resources on building with AI:
- [Builder Briefing newsletter](https://buildermethods.com)
- [YouTube](https://youtube.com/@briancasel)

Join [Builder Methods Pro](https://buildermethods.com/pro) for official support and connect with our community of AI-first builders:

