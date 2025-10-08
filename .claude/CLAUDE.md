# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Agent OS is a development framework that installs into other projects to provide structured AI-assisted software development workflows. It uses **embedded instructions** directly in commands to ensure Claude Code always has full context.

**Key Innovation**: All command instructions are embedded within command files (~250-636 lines each) to solve reliability issues with external references, achieving near-perfect execution reliability.

## Architecture

### Installation Target Structure
When installed into a project via `./setup/project.sh --claude-code`:

```
Target-Project/
├── .agent-os/              # Agent OS runtime and data
│   ├── standards/          # Development standards
│   ├── state/             # Workflow state and caching
│   │   ├── workflow.json
│   │   ├── session-cache.json (auto-generated)
│   │   └── recovery/      # Automatic state backups
│   ├── specs/             # Feature specifications (created by commands)
│   ├── tasks/             # Task breakdowns (created by commands)
│   ├── product/           # Product planning (created by commands)
│   ├── codebase/          # Code references (created by commands)
│   └── recaps/            # Completion summaries (created by commands)
│
└── .claude/
    ├── commands/          # Claude Code commands with embedded instructions
    │   ├── plan-product.md        (~500 lines)
    │   ├── analyze-product.md     (~400 lines)
    │   ├── create-spec.md         (~550 lines)
    │   ├── create-tasks.md        (~250 lines)
    │   ├── execute-tasks.md       (~636 lines, mega command)
    │   ├── index-codebase.md      (~450 lines)
    │   └── debug.md               (~550 lines)
    │
    └── agents/            # Specialized subagents
        ├── spec-cache-manager.md   # One-time spec discovery
        ├── context-fetcher.md      # Batched context retrieval
        ├── git-workflow.md         # Git operations & PRs
        ├── test-runner.md          # Test execution
        ├── codebase-indexer.md     # Code reference updates
        ├── project-manager.md      # Task/roadmap updates
        ├── file-creator.md         # File creation
        └── date-checker.md         # Date/time utilities
```

### Agent OS Repository Structure
This repository contains the source files that get installed:

```
agent-os/
├── commands/              # Source command files
├── claude-code/agents/    # Source subagent files
├── setup/                # Installation scripts
│   ├── project.sh        # Main installer
│   ├── base.sh
│   └── functions.sh
├── standards/            # Standard development practices
├── examples/             # Example implementations
├── config.yml           # Configuration template
└── SYSTEM-OVERVIEW.md   # Comprehensive system documentation
```

## Command Workflow & Dependencies

### Development Lifecycle Commands

1. **`/plan-product`** - Initialize new product
   - Creates: `.agent-os/product/{mission,vision,roadmap}.md`
   - Dependencies: None (starting point)

2. **`/analyze-product`** - Analyze existing codebase
   - Creates: Same as plan-product but derived from code
   - Dependencies: Existing codebase

3. **`/create-spec`** - Create feature specification
   - Creates: `.agent-os/specs/YYYY-MM-DD-feature-name/{spec,spec-lite,sub-specs/technical-spec}.md`
   - Optional sub-specs: `database-schema.md`, `api-spec.md`, `content-mapping.md`
   - Dependencies: `.agent-os/product/` files

4. **`/create-tasks`** - Generate task breakdown
   - Updates: `.agent-os/tasks/[feature]/tasks.md`
   - Dependencies: `.agent-os/specs/[feature]/`

5. **`/execute-tasks`** - Execute tasks with TDD workflow (mega command)
   - 3 Phases: Discovery → Execution Loop → Delivery
   - Creates: Code, tests, `.agent-os/recaps/`, GitHub PR
   - Updates: Task statuses, codebase references, git branch
   - Dependencies: `.agent-os/{specs,tasks,standards}/`

6. **`/index-codebase`** - Create code reference index
   - Creates: `.agent-os/codebase/{structure,functions,imports,schemas}.md`
   - Dependencies: Source code files

7. **`/debug`** - Unified debugging with workflow integration
   - Context-aware: Task/Spec/General scope
   - Creates: `.agent-os/debugging/[timestamp]-[issue].md`, Git commits/PRs
   - Updates: Codebase references, task statuses

### Subagent Specializations

| Subagent | Purpose | Used By |
|----------|---------|---------|
| spec-cache-manager | One-time spec discovery with caching | execute-tasks |
| context-fetcher | Batched document retrieval + content mapping | All commands |
| git-workflow | Branch management, commits, PRs | execute-tasks, debug |
| test-runner | Test execution and failure analysis | execute-tasks, debug |
| build-checker | Build verification and diagnostics | execute-tasks, debug |
| codebase-indexer | Code reference updates | execute-tasks, index-codebase, debug |
| project-manager | Task/roadmap updates, notifications | execute-tasks, create-spec |
| file-creator | Batch file/directory creation | All commands |
| date-checker | Current date/time information | create-spec, plan-product |

## State Management

### Atomic Operations Pattern
All state operations use atomic writes:
```javascript
// Pattern used throughout commands
writeFileSync(tempFile, data);
renameSync(tempFile, targetFile); // Atomic
```

### Session Cache
- 5-minute expiration with auto-extension (up to 12 extensions = 1 hour)
- Stores: spec cache, context cache, metadata
- Location: `.agent-os/state/session-cache.json`

### Recovery Mechanisms
- Automatic backups in `.agent-os/state/recovery/`
- Keeps last 5 versions
- Auto-restore from most recent valid backup

## Key Design Principles

### Embedded Instructions
- **Self-contained**: Each command has everything it needs
- **Reliable**: No external reference failures (99% vs 60% success rate)
- **Single source**: One file per command with all instructions

### Performance Optimizations
- Specification caching: 2-3s saved per task
- Batched context retrieval: 9-12s saved per task
- Smart test result caching: 15-30s saved per workflow
- **Total**: ~40-50% faster execution

### TDD Workflow
All task execution follows:
1. Write tests first
2. Implement code
3. Verify tests pass
4. Update references
5. Commit with spec compliance

## Installation & Setup

### Install Agent OS into a target project:
```bash
# From agent-os repository
./setup/project.sh --claude-code

# With validation hooks
./setup/project.sh --claude-code --with-hooks
```

### What installation does:
1. Creates `.agent-os/` directory structure
2. Copies command files to `.claude/commands/`
3. Copies subagents to `.claude/agents/`
4. Initializes state management
5. Updates `.gitignore` for cache/state files

## Development Standards

Agent OS uses conditional context loading for standards:
- **Core Principles**: Simplicity, readability, DRY
- **Dependencies**: Choose popular, actively maintained libraries
- **Spec Awareness**: Map code to spec requirements with comments
- **Codebase References**: Check existing functions before creating new ones
- **Content Mapping**: Document external content (images, data files) with exact paths

Standards location: `.agent-os/standards/{best-practices,code-style,codebase-reference,tech-stack}.md`

## Content Mapping Pattern

For features that reference external content (images, data files, documents, media), use `content-mapping.md` to prevent incorrect file paths and ensure proper integration.

### When to Create Content Mapping

Create `.agent-os/specs/[SPEC]/sub-specs/content-mapping.md` when your feature requires:

**Static Content:**
- Images: logos, icons, photos, diagrams
- Media: videos, audio files
- Documents: PDFs, markdown content files

**Data Files:**
- JSON/CSV datasets
- Configuration files
- Seed data or fixtures

**Templates:**
- Email templates
- Content structures
- Marketing copy

### Content Mapping Structure

```markdown
# Content Mapping

## Content Categories

### Images

**Hero Background**
- **Path**: `public/images/hero/main-background.jpg`
- **Type**: JPEG image
- **Reference Name**: `heroBackground`
- **Usage**: Background image for hero section
- **Dimensions**: 1920x1080px

### Data Files

**Product Data**
- **Path**: `data/products.json`
- **Type**: JSON dataset
- **Reference Name**: `productsData`
- **Usage**: Load and display in product listing
- **Schema**: `{ id: number, name: string, price: number }[]`

## Implementation Guidelines

### File Path References
```typescript
import heroBackground from '@/public/images/hero/main-background.jpg'
import productsData from '@/data/products.json'
```

## Content Checklist
- [ ] All content files exist at specified paths
- [ ] References use exact names from this mapping
```

### How Content Mapping is Used

1. **During Spec Creation** (`/create-spec`):
   - Detects if feature references external content
   - Prompts for content details
   - Creates `content-mapping.md` in `sub-specs/`

2. **During Task Execution** (`/execute-tasks`):
   - Auto-loads content mapping in batched context retrieval
   - Creates content reference sheet with exact paths/names
   - Validates paths before writing code

3. **During Debugging** (`/debug`):
   - Checks content mapping when debugging file-related issues
   - Verifies actual paths match content-mapping expectations

### Benefits

- ✅ No guessing file paths or content locations
- ✅ Exact reference names documented before implementation
- ✅ Auto-loading during task execution
- ✅ Clear validation criteria
- ✅ Prevents broken references

See `docs/content-mapping-pattern.md` for detailed documentation.

## Configuration

Config file: `config.yml` (in installed projects: `.agent-os/config.yml`)

Key settings:
```yaml
agent_os_version: 1.4.1
specification_discovery:
  enabled: true
  auto_load_relevant: true
  compliance_checking: true

codebase_indexing:
  enabled: true
  incremental: true  # Only update changed files
  context_aware: true
```

## Testing

No formal test suite exists. Testing is done through:
- Manual execution of commands in test projects
- State validation through hooks
- Test plan documented in `test-codebase-indexing.md`

## Working with This Codebase

### Modifying Commands
1. Edit source in `commands/[command-name].md`
2. All instructions are embedded in the command file
3. Test by running `./setup/project.sh --claude-code` in test project
4. No separate instruction files to update

### Adding New Subagents
1. Create in `claude-code/agents/[agent-name].md`
2. Document purpose and usage in SYSTEM-OVERVIEW.md
3. Reference from commands using Task tool

### State Management Guidelines
- Always use atomic write operations
- Check for cache validity before using
- Handle recovery gracefully
- Document state schema changes

### Command Structure Pattern
All commands follow this structure:
1. Quick Navigation
2. Description & Parameters
3. Dependencies
4. Task Tracking (TodoWrite examples)
5. For Claude Code (meta instructions)
6. Core Instructions (embedded)
7. State Management
8. Error Handling
9. Subagent Integration

## File Size Metrics
- Command files: 250-636 lines (with embedded instructions)
- Subagent files: ~1,700-7,800 characters
- Total commands: 7
- Total subagents: 8

## References

- Comprehensive docs: `SYSTEM-OVERVIEW.md` (489 lines)
- Official site: https://buildermethods.com/agent-os
- Changelog: `CHANGELOG.md`
- Example implementations: `examples/codebase/`
