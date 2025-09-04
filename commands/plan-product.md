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

Use the context-fetcher subagent to collect all required inputs from the user including main idea, key features (minimum 3), target users (minimum 1), and tech stack preferences with blocking validation before proceeding.

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

### Step 2: Create Documentation Structure

Use the file-creator subagent to create the following file_structure with validation for write permissions and protection against overwriting existing files:

**File Structure:**
```
.agent-os/
└── product/
    ├── mission.md          # Product vision and purpose
    ├── mission-lite.md     # Condensed mission for AI context
    ├── tech-stack.md       # Technical architecture
    └── roadmap.md          # Development phases
```

### Step 3: Create mission.md

Use the file-creator subagent to create the file: .agent-os/product/mission.md and use the following template:

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

### Step 4: Create tech-stack.md

Use the file-creator subagent to create the file: .agent-os/product/tech-stack.md and use the following template:

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
    USE: @agent:context-fetcher
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

### Step 5: Create mission-lite.md

Use the file-creator subagent to create the file: .agent-os/product/mission-lite.md for the purpose of establishing a condensed mission for efficient AI context usage.

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

### Step 6: Create roadmap.md

Use the file-creator subagent to create the following file: .agent-os/product/roadmap.md using the following template:

**File Template:**
```markdown
# Product Roadmap
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

### State Operations
All product planning uses basic file operations with overwrite protection:

```javascript
// Check for existing Agent OS installation
const agentOSExists = checkDirectory('.agent-os');
if (agentOSExists) {
  const productExists = checkDirectory('.agent-os/product');
  if (productExists) {
    // Prompt for overwrite confirmation
    const confirmed = promptOverwrite();
    if (!confirmed) return;
  }
}

// Create directory structure
createDirectory('.agent-os');
createDirectory('.agent-os/product');

// Track creation progress
const productState = {
  directories_created: ['.agent-os', '.agent-os/product'],
  files_created: [],
  user_inputs: {
    product_concept: productConcept,
    key_features: keyFeatures,
    target_users: targetUsers,
    tech_stack: techStackPreferences
  }
};
```

### Input Validation and Storage
- Validate minimum required inputs before proceeding
- Store user inputs for reference during document generation
- Track file creation sequence for rollback capability
- Maintain input validation state for error recovery

---

## SECTION: Error Handling

### Error Recovery Procedures

1. **Input Validation Failures**:
   - Prompt for missing required inputs
   - Allow partial input completion
   - Save valid inputs for retry
   - Provide clear input format examples

2. **Directory Creation Failures**:
   - Check write permissions in current directory
   - Suggest alternative locations if needed
   - Roll back any partially created structure
   - Report specific permission issues

3. **File Creation Conflicts**:
   - Detect existing Agent OS installations
   - Prompt for merge vs overwrite options
   - Backup existing files before overwrite
   - Allow selective file replacement

4. **Template Generation Errors**:
   - Fall back to minimal template structure
   - Allow manual content completion
   - Preserve successfully generated sections
   - Continue with remaining documents

5. **Tech Stack Resolution Failures**:
   - Continue with provided tech stack preferences
   - Mark missing items for later completion
   - Provide reasonable defaults where possible
   - Document incomplete tech stack items

## Subagent Integration
When the instructions mention agents, use the Task tool to invoke these subagents:
- `context-fetcher` for gathering user requirements and tech stack defaults
- `file-creator` for creating all product documentation files and directory structure