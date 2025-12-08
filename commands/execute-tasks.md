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
  { content: "Verify build (build-check skill auto-invoked)", status: "pending", activeForm: "Verifying build" },
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

## Phase 0: Session Startup (Pre-Flight Check)

### Step 0: Session Startup Protocol
The session-startup skill auto-invokes to verify environment and load cross-session context.

**Instructions:**
```
ACTION: session-startup skill auto-invokes
PURPOSE: Verify environment and establish session context
PROTOCOL:
  1. Directory verification (confirm project root)
  2. Progress context load (read recent progress entries)
  3. Git state review (branch, uncommitted changes)
  4. Task status check (current spec progress)
  5. Environment health (dev server, config files)
  6. Session focus confirmation (confirm task selection)

WAIT: For startup protocol completion
OUTPUT: Session startup summary with suggested task

IF startup fails:
  DISPLAY: Error details and recovery suggestions
  HALT: Do not proceed until environment verified
```

**Benefits:**
- Cross-session context automatically loaded
- Unresolved blockers highlighted before work begins
- Environment issues caught early
- Task selection informed by progress history

**See**: `.claude/skills/session-startup.md` for full protocol details

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

### Step 1.5: Scope Constraint Check
Verify task scope follows best practices for long-running agent sessions.

**Reference**: Anthropic's research suggests focusing on ONE feature per session improves completion rate and code quality.

**Scope Detection:**
```
COUNT: Number of parent tasks selected for this session

IF parent_task_count == 1:
  PROCEED: Single task mode (optimal)

IF parent_task_count > 1:
  DISPLAY:
    "⚠️  Multiple Task Warning
     ─────────────────────────────────────────
     You've selected [count] parent tasks for this session:
     [list task IDs and descriptions]

     Research suggests focusing on ONE task per session:
     • Higher completion rate
     • Better code quality
     • Cleaner context retention

     Recommendation: Start with Task [first_task_id]
     ─────────────────────────────────────────"

  ASK: "How would you like to proceed?"
  OPTIONS:
    1. Single task - Focus on [first_task_id] only (recommended)
    2. All tasks - Execute all [count] tasks this session

  IF user selects option 1 (single task):
    SET: tasks_to_execute = [first_task]
    PROCEED: With single task

  IF user selects option 2 (all tasks):
    LOG: scope_override entry to progress log
    DATA:
      type: "scope_override"
      requested_tasks: [list of task IDs]
      reason: "user_override"
    SET: tasks_to_execute = all_requested_tasks
    PROCEED: With multiple tasks (user chose to override)
```

**Scope Override Logging:**
```
IF user overrides scope constraint:
  ACTION: Append to progress log
  ENTRY_TYPE: scope_override
  DATA:
    description: "User chose to execute multiple parent tasks"
    requested_tasks: [array of task IDs]
    reason: "user_override"
    session_context: "Informed of single-task recommendation"

  PURPOSE: Track scope decisions for analysis
```

### Step 2: Get Current Date and Initialize Cache
Use the current date from the environment context for timestamps and cache management.

**Instructions:**
```
ACTION: Get today's date from environment context
NOTE: Claude Code provides "Today's date: YYYY-MM-DD" in every session
STORE: Date for use in cache metadata and file naming
```

### Step 3: Specification Discovery and Caching
Use the native Explore agent to perform specification discovery.

**Instructions:**
```
ACTION: Use native Explore agent
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
Use the Explore agent (native) to gather minimal context for task understanding by loading core documents.

**Instructions:**
```
ACTION: Use Explore agent (native) via Task tool to:
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

### Step 6.5: Log Session Start (Progress Log)
Log the session start to the persistent progress log for cross-session memory.

**Instructions:**
```
ACTION: Append to progress log
ENTRY_TYPE: session_started
DATA:
  spec: [SPEC_FOLDER_NAME]
  focus_task: [SELECTED_TASK_ID]
  context: [BRIEF_CONTEXT_FROM_PREVIOUS_PROGRESS_OR_TASK_DESCRIPTION]

FILE: .agent-os/progress/progress.json
PATTERN: Use PROGRESS_APPEND_PATTERN from @shared/progress-log.md
```

**Purpose:** Creates cross-session memory so future sessions know what was started and can continue effectively.

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
Use the Explore agent (native) to retrieve ALL relevant context in a SINGLE batched request, reducing overhead and improving performance.

**Codebase Reference Check:**
```
ACTION: Check if .agent-os/codebase/ exists
IF exists:
  MANDATORY: Include codebase references in batched request
  REASON: Prevents incorrect function/variable/component names
ELSE:
  SKIP: Codebase reference section
```

**Content Mapping Check:**
```
ACTION: Check if .agent-os/specs/[SPEC]/sub-specs/content-mapping.md exists
IF exists:
  MANDATORY: Include content mapping in batched request
  REASON: Prevents incorrect file paths and content references
ELSE:
  SKIP: Content mapping section
```

**Batched Request:**
```
ACTION: Use Explore agent (native) via Task tool
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

  FROM .agent-os/codebase/ (REQUIRED if directory exists):
  - Function signatures in modules related to [CURRENT_TASK]
  - Import paths for components/utilities mentioned in task
  - Existing variable/class names in files to be modified
  - Related schemas if data operations involved

  IMPORTANT: For codebase references, return:
  - Exact function names with signatures and line numbers
  - Exact import paths with component names
  - Exact variable/class names with types
  - Format as 'Existing Names Reference' for easy lookup

  FROM .agent-os/specs/[SPEC]/sub-specs/content-mapping.md (REQUIRED if file exists):
  - All content item paths and reference names
  - Implementation guidelines for file references
  - Content types and usage instructions
  - Validation rules

  IMPORTANT: For content mapping, return:
  - Exact file paths relative to project root
  - Exact reference names to use in code
  - Import patterns from implementation guidelines
  - Format as 'Content References' for easy lookup

  Return as structured summary with clear section markers"
```

**Optimization Benefits:**
- BEFORE: 4 sequential subagent calls (12-16 seconds)
- AFTER: 1 batched subagent call (3-4 seconds)
- SAVINGS: 9-12 seconds per task

### Step 7.3.5: Verify Existing Names (MANDATORY Pre-Implementation Gate)
If codebase references were retrieved, create a "reference sheet" of exact names to use BEFORE writing any code.

**Name Verification Protocol:**
```
IF .agent-os/codebase/ exists AND references were retrieved:

  ACTION: Create reference sheet from retrieved context

  EXTRACT AND NOTE:
  1. Function names to call:
     - Exact spelling and casing
     - Expected parameters
     - Return types
     - Line numbers for verification

  2. Components/modules to import:
     - Exact import paths
     - Exact component names
     - Named vs default exports

  3. Variables/classes to reference:
     - Exact names in files being modified
     - Types and interfaces
     - Existing patterns to follow

  4. Schemas/models to use:
     - Table names and column names
     - API endpoint paths
     - Data structure field names

  VALIDATION GATE:
  - ✓ Do NOT guess or approximate names
  - ✓ Do NOT write code until names are verified
  - ✓ If unsure, use Explore agent to search specifically
  - ✓ Create mental checklist or brief comment with correct names
  - HALT if critical names are missing or ambiguous
```

### Step 7.3.6: Verify Content References (MANDATORY if content-mapping exists)
If content-mapping.md exists, create a "content reference sheet" of exact file paths and reference names to use BEFORE writing any code.

**Content Reference Protocol:**
```
IF .agent-os/specs/[SPEC]/sub-specs/content-mapping.md exists:

  ACTION: Create content reference sheet from retrieved mapping

  EXTRACT AND NOTE:
  1. File paths to reference:
     - Exact paths relative to project root
     - File types and formats
     - Dimensions/sizes if applicable

  2. Reference names to use in code:
     - Exact variable/constant names from mapping
     - Import patterns from implementation guidelines
     - Named vs default import style

  3. Content processing requirements:
     - Optimization steps
     - Transformations needed
     - Validation rules

  4. Usage instructions:
     - How to integrate each content item
     - Where content should be used
     - Special handling requirements

  VALIDATION GATE:
  - ✓ Do NOT guess file paths or locations
  - ✓ Do NOT write code until content paths verified
  - ✓ Use exact reference names from content-mapping
  - ✓ Follow import patterns from implementation guidelines
  - HALT if critical content missing or paths ambiguous
```

**Example Content Reference Sheet:**
```markdown
## Content to Use in Implementation

File Paths (from content-mapping.md):
- public/images/hero/main-background.jpg → import as `heroBackground`
- data/products.json → import as `productsData`
- content/marketing/landing-page-copy.md → import as `landingPageCopy`

Import Pattern:
```typescript
import heroBackground from '@/public/images/hero/main-background.jpg'
import productsData from '@/data/products.json'
import { landingPageCopy } from '@/content/marketing'
```

USE THESE EXACT PATHS AND NAMES - DO NOT DEVIATE
```

**Example Reference Sheet:**
```markdown
## Names to Use in Implementation

Functions (from src/auth/utils.js):
- validateUser(email, password): Promise<User> ::line:15
- hashPassword(plaintext): string ::line:42
- generateToken(userId): string ::line:67

Imports:
- import { Button } from '@/components/Button'
- import { useAuth } from '@/hooks/useAuth'
- import { db } from '@/lib/database'

Variables (in src/auth/service.js):
- currentUser: User | null
- authConfig: AuthConfig

USE THESE EXACT NAMES - DO NOT DEVIATE
```

**Missing Name Handling:**
```
IF a needed name is not in retrieved references:
  ACTION: Use Explore agent to search for it specifically
  REQUEST: "Search .agent-os/codebase/functions.md for [specific-function-name]"
  OR: "Find import path for [component-name] in .agent-os/codebase/imports.md"
  WAIT: For confirmation before proceeding
```

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
- ✓ Reference sheet created with exact names from codebase (if applicable)
- ✓ All required function/component/variable names verified
- HALT if approach conflicts with specifications OR critical names are missing

### Step 7.5: Task and Sub-task Execution with TDD (tdd skill)

The tdd skill auto-invokes to enforce test-driven development discipline.

**Core Principle:** NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST

**TDD Workflow (tdd skill):**
```
ACTION: tdd skill auto-invokes before implementation
CYCLE:
  1. RED:    Write failing test for desired behavior
  2. GREEN:  Write minimal code to pass test
  3. REFACTOR: Clean up while tests stay green
  4. COMMIT: After each passing test
```

### Step 7.5.1: TDD Skill Invocation Gate (MANDATORY)

**VALIDATION CHECKPOINT - Verify TDD skill was properly invoked:**

```
GATE CHECK: Before proceeding past implementation
─────────────────────────────────────────────────
VERIFY each of the following exists in this task's execution:

☐ RED Phase Evidence:
  - A test file was created/modified BEFORE production code
  - Test was executed and FAILED (expected failure)
  - Failure reason documented (e.g., "function does not exist")

☐ GREEN Phase Evidence:
  - Production code was written AFTER failing test
  - Test was re-executed and PASSED
  - Implementation is minimal (only what's needed to pass)

☐ REFACTOR Phase Evidence:
  - Code cleanup occurred (if applicable)
  - Tests remained GREEN during refactor
  - No new functionality added during refactor

VALIDATION:
  IF all checkboxes verified:
    ✓ TDD skill properly invoked - PROCEED
  ELSE IF missing RED phase:
    ✗ HALT - Delete any production code written without failing test
    ACTION: Return to Step 7.5, invoke tdd skill explicitly
  ELSE IF missing evidence:
    ⚠ WARNING - Document deviation and reason
    ASK: "TDD cycle appears incomplete. Continue anyway? (yes/no)"
─────────────────────────────────────────────────
```

**TDD Gate Failure Recovery:**
```
IF TDD gate fails:
  1. IDENTIFY: What was skipped (RED/GREEN/REFACTOR)
  2. DOCUMENT: Why it was skipped (if intentional)
  3. REMEDIATE:
     - If code exists without test: Write test first, verify it fails
       with current code commented out, then uncomment
     - If test never failed: Verify test actually tests the new behavior
  4. RE-VERIFY: Run gate check again
```

**Typical Task Structure:**
1. **First subtask**: Write tests for [feature] (RED phase)
2. **Middle subtasks**: Implementation steps (GREEN phase)
3. **Final subtask**: Verify all tests pass

**TodoWrite Example for Each Task:**
```javascript
// Create these todos for each parent task execution
const taskTodos = [
  { content: "Implement [feature/fix from task]", status: "pending", activeForm: "Implementing [feature/fix from task]" },
  { content: "Write/update tests", status: "pending", activeForm: "Writing/updating tests" },
  { content: "Verify build (build-check skill auto-invoked)", status: "pending", activeForm: "Verifying build" },
  { content: "Commit via git-workflow", status: "pending", activeForm: "Committing via git-workflow" }
];
```

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
The test-check skill auto-invokes to run and verify tests specific to this parent task.

**Focused Test Execution:**
```
ACTION: test-check skill auto-invokes
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

### Step 7.9: Output Validation Against Specifications (verification skill)

Validate ALL outputs against specifications before marking tasks complete. The verification skill (if installed) auto-invokes to ensure evidence-based completion claims.

**Core Principle:** NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE

**Verification Gate (5-Step Process):**
```
1. IDENTIFY: What command validates this completion?
2. EXECUTE: Run the verification command freshly
3. READ: Full output and exit codes
4. VERIFY: Output confirms the claim
5. CLAIM: Only now mark task complete
```

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

**Evidence Requirements:**
```
INVALID: "Tests should pass now" (assumption)
VALID:   "Tests pass: npm test exit code 0" (evidence)
```

**Failure Handling:**
IF validation fails:
1. Document specific specification violations
2. Return to appropriate step (design, implementation, or testing)
3. Correct violations and re-validate
4. Do not mark complete until all validations pass

### Step 7.10: Mark Task Complete and Log Progress
ONLY after output validation passes, mark this task and its sub-tasks complete by updating each task checkbox to [x] in tasks.md.

**Task Completion:**
1. Update tasks.md with [x] for completed task and subtasks
2. Note any blockers encountered and resolved

**Progress Logging:**
```
ACTION: Append to progress log
ENTRY_TYPE: task_completed
DATA:
  spec: [SPEC_FOLDER_NAME]
  task_id: [PARENT_TASK_ID]
  description: [TASK_DESCRIPTION]
  duration_minutes: [ESTIMATED_DURATION]
  notes: [KEY_ACCOMPLISHMENTS_OR_CHALLENGES]
  next_steps: [NEXT_TASK_OR_PHASE]

FILE: .agent-os/progress/progress.json
PATTERN: Use PROGRESS_APPEND_PATTERN from @shared/progress-log.md
```

**Purpose:** Creates permanent record of task completion for cross-session context.

## Phase 3: Task Completion and Delivery

### Step 8: Run All Tests
Run ALL tests in the application's test suite to ensure no regressions (test-check skill).

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
ELSE: test-check skill auto-invokes
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
  PROCEED: To build verification
ELSE IF validation was skipped or incomplete:
  PERFORM: Quick compliance check on changed files only
  FOCUS: New functionality added since last validation
```

### Step 9.5: Build Verification and Diagnostics Check
The build-check skill is auto-invoked to verify build status and check for type/lint errors before committing.

**Instructions:**
```
ACTION: Get list of modified files from git
COMMAND: git diff --name-only [BASE_BRANCH]...HEAD

ACTION: Get remaining tasks for context
READ: .agent-os/tasks/[SPEC_FOLDER]/tasks.md
EXTRACT: Uncompleted tasks that might fix build issues

ACTION: build-check skill auto-invokes before commit
CONTEXT: "Check build status before commit for [SPEC_NAME]:
          - Context: spec
          - Modified files: [LIST_OF_MODIFIED_FILES]
          - Current task: [COMPLETED_TASKS]
          - Spec path: [SPEC_FOLDER_PATH]
          - Future tasks: [REMAINING_UNCOMPLETED_TASKS]"

ANALYZE: Returned decision (COMMIT | FIX_REQUIRED | DOCUMENT_AND_COMMIT)
```

**Decision Handling:**

**FIX_REQUIRED:**
```
IF decision == "FIX_REQUIRED":
  DISPLAY: List of must-fix errors to user
  ACTION: Fix each error
  VERIFY: Re-run build-check until COMMIT decision
  THEN: Proceed to git workflow
```

**DOCUMENT_AND_COMMIT:**
```
IF decision == "DOCUMENT_AND_COMMIT":
  DISPLAY: Acceptable errors and reasoning
  SAVE: Commit message addendum for git workflow
  NOTE: These errors will be fixed by future tasks
  PROCEED: To git workflow with enhanced commit message
```

**COMMIT:**
```
IF decision == "COMMIT":
  NOTE: All checks passed
  PROCEED: To git workflow
```

**Build Check Benefits:**
- Catches type/lint errors before they reach CI/CD
- Distinguishes "must fix" from "acceptable for now" failures
- Documents expected build issues for future reference
- Prevents breaking changes from being committed
- Provides context about which future tasks will resolve issues

### Step 9.6: Build-Check Skill Invocation Gate (MANDATORY)

**VALIDATION CHECKPOINT - Verify build-check skill was properly invoked:**

```
GATE CHECK: Before proceeding to git workflow
─────────────────────────────────────────────────
VERIFY the following evidence exists:

☐ Build Verification Evidence:
  - Build command was executed (npm run build, cargo build, etc.)
  - Build output was captured and analyzed
  - Exit code was checked (0 = success, non-zero = failure)

☐ Diagnostics Check Evidence:
  - mcp__ide__getDiagnostics was called (or equivalent lint check)
  - Type errors were identified and classified
  - Lint warnings were reviewed

☐ Decision Documentation:
  - Clear decision recorded: COMMIT | FIX_REQUIRED | DOCUMENT_AND_COMMIT
  - If FIX_REQUIRED: All fixes applied and re-verified
  - If DOCUMENT_AND_COMMIT: Addendum prepared for commit message

VALIDATION:
  IF all evidence present AND decision is COMMIT or DOCUMENT_AND_COMMIT:
    ✓ Build-check skill properly invoked - PROCEED to git workflow
  ELSE IF missing build verification:
    ✗ HALT - Run build-check skill explicitly
    COMMAND: "Invoke build-check skill for [SPEC_NAME]"
  ELSE IF decision is FIX_REQUIRED:
    ✗ HALT - Fixes required before proceeding
    ACTION: Return to Step 9.5, address all FIX_REQUIRED errors
─────────────────────────────────────────────────
```

**Build-Check Gate Failure Recovery:**
```
IF build-check gate fails:
  1. RUN: Build command manually if not executed
  2. RUN: mcp__ide__getDiagnostics if not checked
  3. CLASSIFY: Each error as MUST_FIX or ACCEPTABLE
  4. FIX: All MUST_FIX errors
  5. DOCUMENT: All ACCEPTABLE errors in commit addendum
  6. RE-VERIFY: Run gate check again
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
          - Description: [SUMMARY_OF_IMPLEMENTED_FEATURES]
          - Commit addendum: [BUILD_CHECK_ADDENDUM if any from Step 9.5]"
SAVE: PR URL for summary
```

**Commit Message Enhancement:**
If Step 9.5 returned DOCUMENT_AND_COMMIT, append the build check addendum to the commit message to document expected errors and their resolution plan.

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

### Step 15: Log Session End (Progress Log)
Log the session completion to the persistent progress log for cross-session memory.

**Instructions:**
```
ACTION: Append to progress log
ENTRY_TYPE: session_ended
DATA:
  spec: [SPEC_FOLDER_NAME]
  summary: [BRIEF_SUMMARY_OF_SESSION_ACCOMPLISHMENTS]
  tasks_completed: [LIST_OF_COMPLETED_TASK_IDS]
  pr_url: [PULL_REQUEST_URL_IF_CREATED]
  next_steps: [SUGGESTED_NEXT_ACTIONS]

FILE: .agent-os/progress/progress.json
PATTERN: Use PROGRESS_APPEND_PATTERN from @shared/progress-log.md
ALSO: Regenerate progress.md using PROGRESS_MARKDOWN_PATTERN
```

**Purpose:** Provides complete session summary for future sessions to understand what was accomplished and what remains.

<!-- END EMBEDDED CONTENT -->

---

## SECTION: State Management

Use patterns from @shared/state-patterns.md:
- State writes: ATOMIC_WRITE_PATTERN
- State loads: STATE_LOAD_PATTERN
- Cache validation: CACHE_VALIDATION_PATTERN (5-min expiry, mtime-based)
- Locking: LOCK_PATTERN

Use patterns from @shared/progress-log.md:
- Append entries: PROGRESS_APPEND_PATTERN
- Load progress: PROGRESS_LOAD_PATTERN
- Read recent: PROGRESS_READ_RECENT_PATTERN

**Progress logging events:**
- `session_started`: Log after Phase 1 completes (environment verified, task selected)
- `task_completed`: Log after each parent task marked complete (Step 7.10)
- `session_ended`: Log at Phase 3 completion with summary

**Execute-tasks specific state:**
```json
{
  "task_iteration": {
    "current_task": "1.2",
    "subtask_index": 0,
    "tdd_phase": "RED|GREEN|REFACTOR"
  }
}
```

**Cache rules:** Load at workflow start, auto-extend for active workflows (max 12 extensions = 1 hour), save after each task completion.

**Progress rules:** Progress log NEVER expires. Append after each significant event. Use for cross-session context recovery.

---

## SECTION: Error Handling

**Recovery Philosophy**: Save state early, save often. Every step should be resumable.

See @shared/error-recovery.md for detailed recovery procedures covering:
- State corruption recovery
- Git workflow failures
- Test failures during execution
- Build failures
- Subagent/skill invocation failures
- Cache expiration recovery
- Partial task failure (resume protocol)
- Development server conflicts

### Quick Reference: Error → Recovery

| Error Type | First Action | Escalation |
|------------|--------------|------------|
| State corruption | Load from recovery/ | Reinitialize |
| Git checkout fails | Stash changes | Manual resolution |
| Tests fail | Analyze output, fix | Skip with documentation |
| Build errors (own files) | Fix immediately | - |
| Build errors (other files) | DOCUMENT_AND_COMMIT | Create new task |
| Subagent timeout | Retry once | Manual fallback |
| Cache expired | Rebuild from source | Full context reload |
| Partial execution | Check tasks.md, resume | Restart with context |
| Port conflict | Kill process | Use alternate port |

### Execute-tasks Specific

- **Cache auto-extension failure**: Reset extension_count, rebuild cache
- **TDD gate failure**: Return to Step 7.5, delete code written without failing test

## Subagent Integration
When the instructions mention agents, use the Task tool to invoke these subagents:
- Use native Explore agent for specification discovery
- `codebase-names` skill (auto-invoked) for validating existing function/variable names
- Use native Explore agent for document retrieval
- `git-workflow` for branch and commit management
- `test-check` skill (auto-invoked) for test execution
- `build-check` skill (auto-invoked) for build verification before commits
- `codebase-indexer` for code reference updates
- `project-manager` for documentation and notifications