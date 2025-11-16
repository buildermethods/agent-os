# Agent OS Plugin

Spec-driven agentic development system with structured workflows for product planning, feature specification, and implementation.

## Overview

Agent OS is a Claude Code plugin that transforms AI coding agents into productive developers through structured workflows. It provides commands and skills that guide you through:

1. **Product Planning** - Define mission, roadmap, and tech stack
2. **Specification** - Shape and write comprehensive feature specs
3. **Implementation** - Break specs into tasks and build features

## Installation

### Via Claude Code Plugin System

1. Add the Agent OS marketplace:

    ```bash
    /plugin marketplace add agent-os https://github.com/buildermethods/agent-os
    ```

2. Install the plugin:

    ```bash
    /plugin install agent-os
    ```

3. The plugin will be available in your project with:
   - Commands in `.claude/commands/agent-os/`
   - Skills in `.claude/skills/agent-os/`
   - Agents in `.claude/agents/agent-os/`

## What's Included

### Commands

**`/plan-product`** - Create product mission, roadmap, and tech stack

- Guides through 4-phase planning process
- Creates structured product documentation
- Establishes technical foundation

**`/shape-spec`** - Gather requirements for feature specification

- Interactive requirements gathering
- Visual design analysis
- Existing code identification

**`/write-spec`** - Write comprehensive feature specification

- Architecture-informed spec creation
- Leverages existing codebase patterns
- Visual design integration

**`/create-tasks`** - Create actionable tasks breakdown from spec

- Transforms specifications into task groups
- Orders tasks by dependencies
- Includes focused testing approach
- Groups by specialization (database, API, UI)

**`/implement-task`** - Implement a single task group with multi-agent workflow

- 7-phase guided implementation workflow
- Parallel codebase exploration with code-explorer agents
- Multiple architecture approaches with code-architect agents
- Quality review with code-reviewer agents
- Automated testing and verification reports

### Skills

Skills are automatically invoked by Claude when relevant to your request:

**`product-planning`** - Systematic product planning workflow

- Activated when planning products or features
- Creates mission, roadmap, tech stack documents
- Ensures strategic alignment

**`spec-creation`** - Structured specification workflow

- Activated when creating feature specs
- Two-phase: shaping (gathering) and writing (documenting)
- Reusability-focused with architecture design

**`task-breakdown`** - Task list creation from specs

- Activated when creating task lists or implementation plans
- Breaks specs into grouped, ordered tasks
- Strategic dependency management
- Focused testing approach

### Agents

Specialized subagents for complex workflows:

**`code-explorer`** - Deep codebase analysis

- Finds reusable components and patterns
- Analyzes similar existing features
- Provides integration guidance

**`code-architect`** - Architecture design

- Designs feature architecture
- Creates component design and data flow
- Provides implementation blueprint

**`code-reviewer`** - Code quality review

- Reviews code for bugs and logic errors
- Checks adherence to project conventions
- Identifies security vulnerabilities
- Validates code quality and best practices

## Quick Start

### 1. Plan Your Product

```bash
/plan-product
```

This creates:

- `agent-os/product/mission.md` - Product definition and strategy
- `agent-os/product/roadmap.md` - Prioritized feature checklist
- `agent-os/product/tech-stack.md` - Technical stack documentation

### 2. Shape a Feature Spec

```bash
/shape-spec
```

This creates:

- `agent-os/specs/YYYY-MM-DD-feature-name/planning/requirements.md`
- Gathers requirements through targeted questions
- Analyzes visual mockups if provided
- Identifies existing code to reuse

### 3. Write the Spec

```bash
/write-spec
```

This creates:

- `agent-os/specs/YYYY-MM-DD-feature-name/spec.md`
- Uses code-explorer agents to find reusable code
- Uses code-architect agent for architecture design
- Integrates findings into comprehensive spec

### 4. Create Task Breakdown

```bash
/create-tasks
```

This creates:

- `agent-os/specs/YYYY-MM-DD-feature-name/tasks.md`
- Breaks spec into strategic task groups
- Orders tasks by dependencies
- Includes focused testing approach

### 5. Implement Task Groups

Use the `/implement-task` command for a guided, multi-agent implementation workflow:

```bash
/implement-task
```

This orchestrates a 7-phase workflow:

1. **Discovery** - Select which task group to implement
2. **Codebase Exploration** - Parallel code-explorer agents find patterns
3. **Read Files** - Deep dive into relevant code
4. **Architecture Design** - Parallel code-architect agents design approaches
5. **Implementation** - Build following chosen architecture
6. **Quality Review** - Parallel code-reviewer agents verify quality
7. **Verification** - Run tests and create reports

Creates:

- `agent-os/specs/[spec-name]/implementation/[task-group].md` - Implementation report
- `agent-os/specs/[spec-name]/verification/[task-group]-verification.md` - Verification report
- Updates `tasks.md` with completed checkboxes

## Core Concepts

### Spec-Driven Development

Agent OS follows a specification-driven philosophy:

1. **Planning Phase** → Define product mission and roadmap
2. **Specification Phase** → Shape requirements and write detailed specs
3. **Implementation Phase** → Break specs into tasks, implement, verify

Each phase has dedicated workflows, commands, and skills.

### Structured Workflows

Workflows are organized, step-by-step processes:

- **Product Planning**: Gather info → Create mission → Build roadmap → Document tech stack
- **Specification**: Shape requirements → Explore codebase → Design architecture → Write spec
- **Implementation**: Break into tasks → Implement groups → Verify → Update roadmap

### Reusability First

Agent OS emphasizes finding and reusing existing code:

- code-explorer agents search for similar features
- Specifications document existing code to leverage
- Implementation guides reference established patterns
- Minimal new code creation

### Minimal Testing Approach

Focus on critical behaviors, not exhaustive coverage:

- **During development**: 2-8 focused tests per task group
- **Testing phase**: Max 10 additional tests for critical gaps
- **Total per feature**: ~16-34 tests (not hundreds)
- **Execution**: Run only feature tests, not entire suite

## File Structure

Agent OS creates organized documentation:

```markdown
agent-os/
├── product/
│   ├── mission.md              # Product definition
│   ├── roadmap.md              # Feature roadmap
│   └── tech-stack.md           # Tech stack choices
└── specs/
    └── YYYY-MM-DD-feature-name/
        ├── spec.md             # Feature specification
        ├── tasks.md            # Implementation tasks
        ├── planning/
        │   ├── requirements.md # Gathered requirements
        │   └── visuals/        # Design mockups
        ├── implementation/
        │   └── reports.md      # Implementation reports
        └── verification/
            ├── screenshots/    # UI verification
            └── verification-report.md
```

## Best Practices

### Product Planning

- Gather complete information before creating documents
- Align mission, roadmap, and tech stack
- Keep documents concise and scannable
- Focus on user benefits, not technical details

### Specification

- Always ask for visual assets (mockups, wireframes)
- Search for similar existing features to reuse
- Launch code-explorer agents in parallel
- Use code-architect for architecture design
- Keep specs focused and skimmable
- Define explicit out-of-scope items

### Implementation

- Create task breakdown before coding
- Follow test-driven approach (write tests first)
- Implement in logical groups (database → API → frontend)
- Reuse existing patterns and components
- Build only what's specified (no scope creep)
- Verify against spec before marking complete

## Examples

### Example 1: Planning a SaaS Product

```markdown
User: /plan-product

Claude: I'll help you plan your product. Let me gather some information first.

What is the main idea for your product?
> A project management tool for remote teams

What are the key features? (minimum 3)
> 1. Task boards with drag-and-drop
> 2. Real-time collaboration
> 3. Time tracking and reports

Who are your target users?
> Remote teams and project managers at small to medium businesses

Will this use your usual tech stack or deviate?
> Use my usual stack (Next.js, PostgreSQL, Tailwind)

Claude: I have all the info needed. Creating mission document...

✅ Created agent-os/product/mission.md
✅ Created agent-os/product/roadmap.md
✅ Created agent-os/product/tech-stack.md

Your product planning is complete! Next: /shape-spec
```

### Example 2: Creating a Feature Spec

```markdown
User: /shape-spec

Claude: I'll help shape a feature specification. First, let me check the product mission and roadmap.

What feature do you want to specify?
> Task board with drag-and-drop functionality

[Claude asks 6 clarifying questions]
[User provides answers]

Do you have any mockups or wireframes?
> Yes, I'll upload them

Claude: Please upload visual files to:
agent-os/specs/2025-11-16-task-board/planning/visuals/

[User uploads mockups]

Claude: Found 2 mockup files. Analyzing...
✅ Analyzed task-board-desktop.png
✅ Analyzed task-board-mobile.png

✅ Created planning/requirements.md

Ready to write the spec. Run: /write-spec
```

### Example 3: Creating Task Breakdown

```markdown
User: /create-tasks

Claude: I'll create a tasks breakdown from the spec.

Let me check for the spec and requirements files...

✅ Found agent-os/specs/2025-11-16-task-board/spec.md
✅ Found agent-os/specs/2025-11-16-task-board/planning/requirements.md

Analyzing spec and requirements...
Creating strategic task breakdown...

✅ Created agent-os/specs/2025-11-16-task-board/tasks.md

Task groups:
1. Database Layer (Task model, Board model)
2. API Layer (CRUD endpoints, drag-drop handler)
3. Frontend Layer (Board component, drag-drop)
4. Testing (Integration tests for drag-drop flow)
```

### Example 4: Implementing with Multi-Agent Workflow

```markdown
User: /implement-task

Claude: I'll guide you through implementing a task group.

Which task group should we implement?
1. Database Layer (Task model, Board model)
2. API Layer (CRUD endpoints, drag-drop handler)
3. Frontend Layer (Board component, drag-drop)
4. Testing (Integration tests for drag-drop flow)

User: 1

Claude: Phase 1: Discovery
✅ Selected Task Group 1: Database Layer
✅ Created implementation todo list

Phase 2: Codebase Exploration
Launching 3 code-explorer agents in parallel...
→ Explorer 1: Analyzing similar database models
→ Explorer 2: Finding validation patterns
→ Explorer 3: Identifying migration strategies

✅ Found 18 relevant files
✅ Identified key patterns: Prisma models, Zod schemas, migration structure

Phase 3: Reading Identified Files
📖 Reading 18 key files...
✅ Understood existing model patterns
✅ Identified reusable utilities

Phase 4: Architecture Design
Launching 3 code-architect agents in parallel...
→ Architect 1: Minimal changes approach
→ Architect 2: Clean architecture approach
→ Architect 3: Pragmatic balance approach

Recommendation: Pragmatic balance
- Reuses existing Prisma patterns
- Adds proper validation with Zod
- Includes sensible indexes
- Follows migration conventions

Which approach should we use?
User: Pragmatic balance

Claude: Phase 5: Implementation
Ready to implement? This will create:
- Task and Board Prisma models
- Zod validation schemas
- Database migrations

User: Yes

✅ Created models/task.ts
✅ Created models/board.ts
✅ Created validation/schemas.ts
✅ Created migrations/001_add_boards_tasks.sql
✅ Updated tasks.md

Phase 6: Quality Review
Launching 3 code-reviewer agents in parallel...
→ Reviewer 1: Code quality & DRY
→ Reviewer 2: Functional correctness
→ Reviewer 3: Project conventions

✅ No critical issues found
✅ 2 minor suggestions for improvement

Phase 7: Verification
✅ All tasks marked complete
✅ Test suite: 145 passing, 0 failing
✅ Created implementation/database-layer.md
✅ Created verification/database-layer-verification.md

🎉 Implementation Complete!

Remaining tasks: 3 task groups
Would you like to implement another task group?
```

## Advanced Usage

### Custom Standards

Create project-specific standards in:

- `agent-os/standards/global/` - Universal standards
- `agent-os/standards/backend/` - Backend-specific
- `agent-os/standards/frontend/` - Frontend-specific
- `agent-os/standards/testing/` - Testing standards

These guide implementation and ensure consistency.

### Multi-Agent Workflows

Launch multiple agents in parallel for efficiency:

```markdown
User: Write the spec for user authentication

Claude: Launching 3 code-explorer agents in parallel...
[Launches 3 agents simultaneously]

→ Explorer 1: Analyzing existing auth features
→ Explorer 2: Finding reusable form components
→ Explorer 3: Identifying validation patterns

[Waits for all agents to complete]

Now launching code-architect agent...
→ Architect: Designing auth architecture

[Creates spec integrating all findings]
```

### Custom Workflows

Extend Agent OS with your own:

- Commands in `.claude/commands/`
- Skills in `.claude/skills/`
- Agents in `.claude/agents/`

## Troubleshooting

### Command Not Found

If `/plan-product` or other commands don't work:

1. Verify plugin is installed: `/plugin list`
2. Reinstall if needed: `/plugin install agent-os`
3. Check `.claude/commands/agent-os/` exists

### Skill Not Activating

If skills don't activate automatically:

1. Use more specific language: "I want to plan a product" instead of "help me"
2. Invoke directly: "Use the product-planning skill"
3. Check skill descriptions match your request

### Files Not Created

If `agent-os/` directory missing:

1. Create manually: `mkdir -p agent-os/product`
2. Check write permissions
3. Verify you're in project root

## Contributing

Agent OS is open source. Contributions welcome:

1. Fork the repository
2. Create feature branch
3. Make changes
4. Submit pull request

## License

See LICENSE file for details.

## Support

- Documentation: <https://github.com/schalappe/agent-os>
- Issues: <https://github.com/schalappe/agent-os/issues>

---

**Built by**: Brian Casel & Schalappe
**Version**: 3.0.0
**Plugin Type**: Claude Code Plugin
