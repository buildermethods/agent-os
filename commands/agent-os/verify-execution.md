# Verify Execution

Verify that the execution matched the spec. Check if what was built aligns with what was planned.

## Important Guidelines

- **Always use AskUserQuestion tool** when asking the user anything
- **Verify the intent, not just tasks** — scope in shape.md is the contract
- **Prefer automated checks** — tests/lint/typecheck/build when available
- **Update STATE.md** — enable pause/resume across sessions

## Usage

```
/verify-execution
/verify-execution 2026-01-24-1430-user-comment-system
```

## Process

### Step 1: Resolve Active Spec

1. Read `agent-os/STATE.md`
2. If an argument is provided, resolve it to a spec folder
3. Otherwise, use the active spec path from STATE.md

If still unknown, list recent spec folders in `agent-os/specs/` and ask the user to choose.

### Step 2: Load Spec Context

Read:
- `agent-os/specs/{spec}/shape.md` (scope — what we intended to build)
- `agent-os/specs/{spec}/plan.md` (tasks — what steps were planned)

### Step 3: Detect What Changed

Run `git diff HEAD --name-only` to see all uncommitted files (staged + unstaged).

If uncommitted files exist:
- These are the files that were just created/modified during execution
- List them for the user

If no uncommitted files:
- Check `git log --oneline -5` for recent commits
- Ask user: "Did you already commit? Which files were part of this spec?"

### Step 4: Run Automated Checks (If Available)

Look for existing test/build commands:
- `package.json` scripts (`test`, `lint`, `typecheck`, `build`)
- `Makefile` targets
- Common runners (`pytest`, `go test`, `bundle exec rspec`, etc.)

Run the lightest meaningful set. If none exist, note: "No automated suite found."

### Step 5: Manual Verification

Present to user:

```
Scope (from shape.md):
{scope summary}

Files changed:
{list from git diff or user input}

Tests: {pass/fail/none}
```

Use AskUserQuestion:

```
Does the feature work as intended?

- Yes: everything works
- No: describe what's wrong
```

### Step 6: Record Results

Update `agent-os/specs/{spec}/plan.md` by adding a section:

```markdown
## Verification Results

Date: {YYYY-MM-DD}

### Files Changed
- {file1}
- {file2}

### Automated Checks
- {command}: {result}

### Manual Verification
- {pass/fail}: {notes}
```

### Step 7: Handle Gaps

If issues were found:

1. Add fix tasks to plan.md (1-3 max):
   ```markdown
   ## Fix Tasks

   - [ ] Fix: {description of issue}
   ```

2. Update `agent-os/STATE.md`:
   - Status: `executing`
   - Current task: first fix task
   - Next step: implement fixes, then run /verify-execution again

3. Tell user: "Fix tasks added. Implement them, then run /verify-execution again."

### Step 8: Complete

If everything passes:

1. Update `agent-os/STATE.md`:
   - Status: `done`
   - Next step: commit work, then /shape-spec for next feature

2. Output:
   ```
   Verification passed.

   Suggested: commit your work, then run /shape-spec for the next feature.
   ```

## Tips

- Run /verify-execution after completing all tasks, not after each task
- Trust automated checks over manual verification when both exist
- Keep fix tasks small — if a gap requires major work, consider a new spec
- Uncommitted files = what was just executed (easiest to verify)
