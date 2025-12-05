---
name: code-review
description: "Request and process code reviews with technical rigor. Use this skill before PRs, after completing major features, or when stuck. Provides pre-review checklists and guides feedback integration without performative agreement."
allowed-tools: Read, Grep, Glob, Bash
---

# Code Review Skill

Request reviews early and integrate feedback with technical rigor. This skill covers both requesting reviews and processing feedback effectively.

**Core Principle:** REVIEW EARLY, REVIEW OFTEN

## When to Use This Skill

Claude should invoke this skill:
- **After completing major features** before merging
- **After each significant task** in subagent-driven development
- **Before creating pull requests**
- **When stuck** (fresh perspective helps)
- **When receiving feedback** that needs evaluation

## Part 1: Requesting Code Review

### Pre-Review Checklist

Before requesting review, verify:
```
[ ] All tests pass
[ ] Build succeeds
[ ] No console.log/debug statements left
[ ] Code follows project conventions
[ ] New code has tests
[ ] Documentation updated if needed
```

### Request Format

**1. Get Git Context**
```bash
# Get commit range
BASE_SHA=$(git merge-base HEAD main)
HEAD_SHA=$(git rev-parse HEAD)

# Show changes
git diff $BASE_SHA...$HEAD_SHA --stat
```

**2. Prepare Review Request**
```markdown
## Review Request

**What was implemented:**
[Brief description of changes]

**Files changed:**
[List of modified files]

**Testing done:**
- [Test 1 description]
- [Test 2 description]

**Areas of concern:**
- [Any specific areas needing attention]
```

### Acting on Feedback

**Priority Handling:**
| Category | Action |
|----------|--------|
| Critical | Fix immediately, block merge |
| Important | Fix before proceeding |
| Minor | Note for later, can proceed |
| Opinion | Discuss if disagree |

## Part 2: Receiving Code Review

### Response Protocol

**1. READ - Complete feedback without reacting**
```
ACTION: Read all feedback items first
DO NOT: React or start implementing immediately
```

**2. UNDERSTAND - Restate in own words**
```
IF UNCLEAR: Ask for clarification before implementing
FORMAT: "I understand this means [restatement]. Correct?"
```

**3. VERIFY - Check against codebase**
```
BEFORE implementing any suggestion:
- Is it technically correct for THIS codebase?
- Does it break existing functionality?
- Is there a reason for the current implementation?
```

**4. RESPOND - Technical acknowledgment or pushback**
```
IF CORRECT:
  "Fixed. [Brief description of change]"
  (Then just fix it - actions over words)

IF INCORRECT:
  Push back with technical reasoning
  Show code/tests that prove current approach works
```

### Forbidden Responses

**NEVER say:**
- "You're absolutely right!"
- "Great point!"
- "Thanks for catching that!"

**Instead:**
- Restate the technical requirement
- Ask clarifying questions
- Just fix it and show the result

### Handling Unclear Feedback

```
IF multiple items and some unclear:
  STOP - Do not implement anything yet
  ASK for clarification on ALL unclear items

  "I understand items 1, 2, 6. Need clarification on 3, 4, 5 before proceeding."
```

### YAGNI Check

When reviewer suggests "implementing properly":
```bash
# Check if feature is actually used
grep -r "[feature/endpoint]" src/

IF unused:
  "This endpoint isn't called. Remove it (YAGNI)? Or is there usage I'm missing?"

IF used:
  Implement properly
```

### When to Push Back

Push back when:
- Suggestion breaks existing functionality
- Reviewer lacks full context
- Violates YAGNI (unused feature)
- Technically incorrect for this stack
- Conflicts with architectural decisions

**How to push back:**
```
FORMAT: Use technical reasoning, not defensiveness

"Checking... [investigation]. Found [evidence].
The current implementation [reason].
Should we [alternative]?"
```

## Output Format

```markdown
## Code Review Response

### Feedback Received
[Summary of feedback items]

### Analysis

#### Item 1: [Description]
**Status:** [Agree/Disagree/Clarify]
**Reasoning:** [Technical analysis]
**Action:** [What will be done]

#### Item 2: [Description]
**Status:** [Agree/Disagree/Clarify]
**Reasoning:** [Technical analysis]
**Action:** [What will be done]

### Changes Made
1. `file.ts:123` - [change description]
2. `file.ts:456` - [change description]

### Still Unclear
- [Item needing clarification]

### Verification
- [ ] Changes tested
- [ ] Build passes
- [ ] No regressions
```

## Key Principles

1. **Technical Rigor Over Social Comfort**: Verify before implementing
2. **Actions Over Words**: Just fix it, don't perform gratitude
3. **One at a Time**: Implement and test each change individually
4. **Evidence Over Claims**: Push back with technical reasoning when needed
5. **Clarify Before Implementing**: Don't assume, ask

## Integration with Agent OS

**In execute-tasks.md:**
- Code-review skill can be invoked before task completion
- Catches issues before they compound

**In debug.md:**
- Can be used to review fix implementation before testing
