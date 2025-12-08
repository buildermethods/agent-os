# Plan Product

## Quick Navigation
- [Description](#description)
- [Parameters](#parameters)
- [Dependencies](#dependencies)
- [Task Tracking](#task-tracking)
- [Core Instructions](#core-instructions)
- [State Management](#state-management)
- [Error Handling](#error-handling)
- [Subagent Integration](#subagent-integration)

## Description
Plan a new product and install Agent OS in its codebase. This command creates comprehensive product documentation including mission, technical stack, and development roadmap for AI agent consumption.

## Parameters
- `product_concept` (required): Main idea and description of the product
- `key_features` (required): Array of key features (minimum 3)
- `target_users` (required): Target user segments and use cases (minimum 1)
- `tech_stack_preferences` (optional): Technology stack preferences
- `project_initialized` (required): Boolean - whether the application has been initialized

## Dependencies
**Required State Files:**
- None (this command initializes Agent OS)

**Expected Directories:**
- Current working directory (will create .agent-os structure)

**Creates Directories:**
- `.agent-os/product/` (product documentation)

**Creates Files:**
- `.agent-os/product/mission.md` (comprehensive product mission)
- `.agent-os/product/mission-lite.md` (condensed mission for AI context)
- `.agent-os/product/tech-stack.md` (technical architecture)
- `.agent-os/product/roadmap.md` (development phases)

## Task Tracking
**IMPORTANT: Use Claude's TodoWrite tool throughout execution:**
```javascript
// Example todos for this command workflow
const todos = [
  { content: "Gather and validate user input", status: "pending", activeForm: "Gathering and validating user input" },
  { content: "Get current date for timestamps", status: "pending", activeForm: "Getting current date for timestamps" },
  { content: "Create documentation structure", status: "pending", activeForm: "Creating documentation structure" },
  { content: "Generate comprehensive mission document", status: "pending", activeForm: "Generating comprehensive mission document" },
  { content: "Build technical stack specification", status: "pending", activeForm: "Building technical stack specification" },
  { content: "Create condensed mission summary", status: "pending", activeForm: "Creating condensed mission summary" },
  { content: "Generate development roadmap", status: "pending", activeForm: "Generating development roadmap" },
  { content: "Finalize Agent OS installation", status: "pending", activeForm: "Finalizing Agent OS installation" }
];
// Update status to "in_progress" when starting each task
// Mark as "completed" immediately after finishing
```

## For Claude Code
When executing this command:
1. **Initialize TodoWrite** with the workflow steps above for visibility
2. Validate all required user inputs before proceeding
3. Use Task tool to invoke subagents as specified
4. Handle codebase reference integration if existing code detected
5. **Update TodoWrite** status throughout execution
6. Create complete Agent OS product documentation structure

---

## SECTION: Core Instructions
<!-- BEGIN EMBEDDED CONTENT -->

# Product Planning Rules

## Overview

Generate product docs for new projects: mission, tech-stack and roadmap files for AI agent consumption.

## Process Flow

### Step 1: Gather User Input

Use the Explore agent (native) to collect all required inputs from the user including main idea, key features (minimum 3), target users (minimum 1), and tech stack preferences with blocking validation before proceeding.

**Data Sources:**
- **Primary**: user_direct_input
- **Fallback Sequence**:
  1. @.agent-os/standards/tech-stack.md
  2. @.claude/CLAUDE.md
  3. Cursor User Rules

**Error Template:**
```
Please provide the following missing information:
1. Main idea for the product
2. List of key features (minimum 3)
3. Target users and use cases (minimum 1)
4. Tech stack preferences
5. Has the new application been initialized yet and we're inside the project folder? (yes/no)
```

### Step 2: Get Current Date

Use the current date from the environment context for documentation timestamps.

**Instructions:**
```
ACTION: Get today's date from environment context
NOTE: Claude Code provides "Today's date: YYYY-MM-DD" in every session
STORE: Date for use in roadmap creation date
```

### Step 3: Create Documentation Structure

Create the following directory structure using Bash mkdir:

**Directory Creation:**
```bash
mkdir -p .agent-os/product
```

Create files with validation for write permissions and protection against overwriting existing files:

**File Structure:**
```
.agent-os/
└── product/
    ├── mission.md          # Product vision and purpose
    ├── mission-lite.md     # Condensed mission for AI context
    ├── tech-stack.md       # Technical architecture
    └── roadmap.md          # Development phases
```

### Step 4: Create mission.md

Create the file: .agent-os/product/mission.md using the Write tool with the following template:

**File Template:**
```markdown
# Product Mission
```

**Required Sections:**
- Pitch
- Users
- The Problem
- Differentiators
- Key Features

**Section Templates:**

**Pitch:**
```markdown
## Pitch

[PRODUCT_NAME] is a [PRODUCT_TYPE] that helps [TARGET_USERS] [SOLVE_PROBLEM] by providing [KEY_VALUE_PROPOSITION].
```
- Length: 1-2 sentences
- Style: elevator pitch

**Users:**
```markdown
## Users

### Primary Customers

- [CUSTOMER_SEGMENT_1]: [DESCRIPTION]
- [CUSTOMER_SEGMENT_2]: [DESCRIPTION]

### User Personas

**[USER_TYPE]** ([AGE_RANGE])
- **Role:** [JOB_TITLE]
- **Context:** [BUSINESS_CONTEXT]
- **Pain Points:** [PAIN_POINT_1], [PAIN_POINT_2]
- **Goals:** [GOAL_1], [GOAL_2]
```

**Schema:**
- name: string
- age_range: "XX-XX years old"
- role: string
- context: string
- pain_points: array[string]
- goals: array[string]

**The Problem:**
```markdown
## The Problem

### [PROBLEM_TITLE]

[PROBLEM_DESCRIPTION]. [QUANTIFIABLE_IMPACT].

**Our Solution:** [SOLUTION_DESCRIPTION]
```
- Problems: 2-4
- Description: 1-3 sentences
- Impact: include metrics
- Solution: 1 sentence

**Differentiators:**
```markdown
## Differentiators

### [DIFFERENTIATOR_TITLE]

Unlike [COMPETITOR_OR_ALTERNATIVE], we provide [SPECIFIC_ADVANTAGE]. This results in [MEASURABLE_BENEFIT].
```
- Count: 2-3
- Focus: competitive advantages
- Evidence: required

**Key Features:**
```markdown
## Key Features

### Core Features

- **[FEATURE_NAME]:** [USER_BENEFIT_DESCRIPTION]

### Collaboration Features

- **[FEATURE_NAME]:** [USER_BENEFIT_DESCRIPTION]
```
- Total: 8-10 features
- Grouping: by category
- Description: user-benefit focused

**Codebase Reference Integration:**

**Conditional Check:**
```
IF .agent-os/codebase/ exists AND project has existing code:
  ANALYZE: Existing codebase patterns and architecture decisions
  IDENTIFY: Current technology stack and implementation approaches
  ALIGN: Product mission with established codebase patterns
  INFORM: Key features based on existing functionality
ELSE:
  PROCEED: With standard product planning (greenfield project)
```

**Tech Stack Awareness:**
- Review existing dependencies and frameworks
- Align mission statements with current architecture
- Ensure feature descriptions match existing patterns
- Consider technical constraints from current implementation

### Step 5: Create tech-stack.md

Create the file: .agent-os/product/tech-stack.md using the Write tool with the following template:

**File Template:**
```markdown
# Technical Stack
```

**Required Items:**
- application_framework: string + version
- database_system: string
- javascript_framework: string
- import_strategy: ["importmaps", "node"]
- css_framework: string + version
- ui_component_library: string
- fonts_provider: string
- icon_library: string
- application_hosting: string
- database_hosting: string
- asset_hosting: string
- deployment_solution: string
- code_repository_url: string

**Data Resolution:**
```
IF has_context_fetcher:
  FOR missing tech stack items:
    USE: Explore agent
    REQUEST: "Find [ITEM_NAME] from tech-stack.md"
    PROCESS: Use found defaults
ELSE:
  PROCEED: To manual resolution below

Manual Resolution:
FOR each item in required_items:
  IF not in user_input:
    CHECK:
      1. @.agent-os/standards/tech-stack.md
      2. @.claude/CLAUDE.md
      3. Cursor User Rules
  ELSE:
    add_to_missing_list
```

**Missing Items Template:**
```
Please provide the following technical stack details:
[NUMBERED_LIST_OF_MISSING_ITEMS]

You can respond with the technology choice or "n/a" for each item.
```

### Step 6: Create mission-lite.md

Create the file: .agent-os/product/mission-lite.md using the Write tool. Purpose: condensed mission for efficient AI context usage.

**File Template:**
```markdown
# Product Mission (Lite)
```

**Content Structure:**
- **Elevator Pitch**:
  - Source: Step 3 mission.md pitch section
  - Format: single sentence
- **Value Summary**:
  - Length: 1-3 sentences
  - Includes: value proposition, target users, key differentiator
  - Excludes: secondary users, secondary differentiators

**Content Template:**
```
[ELEVATOR_PITCH_FROM_MISSION_MD]

[1-3_SENTENCES_SUMMARIZING_VALUE_TARGET_USERS_AND_PRIMARY_DIFFERENTIATOR]
```

**Example:**
```
TaskFlow is a project management tool that helps remote teams coordinate work efficiently by providing real-time collaboration and automated workflow tracking.

TaskFlow serves distributed software teams who need seamless task coordination across time zones. Unlike traditional project management tools, TaskFlow automatically syncs with development workflows and provides intelligent task prioritization based on team capacity and dependencies.
```

### Step 7: Create roadmap.md

Create the file: .agent-os/product/roadmap.md using the Write tool with the following template:

**File Template:**
```markdown
# Product Roadmap

Created: [CURRENT_DATE from environment]
```

**Phase Structure:**
- **Phase Count**: 1-3
- **Features per Phase**: 3-7
- **Phase Template**:
```markdown
## Phase [NUMBER]: [NAME]

**Goal:** [PHASE_GOAL]
**Success Criteria:** [MEASURABLE_CRITERIA]

### Features

- [ ] [FEATURE] - [DESCRIPTION] `[EFFORT]`

### Dependencies

- [DEPENDENCY]
```

**Phase Guidelines:**
- Phase 1: Core MVP functionality
- Phase 2: Key differentiators
- Phase 3: Scale and polish
- Phase 4: Advanced features
- Phase 5: Enterprise features

**Effort Scale:**
- XS: 1 day
- S: 2-3 days
- M: 1 week
- L: 2 weeks
- XL: 3+ weeks

<!-- END EMBEDDED CONTENT -->

---

## SECTION: State Management

Use patterns from @shared/state-patterns.md for file operations.

**Plan-product specific:** Check for existing .agent-os installation, prompt before overwriting existing product docs.

---

## SECTION: Error Handling

See @shared/error-recovery.md for general recovery procedures.

### Plan-product Specific Error Handling

| Error | Recovery |
|-------|----------|
| Input validation failure | Prompt for missing inputs, save valid for retry |
| Directory creation failure | Check permissions, roll back partial structure |
| File creation conflict | Detect existing install, prompt merge/overwrite |
| Template generation error | Fall back to minimal template, allow manual completion |
| Tech stack resolution failure | Continue with defaults, mark for later completion |

## Subagent Integration
When the instructions mention agents, use the Task tool to invoke these subagents:
- Use native Explore agent for gathering context and tech stack defaults
