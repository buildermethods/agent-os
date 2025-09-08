# Execute Tasks

## Quick Navigation
- [Description](#description)
- [Parameters](#parameters)
- [Dependencies](#dependencies)
- [Task Tracking](#task-tracking)
- [Core Instructions](#core-instructions)
- [State Management](#state-management)
- [Error Handling](#error-handling)

## Description
Execute one or more tasks from a specification, including all sub-tasks, testing, and completion workflow. This command combines task discovery, execution, and delivery into a single comprehensive workflow.

## Parameters
- `spec_srd_reference` (required): Path to the specification file or folder
- `specific_tasks` (optional): Array of specific task IDs to execute (defaults to next uncompleted task)

## Dependencies
**Required State Files:**
- `.agent-os/state/workflow.json` (read/write)
- `.agent-os/state/session-cache.json` (read/write for cache persistence)

**Expected Directories:**
- `.agent-os/specs/` (specifications)
- `.agent-os/tasks/` (task definitions)
- `.agent-os/standards/` (coding standards)
- `.agent-os/codebase/` (optional - codebase references)

**Creates Directories:**
- `.agent-os/state/recovery/` (state backups)
- `.agent-os/recaps/` (completion summaries)

## Task Tracking
**IMPORTANT: Use Claude's TodoWrite tool throughout execution:**
```javascript
// Example todos for this command workflow
const todos = [
  { content: "Load state and validate cache", status: "pending", activeForm: "Loading state and validating cache" },
  { content: "Identify tasks to execute", status: "pending", activeForm: "Identifying tasks to execute" },
  { content: "Get current date for timestamps", status: "pending", activeForm: "Getting current date for timestamps" },
  { content: "Discover and cache specifications", status: "pending", activeForm: "Discovering and caching specifications" },
  { content: "Gather initial context", status: "pending", activeForm: "Gathering initial context" },
  { content: "Check for development server", status: "pending", activeForm: "Checking for development server" },
  { content: "Setup git branch", status: "pending", activeForm: "Setting up git branch" },
  { content: "Execute assigned tasks", status: "pending", activeForm: "Executing assigned tasks" },
  { content: "Run test suite", status: "pending", activeForm: "Running test suite" },
  { content: "Complete git workflow", status: "pending", activeForm: "Completing git workflow" },
  { content: "Generate documentation", status: "pending", activeForm: "Generating documentation" },
  { content: "Save state and cleanup", status: "pending", activeForm: "Saving state and cleanup" }
];
// Update status to "in_progress" when starting each task
// Mark as "completed" immediately after finishing
```

## For Claude Code
When executing this command:
1. **Initialize TodoWrite** with the workflow steps above for visibility
2. Load any existing state from `.agent-os/state/`
3. Use atomic operations for all state reads/writes
4. Follow the embedded instructions below completely
5. Use Task tool to invoke subagents as specified
6. Persist cache data between task iterations
7. Handle cache auto-extension for long workflows
8. **Update TodoWrite** status throughout execution

---

## SECTION: Core Instructions
<!-- BEGIN EMBEDDED CONTENT -->

# Task Execution Workflow (Combined)

## Phase 1: Task Discovery and Setup

### Step 1: Task Assignment
Identify which tasks to execute from the spec (using spec_srd_reference file path and optional specific_tasks array), defaulting to the next uncompleted parent task if not specified.

**Task Selection Logic:**
- **Explicit**: User specifies exact task(s) to execute
- **Implicit**: Find next uncompleted task in tasks.md

**Instructions:**
1. ACTION: Identify task(s) to execute
2. DEFAULT: Select next uncompleted parent task if not specified
3. CONFIRM: Task selection with user

### Step 2: Get Current Date and Initialize Cache
Use the date-checker subagent to get the current date for timestamps and cache management.

**Instructions:**
```
ACTION: Use date-checker subagent via Task tool
REQUEST: "Determine today's date in YYYY-MM-DD format for 
          workflow timestamps and cache management"
STORE: Date for use in cache metadata and file naming
```

### Step 3: Specification Discovery and Caching
Use the spec-cache-manager subagent to perform comprehensive specification discovery once and cache for entire session.

**Instructions:**
```
ACTION: Use spec-cache-manager subagent via Task tool
REQUEST: "Perform specification discovery for project:
          - Search all specification directories
          - Create lightweight index of spec files
          - Map spec sections to file paths
          - Return cached index for session use"
STORE: Spec index in session-cache.json
NOTE: This happens ONCE for entire task session
```

**Cache Structure:**
```json
{
  "spec_index": {
    "auth-spec.md": {
      "path": ".agent-os/specs/auth/auth-spec.md",
      "sections": ["2.1 Login", "2.2 Logout", "2.3 Session"],
      "last_modified": "timestamp"
    }
  }
}
```

### Step 4: Initial Context Analysis
Use the context-fetcher subagent to gather minimal context for task understanding by loading core documents.

**Instructions:**
```
ACTION: Use context-fetcher subagent via Task tool to:
  - REQUEST: "Get product pitch from mission-lite.md"
  - REQUEST: "Get spec summary from spec-lite.md"
  - REQUEST: "Get technical approach from technical-spec.md"
PROCESS: Returned information
CACHE: In session-cache.json for use across all task iterations
```

**Context Documents:**
- **Essential**: tasks.md for task breakdown
- **Conditional**: mission-lite.md, spec-lite.md, technical-spec.md

### Step 5: Development Server Check
Check for any running development server and ask user permission to shut it down if found to prevent port conflicts.

**Server Check Flow:**
```
IF server_running:
  ASK: "A development server is currently running. Should I shut it down before proceeding? (yes/no)"
  WAIT: For user response
ELSE:
  PROCEED: Immediately to next step
```

### Step 6: Git Branch Management
Use the git-workflow subagent to manage git branches to ensure proper isolation by creating or switching to the appropriate branch for the spec.

**Instructions:**
```
ACTION: Use git-workflow subagent via Task tool
REQUEST: "Check and manage branch for spec: [SPEC_FOLDER]
          - Create branch if needed
          - Switch to correct branch
          - Handle any uncommitted changes"
WAIT: For branch setup completion
```

**Branch Naming:**
- Source: spec folder name
- Format: exclude date prefix
- Example: folder `2025-03-15-password-reset` → branch `password-reset`

## Phase 2: Task Execution Loop

### Step 7: Execute Tasks with Cached Specifications
Execute all assigned parent tasks and their subtasks, continuing until all tasks are complete.

**Execution Flow:**
```
FOR each parent_task assigned in Step 1:
  EXECUTE the following sub-workflow:
    → Step 6.1: Use Cached Specification Index
    → Step 6.2: Task Understanding with Specification Context
    → Step 6.3: Batched Context Retrieval
    → Step 6.4: Approach Design and Specification Validation
    → Step 6.5: Task and Sub-task Execution
    → Step 6.6: Task-Specific Test Verification
    → Step 6.7: Update Codebase References
    → Step 6.8: Task Status Updates
    → Step 6.9: Output Validation Against Specifications
    → Step 6.10: Mark Task Complete
  
  UPDATE: tasks.md status
  SAVE: Cache state with auto-extension
END FOR
```

### Step 7.1: Use Cached Specification Index
Use the specification cache from Step 2 to quickly access relevant specifications without redundant discovery.

**Cache Usage:**
```
IF spec_cache provided from Step 2:
  USE: Cached specification index
  SKIP: File system discovery
  ACCESS: Spec locations from cache
ELSE:
  FALLBACK: Perform specification discovery
  CACHE: Results for subsequent tasks
```

### Step 7.2: Task Understanding with Specification Context
Read and analyze tasks from tasks.md while mapping requirements to discovered specifications.

**Task Analysis:**
1. Read from tasks.md:
   - Parent task description
   - All sub-task descriptions
   - Task dependencies
   - Expected outcomes

2. Specification Mapping:
   - Search for corresponding spec sections
   - Extract relevant constraints and rules
   - Note any requirements without spec coverage
   - Document spec-to-requirement relationships

### Step 7.3: Batched Context Retrieval
Use the context-fetcher subagent to retrieve ALL relevant context in a SINGLE batched request, reducing overhead and improving performance.

**Batched Request:**
```
ACTION: Use context-fetcher subagent via Task tool
REQUEST: "Batch retrieve the following context for task execution:
  
  FROM technical-spec.md:
  - Sections related to [CURRENT_TASK_FUNCTIONALITY]
  - Implementation approach for this feature
  - Integration requirements
  - Performance criteria
  
  FROM @.agent-os/standards/best-practices.md:
  - Best practices for [TASK_TECH_STACK]
  - Patterns for [FEATURE_TYPE]
  - Testing approaches
  - Code organization patterns
  
  FROM @.agent-os/standards/code-style.md:
  - Style rules for [LANGUAGES_IN_TASK]
  - Formatting for [FILE_TYPES]
  - Component patterns
  - Testing style guidelines
  
  FROM .agent-os/codebase/ (if exists and needed):
  - Function signatures in [RELEVANT_MODULES]
  - Import paths for [NEEDED_COMPONENTS]
  - Related schemas if data operations
  
  Return as structured summary with clear section markers"
```

**Optimization Benefits:**
- BEFORE: 4 sequential subagent calls (12-16 seconds)
- AFTER: 1 batched subagent call (3-4 seconds)
- SAVINGS: 9-12 seconds per task

### Step 7.4: Approach Design and Specification Validation
Document implementation approach and validate against specifications BEFORE coding.

**Approach Documentation:**
```markdown
## Implementation Approach

### Specification Alignment
- Relevant specs: [list spec files and sections consulted]
- Key requirements: [extracted from specifications]
- Constraints: [from specs and requirements]

### Implementation Strategy
- Approach: [high-level implementation method]
- Expected inputs: [format, structure, constraints]
- Expected outputs: [format, structure, validation criteria]
- Dependencies: [external systems, libraries, data sources]

### Validation Criteria
- Success metrics: [from specifications]
- Acceptance criteria: [from requirements]
- Error handling: [from specs or best practices]
```

**Pre-Implementation Validation:**
- ✓ Implementation strategy aligns with architectural specs
- ✓ Expected outputs match specification requirements
- ✓ Dependencies and interfaces follow defined contracts
- ✓ Error handling covers specified scenarios
- HALT if approach conflicts with specifications

### Step 7.5: Task and Sub-task Execution with TDD
Execute the parent task and all sub-tasks in order using test-driven development (TDD) approach with specification compliance checks.

**Typical Task Structure:**
1. **First subtask**: Write tests for [feature]
2. **Middle subtasks**: Implementation steps
3. **Final subtask**: Verify all tests pass

**Execution Order:**

**Subtask 1 - Write Tests:**
IF sub-task 1 is "Write tests for [feature]":
- Write tests based on specification requirements
- Include unit tests, integration tests, edge cases from specs
- Add tests for specification compliance
- Run tests to ensure they fail appropriately
- Mark sub-task 1 complete

**Middle Subtasks - Implementation:**
FOR each implementation sub-task (2 through n-1):
- Implement functionality according to specifications
- Reference spec sections in code comments
- Make relevant tests pass
- Validate outputs against spec expectations during development
- Update any adjacent/related tests if needed
- Refactor while keeping tests green
- Mark sub-task complete

**Final Subtask - Verification:**
IF final sub-task is "Verify all tests pass":
- Run entire test suite
- Fix any remaining failures
- Ensure specification compliance tests pass
- Ensure no regressions
- Mark final sub-task complete

### Step 7.6: Task-Specific Test Verification
Use the test-runner subagent to run and verify only the tests specific to this parent task.

**Focused Test Execution:**
```
ACTION: Use test-runner subagent via Task tool
REQUEST: "Run tests for [this parent task's test files]"
CACHE: Results in session-cache.json
VERIFY: 100% pass rate for task-specific tests
```

**Test Result Caching:**
- Cache test results for use in complete-tasks phase
- Store: test files executed, pass/fail status, timestamp
- Benefit: Avoid re-running same tests in complete-tasks

### Step 7.7: Update Codebase References (Conditional)
If any new functions, classes, or exports were created during this task, update the codebase references incrementally.

**Smart Skip Logic:**
```
CHECK: Git diff for actual code changes
IF only test files or documentation changed:
  SKIP: No production code to index
  SAVE: 3-5 seconds
ELSE IF only minor changes (< 5 lines):
  CONSIDER: Skipping if changes don't affect signatures
ELSE:
  ACTION: Use codebase-indexer subagent via Task tool
  REQUEST: "Update codebase references for changed files:
            - Files modified: [LIST_OF_MODIFIED_FILES]
            - Extract new/updated signatures
            - Update functions.md and imports.md
            - Maintain existing unchanged references"
```

### Step 7.8: Task Status Updates
Update task statuses in real-time as work progresses.

**Update Format:**
- **Completed**: `- [x] Task description`
- **Incomplete**: `- [ ] Task description`
- **Blocked**: `- [ ] Task description ⚠️ Blocking issue: [DESCRIPTION]`

### Step 7.9: Output Validation Against Specifications
Validate ALL outputs against specifications before marking tasks complete.

**Validation Checklist:**

**Specification Compliance:**
- ✓ Output format matches specification requirements
- ✓ Data structure follows defined schemas
- ✓ Business rules and constraints properly enforced
- ✓ Interface contracts correctly implemented
- ✓ Error handling covers specified scenarios

**Quality Checks:**
- ✓ Expected functionality delivered
- ✓ Edge cases handled as specified
- ✓ Dependencies work as documented
- ✓ Performance meets specified criteria
- ✓ No specification requirements missed

**Failure Handling:**
IF validation fails:
1. Document specific specification violations
2. Return to appropriate step (design, implementation, or testing)
3. Correct violations and re-validate
4. Do not mark complete until all validations pass

### Step 7.10: Mark Task Complete
ONLY after output validation passes, mark this task and its sub-tasks complete by updating each task checkbox to [x] in tasks.md.

## Phase 3: Task Completion and Delivery

### Step 8: Run All Tests
Use the test-runner subagent to run ALL tests in the application's test suite to ensure no regressions.

**Smart Test Execution:**
```
IF test results cached from Step 6.6 (last 5 minutes):
  CHECK: Cached test status
  IF all tests passed in cache:
    SKIP: Re-running tests
    USE: Cached results
    SAVE: 15-30 seconds
  ELSE:
    RUN: Only previously failed tests
ELSE:
  RUN: Full test suite as normal
```

**Instructions:**
```
ACTION: Check for cached test results first
IF CACHED AND PASSING: Skip test execution
ELSE: Use test-runner subagent via Task tool
REQUEST: "Run the full test suite"
VERIFY: 100% pass rate
FIX: Any failures before proceeding
```

### Step 9: Quick Specification Compliance Check
Verify that specification validation was completed during task execution.

**Smart Skip Logic:**
```
IF execute-task already validated specifications (Step 6.9):
  SKIP: Full validation (already completed)
  VERIFY: No new specification violations reported
  PROCEED: To git workflow
ELSE IF validation was skipped or incomplete:
  PERFORM: Quick compliance check on changed files only
  FOCUS: New functionality added since last validation
```

### Step 10: Git Workflow
Use the git-workflow subagent to create git commit, push to GitHub, and create pull request.

**Instructions:**
```
ACTION: Use git-workflow subagent via Task tool
REQUEST: "Complete git workflow for [SPEC_NAME] feature:
          - Spec: [SPEC_FOLDER_PATH]
          - Changes: All modified files
          - Target: main branch
          - Description: [SUMMARY_OF_IMPLEMENTED_FEATURES]"
SAVE: PR URL for summary
```

### Step 11: Tasks Completion Verification
Use the project-manager subagent to verify all tasks are marked complete or have documented blockers.

**Instructions:**
```
ACTION: Use project-manager subagent via Task tool
REQUEST: "Verify task completion in current spec:
          - Read [SPEC_FOLDER_PATH]/tasks.md
          - Check all tasks are marked complete with [x]
          - Verify any incomplete tasks have documented blockers
          - Mark completed tasks as [x] if verification confirms completion"
```

### Step 12: Roadmap Progress Update (Conditional)
Use the project-manager subagent to update roadmap ONLY IF tasks completed roadmap items.

**Smart Preliminary Check:**
```
QUICK_CHECK: Task names against roadmap keywords
IF no task names match roadmap items:
  SKIP: Entire step immediately
  SAVE: 3-5 seconds
ELSE IF partial match found:
  EVALUATE: Did executed tasks complete any roadmap item(s)?
  IF YES:
    ACTION: Use project-manager subagent via Task tool
    UPDATE: Mark roadmap items complete with [x]
```

### Step 13: Create Documentation and Summary
Use the project-manager subagent to create recap document and completion summary in a single batched request.

**Batched Request:**
```
ACTION: Use project-manager subagent via Task tool
REQUEST: "Complete documentation and summary tasks:
          
          TASK 1 - Create recap document:
          - Create file: .agent-os/recaps/[SPEC_FOLDER_NAME].md
          - Use template format with completed features summary
          - Include context from spec-lite.md
          - Document: [SPEC_FOLDER_PATH]
          
          TASK 2 - Generate completion summary:
          - List what's been done with descriptions
          - Note any issues encountered
          - Include testing instructions if applicable
          - Add PR link from Step 9
          
          Return both outputs in single response"
```

**Recap Template:**
```markdown
# [yyyy-mm-dd] Recap: Feature Name

This recaps what was built for the spec documented at .agent-os/specs/[spec-folder-name]/spec.md.

## Recap
[1 paragraph summary plus short bullet list of what was completed]

## Context
[Copy the summary found in spec-lite.md to provide concise context]
```

### Step 14: Task Completion Notification
Use the project-manager subagent to play a system sound to alert the user that tasks are complete.

**Instructions:**
```
ACTION: Play completion sound
COMMAND: afplay /System/Library/Sounds/Glass.aiff
PURPOSE: Alert user that task is complete
```

<!-- END EMBEDDED CONTENT -->

---

## SECTION: State Management

### State Operations
All state operations use atomic functions to prevent corruption:

```javascript
// Load existing state or create new
const stateFile = '.agent-os/state/workflow.json';
const cacheFile = '.agent-os/state/session-cache.json';

// Initialize state if needed
initializeStateFiles('.agent-os');

// Load with recovery fallback
const workflow = loadState(stateFile, {
  state_version: "1.0.0",
  current_workflow: null
});

// Create session cache for task execution
// Note: [CURRENT_DATE] should be replaced with the date from date-checker agent
// Note: Cache expiration is managed by file modification time, not JavaScript dates
const sessionCache = {
  spec_cache: {},
  context_cache: {},
  metadata: {
    created_date: "[CURRENT_DATE from date-checker]",
    workflow_id: "tasks-[CURRENT_DATE]-[SESSION_NUMBER]",
    access_count: 1,
    auto_extend: true,
    extension_count: 0,
    max_extensions: 12,
    state_version: "1.0.0"
  }
};

// Save cache file with atomic operation
// The file's modification time serves as the expiration mechanism
saveState(cacheFile, sessionCache);

// Check cache validity using file modification time
// Cache expires after 5 minutes since last modification
// Use: ls -la .agent-os/state/session-cache.json to check age
```

### Cache Persistence Between Task Iterations
- Load spec_cache at start of workflow
- Pass cache to each task iteration
- Auto-extend expiration for active workflows
- Save cache state after each task completion
- Clean expired caches after workflow completion

### Lock Management
```javascript
// Acquire lock for critical sections
acquireLock('.agent-os/state/.lock');

try {
  // Perform state modifications
  // ...
} finally {
  // Always release lock
  releaseLock('.agent-os/state/.lock');
}
```

---

## SECTION: Error Handling

### Error Recovery Procedures

1. **State Corruption**:
   - Attempt recovery from `.agent-os/state/recovery/`
   - Use most recent valid backup
   - Reinitialize if no valid backups

2. **Lock Timeout**:
   - Force acquire after 30 seconds with warning
   - Log process that held lock too long
   - Continue with caution

3. **Cache Expiration**:
   - Reload from source specifications if auto-extension fails
   - Rebuild spec_cache and context_cache
   - Continue with fresh cache

4. **Partial Failure**:
   - Save progress to recovery point
   - Document blocking issues in tasks.md
   - Allow resume from last successful step

5. **Subagent Failures**:
   - Retry subagent invocation once
   - Fall back to manual approach if critical
   - Document failure and continue if non-critical

## Subagent Integration
When the instructions mention agents, use the Task tool to invoke these subagents:
- `spec-cache-manager` for specification discovery and caching
- `context-fetcher` for batched context retrieval
- `git-workflow` for branch and commit management
- `test-runner` for test execution
- `codebase-indexer` for code reference updates
- `project-manager` for documentation and notifications