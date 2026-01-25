# Algorithm Drift

Detect drift between algorithm documentation and implementation code.

This command compares an algorithm spec in `agent-os/standards/algorithms/` against its owned implementation files to find mismatches in conventions, parameters, or structure.

---

## When to Use

- After modifying algorithm implementation code
- Before major refactors of mathematical code
- When debugging convention-related bugs (wrong frames, units, quaternions)
- Periodic sync checks for algorithm-heavy projects

---

## Process

### Step 1: Identify the Algorithm

If the user specifies an algorithm name (e.g., `/algorithm-drift ekf`), use it directly.

If no name provided, list available algorithms:

```bash
ls agent-os/standards/algorithms/*.md
```

Use `AskUserQuestion` to let user select which algorithm to check.

### Step 2: Read the Algorithm Spec

Read the algorithm spec file at `agent-os/standards/algorithms/{name}.md`.

Parse the frontmatter to extract the `owns:` field listing implementation files.

**owns: field rules:**
- Paths are relative to project root
- Globs are supported (e.g., `src/filters/*.py`)
- If a file is missing, report as warning (not error)

### Step 3: Read Owned Implementation Files

For each path in `owns:`:
- Expand globs if present
- Read each file
- If file missing, note it as warning

### Step 4: Compare Spec vs Code

Analyze for four types of drift:

1. **Structural drift**: Functions present/missing, different step order than spec
2. **Parameter drift**: Different I/O signatures, changed constants
3. **Mathematical drift**: Different equations, changed conventions (frames, quaternions, units)
4. **Implementation drift**: Refactored code, new files not listed in `owns:`

Focus especially on the **Conventions** section — this is where silent bugs hide.

### Step 5: Report Findings

If no drift detected:
```
No drift detected in agent-os/standards/algorithms/{name}.md

Checked files:
- src/filters/ekf.ts (ok)
- src/filters/ekf.test.ts (ok)
```

If drift detected:
```
Drift detected in agent-os/standards/algorithms/{name}.md:

- Conventions: Spec says Hamilton quaternions, code uses JPL (src/filters/ekf.ts:45)
- Parameters: Spec says Q=0.1, code has Q=0.01 (src/filters/ekf.ts:78)
- Structural: Function `predict()` in spec not found in code

Warnings:
- File src/filters/ekf.test.ts not found
```

### Step 6: Offer Resolution

Use `AskUserQuestion` to present options:

1. **Update spec to match code** — Code is correct, spec is outdated
2. **Update code to match spec** — Spec is correct, code drifted
3. **Review manually** — Need to investigate further

Execute the chosen option or provide guidance for manual review.

---

## Algorithm Doc Template

When creating new algorithm docs, use this template:

```markdown
---
owns:
  - path/to/impl.py
  - path/to/impl.cpp
---

# [Algorithm Name]

## Purpose

[What this solves. Where it fits in the system.]

## I/O

**Inputs:**
- `name` (type/shape): description [units/frame if applicable]

**Outputs:**
- `name` (type/shape): description [units/frame if applicable]

## Conventions

[Domain-specific conventions that affect correctness:
coordinate frames, rotation conventions, tensor layouts, sign conventions, etc.]

## Diagram

[Required. Visual representation of the algorithm flow.

Choose the style that best fits:
- Pipeline: A → B → C → D
- Architecture: Layered boxes
- Flowchart: Branches and decisions
- Data flow: Variable transformations
- Math flow: Equations connected by arrows]

## Method

[High-level description of the approach.]

### Step 1: [Name]

[Description with equations, variables, implementation hints as needed.]

### Step 2: [Name]

[Continue for each major step...]

---

## Implementation

[How spec maps to code:
- File structure and key functions
- Function → Step mapping
- Key constants and rationale]

## Notes

[Invariants, edge cases, validation approaches, known limitations.]
```

---

## Output Location

Algorithm specs: `agent-os/standards/algorithms/{name}.md`

After creating or updating specs, run `/index-standards` to update the index.

---

## Tips

- **Conventions section is critical** — This is where quaternion bugs, frame mismatches, and unit errors hide
- **Diagram is required** — Visual representation helps catch structural drift
- **owns: field enables drift detection** — Keep it updated when refactoring
- **Run periodically** — Drift accumulates silently over time
- **Check before releases** — Especially for safety-critical algorithms
