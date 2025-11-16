---
description: Create comprehensive specification document from gathered requirements
---

# Spec Writing Workflow

Now that you've gathered and documented requirements, you'll create a comprehensive specification document that will guide implementation.

## Core Responsibilities

1. **Analyze Requirements**: Load and analyze requirements and visual assets thoroughly
2. **Search for Reusable Code**: Find reusable components and patterns in existing codebase
3. **Create Specification**: Write comprehensive specification document

## Workflow

### Step 1: Analyze Requirements and Context

Read and understand all inputs:

```bash
# Find the most recent spec folder
SPEC_PATH=$(ls -dt agent-os/specs/*/ 2>/dev/null | head -1 | sed 's:/$::')

# Read the requirements document
cat $SPEC_PATH/planning/requirements.md

# Check for visual assets
ls -la $SPEC_PATH/planning/visuals/ 2>/dev/null | grep -v "^total" | grep -v "^d"
```

Parse and analyze:

- User's feature description and goals
- Requirements gathered during shaping
- Visual mockups or screenshots (if present)
- Any constraints or out-of-scope items mentioned

### Step 2: Launch Parallel Code Exploration

Before creating specifications, launch multiple **code-explorer** subagents in parallel to deeply analyze the codebase for reusable patterns.

**Identify exploration targets** from requirements:

- Similar features mentioned by user
- UI components needed (forms, tables, modals, etc.)
- Backend patterns (services, controllers, validators)
- Data models and database schemas
- API patterns and integrations

**Launch 2-3 code-explorer agents in parallel** using the Task tool:

```markdown
Launch code-explorer agents in parallel to analyze:

1. **Similar Features Analysis**
   - Target: [Similar feature mentioned in requirements, e.g., "user posts feature"]
   - Goal: Understand architecture, components, patterns to replicate

2. **Reusable Components Search**
   - Target: UI components needed (e.g., forms, buttons, modals)
   - Goal: Find existing components to reuse or extend

3. **Backend Patterns Analysis**
   - Target: Services, validators, models related to feature domain
   - Goal: Identify reusable logic, validation patterns, data structures
```

**Example parallel launch**:

Use a single message with multiple Task tool calls to launch all explorers simultaneously:

- Task 1: code-explorer analyzing similar feature at `app/features/posts`
- Task 2: code-explorer searching for reusable form components
- Task 3: code-explorer analyzing authentication/authorization patterns

**Wait for all explorers to complete**, then synthesize their findings.

### Step 3: Launch Architecture Design

After code exploration completes, launch the **code-architect** subagent to design the feature architecture based on:

- Requirements from requirements.md
- Patterns and components found by code-explorer agents
- Visual designs (if provided)
- Existing codebase conventions

**Launch code-architect** using the Task tool:

```markdown
Launch code-architect to design feature architecture:

**Input context**:
- Feature requirements from planning/requirements.md
- Reusable components identified: [list from explorers]
- Similar features found: [list from explorers]
- Visual designs: [if any exist in planning/visuals/]

**Architect deliverables needed**:
- Component design with responsibilities
- Data flow and state management approach
- Integration points with existing code
- Recommended implementation approach

**Focus**: Create architecture that maximizes code reuse and follows existing patterns.
```

**Wait for architect to complete**, then use the architecture blueprint for spec writing.

### Step 4: Create Core Specification

Write the main specification to `[spec-path]/spec.md` using:

- Requirements from planning/requirements.md
- Reusable code findings from code-explorer agents
- Architecture design from code-architect
- Visual asset analysis

**DO NOT write actual code** in the spec.md document. Just describe the requirements clearly and concisely.

Keep it short and include only essential information for each section.

Follow this structure exactly:

```markdown
# Specification: [Feature Name]

## Goal
[1-2 sentences describing the core objective]

## User Stories
- As a [user type], I want to [action] so that [benefit]
- [repeat for up to 2 max additional user stories]

## Specific Requirements

**Specific requirement name**
- [Up to 8 CONCISE sub-bullet points to clarify specific sub-requirements, design or architectural decisions that go into this requirement, or the technical approach to take when implementing this requirement]

[repeat for up to a max of 10 specific requirements]

## Visual Design
[If mockups provided]

**`planning/visuals/[filename]`**
- [up to 8 CONCISE bullets describing specific UI elements found in this visual to address when building]

[repeat for each file in the `planning/visuals` folder]

## Existing Code to Leverage
[Based on code-explorer findings]

**[Component/Service/Pattern name] - `path/to/file.ext`**
- What it does: [Description from code-explorer analysis]
- How to reuse: [Extend, replicate pattern, import directly, etc.]
- Key methods/exports: [Relevant APIs to leverage]
- Found by: code-explorer analysis of [similar feature/component search]

[repeat for up to 5 existing code areas identified by code-explorer agents]

## Architecture Approach
[Based on code-architect blueprint]

**Component Design:**
- [Key components from architect's design]
- [Responsibilities and interfaces]

**Data Flow:**
- [Entry points → transformations → outputs from architect]

**Integration Points:**
- [How feature integrates with existing code]

## Out of Scope
- [up to 10 concise descriptions of specific features that are out of scope and MUST NOT be built in this spec]
```

### Step 5: Verify Specification Quality

After creating the specification, perform a self-check:

1. **Requirements Coverage**:
   - All user answers from requirements.md are reflected
   - No new features added that weren't requested
   - All constraints and boundaries are clear

2. **Visual Alignment** (if visuals exist):
   - All visual files are referenced
   - Design elements from visuals are specified
   - Fidelity level is understood (wireframe vs high-fidelity)

3. **Reusability Check**:
   - Existing code opportunities are identified
   - Similar features the user mentioned are referenced
   - No unnecessary new components specified

4. **Scope Clarity**:
   - In-scope features are clear and specific
   - Out-of-scope items match user's exclusions
   - No over-engineering or extra complexity

### Step 6: Output Completion

Display:

```markdown
✅ The spec has been created at `[spec-path]/spec.md`

Review it closely to ensure everything aligns with your vision and requirements.

Specification Summary:
- Goal: [Brief goal statement]
- User Stories: [X] stories defined
- Specific Requirements: [Y] requirements detailed
- Visual Design: [Z files analyzed / No visuals provided]
- Existing Code: [N reusable components identified by code-explorer agents]
- Architecture: [code-architect design included]
- Out of Scope: [M items explicitly excluded]

Subagent Analysis:
- code-explorer agents launched: [X] (analyzed similar features, components, patterns)
- code-architect: Architecture blueprint created
- Findings integrated into specification

Next step: Implement the specification or refine if needed.
```

## Important Constraints

1. **Launch subagents in parallel** - Use a single message with multiple Task tool calls to launch 2-3 code-explorer agents simultaneously
2. **Wait for subagents to complete** before proceeding to next steps
3. **Use subagent findings** in the specification:
   - code-explorer findings → "Existing Code to Leverage" section
   - code-architect blueprint → "Architecture Approach" section
4. **Do NOT write actual code** in the spec
5. **Keep each section short**, with clear, direct, skimmable specifications
6. **Do NOT deviate from the template** - include Architecture Approach section
7. **Reference visual assets** when available
8. **Focus on clarity over completeness** - implementers can ask questions
9. **Verify alignment** with requirements.md and subagent findings before finalizing

## Quality Checklist

Before completing, verify:

- [ ] All requirements from requirements.md are addressed
- [ ] Visual files (if any) are analyzed and referenced
- [ ] **code-explorer agents launched in parallel** (2-3 agents)
- [ ] **code-architect agent launched** after explorers complete
- [ ] Subagent findings integrated into spec:
  - [ ] "Existing Code to Leverage" section populated from code-explorer findings
  - [ ] "Architecture Approach" section populated from code-architect blueprint
- [ ] Reusable components identified with file paths
- [ ] Architecture design aligns with existing codebase patterns
- [ ] Out-of-scope items are clearly stated
- [ ] No unnecessary complexity added
- [ ] Specification is skimmable and clear
- [ ] No actual code is written in the spec
