# Tech Stack

## Core Technologies

### Shell Scripting (Bash)
- **Primary Language:** All installation, compilation, and processing logic written in Bash shell scripts
- **Version:** Compatible with Bash 3.2+ (macOS default) and Bash 4.0+ (Linux)
- **Key Scripts:**
  - `scripts/base-install.sh` - One-time installation to ~/qa-agent-os
  - `scripts/project-install.sh` - Per-project installation and compilation
  - `scripts/project-update.sh` - Update existing installations
  - `scripts/common-functions.sh` - Shared utilities (YAML parsing, Markdown processing, path normalization)
  - `scripts/create-profile.sh` - Custom profile creation utility
- **Rationale:** Shell scripts provide universal compatibility across Unix-based systems, require no external dependencies, and enable direct file system manipulation for knowledge compilation

### YAML (Configuration)
- **Format:** YAML 1.2
- **Configuration File:** `config.yml` at project root
- **Usage:** Central configuration controlling AI agent targeting, installation behavior, profile selection, and feature flags
- **Parsing:** Custom shell-based YAML parser in `common-functions.sh` handling tabs, variable spacing, and quoted values
- **Key Configuration Points:**
  - `claude_code_commands` - Enable/disable Claude Code command installation
  - `use_claude_code_subagents` - Toggle multi-agent vs single-agent mode
  - `standards_as_claude_code_skills` - Control standards injection method
  - `profile` - Select which profile to compile (default, custom, etc.)
- **Rationale:** YAML provides human-readable configuration with hierarchical structure, widely understood format, and no external parser dependencies needed

### Markdown (Knowledge Format)
- **Format:** GitHub Flavored Markdown (GFM)
- **Knowledge Files:** All standards, workflows, commands, and agent definitions stored as .md files
- **Structure:**
  - `profiles/default/standards/` - QA standards and conventions
  - `profiles/default/workflows/` - Multi-step process definitions
  - `profiles/default/commands/` - Discrete command definitions with phase sub-files
  - `profiles/default/agents/` - Subagent role definitions
- **Processing:** Custom phase tag system using `@qa-agent-os/` references for modular composition
- **Compilation:** `common-functions.sh` functions process phase tags, inject standards references, normalize paths
- **Rationale:** Markdown is AI-native format, human-readable for editing, supports hierarchical structure, and requires no parsing complexity for AI consumption

## AI Agent Integrations

### Claude Code (Primary Target)
- **Platform:** Anthropic's Claude Code (claude.ai/code)
- **Command System:** Custom commands installed to `.claude/commands/qa-agent-os/`
- **Command Format:** Markdown files with structured prompts, phase orchestration, and standards references
- **Key Commands:**
  - `/plan-product` - Product mission/spec creation (vision + team ownership map)
  - `/init-feature` - Feature/ticket directory initialization
  - `/create-ticket` - Chains requirement analysis + test case workflows for a ticket
  - `/analise-requirements` - Standalone requirement-analysis workflow (also used inside `/create-ticket`)
  - `/generate-testcases` - Standalone test case generation from requirements
  - `/improve-skills` - Claude Code skills enhancement
- **Subagent Support:** Optional multi-agent setup with agents installed to `.claude/agents/qa-agent-os/`
- **Subagent Roles:**
  - product-planner.md - Product planning specialist
  - requirement-analyst.md - BRD/requirement analysis expert
  - testcase-writer.md - Test case generation specialist
  - bug-writer.md - Bug reporting specialist
  - evidence-summarizer.md - Log/evidence analysis expert
  - feature-initializer.md - Feature setup specialist
  - integration-actions.md - External tool integration handler
- **Skills System:** Experimental support for Claude Code Skills as alternative standards delivery method
- **Rationale:** Claude Code provides native command and subagent systems, high-quality AI reasoning for complex QA tasks, and active development/support from Anthropic

### Cursor (Future Support)
- **Platform:** Cursor IDE (cursor.sh)
- **Installation Target:** `.cursor/` directory (planned)
- **Status:** Architecture designed for extension, not yet implemented
- **Rationale:** Cursor is popular AI-powered IDE with growing user base and command system

### Windsurf (Future Support)
- **Platform:** Windsurf AI coding assistant
- **Status:** Architecture designed for extension, not yet implemented
- **Rationale:** Multi-tool support provides user choice and reduces vendor lock-in

## System Architecture

### Component 1: Engine (Processing Logic)
- **Location:** `scripts/` directory
- **Function:** Reads configuration, processes knowledge files, compiles final outputs
- **Key Patterns:**
  - Configuration-driven behavior via YAML
  - Modular function library in common-functions.sh
  - Idempotent installation (safe to re-run)
  - Profile-based knowledge loading
- **Data Flow:** config.yml → profile selection → Markdown processing → compiled output
- **Error Handling:** Validation checks, dependency verification, rollback-safe operations

### Component 2: Configuration Layer
- **Location:** `config.yml` at project root
- **Function:** Central control panel defining system behavior
- **Capabilities:**
  - AI agent targeting (which tools to support)
  - Installation mode selection (commands, subagents, skills)
  - Profile selection and customization
  - Feature flag management
- **Extensibility:** New flags can be added without breaking existing installations

### Component 3: Knowledge & Personality Core
- **Location:** `profiles/` directory with profile subdirectories
- **Default Profile:** `profiles/default/` containing standard QA knowledge
- **Structure:**
  - `standards/` - Foundational QA rules (bugs/, testcases/, requirement-analysis/, testing/, global/)
  - `workflows/` - Multi-step processes (planning/, testing/, bug-tracking/, implementation/)
  - `commands/` - Executable commands with single-agent/ and multi-agent/ variants
  - `agents/` - Subagent role definitions for multi-agent setups
- **Customization:** Users can create custom profiles in `profiles/[name]/` with modified knowledge
- **Compilation:** Engine processes Markdown files, resolves phase tags, injects standards

### Component 4: Installation Output
- **Target:** End-user project directory
- **Generated Structure:**
  - `.claude/commands/qa-agent-os/` - Compiled commands for Claude Code
  - `.claude/agents/qa-agent-os/` - Compiled subagents (if enabled)
  - `qa-agent-os/standards/` - Copied standards for reference
  - `qa-agent-os/product/` - User-created product mission and roadmap
  - `qa-agent-os/features/` - User-created feature specs and test cases
- **Persistence:** Knowledge remains in project after installation for AI context

## File Processing & Compilation

### Phase Tag System
- **Syntax:** `@qa-agent-os/commands/[command-name]/[phase-file].md`
- **Function:** References sub-files within command definitions for modular composition
- **Processing:** `process_phase_tags()` function in common-functions.sh replaces tags with actual file paths
- **Example:** Orchestrator file contains `@qa-agent-os/commands/analise-requirements/1-initialize-feature.md` which gets replaced with full path during compilation
- **Benefits:** Modular command construction, clean source files, reusable phases

### Standards Injection
- **Method 1: File References (Default)**
  - Include path like `@qa-agent-os/standards/bugs/severity-rules.md` in commands
  - AI reads standard from project's qa-agent-os/standards/ directory
  - Keeps command files lightweight
  - Standards can be updated independently
- **Method 2: Direct Embedding (Skills Mode)**
  - Full standard content embedded in command during compilation
  - Used when `standards_as_claude_code_skills: true`
  - Larger command files but self-contained
  - Experimental feature for Claude Code Skills

### Path Normalization
- **Function:** Convert relative profile paths to absolute paths in compiled outputs
- **Processing:** `normalize_paths()` function handles project-specific path resolution
- **Example:** `profiles/default/standards/bugs.md` → `/absolute/path/to/project/qa-agent-os/standards/bugs.md`
- **Benefits:** Ensures AI can locate referenced files regardless of working directory

### YAML Configuration Parsing
- **Implementation:** Pure shell functions in common-functions.sh
- **Capabilities:**
  - Handles tabs and variable spacing in YAML
  - Supports quoted and unquoted values
  - Provides defaults for missing keys
  - No external dependencies (no yq, jq required)
- **Limitations:** Supports flat key-value structure, not complex nested YAML
- **Example:** `get_config_value "claude_code_commands" "true"`

## Dependencies & Requirements

### System Requirements
- **Operating System:** macOS, Linux, or Unix-based systems
- **Shell:** Bash 3.2+ (included in all modern Unix systems)
- **File System:** Standard Unix file system with read/write permissions
- **Network:** Internet connection for base installation (curl download)

### External Dependencies
- **Required:**
  - `curl` - For base installation script download
  - `mkdir`, `cp`, `cat`, `sed` - Standard Unix utilities for file operations
- **Optional:**
  - `git` - For version control integration (not required for core functionality)
  - `gh` (GitHub CLI) - For future GitHub integration features
  - Jira REST API access - For future Jira integration
  - Testmo API access - For future Testmo integration

### AI Assistant Requirements
- **Claude Code:** Active subscription to Claude (claude.ai) with Code feature access
- **Future Tools:** Cursor IDE license, Windsurf license (when supported)

### No External Package Dependencies
- **Philosophy:** Zero npm, pip, gem, or other package manager dependencies
- **Rationale:** Maximum portability, minimal installation friction, reduced dependency conflicts
- **Exception:** Future integrations may require API client libraries (evaluated case-by-case)

## Development & Extensibility

### Adding New Commands
1. Create directory: `profiles/default/commands/[command-name]/single-agent/`
2. Create phase files (if multi-phase): `1-phase.md`, `2-phase.md`, etc.
3. Create orchestrator file: `[command-name].md` with phase tags
4. Run `project-install.sh` to compile and test

### Adding New Standards
1. Create file: `profiles/default/standards/[category]/[standard-name].md`
2. Write standard content in Markdown
3. Reference in commands using path tags or inline content
4. Run `project-install.sh` to copy into project

### Creating Custom Profiles
1. Run `scripts/create-profile.sh [profile-name]`
2. Customize copied standards, workflows, commands
3. Set `profile: [profile-name]` in config.yml
4. Run `project-install.sh` to use custom profile

### Testing & Validation
- **Local Testing:** Create test project directory, run installation, verify outputs
- **Command Testing:** Execute commands in real project context with sample requirements
- **Integration Testing:** Validate phase tag resolution, standards injection, path normalization
- **No Automated Test Suite:** Manual testing currently, opportunity for future test automation

## Version Control & Distribution

### Git-Based Distribution
- **Repository:** GitHub (public or private repos supported)
- **Installation:** Base install via curl from raw GitHub URL
- **Updates:** `project-update.sh` pulls latest changes from installed base
- **Versioning:** `config.yml` contains version field (e.g., version: 2.2.0)

### Profile Versioning
- **Strategy:** Profiles are versioned with parent project
- **Compatibility:** Breaking changes in standards require new major version
- **Migration:** No automated migration, users manually update custom profiles

### Future Distribution Options
- **Package Managers:** Could distribute via Homebrew (macOS/Linux)
- **Docker:** Containerized version for isolated environments
- **Standalone Binaries:** Compiled shell script bundles for offline installation
