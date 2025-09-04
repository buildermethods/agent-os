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
3. Use Task tool to invoke file-creator subagent as specified
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

### Step 1: Create tasks.md

Use the file-creator subagent to create file: tasks.md inside of the current feature's spec folder.

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
  - First subtask: typically write tests
  - Last subtask: verify all tests pass

**Task Template:**
```markdown
## Tasks

- [ ] 1. [MAJOR_TASK_DESCRIPTION]
  - [ ] 1.1 Write tests for [COMPONENT]
  - [ ] 1.2 [IMPLEMENTATION_STEP]
  - [ ] 1.3 [IMPLEMENTATION_STEP]
  - [ ] 1.4 Verify all tests pass

- [ ] 2. [MAJOR_TASK_DESCRIPTION]
  - [ ] 2.1 Write tests for [COMPONENT]
  - [ ] 2.2 [IMPLEMENTATION_STEP]
```

**Ordering Principles:**
- Consider technical dependencies
- Follow TDD approach
- Group related functionality
- Build incrementally

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

### State Operations
All task creation uses simple file operations with validation:

```javascript
// Validate spec folder exists
const specFolder = validateSpecFolder(specFolderPath);
if (!specFolder) {
  throw new Error(`Specification folder not found: ${specFolderPath}`);
}

// Read specification documents
const specFiles = {
  main: readFile(`${specFolder}/spec.md`),
  technical: readFile(`${specFolder}/sub-specs/technical-spec.md`),
  database: readFileIfExists(`${specFolder}/sub-specs/database-schema.md`),
  api: readFileIfExists(`${specFolder}/sub-specs/api-spec.md`)
};

// Check for existing tasks.md
const tasksFile = `${specFolder}/tasks.md`;
if (fileExists(tasksFile)) {
  const overwrite = promptOverwrite();
  if (!overwrite) return;
}

// Track task creation state
const taskState = {
  spec_folder: specFolder,
  generated_tasks: [],
  codebase_references: codebaseAware ? loadCodebaseReferences() : null,
  complexity_estimates: {}
};
```

### Codebase Reference Integration
- Conditionally load codebase references based on availability
- Use function signatures for task complexity estimation
- Identify reusable components and integration points
- Adjust task breakdown based on existing implementations

---

## SECTION: Error Handling

### Error Recovery Procedures

1. **Specification Reading Failures**:
   - Validate all required spec files exist
   - Prompt for missing specifications
   - Continue with available documentation
   - Note missing context in task breakdown

2. **Task Generation Failures**:
   - Fall back to basic task template structure
   - Allow manual task entry and refinement
   - Preserve any successfully generated tasks
   - Provide clear editing instructions

3. **Codebase Reference Failures**:
   - Continue without codebase integration
   - Use standard task complexity estimates
   - Log codebase analysis errors for debugging
   - Proceed with greenfield development approach

4. **File Creation Conflicts**:
   - Prompt for overwrite confirmation
   - Backup existing tasks.md if present
   - Allow side-by-side comparison
   - Preserve user customizations where possible

5. **User Confirmation Timeout**:
   - Save generated tasks.md for later review
   - Provide clear resumption instructions
   - Allow partial execution of individual tasks
   - Maintain task completion tracking

## Subagent Integration
When the instructions mention agents, use the Task tool to invoke these subagents:
- `file-creator` for creating the tasks.md file with proper formatting and structure