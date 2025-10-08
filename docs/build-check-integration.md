# Build Check Integration

## Overview

The `/execute-tasks` and `/debug` commands now include intelligent build verification before commits. This prevents build failures from reaching CI/CD by catching type and lint errors early, while smartly distinguishing between "must fix now" and "acceptable for future tasks" issues.

## What's New

### New Subagent: `build-checker`

**Location:** `claude-code/agents/build-checker.md`

**Purpose:** Verify build status and diagnostics before commits with intelligent failure classification.

**Key Features:**
- Runs project build command (if available)
- Uses `mcp__ide__getDiagnostics` for type/lint error detection
- Classifies failures as MUST_FIX, ACCEPTABLE_FOR_NOW, or INVESTIGATE
- Provides context-aware decisions based on task dependencies

### Updated Commands

#### `/execute-tasks`
- **New Step 9.5:** Build Verification and Diagnostics Check
- **Position:** After tests pass, before git commit
- **Integration:** Passes spec context and future tasks to build-checker

#### `/debug`
- **New Step 10.5:** Build Verification and Diagnostics Check
- **Position:** After fix implementation, before git commit
- **Integration:** Passes debugging scope and context to build-checker

## How It Works

### Build Check Workflow

```
┌─────────────────────────────────────┐
│  Step 1: Run Build Command          │
│  (if package.json has build script) │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  Step 2: Get IDE Diagnostics        │
│  (mcp__ide__getDiagnostics)         │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  Step 3: Analyze Modified Files     │
│  - Errors in modified files         │
│  - Type/lint issues in our code     │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  Step 4: Analyze Other Files        │
│  - Breaking changes we caused       │
│  - Errors future tasks will fix     │
│  - Pre-existing unrelated errors    │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  Step 5: Smart Classification       │
│  - MUST_FIX                         │
│  - ACCEPTABLE_FOR_NOW               │
│  - INVESTIGATE                      │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  Step 6: Return Decision            │
│  - FIX_REQUIRED                     │
│  - DOCUMENT_AND_COMMIT              │
│  - COMMIT                           │
└─────────────────────────────────────┘
```

### Decision Types

#### 1. COMMIT ✅
**When:** No errors found, all checks pass
**Action:** Proceed with git commit immediately

#### 2. FIX_REQUIRED ❌
**When:** Critical errors that must be fixed now
**Examples:**
- Type errors in files modified by current task
- Breaking changes affecting other parts of codebase
- Import errors for existing code
- Syntax errors or critical type mismatches

**Action:**
- Display errors to user
- Fix each error
- Re-run build-checker until COMMIT decision
- Then proceed to git workflow

#### 3. DOCUMENT_AND_COMMIT ⚠️
**When:** Errors exist but are acceptable for now
**Examples:**
- Errors in unmodified files about interfaces/types that future tasks will implement
- Type errors about incomplete features in remaining tasks
- Dependencies explicitly mentioned in task breakdown

**Action:**
- Display acceptable errors with reasoning
- Add commit message addendum documenting the errors
- Note which future tasks will resolve them
- Proceed to git commit with enhanced message

## Smart Failure Classification

### MUST_FIX Criteria
```typescript
// Errors that BLOCK commits
- Type/lint errors in modified files
- Breaking changes affecting other code
- Errors preventing core functionality
- Syntax errors or critical type mismatches
- Import errors for existing code
```

### ACCEPTABLE_FOR_NOW Criteria
```typescript
// Errors that can be DOCUMENTED and committed
- Errors in unmodified files about missing interfaces future tasks will add
- Type errors about incomplete features in remaining tasks
- Circular dependencies that resolve when all tasks complete
- Errors explicitly mentioned as "to be implemented" in task dependencies
```

### INVESTIGATE Criteria
```typescript
// Errors needing HUMAN JUDGMENT
- Errors in unmodified files unrelated to current task
- Pre-existing errors not documented in tasks
- Ambiguous type errors without clear resolution path
```

## Example Scenarios

### Scenario 1: Clean Build ✅
```
Task: Implement user login (Task 2.1)
Modified: src/auth/login.ts, src/auth/login.test.ts

Build Check Result:
✓ Build: passed
✓ Diagnostics: 0 errors, 2 warnings (unused imports - acceptable)
✓ Decision: COMMIT
→ Action: Proceed with commit
```

### Scenario 2: Errors in Modified Files ❌
```
Task: Add logout functionality (Task 2.2)
Modified: src/auth/logout.ts

Build Check Result:
✗ Build: failed
✗ Must Fix Error:
  - src/auth/logout.ts:34 - Type 'undefined' not assignable to 'User'
  - Reason: Type error in file modified by current task
✗ Decision: FIX_REQUIRED
→ Action: Fix type error before committing
```

### Scenario 3: Acceptable Future Task Errors ⚠️
```
Task: Define auth types (Task 2.1)
Modified: src/types/auth.ts
Future Tasks: 2.2 (implement login), 2.3 (implement logout)

Build Check Result:
⚠ Build: failed (expected)
⚠ External Errors: 5 in src/auth/login.ts, src/auth/logout.ts
  - Using newly defined User type
  - Will be implemented in tasks 2.2, 2.3
⚠ Acceptable Errors:
  - src/auth/login.ts:12 - Cannot find name 'validateUser'
    → Will be fixed by Task 2.2
  - src/auth/logout.ts:8 - Cannot find name 'clearSession'
    → Will be fixed by Task 2.3
⚠ Decision: DOCUMENT_AND_COMMIT
⚠ Commit Addendum: "Note: 5 expected errors in auth files will be resolved by tasks 2.2-2.3"
→ Action: Add note to commit message and proceed
```

### Scenario 4: Breaking Change ❌
```
Task: Refactor User interface
Modified: src/types/user.ts (changed User interface)

Build Check Result:
✗ Build: failed
✗ Must Fix Error:
  - src/profile/display.ts:45 - Property 'email' does not exist on type 'User'
  - Reason: Breaking change in User interface affects existing code
✗ Decision: FIX_REQUIRED
→ Action: Update all files using User.email to use new structure
```

## Integration Points

### In `/execute-tasks` Command

**Step 9.5 is invoked with:**
```javascript
{
  context: "spec",
  modifiedFiles: ["list", "of", "files"],
  currentTask: "Task 2.1 - Define authentication types",
  specPath: ".agent-os/specs/2024-03-15-auth-system",
  futureTasks: [
    "Task 2.2 - Implement login",
    "Task 2.3 - Implement logout"
  ]
}
```

**The build-checker returns:**
```javascript
{
  decision: "DOCUMENT_AND_COMMIT",
  buildStatus: "failed",
  diagnosticsSummary: {
    totalErrors: 5,
    modifiedFileErrors: 0,
    externalFileErrors: 5,
    warnings: 2
  },
  mustFixErrors: [],
  acceptableErrors: [
    {
      file: "src/auth/login.ts",
      line: 12,
      message: "Cannot find name 'validateUser'",
      reason: "Function will be implemented in Task 2.2",
      futureTask: "Task 2.2 - Implement login"
    }
  ],
  commitMessageAddendum: "\n\nNote: 5 expected errors...",
  recommendedAction: "Document acceptable errors and proceed"
}
```

### In `/debug` Command

**Step 10.5 is invoked with:**
```javascript
{
  context: "task" | "spec" | "general",
  modifiedFiles: ["files", "changed", "in", "fix"],
  currentFix: "Fix authentication session timeout",
  specPath: ".agent-os/specs/auth-system" (if applicable),
  futureTasks: [...] (if within active spec)
}
```

## Benefits

### 1. Early Error Detection
- Catches type/lint errors before they reach CI/CD
- Prevents broken builds from being committed
- Reduces debugging time in code review

### 2. Context-Aware Decisions
- Understands task dependencies and future work
- Distinguishes between critical and temporary errors
- Provides clear reasoning for each decision

### 3. Documentation
- Documents expected build issues in commit messages
- Links errors to future tasks that will fix them
- Creates audit trail of intentional incomplete states

### 4. Developer Experience
- Clear actionable feedback (commit/fix/document)
- No false positives blocking legitimate work
- Transparent reasoning for all decisions

### 5. Build Confidence
- Know exactly what errors exist and why
- Understand which tasks will resolve issues
- Commit with confidence even with "acceptable" errors

## Configuration

### Build Command Detection
The build-checker automatically detects build commands from `package.json`:
```json
{
  "scripts": {
    "build": "tsc && vite build"  // ← Automatically used
  }
}
```

If no build script exists, the checker skips build execution and relies solely on IDE diagnostics.

### Diagnostics Source
Uses `mcp__ide__getDiagnostics` tool which provides:
- TypeScript type errors
- ESLint/Prettier lint errors
- IDE-detected issues
- All severity levels (error, warning, info)

## File Locations

```
agent-os/
├── claude-code/agents/
│   └── build-checker.md           # New subagent
├── commands/
│   ├── execute-tasks.md           # Updated with Step 9.5
│   └── debug.md                   # Updated with Step 10.5
└── docs/
    └── build-check-integration.md # This document
```

## Rollout Plan

### Phase 1: Installation ✅
1. Create `build-checker.md` subagent
2. Update `execute-tasks.md` with Step 9.5
3. Update `debug.md` with Step 10.5
4. Document integration (this file)

### Phase 2: Testing
1. Test with multi-task specs (acceptable errors scenario)
2. Test with breaking changes (must-fix scenario)
3. Test with clean code (commit scenario)
4. Verify commit message enhancement

### Phase 3: Deployment
1. Run `./setup/project.sh --claude-code` in target projects
2. Build-checker will be automatically included
3. Existing workflows enhanced with build checks

## Troubleshooting

### Issue: Build check takes too long
**Solution:** Build timeout is 5 minutes. If exceeds, skip build and rely on diagnostics.

### Issue: Too many "acceptable" errors flagged as must-fix
**Solution:** Ensure future tasks are properly passed to build-checker. Check Step 9.5/10.5 context gathering.

### Issue: Pre-existing errors blocking commits
**Solution:** Build-checker only flags errors in modified files as must-fix. Pre-existing errors in other files are classified as "investigate" and don't block.

### Issue: Build command not found
**Solution:** Add "build" script to package.json, or rely on diagnostics-only checking.

## Migration Notes

### For Existing Projects
No migration needed. When you run:
```bash
./setup/project.sh --claude-code
```

The new build-checker subagent will be installed automatically, and commands will use it.

### For Active Specs
Build checks will intelligently handle incomplete work:
- Tasks in progress: Errors in other files are acceptable
- Final task: All errors must be fixed before commit
- Breaking changes: Always flagged as must-fix

### Backward Compatibility
- Old command versions (without build check) still work
- New versions enhance with build verification
- No breaking changes to existing workflows

## Future Enhancements

### Potential Improvements
1. **Custom Severity Rules:** Allow projects to define which error types are acceptable
2. **Build Cache:** Cache build results to avoid redundant builds
3. **Auto-Fix:** Suggest or apply fixes for common type errors
4. **Integration Tests:** Run integration tests as part of build check
5. **Performance Metrics:** Track build check performance and optimization opportunities

## Summary

The build check integration provides:
- ✅ Intelligent error detection before commits
- ✅ Context-aware classification of failures
- ✅ Clear documentation of acceptable errors
- ✅ Confidence in commit quality
- ✅ Reduced CI/CD failures
- ✅ Better developer experience

All while recognizing that multi-task workflows naturally have temporary incomplete states that shouldn't block progress.
