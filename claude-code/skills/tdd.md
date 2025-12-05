---
name: tdd
description: "Test-Driven Development enforcement. Auto-invoke this skill before implementing new features or functionality. Enforces RED-GREEN-REFACTOR cycle: write failing test first, implement minimal code, then refactor."
allowed-tools: Read, Bash, Grep, Glob
---

# Test-Driven Development Skill

Write tests before implementation code. This skill enforces the discipline that prevents false confidence and ensures tests actually validate behavior.

**Core Principle:** NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST

## When to Use This Skill

Claude should automatically invoke this skill:
- **Before implementing new features** or functionality
- **Before fixing bugs** (write test that reproduces bug first)
- **When adding new methods** or functions to existing code
- **When task includes test requirements** in the spec

## Workflow

### Phase 1: RED - Create Failing Test

**1.1 Write Test First**
```
ACTION: Write a single test for desired behavior
FOCUS: Test the behavior, not the implementation
NAME: Test name describes what should happen
```

**1.2 Run Test - Must Fail**
```bash
# Run the specific test
npm test -- --grep "[test name]"  # or equivalent

# Expected output: FAIL
```

**1.3 Verify Failure is Correct**
```
CHECK: Test fails for the RIGHT reason
- Fails because code doesn't exist yet ✓
- Fails because feature not implemented ✓
- Passes immediately ✗ (test is wrong)
- Fails due to syntax error ✗ (fix test first)
```

**Critical Rule:**
```
IF test passes immediately:
  PROBLEM: Test doesn't verify new behavior
  ACTION: Delete test and write one that fails

IF you wrote code before tests:
  ACTION: Delete the implementation
  START OVER: Write test first
```

### Phase 2: GREEN - Make Test Pass

**2.1 Implement Minimal Code**
```
GOAL: Make the test pass with MINIMUM code
AVOID: Writing extra functionality
AVOID: "Improving" while implementing
```

**2.2 Run Test - Must Pass**
```bash
# Run the specific test
npm test -- --grep "[test name]"

# Expected output: PASS
```

**2.3 Run All Related Tests**
```bash
# Ensure no regressions
npm test -- --grep "[related tests]"

# All should pass
```

### Phase 3: REFACTOR - Improve Code

**3.1 Clean Up**
```
ONLY AFTER tests pass:
- Remove duplication
- Improve naming
- Extract helpers if needed
```

**3.2 Run Tests After Each Change**
```bash
# Tests must stay green during refactor
npm test

# Any red = revert refactor change
```

## TDD Cycle Summary

```
┌─────────────────────────────────────────────────┐
│                  TDD CYCLE                       │
├─────────────────────────────────────────────────┤
│                                                  │
│   1. RED:    Write failing test                 │
│              ↓                                   │
│   2. GREEN:  Write minimal code to pass         │
│              ↓                                   │
│   3. REFACTOR: Clean up (tests stay green)      │
│              ↓                                   │
│   [repeat for next behavior]                    │
│                                                  │
└─────────────────────────────────────────────────┘
```

## Output Format

```markdown
## TDD Implementation

### Behavior to Implement
[Description of feature/behavior]

### RED Phase
**Test:**
```[language]
// Test code
```

**Test Run Result:**
- Command: `[test command]`
- Result: FAIL ✓
- Failure Reason: [expected - code not implemented yet]

### GREEN Phase
**Implementation:**
```[language]
// Minimal implementation code
```

**Test Run Result:**
- Command: `[test command]`
- Result: PASS ✓
- Related Tests: All passing ✓

### REFACTOR Phase
**Changes Made:**
- [refactoring change 1]
- [refactoring change 2]

**Final Test Run:**
- All tests: PASS ✓

### TDD Checklist
- [ ] Test written before implementation
- [ ] Test failed initially (verified RED)
- [ ] Minimal code written (GREEN)
- [ ] Tests stayed green during refactor
- [ ] No production code without failing test
```

## Key Principles

1. **Test First, Always**: No exceptions, no "quick implementations"
2. **Watch the Fail**: A test that never failed proves nothing
3. **Minimal Implementation**: Only write code to pass the current test
4. **One Behavior Per Test**: Keep tests focused and specific
5. **Refactor Only When Green**: Never refactor with failing tests

## Common Rationalizations (All Invalid)

| Excuse | Reality |
|--------|---------|
| "I'll write tests after" | Tests after implementation don't catch bugs |
| "This is too simple for TDD" | Simple code still needs verification |
| "TDD takes too long" | Debugging untested code takes longer |
| "I'm confident it works" | Confidence is not evidence |
| "Let me prototype first" | Prototypes without tests become production |

## Integration with Agent OS Workflow

**In execute-tasks.md:**
- TDD skill auto-invokes when task involves new functionality
- VALIDATION_GATE: Test exists and fails before implementation begins

**In create-tasks.md:**
- Tasks should include "Write test for [behavior]" as first subtask
- Implementation subtask comes after test subtask

## Test Types by Context

**Unit Tests (most common):**
- Individual functions/methods
- Fast, isolated, no external dependencies

**Integration Tests:**
- Multiple components working together
- May use test databases or mocks

**E2E Tests (when specified in task):**
- Full user flows
- Slower, use sparingly
