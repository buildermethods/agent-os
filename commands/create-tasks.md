# Create Tasks

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
Create a tasks list with sub-tasks to execute a feature based on its spec. This command analyzes an approved specification and generates an actionable task breakdown with proper sequencing and dependency management.

## Parameters
- `spec_folder_path` (required): Path to the approved specification folder
- `codebase_aware` (optional): Enable codebase reference integration for task complexity estimation

## Dependencies
**Required State Files:**
- `.agent-os/specs/[spec-folder]/spec.md` (read for task generation)
- `.agent-os/specs/[spec-folder]/sub-specs/technical-spec.md` (read for technical details)
- `.agent-os/codebase/` (conditional - for task complexity estimation)

**Expected Directories:**
- `.agent-os/specs/[spec-folder]/` (specification folder)
- `.agent-os/standards/` (coding standards)

**Creates Files:**
- `.agent-os/specs/[spec-folder]/tasks.md` (task breakdown)

## Task Tracking
**IMPORTANT: Use Claude's TodoWrite tool throughout execution:**
```javascript
// Example todos for this command workflow
const todos = [
  { content: "Read and analyze specification documents", status: "pending", activeForm: "Reading and analyzing specification documents" },
  { content: "Analyze codebase references if available", status: "pending", activeForm: "Analyzing codebase references if available" },
  { content: "Generate task breakdown structure", status: "pending", activeForm: "Generating task breakdown structure" },
  { content: "Create tasks.md file", status: "pending", activeForm: "Creating tasks.md file" },
  { content: "Present first task summary", status: "pending", activeForm: "Presenting first task summary" },
  { content: "Request execution confirmation", status: "pending", activeForm: "Requesting execution confirmation" }
];
// Update status to "in_progress" when starting each task
// Mark as "completed" immediately after finishing
```

## For Claude Code
When executing this command:
1. **Initialize TodoWrite** with the workflow steps above for visibility
2. Read specification documents from the provided spec folder
3. Use Write tool to create files as specified
4. Handle codebase reference integration conditionally
5. **Update TodoWrite** status throughout execution
6. Present clear execution readiness check

---

## SECTION: Core Instructions
<!-- BEGIN EMBEDDED CONTENT -->

# Spec Creation Rules

## Overview

With the user's approval, proceed to creating a tasks list based on the current feature spec.

## Process Flow

### Step 1: Create tasks.md (writing-plans + tdd skills)

Use the writing-plans skill to create detailed micro-tasks and the tdd skill to enforce test-first structure.

**Core Principle:** DOCUMENT EVERYTHING THE EXECUTOR NEEDS TO KNOW

**Writing Plans Approach:**
```
ACTION: writing-plans skill structures task breakdown
WORKFLOW:
  1. Break down hierarchically: Feature → Components → Tasks → Subtasks
  2. Each subtask should be 2-5 minutes of focused work
  3. Include exact file paths and complete code examples
  4. Follow TDD structure for each task
```

**TDD Task Structure (tdd skill):**
```
FOR each behavior/component:
  1. Write failing test for [behavior]
  2. Verify test fails (RED)
  3. Implement minimal code (GREEN)
  4. Verify test passes
  5. Commit
```

Create the file: tasks.md inside of the current feature's spec folder using the Write tool.

**File Template:**
```markdown
# Spec Tasks
```

**Task Structure:**
- **Major Tasks**:
  - Count: 1-5
  - Format: numbered checklist
  - Grouping: by feature or component
- **Subtasks**:
  - Count: up to 8 per major task
  - Format: decimal notation (1.1, 1.2)
  - First subtask: write tests (TDD RED phase)
  - Implementation subtask: minimal code (TDD GREEN phase)
  - Last subtask: verify all tests pass

**Task Template:**
```markdown
## Tasks

- [ ] 1. [MAJOR_TASK_DESCRIPTION]
  - [ ] 1.1 Write failing tests for [COMPONENT] (TDD RED)
  - [ ] 1.2 Verify tests fail as expected
  - [ ] 1.3 Implement [COMPONENT] (TDD GREEN)
  - [ ] 1.4 Verify all tests pass
  - [ ] 1.5 Commit changes

- [ ] 2. [MAJOR_TASK_DESCRIPTION]
  - [ ] 2.1 Write failing tests for [COMPONENT] (TDD RED)
  - [ ] 2.2 Implement [COMPONENT] (TDD GREEN)
```

**Ordering Principles:**
- Consider technical dependencies
- **Enforce TDD approach** (test before implementation)
- Group related functionality
- Build incrementally
- Micro-tasks (2-5 min each)

**Codebase Reference Integration:**

**Conditional Analysis:**
```
IF .agent-os/codebase/ exists:
  ANALYZE: Existing function signatures and patterns relevant to spec requirements
  IDENTIFY: Reusable components and established integration points
  ESTIMATE: Task complexity based on existing implementations vs new development
  REFERENCE: Existing functions that can be extended or integrated
ELSE:
  PROCEED: With standard task breakdown for greenfield development
```

**Task Enhancement:**
- Reference existing functions in implementation steps
- Adjust complexity estimates based on code reuse opportunities
- Include integration tasks for existing components
- Consider refactoring needs for legacy code integration

### Step 2: Execution Readiness Check

Evaluate readiness to begin implementation by presenting the first task summary and requesting user confirmation to proceed.

**Readiness Summary:**
- **Present to User**:
  - Spec name and description
  - First task summary from tasks.md
  - Estimated complexity/scope
  - Key deliverables for task 1

**Execution Prompt:**
```
PROMPT: "The spec planning is complete. The first task is:

**Task 1:** [FIRST_TASK_TITLE]
[BRIEF_DESCRIPTION_OF_TASK_1_AND_SUBTASKS]

Would you like me to proceed with implementing Task 1? I will focus only on this first task and its subtasks unless you specify otherwise.

Type 'yes' to proceed with Task 1, or let me know if you'd like to review or modify the plan first."
```

**Execution Flow:**
```
IF user_confirms_yes:
  REFERENCE: @.agent-os/instructions/core/execute-tasks.md
  FOCUS: Only Task 1 and its subtasks
  CONSTRAINT: Do not proceed to additional tasks without explicit user request
ELSE:
  WAIT: For user clarification or modifications
```

<!-- END EMBEDDED CONTENT -->

---

## SECTION: State Management

Use patterns from @shared/state-patterns.md for file operations.

**Create-tasks specific:** Validate spec folder exists, read spec documents, check for existing tasks.md before overwriting.

---

## SECTION: Error Handling

See @shared/error-recovery.md for general recovery procedures.

### Create-tasks Specific Error Handling

| Error | Recovery |
|-------|----------|
| Spec folder not found | Verify path, run create-spec first |
| Spec reading failure | Continue with available docs, note gaps in breakdown |
| Task generation failure | Fall back to basic template, allow manual entry |
| Codebase reference failure | Continue without, use standard complexity estimates |
| File creation conflict | Prompt overwrite, backup existing tasks.md |

## File Creation
Use the native Write tool for creating the tasks.md file with proper formatting and structure.