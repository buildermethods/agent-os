---
name: task-breakdown
description: Breaks down feature specs and requirements into strategic, grouped, and ordered implementation tasks. Use when users need help creating task lists, planning implementation phases, organizing development work, or structuring feature development from specifications.
---

# Task Breakdown Skill

This skill helps you systematically transform feature specifications and requirements into actionable implementation tasks. Use this skill when the user needs help planning how to build a feature, organizing development work, or creating structured task lists.

## When to Use This Skill

Activate this skill when users:

- Want to break down a spec into implementation tasks
- Ask to create a task list or implementation plan
- Need help organizing development work
- Want to know the order to implement features
- Ask about implementation strategy or approach
- Need to plan development phases for a feature
- Want to group related tasks together
- Ask how to structure development work

## Task Breakdown Philosophy

The goal is to transform high-level specifications into concrete, actionable tasks that:

1. **Are small to medium in size** - Prefer multiple small tasks over one large task
2. **Are specific and verifiable** - Each task has clear completion criteria
3. **Follow natural dependencies** - Tasks are ordered so prerequisites come first
4. **Group by specialization** - Related work is grouped together (backend, frontend, testing)
5. **Balance detail and clarity** - Tasks are detailed enough to execute but not overwhelming
6. **Support focused testing** - Each phase includes targeted tests, not exhaustive coverage
7. **Align with standards** - Tasks follow project coding conventions and best practices

### Task Size Principle

**CRITICAL**: Always prefer small and medium tasks over large tasks.

**Task Sizing Guidelines**:

- **Small Task**: Can be completed in 15-45 minutes (1-3 file changes, 20-80 lines of code)
- **Medium Task**: Can be completed in 1-2 hours (3-6 file changes, 80-200 lines of code)
- **Large Task**: Takes 3+ hours (7+ file changes, 200+ lines of code) - **AVOID THESE**

**Why Small/Medium Tasks Are Better**:

1. **Easier to estimate** - More predictable completion time
2. **Faster feedback loops** - See progress quickly
3. **Simpler to test** - Each task has focused test scope
4. **Better for tracking** - Clear checkpoints show real progress
5. **Easier to debug** - Smaller scope when issues arise
6. **Less overwhelming** - Builds momentum and confidence
7. **Clearer acceptance criteria** - Simpler to verify completion

**How to Break Down Large Tasks**:

If you find yourself creating a large task, split it:

❌ **Bad (Large Task)**:

```markdown
- [ ] Build entire user authentication system
```

✅ **Good (Small/Medium Tasks)**:

```markdown
- [ ] Create User model with email/password fields
- [ ] Add password hashing with bcrypt
- [ ] Create login endpoint
- [ ] Create registration endpoint
- [ ] Add JWT token generation
- [ ] Create authentication middleware
- [ ] Add password reset flow
```

❌ **Bad (Large Task)**:

```markdown
- [ ] Implement complete dashboard with all widgets
```

✅ **Good (Small/Medium Tasks)**:

```markdown
- [ ] Create Dashboard layout component
- [ ] Build StatsCard widget
- [ ] Build RecentActivity widget
- [ ] Build UserProfile widget
- [ ] Add dashboard data fetching
- [ ] Connect widgets to data
- [ ] Add dashboard responsive styling
```

## Task Breakdown Process

### Phase 1: Analyze Inputs

**Required Files** (need at least one):

- `agent-os/specs/[spec-name]/spec.md` - Full feature specification
- `agent-os/specs/[spec-name]/planning/requirements.md` - Detailed requirements

**Analysis Steps**:

1. Read the complete spec and/or requirements
2. Identify major functional areas (database, API, UI, integrations, etc.)
3. Understand dependencies between components
4. Note any visual assets or design references
5. Review project coding standards for alignment

### Phase 2: Identify Task Groups

Common task group patterns (adapt based on actual needs):

**Database Layer**:

- Data models and validations
- Database migrations
- Model associations and relationships
- Database indexes

**API Layer**:

- Controller/route creation
- Business logic services
- Authentication and authorization
- Request/response formatting
- Error handling

**Frontend Layer**:

- Component creation
- Form implementation
- Page layouts
- Styling and theming
- Responsive design
- Interactions and animations

**Integration Layer**:

- Third-party API integration
- Webhook handling
- Background job processing
- Email/notification systems

**Testing Layer**:

- Review existing tests from other phases
- Identify critical coverage gaps
- Add strategic integration tests
- End-to-end workflow verification

### Phase 3: Create Task Structure

For each task group:

1. **Start with focused tests** (2-8 tests maximum)
   - Test only critical behaviors for this group
   - Skip exhaustive coverage
   - Focus on core functionality

2. **Implementation tasks**
   - Break work into logical sub-tasks
   - Reference existing patterns to follow
   - Include specific technical details
   - Note files/components to create or modify

3. **Verification tasks**
   - Run ONLY the tests from this group
   - Verify core functionality works
   - Do NOT run entire test suite

4. **Acceptance criteria**
   - Define clear completion criteria
   - Specify what "done" looks like
   - Include both technical and functional requirements

### Phase 4: Order and Dependencies

**Ordering Principles**:

1. **Foundation first**: Database models before API before UI
2. **Dependencies**: Required tasks before dependent tasks
3. **Logical flow**: Follow natural development progression
4. **Parallel potential**: Note tasks that can be done concurrently

**Dependency Notation**:

```markdown
#### Task Group 2: API Endpoints
**Dependencies:** Task Group 1
```

## Task Template Structure

```markdown
# Task Breakdown: [Feature Name]

## Overview
Total Tasks: [count]
Estimated Complexity: [Low/Medium/High]

## Task List

### [Layer Name]

#### Task Group N: [Group Name]
**Dependencies:** [None | Task Group X, Y]

- [ ] N.0 Complete [layer name]
  - [ ] N.1 Write 2-8 focused tests for [functionality]
    - Limit to 2-8 highly focused tests maximum
    - Test only critical [specific] behaviors
    - Skip exhaustive coverage
  - [ ] N.2 [Implementation task 1]
    - Detail A
    - Detail B
    - Reuse pattern from: [existing file/component]
  - [ ] N.3 [Implementation task 2]
  - [ ] N.4 Ensure [layer] tests pass
    - Run ONLY the 2-8 tests written in N.1
    - Verify [specific functionality]
    - Do NOT run the entire test suite at this stage

**Acceptance Criteria:**
- The 2-8 tests written in N.1 pass
- [Specific technical requirement]
- [Specific functional requirement]

## Execution Order

Recommended implementation sequence:
1. [Task Group 1] ([reason])
2. [Task Group 2] ([reason])
3. [Task Group 3] ([reason])
```

## Important Constraints

### Task Sizing

**ENFORCE**: All tasks must be small or medium sized. Large tasks are NOT acceptable.

- **Maximum task size**: Medium (1-2 hours)
- **Preferred task size**: Small (15-45 minutes)
- **Signs a task is too large**:
  - Requires changes to 7+ files
  - Involves 200+ lines of code
  - Takes more than 2 hours to complete
  - Has vague or multiple responsibilities
  - Cannot be tested in isolation

**When you encounter a large task**:

1. **Stop** - Do not include it in the task list
2. **Decompose** - Break it into 3-7 smaller tasks
3. **Sequence** - Order the smaller tasks logically
4. **Verify** - Ensure each smaller task is small or medium

**Example Decomposition**:

Instead of:

- ❌ "Build payment system" (LARGE - 8+ hours)

Create:

- ✅ "Add Stripe API credentials to environment" (SMALL - 30 min)
- ✅ "Create Payment model and migration" (SMALL - 45 min)
- ✅ "Create payment intent endpoint" (MEDIUM - 90 min)
- ✅ "Create payment confirmation endpoint" (MEDIUM - 90 min)
- ✅ "Add Stripe webhook handler" (MEDIUM - 2 hours)
- ✅ "Create PaymentForm component" (MEDIUM - 90 min)
- ✅ "Add payment success/failure pages" (SMALL - 45 min)

### Testing Strategy

- **Each development phase**: Write 2-8 focused tests maximum
- **Test scope**: Cover only critical behaviors, not edge cases
- **Test execution**: Run ONLY new tests, not entire suite
- **Final testing phase**: Add maximum of 10 additional strategic tests to fill gaps
- **Total feature tests**: Approximately 16-34 tests for the entire feature

### Task Specificity

**Good tasks**:

```markdown
- [ ] Create User model with email validation
  - Fields: email (string, required), name (string), created_at (timestamp)
  - Validations: email format, email uniqueness
  - Reuse pattern from: app/models/account.rb
```

**Bad tasks**:

```markdown
- [ ] Set up the database
- [ ] Make the backend work
- [ ] Create user stuff
```

### Task Grouping

**Group related work together**:

- All database work in one group
- All API/backend logic in another
- All frontend/UI in another
- Integration/external services together
- Testing review as final phase

**Don't mix unrelated work**:

- Database + frontend in same group
- API + styling in same group
- Testing scattered throughout

## Standards Alignment

Before finalizing tasks, ensure alignment with:

**Global Standards** (`~/.claude/CLAUDE.md`):

- Coding conventions (naming, formatting, structure)
- Testing requirements and coverage expectations
- Error handling patterns
- Documentation standards

**Project Standards** (`CLAUDE.md` if exists):

- Project-specific patterns
- Technology stack choices
- Architecture preferences
- Team conventions

## Visual Asset References

If the spec includes visual designs:

- Reference mockup files in task descriptions
- Note design system components to reuse
- Specify responsive breakpoints
- Include style guide references

Example:

```markdown
- [ ] 3.4 Build Dashboard page
  - Layout: Two-column grid as shown in `planning/visuals/dashboard-mockup.png`
  - Components: Header, SideNav, StatsCards, ActivityFeed
  - Match mockup: `planning/visuals/dashboard-mockup.png`
  - Use design system: `styles/design-system.css`
```

## Common Patterns

### Full-Stack CRUD Feature

1. **Database**: Model + migration + associations
2. **API**: Controller + routes + auth + validation
3. **Frontend**: List view + detail view + form + styling
4. **Testing**: Integration tests for critical workflows

### Integration Feature

1. **Configuration**: API credentials + environment setup
2. **Integration Layer**: API client + webhook handlers
3. **Business Logic**: Service layer + data transformations
4. **Error Handling**: Retry logic + failure notifications
5. **Testing**: Integration tests with mocked external calls

### UI Enhancement

1. **Component Design**: New components + styling
2. **State Management**: Data flow + event handling
3. **Responsive Design**: Breakpoints + mobile/tablet/desktop
4. **Interactions**: Animations + transitions + loading states
5. **Testing**: Component behavior + interaction tests

## Output Format

After creating tasks, always output the file location:

```markdown
✅ The tasks list has been created at `agent-os/specs/[spec-name]/tasks.md`.

Review it closely to make sure it all looks good.

NEXT STEP 👉 You can now implement these tasks manually, or use implementation commands if available.
```

## Tips for Success

1. **Keep tasks small/medium**: Break large tasks into smaller ones - this is CRITICAL
2. **Read everything first**: Fully understand spec before creating tasks
3. **Think in layers**: Organize by architectural layers or functional areas
4. **Be concrete**: Include specific files, fields, methods, components
5. **Show dependencies**: Make task order clear and logical
6. **Reference patterns**: Point to existing code to follow
7. **Keep tests focused**: Resist urge for comprehensive coverage
8. **Add acceptance criteria**: Define clear "done" state
9. **Check alignment**: Verify tasks match coding standards
10. **Consider the developer**: Would someone else understand these tasks?
11. **Verify task size**: Before finalizing, ensure no task is too large
12. **Adapt the template**: Don't force tasks into wrong structure

## Example Applications

### Small Feature (5-10 tasks)

Simple features might only need:

- One backend task group (model + API)
- One frontend task group (component + page)
- One testing task group (integration tests)

### Medium Feature (15-25 tasks)

Standard features typically include:

- Database layer (models + migrations)
- API layer (controllers + services)
- Frontend layer (components + pages + styling)
- Testing layer (gap analysis + integration tests)

### Large Feature (30+ tasks)

Complex features might need:

- Multiple database task groups (different models)
- Multiple API task groups (different resources)
- Multiple frontend task groups (different pages/flows)
- Integration task group (external services)
- Background job task group (async processing)
- Testing layer (comprehensive integration coverage)

## Remember

- **ALWAYS break down large tasks**: This is the #1 rule - no large tasks allowed
- **Small/medium tasks only**: Each task should be completable in under 2 hours
- **Adapt to the feature**: Don't force tasks into templates
- **Stay focused**: Each task group should be cohesive
- **Think dependencies**: Order matters for smooth implementation
- **Be specific**: Generic tasks lead to confusion
- **Test strategically**: Cover critical paths, not every edge case
- **Align with standards**: Follow project conventions throughout
- **Consider the builder**: Tasks should guide, not overwhelm
- **Verify before finalizing**: Review all tasks to ensure none are too large
