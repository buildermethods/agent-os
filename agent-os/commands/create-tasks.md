---
description: Create an actionable tasks breakdown from a spec and requirements for a new feature
---

# Create Tasks

You are helping to create a comprehensive tasks breakdown from a given spec and requirements for a new feature. This command guides you through a systematic 2-phase process to transform specifications into actionable implementation tasks.

## Overview

This command will help you:

- **Validate Inputs**: Ensure spec.md and/or requirements.md are available
- **Create Tasks List**: Break down requirements into strategic, grouped, and ordered tasks

## Process

Follow these phases sequentially. Do not skip ahead until the current phase is complete.

---

## Phase 1: Get Spec and Requirements

### Step 1: Locate Required Files

Check for ONE OR BOTH of these files to inform your tasks breakdown:

- `agent-os/specs/[this-spec]/spec.md`
- `agent-os/specs/[this-spec]/planning/requirements.md`

Where `[this-spec]` is the name/folder for the feature specification.

### Step 2: Validate Availability

If you don't have ONE OR BOTH of those files in your current conversation context, ask the user:

```markdown
I'll need a spec.md or requirements.md (or both) in order to build a tasks list.

Please direct me to where I can find those. If you haven't created them yet, you can run /shape-spec or /write-spec.
```

### Step 3: Confirm and Proceed

Once you've confirmed you have the spec and/or requirements, output:

```markdown
✅ I have the spec and requirements from `[spec and requirements path]`.

Proceeding to Phase 2: Create Tasks List...
```

---

## Phase 2: Create Tasks List

### Core Responsibilities

Now that you have the spec.md AND/OR requirements.md, break those down into an actionable tasks list with strategic grouping and ordering:

1. **Analyze spec and requirements**: Read and analyze the spec.md and/or requirements.md thoroughly
2. **Plan task execution order**: Break requirements into tasks ordered by dependencies
3. **Group tasks by specialization**: Group tasks requiring the same skill/stack (backend, api, ui design, etc.)
4. **Create Tasks list**: Generate markdown tasks list broken into groups with sub-tasks

### Step 1: Analyze Spec & Requirements

Read each of these files (whichever are available) and analyze them to understand the requirements:

- `agent-os/specs/[this-spec]/spec.md`
- `agent-os/specs/[this-spec]/planning/requirements.md`

Use your learnings to inform the tasks list and groupings you will create in the next step.

### Step 2: Create Tasks Breakdown

Generate `agent-os/specs/[current-spec]/tasks.md`.

**Important**: The exact tasks, task groups, and organization will vary based on the feature's specific requirements. The following is an example format - adapt the content to match what THIS feature actually needs.

#### Example Task Structure

```markdown
# Task Breakdown: [Feature Name]

## Overview
Total Tasks: [count]

## Task List

### Database Layer

#### Task Group 1: Data Models and Migrations
**Dependencies:** None

- [ ] 1.0 Complete database layer
  - [ ] 1.1 Write 2-8 focused tests for [Model] functionality
    - Limit to 2-8 highly focused tests maximum
    - Test only critical model behaviors
    - Skip exhaustive coverage of all methods and edge cases
  - [ ] 1.2 Create [Model] with validations
    - Fields: [list]
    - Validations: [list]
    - Reuse pattern from: [existing model if applicable]
  - [ ] 1.3 Create migration for [table]
    - Add indexes for: [fields]
    - Foreign keys: [relationships]
  - [ ] 1.4 Set up associations
    - [Model] has_many [related]
    - [Model] belongs_to [parent]
  - [ ] 1.5 Ensure database layer tests pass
    - Run ONLY the 2-8 tests written in 1.1
    - Verify migrations run successfully
    - Do NOT run the entire test suite at this stage

**Acceptance Criteria:**
- The 2-8 tests written in 1.1 pass
- Models pass validation tests
- Migrations run successfully
- Associations work correctly

### API Layer

#### Task Group 2: API Endpoints
**Dependencies:** Task Group 1

- [ ] 2.0 Complete API layer
  - [ ] 2.1 Write 2-8 focused tests for API endpoints
    - Limit to 2-8 highly focused tests maximum
    - Test only critical controller actions
    - Skip exhaustive testing of all actions and scenarios
  - [ ] 2.2 Create [resource] controller
    - Actions: index, show, create, update, destroy
    - Follow pattern from: [existing controller]
  - [ ] 2.3 Implement authentication/authorization
    - Use existing auth pattern
    - Add permission checks
  - [ ] 2.4 Add API response formatting
    - JSON responses
    - Error handling
    - Status codes
  - [ ] 2.5 Ensure API layer tests pass
    - Run ONLY the 2-8 tests written in 2.1
    - Verify critical CRUD operations work
    - Do NOT run the entire test suite at this stage

**Acceptance Criteria:**
- The 2-8 tests written in 2.1 pass
- All CRUD operations work
- Proper authorization enforced
- Consistent response format

### Frontend Components

#### Task Group 3: UI Design
**Dependencies:** Task Group 2

- [ ] 3.0 Complete UI components
  - [ ] 3.1 Write 2-8 focused tests for UI components
    - Limit to 2-8 highly focused tests maximum
    - Test only critical component behaviors
    - Skip exhaustive testing of all component states
  - [ ] 3.2 Create [Component] component
    - Reuse: [existing component] as base
    - Props: [list]
    - State: [list]
  - [ ] 3.3 Implement [Feature] form
    - Fields: [list]
    - Validation: client-side
    - Submit handling
  - [ ] 3.4 Build [View] page
    - Layout: [description]
    - Components: [list]
    - Match mockup: `planning/visuals/[file]`
  - [ ] 3.5 Apply base styles
    - Follow existing design system
    - Use variables from: [style file]
  - [ ] 3.6 Implement responsive design
    - Mobile: 320px - 768px
    - Tablet: 768px - 1024px
    - Desktop: 1024px+
  - [ ] 3.7 Add interactions and animations
    - Hover states
    - Transitions
    - Loading states
  - [ ] 3.8 Ensure UI component tests pass
    - Run ONLY the 2-8 tests written in 3.1
    - Verify critical component behaviors work
    - Do NOT run the entire test suite at this stage

**Acceptance Criteria:**
- The 2-8 tests written in 3.1 pass
- Components render correctly
- Forms validate and submit
- Matches visual design

### Testing

#### Task Group 4: Test Review & Gap Analysis
**Dependencies:** Task Groups 1-3

- [ ] 4.0 Review existing tests and fill critical gaps only
  - [ ] 4.1 Review tests from Task Groups 1-3
    - Review the 2-8 tests written by database-engineer (Task 1.1)
    - Review the 2-8 tests written by api-engineer (Task 2.1)
    - Review the 2-8 tests written by ui-designer (Task 3.1)
    - Total existing tests: approximately 6-24 tests
  - [ ] 4.2 Analyze test coverage gaps for THIS feature only
    - Identify critical user workflows that lack test coverage
    - Focus ONLY on gaps related to this spec's feature requirements
    - Do NOT assess entire application test coverage
    - Prioritize end-to-end workflows over unit test gaps
  - [ ] 4.3 Write up to 10 additional strategic tests maximum
    - Add maximum of 10 new tests to fill identified critical gaps
    - Focus on integration points and end-to-end workflows
    - Do NOT write comprehensive coverage for all scenarios
    - Skip edge cases, performance tests, accessibility tests unless business-critical
  - [ ] 4.4 Run feature-specific tests only
    - Run ONLY tests related to this spec's feature
    - Expected total: approximately 16-34 tests maximum
    - Do NOT run the entire application test suite
    - Verify critical workflows pass

**Acceptance Criteria:**
- All feature-specific tests pass (approximately 16-34 tests total)
- Critical user workflows for this feature are covered
- No more than 10 additional tests added when filling in testing gaps
- Testing focused exclusively on this spec's feature requirements

## Execution Order

Recommended implementation sequence:
1. Database Layer (Task Group 1)
2. API Layer (Task Group 2)
3. Frontend Design (Task Group 3)
4. Test Review & Gap Analysis (Task Group 4)
```

**Note**: Adapt this structure based on the actual feature requirements. Some features may need:

- Different task groups (e.g., email notifications, payment processing, data migration)
- Different execution order based on dependencies
- More or fewer sub-tasks per group

### Important Constraints

When creating the tasks list:

- **Create tasks that are specific and verifiable**
- **Group related tasks**: Group back-end engineering tasks together and front-end UI tasks together
- **Limit test writing during development**:
  - Each task group (1-3) should write 2-8 focused tests maximum
  - Tests should cover only critical behaviors, not exhaustive coverage
  - Test verification should run ONLY the newly written tests, not the entire suite
  - Dedicated test coverage group should add only a maximum of 10 additional tests IF NECESSARY
- **Use a focused test-driven approach** where each task group starts with writing 2-8 tests (x.1 sub-task) and ends with running ONLY those tests (final sub-task)
- **Include acceptance criteria** for each task group
- **Reference visual assets** if visuals are available in `planning/visuals/`

### User Standards & Preferences Compliance

**IMPORTANT**: Ensure that the tasks list is ALIGNED and DOES NOT CONFLICT with the user's preferences and standards. Review the user's global coding standards from `~/.claude/CLAUDE.md` and project-specific standards from `CLAUDE.md` if available.

### Step 3: Display Confirmation

After creating the tasks list, display:

```markdown
✅ The tasks list has been created at `agent-os/specs/[this-spec]/tasks.md`.

Review it closely to make sure it all looks good.

NEXT STEP 👉 You can now implement these tasks manually, or use /implement-tasks or /orchestrate-tasks commands if available.
```

---

## Tips for Success

- **Be Thorough**: Analyze the spec completely before creating tasks
- **Think in Phases**: Group related work together logically
- **Consider Dependencies**: Order tasks so prerequisites come first
- **Be Specific**: Each task should be clear and actionable
- **Stay Focused**: Keep tests minimal and targeted during development
- **Verify Alignment**: Ensure tasks match user's coding standards

## Common Task Groups

Depending on your feature, you might need task groups for:

- Database models and migrations
- API endpoints and business logic
- Frontend components and pages
- Authentication and authorization
- Third-party integrations
- Email/notification systems
- Background jobs and queues
- Admin interfaces
- Documentation
- Testing and QA
