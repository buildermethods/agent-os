---
name: writing-plans
description: "Create detailed implementation plans with micro-tasks. Use this skill during create-tasks or when breaking down complex features. Produces plans with 2-5 minute tasks, TDD structure, and complete code examples."
allowed-tools: Read, Grep, Glob
---

# Writing Plans Skill

Create comprehensive implementation plans assuming the executor has minimal codebase context. Plans should be detailed enough that each task is unambiguous.

**Core Principle:** DOCUMENT EVERYTHING THE EXECUTOR NEEDS TO KNOW

## When to Use This Skill

Claude should invoke this skill:
- **During create-tasks** when breaking down features
- **When planning complex implementations**
- **When creating tasks for subagents**
- **When documentation structure needs planning**

## Workflow

### Phase 1: Understand the Goal

**1.1 Read the Specification**
```
ACTION: Read spec document thoroughly
IDENTIFY:
- Feature goal and scope
- Success criteria
- Dependencies and constraints
```

**1.2 Examine Existing Code**
```
ACTION: Find related existing implementations
USE: Grep/Glob to locate similar patterns
NOTE: Conventions to follow
```

### Phase 2: Decompose into Micro-Tasks

**2.1 Break Down Hierarchically**
```
Feature → Components → Tasks → Subtasks

EACH TASK should be:
- 2-5 minutes of focused work
- Single responsibility
- Independently testable
```

**2.2 TDD Task Structure**
```
FOR each behavior:
  1. Write failing test for [behavior]
  2. Verify test fails
  3. Implement [behavior]
  4. Verify test passes
  5. Commit
```

**2.3 Include Everything Needed**
```
EACH TASK includes:
- Exact file paths
- Complete code examples (not descriptions)
- Specific commands with expected output
- Verification steps
```

### Phase 3: Write the Plan

**3.1 Header Section**
```markdown
# Implementation Plan: [Feature Name]

## Goal
[One sentence description of what we're building]

## Architecture
[Brief overview of how it fits into the system]

## Prerequisites
- [ ] [dependency 1]
- [ ] [dependency 2]
```

**3.2 Task Breakdown**
```markdown
## Tasks

### Task 1: [Name]
**Goal:** [What this accomplishes]
**File:** `[exact/path/to/file.ts]`

#### 1.1 Write Test
```typescript
// Complete test code - copy-paste ready
```

#### 1.2 Verify Test Fails
```bash
npm test -- --grep "[test name]"
# Expected: FAIL - [reason]
```

#### 1.3 Implement
```typescript
// Complete implementation code
```

#### 1.4 Verify Test Passes
```bash
npm test -- --grep "[test name]"
# Expected: PASS
```

#### 1.5 Commit
```bash
git add [file]
git commit -m "feat: [description]"
```
```

### Phase 4: Validate Plan Quality

**4.1 Plan Checklist**
```
CHECK each task:
- [ ] File paths are exact (not "somewhere in src/")
- [ ] Code is complete (not "implement the logic")
- [ ] Commands include expected output
- [ ] Test comes before implementation
- [ ] Task is 2-5 minutes of work
```

**4.2 Principles Check**
```
VERIFY plan follows:
- DRY: Don't Repeat Yourself
- YAGNI: You Aren't Gonna Need It
- TDD: Test-Driven Development
```

## Output Format

```markdown
# Implementation Plan: [Feature Name]

**Created:** [YYYY-MM-DD]
**Spec:** [link to spec document]

## Goal
[Single sentence describing the feature]

## Architecture Overview
[2-3 sentences on how this fits into the system]

```
[ASCII diagram if helpful]
```

## Prerequisites
- [ ] [prerequisite 1]
- [ ] [prerequisite 2]

---

## Task 1: [Task Name]

**Goal:** [What this accomplishes]
**Estimated:** 2-5 min

### Files
- `[path/to/file.ts]` - [what changes]

### 1.1 Write Test
```[language]
// Complete, copy-paste ready test code
```

### 1.2 Run Test (Should Fail)
```bash
[exact command]
# Expected output: FAIL
```

### 1.3 Implement
```[language]
// Complete, copy-paste ready implementation
```

### 1.4 Run Test (Should Pass)
```bash
[exact command]
# Expected output: PASS
```

### 1.5 Commit
```bash
git add [files]
git commit -m "[type]: [description]"
```

---

## Task 2: [Task Name]
[repeat structure]

---

## Verification

After all tasks:
```bash
# Run full test suite
npm test

# Run build
npm run build

# Expected: All passing, no errors
```

## Notes
- [Any additional context]
- [Edge cases to be aware of]
```

## Key Principles

1. **Explicit Over Implicit**: Complete code beats "implement the logic here"
2. **Micro-Tasks**: 2-5 minutes each, frequently commit
3. **TDD Structure**: Test → Fail → Implement → Pass → Commit
4. **Zero Ambiguity**: Reader should never wonder "what does this mean?"
5. **Copy-Paste Ready**: Code examples should work as-is

## Task Sizing Guidelines

| Size | Duration | Example |
|------|----------|---------|
| Too Small | < 1 min | "Add import statement" |
| Ideal | 2-5 min | "Add validation function with tests" |
| Too Large | > 10 min | "Implement user authentication" |

**If task > 10 min:** Break into subtasks

## Integration with Agent OS

**In create-tasks.md:**
- Writing-plans skill structures task decomposition
- Output goes to `.agent-os/specs/[feature]/tasks.md`

**In execute-tasks.md:**
- Plans provide the detailed execution guidance
- Each task becomes a TodoWrite item

## Anti-Patterns to Avoid

- **Vague tasks**: "Set up the database" → Be specific
- **Missing paths**: "Update the config" → Which file exactly?
- **Implementation before test**: Swap the order
- **Giant tasks**: 30-min tasks → Break down further
- **Descriptions instead of code**: "Add error handling" → Show the code
