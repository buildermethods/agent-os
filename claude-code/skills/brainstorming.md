---
name: brainstorming
description: "Socratic design refinement through questioning. Use this skill during create-spec or when exploring implementation approaches. Transforms rough ideas into concrete designs through incremental clarification and trade-off analysis."
allowed-tools: Read, Grep, Glob, AskUserQuestion
---

# Brainstorming Skill

Transform rough concepts into concrete designs through structured dialogue. This skill emphasizes understanding through questions before presenting solutions.

**Core Principle:** UNDERSTAND BEFORE DESIGNING

## When to Use This Skill

Claude should invoke this skill:
- **During create-spec** when exploring feature scope
- **When multiple approaches** are viable and trade-offs unclear
- **Before major architectural decisions**
- **When user's initial request needs refinement**

**Not for:** Mechanical execution tasks, clear single-approach problems

## Workflow

### Phase 1: Understand the Concept

**1.1 Examine Existing Context**
```
ACTION: Review project structure, related code, existing patterns
SEARCH: Similar implementations in codebase
NOTE: Constraints from existing architecture
```

**1.2 Ask Clarifying Questions (One at a Time)**
```
RULE: Ask ONE question per message
AVOID: Overwhelming with multiple questions
FORMAT: Provide multiple-choice options when possible

Example:
"What's the primary use case for this feature?
A) Real-time updates for active users
B) Batch processing for reports
C) Both equally important"
```

**1.3 Questions to Ask**
```
- What problem does this solve?
- Who are the users?
- What are the success criteria?
- Are there constraints (performance, compatibility)?
- What's out of scope?
```

### Phase 2: Explore Approaches

**2.1 Generate 2-3 Approaches**
```
FOR each viable approach:
  - Name the approach
  - Summarize in 2-3 sentences
  - List key trade-offs
  - Note complexity level
```

**2.2 Trade-off Analysis**
```
CREATE comparison table:
| Approach | Pros | Cons | Complexity | Fits Context? |
```

**2.3 Recommend with Reasoning**
```
RECOMMEND: One approach
EXPLAIN: Why it fits this context
ACKNOWLEDGE: What we're giving up
```

### Phase 3: Present Design

**3.1 Digestible Sections (200-300 words each)**
```
Present design in chunks:
1. Architecture overview
2. Key components
3. Data flow
4. Error handling
5. Testing considerations

After each section:
"Does this align with your expectations?"
```

**3.2 Validate Incrementally**
```
AFTER each section:
  PAUSE: Ask if understanding is correct
  IF MISALIGNMENT: Return to clarify
  IF ALIGNED: Continue to next section
```

### Phase 4: Document Design

**4.1 Create Design Document**
```
OUTPUT: docs/plans/YYYY-MM-DD-<topic>-design.md

Include:
- Problem statement
- Chosen approach with rationale
- Architecture diagram (ASCII or mermaid)
- Key decisions and trade-offs
- Open questions (if any)
```

## Output Format

```markdown
## Brainstorming: [Feature Name]

### Problem Understanding

**Primary Goal:** [what we're trying to achieve]

**Users:** [who will use this]

**Constraints:**
- [constraint 1]
- [constraint 2]

**Out of Scope:**
- [excluded item 1]

### Approaches Considered

#### Approach A: [Name]
[2-3 sentence description]

**Pros:**
- [advantage 1]
- [advantage 2]

**Cons:**
- [disadvantage 1]

**Complexity:** [Low/Medium/High]

#### Approach B: [Name]
[2-3 sentence description]

**Pros:**
- [advantage 1]

**Cons:**
- [disadvantage 1]

**Complexity:** [Low/Medium/High]

### Recommendation

**Chosen Approach:** [A or B]

**Rationale:** [Why this fits the context]

**Trade-offs Accepted:** [What we're giving up]

### Design Overview

[Digestible sections covering architecture, components, data flow]

### Next Steps

- [ ] Document final design
- [ ] Create implementation tasks
- [ ] [other actions]
```

## Key Principles

1. **One Question at a Time**: Don't overwhelm, build understanding incrementally
2. **Options Over Open-Ended**: Provide choices when possible
3. **Ruthless Simplification**: Remove unnecessary complexity aggressively
4. **Validate Before Proceeding**: Confirm alignment at each step
5. **Trade-offs, Not Perfection**: Every approach has cons, acknowledge them

## Question Patterns

**For Scope:**
- "Should X include Y, or is that separate?"
- "Is [complex feature] essential for MVP?"

**For Architecture:**
- "Do you prefer [simpler] or [more flexible] approach?"
- "Is [constraint] hard requirement or nice-to-have?"

**For Priorities:**
- "If you had to choose: [A] or [B]?"
- "What's more important: [speed] or [flexibility]?"

## Integration with Agent OS

**In create-spec.md:**
- Brainstorming skill invoked during requirements clarification
- Output feeds into spec document structure

**In create-tasks.md:**
- Can be used to explore task sequencing approaches
- Helps clarify dependencies when unclear

## Anti-Patterns to Avoid

- **Asking 5 questions at once** → Ask one, wait for answer
- **Presenting only one option** → Always show alternatives
- **Hiding trade-offs** → Be explicit about downsides
- **Designing without context** → Read codebase first
- **Assuming user knows best approach** → Guide with expertise
