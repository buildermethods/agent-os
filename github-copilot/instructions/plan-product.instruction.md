# Product Planning for GitHub Copilot

## Purpose
Generate comprehensive product documentation for new projects using Agent OS methodology. This creates the foundation for systematic, spec-driven development.

## When to Use
- Starting a new product or project
- Need to establish clear product vision and technical direction
- Setting up Agent OS workflow for the first time in a repository

## What This Creates
- `@.agent-os/product/mission-lite.md` - Core product vision and goals
- `@.agent-os/product/tech-stack.md` - Technology choices and rationale  
- `@.agent-os/product/roadmap.md` - Feature roadmap with priorities
- `@.agent-os/product/decisions.md` - Key architectural and product decisions

## Required Information

Before starting, gather:

### Product Basics
- **Main idea**: Clear description of what the product does
- **Key features**: At least 3 core features (be specific)
- **Target users**: Who will use this product (be specific about user types)

### Technical Details
- **Primary language**: JavaScript, Python, etc.
- **Framework**: React, Next.js, Django, etc.
- **Database**: PostgreSQL, MongoDB, etc.
- **Deployment**: Vercel, AWS, Railway, etc.

## Step-by-Step Process

### 1. Validate Input Requirements
Ensure you have all required information listed above. If missing any details, ask the user before proceeding.

### 2. Create Product Directory Structure
```bash
mkdir -p @.agent-os/product
```

### 3. Generate Mission Document
Create `@.agent-os/product/mission-lite.md` with:
- Product name and tagline
- Core problem being solved
- Target user personas
- Key value propositions
- Success metrics

Use this template structure:
```markdown
# [Product Name]

## Mission
[One sentence describing the core purpose]

## Problem
[2-3 sentences describing the problem you're solving]

## Target Users
- **[User Type 1]**: [Description and pain points]
- **[User Type 2]**: [Description and pain points]

## Key Features
1. **[Feature 1]**: [User benefit]
2. **[Feature 2]**: [User benefit]
3. **[Feature 3]**: [User benefit]

## Success Metrics
- [Metric 1]
- [Metric 2]
- [Metric 3]
```

### 4. Generate Tech Stack Document
Create `@.agent-os/product/tech-stack.md` with:
- Technology choices for each layer
- Rationale for each choice
- Integration considerations
- Development workflow tools

### 5. Generate Initial Roadmap
Create `@.agent-os/product/roadmap.md` with:
- MVP features (Phase 1)
- Post-MVP enhancements (Phase 2+)
- Future considerations
- Status tracking structure

### 6. Initialize Decisions Log
Create `@.agent-os/product/decisions.md` with:
- Template for documenting key decisions
- Initial architectural decisions
- Process for ongoing decision tracking

## Quality Checklist

Before completing, verify:
- [ ] All four product files created
- [ ] Mission is clear and specific
- [ ] Tech stack choices are justified
- [ ] Roadmap has clear phases
- [ ] Decisions template is ready for use

## Next Steps

After completing product planning:
1. Review documents with stakeholders
2. Create first feature spec using `@.github/instructions/create-spec.instruction.md`
3. Begin implementation with `@.github/instructions/execute-tasks.instruction.md`

## Integration with Agent OS

This process creates the foundation documents that other Agent OS workflows reference:
- Specs reference mission and roadmap
- Task execution follows tech stack guidelines
- Decisions inform ongoing development choices

All subsequent Agent OS workflows assume these product documents exist and are up-to-date.
