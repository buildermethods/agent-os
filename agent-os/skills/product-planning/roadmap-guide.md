# Roadmap Creation Guide

This guide helps you create effective, actionable product roadmaps.

## Overview

A good roadmap:

- Orders features by technical dependencies
- Prioritizes direct path to achieving mission
- Builds incrementally from MVP to full product
- Makes each item concrete, testable, and estimable

## Step-by-Step Process

### 1. Review the Mission

Before creating the roadmap, read `agent-os/product/mission.md` to understand:

- Product goals and vision
- Target users and their needs
- Success criteria
- Key differentiators

### 2. Identify Features

Based on the mission, list all concrete features needed to:

- Solve the core problem
- Serve target users effectively
- Achieve differentiators
- Deliver on key features mentioned in mission

### 3. Order Strategically

Order features considering:

**Technical Dependencies:**

- What must exist before other features can work?
- What provides foundational capabilities?
- What builds on top of other features?

**Mission Alignment:**

- Which features most directly achieve the mission?
- What's the shortest path to delivering core value?
- Which features unlock the most user benefit?

**Incremental Building:**

- Can we start with a minimal version?
- How do we expand from MVP to full product?
- What's the natural progression of capabilities?

### 4. Write Feature Descriptions

Each roadmap item should follow this format:

```markdown
[#]. [ ] [FEATURE_NAME] — [1-2 sentence description] `[EFFORT]`
```

**Feature Name:**

- Short, descriptive, noun-based
- Examples: "User Authentication", "Dashboard Analytics", "Export to PDF"

**Description:**

- 1-2 sentences maximum
- Focus on WHAT users can do when complete
- Make it testable (you should be able to verify it works)
- Include both frontend and backend if applicable

**Effort Estimate:**

- `XS`: 1 day
- `S`: 2-3 days
- `M`: 1 week
- `L`: 2 weeks
- `XL`: 3+ weeks

## Good vs Bad Examples

### ✅ Good Roadmap Items

```markdown
1. [ ] User Authentication — Users can sign up with email/password and log in securely. Includes session management and password reset. `M`

2. [ ] Dashboard Overview — Display key metrics and recent activity on landing page after login. Includes charts and activity feed. `S`

3. [ ] Export to PDF — Users can export reports as formatted PDF documents with custom branding options. `S`
```

**Why these are good:**

- Clear what users can do
- Testable outcomes
- Include relevant scope details
- Reasonable effort estimates

### ❌ Bad Roadmap Items

```markdown
1. [ ] Setup backend infrastructure `L`
2. [ ] Make it look nice `M`
3. [ ] Add some charts `S`
```

**Why these are bad:**

- Too vague or technical
- Not user-focused
- Not testable
- Missing important details

## Roadmap Template

```markdown
# Product Roadmap

1. [ ] [FEATURE_NAME] — [Description of what users can do] `[EFFORT]`
2. [ ] [FEATURE_NAME] — [Description of what users can do] `[EFFORT]`
3. [ ] [FEATURE_NAME] — [Description of what users can do] `[EFFORT]`
4. [ ] [FEATURE_NAME] — [Description of what users can do] `[EFFORT]`
5. [ ] [FEATURE_NAME] — [Description of what users can do] `[EFFORT]`
6. [ ] [FEATURE_NAME] — [Description of what users can do] `[EFFORT]`
7. [ ] [FEATURE_NAME] — [Description of what users can do] `[EFFORT]`
8. [ ] [FEATURE_NAME] — [Description of what users can do] `[EFFORT]`

> Notes
> - Order items by technical dependencies and product architecture
> - Each item should represent an end-to-end (frontend + backend) functional and testable feature
```

## Important Constraints

### DO Include

- ✅ End-to-end features users can interact with
- ✅ Both frontend and backend aspects
- ✅ Features mentioned in the mission
- ✅ Foundational capabilities needed for other features
- ✅ Clear success criteria

### DO NOT Include

- ❌ Bootstrapping or initialization tasks
- ❌ "Setup development environment"
- ❌ "Configure CI/CD"
- ❌ Internal refactoring without user benefit
- ❌ Pure technical debt items

**Assumption:** The codebase already has bare-bones application initialized.

## Validation Checklist

Before finalizing the roadmap, verify:

- [ ] Each item is ordered logically (dependencies first)
- [ ] Each description is 1-2 sentences, user-focused
- [ ] Each item has an effort estimate
- [ ] Each item is testable (clear success criteria)
- [ ] No bootstrapping or initialization tasks
- [ ] Items align with mission document
- [ ] Progression builds from MVP to full product
- [ ] Technical dependencies are respected

## Common Patterns

### MVP Features (Items 1-3)

Start with absolute minimum to deliver core value:

- User authentication (if needed)
- Core feature that solves main problem
- Basic UI to interact with core feature

### Expansion Features (Items 4-6)

Add capabilities that enhance core value:

- Additional user-facing features
- Improved workflows
- Extended functionality

### Advanced Features (Items 7+)

Features that differentiate or delight:

- Collaboration capabilities
- Advanced analytics
- Integrations
- Polish and optimization
