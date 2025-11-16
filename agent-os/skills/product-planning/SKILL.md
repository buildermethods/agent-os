---
name: product-planning
description: Guides systematic product planning by gathering product information, creating mission documents, building roadmaps, and documenting tech stack. Use when users need help defining their product vision, planning features, or documenting product strategy.
---

# Product Planning Skill

This skill helps you systematically plan and document a product through a structured 4-phase process. Use this skill when the user needs help with product strategy, feature planning, or creating product documentation.

## When to Use This Skill

Activate this skill when users:

- Want to plan a new product
- Need help defining product vision and mission
- Ask to create a product roadmap
- Want to document their tech stack
- Need to organize features strategically
- Ask about product planning best practices

## Planning Process

This skill guides you through 4 sequential phases:

### Phase 1: Gather Product Information

Collect comprehensive details from the user:

**Required Information:**

- **Product Idea**: Core concept and purpose
- **Key Features**: Minimum 3 features with descriptions
- **Target Users**: At least 1 user segment with use cases
- **Tech Stack**: Technology choices or confirmation of defaults

**Process:**

1. Check if `agent-os/product/` directory exists
2. If exists, ask user whether to review or start fresh
3. Prompt for missing required information
4. Confirm all information before proceeding

**Prompt Template:**

```markdown
Please provide the following to create your product plan:
1. Main idea for the product
2. List of key features (minimum 3)
3. Target users and use cases (minimum 1)
4. Will this product use your usual tech stack choices or deviate in any way?
```

### Phase 2: Create Mission Document

Generate `agent-os/product/mission.md` with comprehensive product definition.

**Mission Structure:**

- **Pitch**: One-sentence value proposition
- **Users**: Primary customers and detailed personas
- **The Problem**: Problem statement and solution approach
- **Differentiators**: How you're different from alternatives
- **Key Features**: Categorized feature list

**Important Guidelines:**

- Focus on user benefits, not technical implementation
- Keep content concise and scannable
- Use quantifiable impacts where possible
- Emphasize strategic advantages

**See:** [mission-template.md](mission-template.md) for complete structure

### Phase 3: Build Roadmap

Generate `agent-os/product/roadmap.md` with prioritized feature checklist.

**Roadmap Creation Process:**

1. Review mission to understand goals and success criteria
2. Identify concrete features needed for product vision
3. Order strategically based on:
   - Technical dependencies (foundational features first)
   - Most direct path to achieving mission
   - MVP to full product progression

**Feature Format:**

```markdown
1. [ ] [FEATURE_NAME] — [1-2 sentence description] `[EFFORT]`
```

**Effort Scale:**

- `XS`: 1 day
- `S`: 2-3 days
- `M`: 1 week
- `L`: 2 weeks
- `XL`: 3+ weeks

**Important Constraints:**

- Each item must be end-to-end functional and testable
- Include both frontend and backend when applicable
- Do NOT include bootstrapping or initialization tasks
- Assume bare-bones application already exists

**See:** [roadmap-guide.md](roadmap-guide.md) for detailed guidance

### Phase 4: Document Tech Stack

Generate `agent-os/product/tech-stack.md` with comprehensive technical choices.

**Information Sources (in priority order):**

1. User-provided tech stack information (highest priority)
2. User's global standards in `~/.claude/CLAUDE.md`
3. Project-level `CLAUDE.md` or `agents.md`

**Process:**

1. Note any tech stack details user mentioned
2. Read available documentation sources
3. Reconcile information from all sources
4. Create comprehensive tech stack document

**See:** [tech-stack-template.md](tech-stack-template.md) for structure

## Output Files

This skill creates three key documents:

1. **`agent-os/product/mission.md`** - Product definition and strategy
2. **`agent-os/product/roadmap.md`** - Prioritized feature checklist
3. **`agent-os/product/tech-stack.md`** - Technical stack documentation

## Best Practices

### Sequential Execution

- Complete each phase fully before proceeding
- Wait for user confirmation between phases
- Don't skip ahead or combine phases

### User Alignment

- Ensure documents align with user's standards
- Reference user's CLAUDE.md for preferences
- Ask clarifying questions when needed

### Document Quality

- Keep content concise and scannable
- Focus on "why" over "what"
- Use clear, actionable language
- Include quantifiable metrics where possible

### Roadmap Ordering

- Start with MVP features
- Build incrementally toward full vision
- Order by technical dependencies
- Prioritize features that directly achieve mission

## Phase Completion Messages

### After Phase 1

```markdown
I have all the info I need to help you plan this product:
- Product: [NAME]
- Key Features: [LIST]
- Target Users: [LIST]
- Tech Stack: [NOTES]

Ready to proceed to creating the mission document?
```

### After Phase 2

```markdown
✅ I have documented the product mission at `agent-os/product/mission.md`.

Review it to ensure it matches your vision and strategic goals.

Ready to proceed to creating the roadmap?
```

### After Phase 3

```markdown
✅ I have documented the product roadmap at `agent-os/product/roadmap.md`.

Review it to ensure it aligns with how you see the product roadmap.

Ready to proceed to documenting the tech stack?
```

### After Phase 4

```markdown
✅ I have documented the product's tech stack at `agent-os/product/tech-stack.md`.

Review it to ensure all tech stack details are correct.

You're ready to start planning feature specs using `/shape-spec` or `/write-spec`.
```

## Related Commands

- `/plan-product` - User-invoked command that uses this skill
- `/shape-spec` - Next step: Shape feature specifications
- `/write-spec` - Next step: Write detailed specifications

## Supporting Files

- [mission-template.md](mission-template.md) - Complete mission document structure
- [roadmap-guide.md](roadmap-guide.md) - Detailed roadmap creation guidance
- [tech-stack-template.md](tech-stack-template.md) - Tech stack documentation template
