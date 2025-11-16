---
description: Plan and document the mission, roadmap, and tech stack for the current product
---

# Plan Product

You are helping to plan and document the mission, roadmap, and tech stack for the current product. This command guides you through a systematic 4-phase planning process.

## Overview

This command will help you:

- **Gather Information**: Product vision, user personas, problems, and key features
- **Create Mission Document**: Comprehensive product definition with users, problems, and differentiators
- **Build Roadmap**: Phased development plan with prioritized, actionable features
- **Define Tech Stack**: Document technical choices for all aspects of the codebase

## Process

Follow these phases sequentially. Do not skip ahead until the current phase is complete.

---

## Phase 1: Gather Product Information

### Step 1: Check for Existing Documentation

Check if product documentation already exists:

```bash
if [ -d "agent-os/product" ]; then
    echo "Product documentation already exists. Review existing files or start fresh?"
    ls -la agent-os/product/
fi
```

### Step 2: Collect Required Information

Gather from the user:

- **Product Idea**: Core concept and purpose (required)
- **Key Features**: Minimum 3 features with descriptions
- **Target Users**: At least 1 user segment with use cases
- **Tech Stack**: Confirmation or info regarding the product's tech stack choices

If any required information is missing, prompt:

```markdown
Please provide the following to create your product plan:
1. Main idea for the product
2. List of key features (minimum 3)
3. Target users and use cases (minimum 1)
4. Will this product use your usual tech stack choices or deviate in any way?
```

### Step 3: Confirm Information

Once all information is gathered, create a todo list and confirm with the user:

```markdown
I have all the info I need to help you plan this product:
- Product: [PRODUCT_NAME]
- Key Features: [LIST]
- Target Users: [LIST]
- Tech Stack: [NOTES]

Ready to proceed to Phase 2?
```

---

## Phase 2: Create Mission Document

### Mission Structure

Create `agent-os/product/mission.md` with this structure:

```markdown
# Product Mission

## Pitch
[PRODUCT_NAME] is a [PRODUCT_TYPE] that helps [TARGET_USERS] [SOLVE_PROBLEM]
by providing [KEY_VALUE_PROPOSITION].

## Users

### Primary Customers
- [CUSTOMER_SEGMENT_1]: [DESCRIPTION]
- [CUSTOMER_SEGMENT_2]: [DESCRIPTION]

### User Personas
**[USER_TYPE]** ([AGE_RANGE])
- **Role:** [JOB_TITLE/CONTEXT]
- **Context:** [BUSINESS/PERSONAL_CONTEXT]
- **Pain Points:** [SPECIFIC_PROBLEMS]
- **Goals:** [DESIRED_OUTCOMES]

## The Problem

### [PROBLEM_TITLE]
[PROBLEM_DESCRIPTION]. [QUANTIFIABLE_IMPACT].

**Our Solution:** [SOLUTION_APPROACH]

## Differentiators

### [DIFFERENTIATOR_TITLE]
Unlike [COMPETITOR/ALTERNATIVE], we provide [SPECIFIC_ADVANTAGE].
This results in [MEASURABLE_BENEFIT].

## Key Features

### Core Features
- **[FEATURE_NAME]:** [USER_BENEFIT_DESCRIPTION]

### Collaboration Features
- **[FEATURE_NAME]:** [USER_BENEFIT_DESCRIPTION]

### Advanced Features
- **[FEATURE_NAME]:** [USER_BENEFIT_DESCRIPTION]
```

### Important Constraints

- **Focus on user benefits** in feature descriptions, not technical details
- **Keep it concise** and easy for users to scan and get the more important concepts quickly

### Completion

Once mission.md is created, output:

```markdown
✅ I have documented the product mission at `agent-os/product/mission.md`.

Review it to ensure it matches your vision and strategic goals for this product.

Ready to proceed to Phase 3?
```

---

## Phase 3: Create Roadmap

### Step 1: Review the Mission

Read `agent-os/product/mission.md` to understand the product's goals, target users, and success criteria.

### Step 2: Identify Features

Based on the mission, determine the list of concrete features needed to achieve the product vision.

### Step 3: Strategic Ordering

Order features based on:

- Technical dependencies (foundational features first)
- Most direct path to achieving the mission
- Building incrementally from MVP to full product

### Step 4: Create the Roadmap

Create `agent-os/product/roadmap.md`:

```markdown
# Product Roadmap

1. [ ] [FEATURE_NAME] — [1-2 SENTENCE DESCRIPTION OF COMPLETE, TESTABLE FEATURE] `[EFFORT]`
2. [ ] [FEATURE_NAME] — [1-2 SENTENCE DESCRIPTION OF COMPLETE, TESTABLE FEATURE] `[EFFORT]`
3. [ ] [FEATURE_NAME] — [1-2 SENTENCE DESCRIPTION OF COMPLETE, TESTABLE FEATURE] `[EFFORT]`
4. [ ] [FEATURE_NAME] — [1-2 SENTENCE DESCRIPTION OF COMPLETE, TESTABLE FEATURE] `[EFFORT]`
5. [ ] [FEATURE_NAME] — [1-2 SENTENCE DESCRIPTION OF COMPLETE, TESTABLE FEATURE] `[EFFORT]`
6. [ ] [FEATURE_NAME] — [1-2 SENTENCE DESCRIPTION OF COMPLETE, TESTABLE FEATURE] `[EFFORT]`
7. [ ] [FEATURE_NAME] — [1-2 SENTENCE DESCRIPTION OF COMPLETE, TESTABLE FEATURE] `[EFFORT]`
8. [ ] [FEATURE_NAME] — [1-2 SENTENCE DESCRIPTION OF COMPLETE, TESTABLE FEATURE] `[EFFORT]`

> Notes
> - Order items by technical dependencies and product architecture
> - Each item should represent an end-to-end (frontend + backend) functional and testable feature
```

**Effort Scale:**

- `XS`: 1 day
- `S`: 2-3 days
- `M`: 1 week
- `L`: 2 weeks
- `XL`: 3+ weeks

### Important Constraints

- **Make roadmap actionable** - include effort estimates and dependencies
- **Priorities guided by mission** - Aim for the most direct path to achieving the mission
- **Ensure phases are achievable** - Start with MVP, build incrementally
- **Do not include** tasks for initializing a new codebase or bootstrapping (assume bare-bones app exists)

### Completion

Once roadmap.md is created, output:

```markdown
✅ I have documented the product roadmap at `agent-os/product/roadmap.md`.

Review it to ensure it aligns with how you see this product roadmap going forward.

Ready to proceed to Phase 4?
```

---

## Phase 4: Document Tech Stack

### Step 1: Note User's Tech Stack Input

If the user provided specific tech stack information in the current conversation, these notes ALWAYS take precedence. They must be reflected in the final document.

### Step 2: Gather Default Tech Stack Information

Fill in remaining gaps by reading tech stack information from these sources (in order):

1. User's global standards in `~/.claude/CLAUDE.md`
2. Project-level documentation:
   - `CLAUDE.md`
   - `agents.md`

### Step 3: Create the Tech Stack Document

Create `agent-os/product/tech-stack.md` with a comprehensive list of all technical stack choices, reconciled between:

- User-provided information
- Information found in documentation sources

### Completion

Once tech-stack.md is created, output:

```markdown
✅ I have documented the product's tech stack at `agent-os/product/tech-stack.md`.

Review it to ensure all of the tech stack details are correct for this product.

You're ready to start planning a feature spec! You can do so by running `/shape-spec` or `/write-spec`.
```

---

## Best Practices

1. **Sequential Execution**: Complete each phase fully before moving to the next
2. **User Confirmation**: Wait for user approval before proceeding to next phase
3. **Alignment**: Ensure mission, roadmap, and tech stack are aligned with user's standards
4. **Clarity**: Keep documents concise, scannable, and focused on user benefits
5. **Actionability**: Make roadmap items concrete, testable, and estimable
