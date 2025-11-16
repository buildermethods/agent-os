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

### Step 2: Search for Reusable Code

Before creating specifications, search the codebase for existing patterns and components that can be reused.

Based on the feature requirements, identify relevant keywords and search for:
- Similar features or functionality
- Existing UI components that match your needs
- Models, services, or controllers with related logic
- API patterns that could be extended
- Database structures that could be reused

Use appropriate search tools to find:
- Components that can be reused or extended
- Patterns to follow from similar features
- Naming conventions used in the codebase
- Architecture patterns already established

Document your findings for use in the specification.

### Step 3: Create Core Specification

Write the main specification to `[spec-path]/spec.md`.

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

**Code, component, or existing logic found**
- [up to 5 bullets that describe what this existing code does and how it should be re-used or replicated when building this spec]

[repeat for up to 5 existing code areas]

## Out of Scope
- [up to 10 concise descriptions of specific features that are out of scope and MUST NOT be built in this spec]
```

### Step 4: Verify Specification Quality

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

### Step 5: Output Completion

Display:
```bash
✅ The spec has been created at `[spec-path]/spec.md`

Review it closely to ensure everything aligns with your vision and requirements.

Specification Summary:
- Goal: [Brief goal statement]
- User Stories: [X] stories defined
- Specific Requirements: [Y] requirements detailed
- Visual Design: [Z files analyzed / No visuals provided]
- Existing Code: [N reusable components identified / Starting fresh]
- Out of Scope: [M items explicitly excluded]

Next step: Implement the specification or refine if needed.
```

## Important Constraints

1. **Always search for reusable code** before specifying new components
2. **Reference visual assets** when available
3. **Do NOT write actual code** in the spec
4. **Keep each section short**, with clear, direct, skimmable specifications
5. **Do NOT deviate from the template** and do not add additional sections
6. **Focus on clarity over completeness** - implementers can ask questions
7. **Verify alignment** with requirements.md before finalizing

## Quality Checklist

Before completing, verify:
- [ ] All requirements from requirements.md are addressed
- [ ] Visual files (if any) are analyzed and referenced
- [ ] Existing similar code is identified and noted
- [ ] Out-of-scope items are clearly stated
- [ ] No unnecessary complexity added
- [ ] Specification is skimmable and clear
- [ ] No actual code is written in the spec
