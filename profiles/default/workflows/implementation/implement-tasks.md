Implement all tasks assigned to you and ONLY those task(s) that have been assigned to you.

## Implementation process:

1. Analyze the provided spec.md, requirements.md, and visuals (if any)
2. Analyze patterns in the codebase according to its built-in workflow
3. Implement the assigned task group according to requirements and standards
4. Update `agent-os/specs/[this-spec]/tasks.md` to update the tasks you've implemented to mark that as done by updating their checkbox to checked state: `- [x]`

## Guide your implementation using:
- **The existing patterns** that you've found and analyzed in the codebase.
- **Specific notes provided in requirements.md, spec.md AND/OR tasks.md**
- **Visuals provided (if any)** which would be located in `agent-os/specs/[this-spec]/planning/visuals/`
- **CLAUDE.md** in the project root (if exists) - contains project-specific rules, conventions, and requirements that you MUST follow.
- **Available Skills** - check available skills in your system context (listed in `<available_skills>` section). Use the `Skill(skill_name)` tool to invoke relevant skills for your task (e.g., testing skills when writing tests). Skills contain important requirements you MUST follow.
- **User Standards & Preferences** which are defined below.

## Self-verify and test your work by:
- Running ONLY the tests you've written (if any) and ensuring those tests pass.
- IF your task involves user-facing UI, and IF you have access to browser testing tools, open a browser and use the feature you've implemented as if you are a user to ensure a user can use the feature in the intended way.
  - Take screenshots of the views and UI elements you've tested and store those in `agent-os/specs/[this-spec]/verification/screenshots/`.  Do not store screenshots anywhere else in the codebase other than this location.
  - Analyze the screenshot(s) you've taken to check them against your current requirements.

## CRITICAL: Task Completion Rules

### Rule 1: A Task Is Complete ONLY When Actually Executed
- If a task says "Run tests" - you MUST execute the tests and see the output
- If a task says "Verify X works" - you MUST actually verify it
- Do NOT mark tasks as complete based on intent or assumption
- "I wrote the code" ≠ "task complete" - you must perform the actual action described

### Rule 2: Handle Missing Prerequisites
- If a task requires a running service (dev server, database) that is not running:
  - Start the service yourself (safe for parallel execution in isolated environments)
- If a task requires dependencies that are not installed:
  - Do NOT install them yourself (may conflict with parallel agents)
  - Report the blocker and keep task as `[ ]`
  - Dependency installation is the responsibility of planning/setup phase
- If you cannot determine how to proceed, ask the user for guidance

### Rule 3: Parent Tasks Require All Subtasks Complete
- A parent task (e.g., "5.0 Complete verification") can ONLY be marked `[x]` when ALL its subtasks are `[x]`
- If subtasks 5.2, 5.3, 5.4 are `[ ]`, then 5.0 MUST remain `[ ]`
- Never mark a parent task complete while leaving subtasks incomplete

### Rule 4: TDD Phases Require Actual Test Execution
- If tasks.md specifies TDD workflow:
  - RED phase: Tests must be written AND executed to verify they fail
  - GREEN phase: Tests must be executed AND pass
- Do NOT mark TDD phases complete without actual test execution output

### Rule 5: Verification Tasks Require Evidence
- If a task says "Manual verification" or "Verify in browser":
  - Actually perform the verification using available tools
  - Take screenshots as evidence when possible
  - Store evidence in the designated location (e.g., verification/screenshots/)
- Do NOT mark verification tasks complete without performing verification

### Rule 6: Incomplete Tasks Must Stay Incomplete
- If you cannot complete a task after attempting to resolve blockers:
  - Keep the task marked as `[ ]` (incomplete)
  - Add a comment in tasks.md explaining what you tried and what blocked you
  - NEVER mark a task `[x]` if you did not actually complete it
