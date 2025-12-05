---
name: verification
description: "Evidence-based completion verification. Auto-invoke this skill before claiming work is complete, fixed, or passing. Enforces fresh verification runs before any success claims."
allowed-tools: Bash, Read, Grep, mcp__ide__getDiagnostics
---

# Verification Before Completion Skill

Run verification commands and confirm output before making any completion claims. This skill prevents false success assertions.

**Core Principle:** NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE

## When to Use This Skill

Claude should automatically invoke this skill:
- **Before marking any task complete**
- **Before claiming tests pass**
- **Before claiming build succeeds**
- **Before claiming a fix works**
- **Before creating PRs**

## Workflow

### The 5-Step Gate

Before ANY completion claim:

```
┌─────────────────────────────────────────────────┐
│         VERIFICATION GATE FUNCTION              │
├─────────────────────────────────────────────────┤
│                                                  │
│  1. IDENTIFY: What command validates this claim?│
│                                                  │
│  2. EXECUTE: Run the complete command freshly   │
│                                                  │
│  3. READ: Full output and exit codes            │
│                                                  │
│  4. VERIFY: Output confirms the assertion       │
│                                                  │
│  5. CLAIM: Only now make the statement          │
│                                                  │
└─────────────────────────────────────────────────┘
```

### Verification by Claim Type

**"Tests Pass"**
```bash
# Run full test suite
npm test

# Check exit code
echo "Exit code: $?"

# Expected: 0 (success)
```

**"Build Succeeds"**
```bash
# Run build
npm run build

# Check exit code
echo "Exit code: $?"

# Check for error output
```

**"Fix Works"**
```bash
# Run specific test for the fix
npm test -- --grep "[test for fixed behavior]"

# Run related tests
npm test -- --grep "[related tests]"

# All must pass
```

**"No Regressions"**
```bash
# Run full test suite
npm test

# Run build
npm run build

# Get diagnostics
# Use mcp__ide__getDiagnostics tool
```

### Red Flags - Claims Without Evidence

**Dangerous patterns:**
```
❌ "Tests should pass now"      → Run them
❌ "This should fix it"         → Verify it does
❌ "Build is probably fine"     → Run it
❌ "I'm confident this works"   → Confidence ≠ evidence
```

**Required patterns:**
```
✓ "Tests pass: [output showing PASS]"
✓ "Build succeeds: [exit code 0]"
✓ "Fix verified: [specific test passes]"
```

### Partial Checks Are Insufficient

| Partial Check | Missing Verification |
|---------------|---------------------|
| "Linter passed" | Build might fail |
| "Unit tests pass" | Integration tests? |
| "Compiles" | Runtime errors? |
| "Works locally" | CI might fail |

**Always run the FULL verification appropriate for the claim.**

## Output Format

```markdown
## Verification Report

### Claim to Verify
"[The completion claim being made]"

### Verification Command
```bash
[exact command run]
```

### Output
```
[complete command output]
```

### Exit Code
[exit code]

### Analysis
- Expected: [what should happen]
- Actual: [what happened]
- Match: [Yes/No]

### Verification Status
[VERIFIED | NOT VERIFIED | PARTIAL]

### Evidence Summary
[1-2 sentence summary of proof]
```

## Invalid Rationalizations

| Excuse | Reality |
|--------|---------|
| "I'm exhausted, it's fine" | Exhaustion causes mistakes |
| "I'm confident" | Confidence is not evidence |
| "Just this once" | Exceptions become habits |
| "Takes too long" | Debugging takes longer |
| "It's a small change" | Small changes still break things |

**Honesty is a core value.** If you can't verify, say so.

## Key Principles

1. **Fresh Runs Only**: Previous runs don't count, run it again
2. **Complete Output**: Read the full output, not just the summary
3. **Exit Codes Matter**: Check them explicitly
4. **No Assumptions**: "Should" is not "does"
5. **Honest Reporting**: If verification fails, say so

## Integration with Agent OS

**In execute-tasks.md:**
- Verification skill auto-invokes before marking tasks complete
- Required before git commit workflows

**In debug.md:**
- Verification skill auto-invokes before claiming fix works
- Required before closing debug session

## Verification Checklist

```markdown
Before any completion claim:
- [ ] Identified verification command
- [ ] Ran command (fresh, not cached)
- [ ] Read complete output
- [ ] Checked exit code
- [ ] Output confirms claim
- [ ] Can show evidence if asked
```
