---
name: build-check
description: "Verify build passes and classify errors before git commits. Auto-invoke this skill before any git commit to check for type/lint errors and classify them as 'must fix now' vs 'acceptable for future tasks'."
allowed-tools: mcp__ide__getDiagnostics, Bash, Read, Grep
---

# Build Verification Skill

Automatically verify build status and check for diagnostics before commits. Provides intelligent failure classification to distinguish between blocking errors and acceptable temporary errors.

## When to Use This Skill

Claude should automatically invoke this skill:
- **Before any git commit** (mandatory)
- **After implementing code changes** that could affect build
- **Before creating pull requests**

## Workflow

### 1. Run Build Command (if available)
```bash
# Check package.json for build script
if [ -f "package.json" ]; then
  npm run build  # or yarn build
fi
```

### 2. Get IDE Diagnostics
```
ACTION: Use mcp__ide__getDiagnostics tool
RETRIEVE: All current diagnostics (type errors, lint errors)
FILTER: By severity (errors vs warnings)
GROUP: By file
```

### 3. Classify Errors

**MUST_FIX (Blocking):**
- Type/lint errors in files modified by current task
- Breaking changes affecting other parts of codebase
- Syntax errors or critical type mismatches
- Import errors for existing code

**ACCEPTABLE_FOR_NOW (Document):**
- Errors in unmodified files about missing interfaces/types that future tasks will implement
- Type errors about incomplete features scheduled in remaining tasks
- Errors explicitly mentioned as dependencies of future tasks

### 4. Return Decision

**Decision Options:**
- `COMMIT` - All checks passed, proceed
- `FIX_REQUIRED` - Must fix errors before commit
- `DOCUMENT_AND_COMMIT` - Document acceptable errors in commit message

## Output Format

```markdown
## Build Check Results

**Decision:** [COMMIT | FIX_REQUIRED | DOCUMENT_AND_COMMIT]

### Build Status
- Command: [build command or "not available"]
- Result: [passed/failed/skipped]

### Diagnostics Summary
- Total Errors: [N]
- Errors in Modified Files: [N]
- Errors in Other Files: [N]

### Must Fix Errors (Blocking)
[IF ANY]
1. `file.ts:123` - [error message]
   - Reason: [Why this blocks the commit]

### Acceptable Errors (Document)
[IF ANY]
1. `other-file.ts:456` - [error message]
   - Reason: [Why this is acceptable]
   - Will be fixed by: Task [N] - [description]

### Recommended Action
[Clear next step]

### Commit Message Addendum
[IF DOCUMENT_AND_COMMIT - text to add to commit message]
```

## Key Principles

1. **Context-Aware**: Consider task dependencies and future work
2. **Conservative on Breaking Changes**: Always flag breaking changes as must-fix
3. **Document Acceptable Failures**: Require documentation when errors are acceptable
4. **Clear Reasoning**: Always explain classification decisions
5. **File-Focused**: Prioritize errors in modified files over external files
