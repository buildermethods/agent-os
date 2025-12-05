---
name: systematic-debugging
description: "Root cause analysis before attempting fixes. Auto-invoke this skill when debugging issues, encountering errors, or when fix attempts have failed. Enforces 4-phase methodology: Root Cause Investigation → Pattern Analysis → Hypothesis Testing → Implementation."
allowed-tools: Read, Grep, Glob, Bash
---

# Systematic Debugging Skill

Find root causes before attempting fixes. This skill prevents trial-and-error debugging by enforcing a structured investigation process.

**Core Principle:** NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST

## When to Use This Skill

Claude should automatically invoke this skill:
- **When encountering errors** during development
- **Before attempting any fix** for a bug or issue
- **After a fix attempt fails** (mandatory escalation)
- **When multiple components** could be the source of an issue
- **Under time pressure** (when rushing tempts guessing)

## Workflow

### Phase 1: Root Cause Investigation

**1.1 Read Errors Carefully**
```
ACTION: Read complete error messages and stack traces
DO NOT: Assume you understand the error from the first line
CAPTURE: Error type, location, full message, stack trace
```

**1.2 Reproduce Consistently**
```
ACTION: Create minimal reproduction steps
VERIFY: Issue reproduces reliably before investigating
IF FLAKY: Note conditions that affect reproduction
```

**1.3 Check Recent Changes**
```bash
# Review recent modifications
git log --oneline -10
git diff HEAD~3

# Identify what changed near the error location
git log -p -- [affected_file]
```

**1.4 Trace Data Flow**
```
ACTION: Follow data from source to error point
DOCUMENT: Each transformation or handoff
IDENTIFY: Where expected state diverges from actual
```

### Phase 2: Pattern Analysis

**2.1 Find Working Examples**
```
ACTION: Search codebase for similar working patterns
USE: Grep tool to find comparable implementations
COMPARE: Working vs broken code
```

**2.2 Identify Differences**
```
ANALYZE: What differs between working and broken?
CATEGORIES:
- Configuration differences
- Data type mismatches
- Missing dependencies
- Timing/ordering issues
```

### Phase 3: Hypothesis Testing

**3.1 Form Specific Hypothesis**
```
FORMAT: "The error occurs because [specific cause] which leads to [observed behavior]"
REQUIRE: Testable prediction
AVOID: Vague hypotheses like "something is wrong with X"
```

**3.2 Test Minimally**
```
RULE: Change ONE variable at a time
VERIFY: Each test confirms or refutes hypothesis
IF REFUTED: Form new hypothesis, don't guess
```

### Phase 4: Implementation

**4.1 Create Failing Test**
```
ACTION: Write test that demonstrates the bug
VERIFY: Test fails before fix
PURPOSE: Proves test catches the actual issue
```

**4.2 Implement Single Fix**
```
RULE: One fix per attempt
AVOID: Multiple simultaneous changes
VERIFY: Fix addresses root cause, not symptoms
```

**4.3 Verify Results**
```
ACTION: Run failing test - should pass
ACTION: Run related tests - should still pass
CONFIRM: No regressions introduced
```

## Escalation Protocol

**After 3+ Failed Fix Attempts:**
```
STOP - Do not attempt another fix

ASK:
1. Am I treating a symptom instead of the cause?
2. Is there an architectural problem?
3. Do I need to step back and re-examine assumptions?
4. Should I seek external perspective?

EVIDENCE: Multiple failed fixes indicate deeper problem
```

## Output Format

```markdown
## Systematic Debug Analysis

### Phase 1: Root Cause Investigation

**Error Summary:**
- Type: [error type]
- Location: `[file:line]`
- Message: [full error message]

**Reproduction:**
- Steps: [minimal reproduction steps]
- Consistent: [yes/no]

**Recent Changes:**
- [relevant commits or modifications]

**Data Flow Trace:**
1. [source] → [expected: X, actual: Y]
2. [transformation] → [expected: X, actual: Y]
3. [error point] → [divergence identified]

### Phase 2: Pattern Analysis

**Working Example:**
- Location: `[file:line]`
- Pattern: [description]

**Key Differences:**
1. [difference 1]
2. [difference 2]

### Phase 3: Hypothesis

**Hypothesis:** [specific testable hypothesis]

**Test Plan:**
1. [test to confirm/refute]

### Phase 4: Fix Implementation

**Root Cause:** [identified cause]

**Fix:**
- File: `[file:line]`
- Change: [description]

**Verification:**
- [ ] Failing test created
- [ ] Test now passes
- [ ] No regressions
```

## Key Principles

1. **Evidence Before Action**: Never attempt fixes without understanding the cause
2. **Systematic Over Ad-Hoc**: Follow the phases in order, don't skip
3. **One Change at a Time**: Isolate variables to identify true cause
4. **Escalate Early**: Three failed attempts triggers mandatory reassessment
5. **Document Everything**: Written traces prevent circular debugging

## Anti-Patterns to Avoid

- "Let me just try this quick fix" → Follow the phases
- "I'm confident this will work" → Confidence is not evidence
- "Time pressure justifies skipping steps" → Skipping causes more delays
- "Multiple fixes at once save time" → They don't, they obscure the cause
