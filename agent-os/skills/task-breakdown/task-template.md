# Task List Template

This template provides the standard structure for creating task breakdowns. Adapt sections based on the feature's actual requirements.

## Basic Template

```markdown
# Task Breakdown: [Feature Name]

## Overview
Total Tasks: [count]
Estimated Complexity: [Low/Medium/High]
Primary Stack: [e.g., Rails + React, Node + Vue, etc.]

## Task List

### Database Layer

#### Task Group 1: Data Models and Migrations
**Dependencies:** None

- [ ] 1.0 Complete database layer
  - [ ] 1.1 Write 2-8 focused tests for [Model] functionality
    - Limit to 2-8 highly focused tests maximum
    - Test only critical model behaviors (e.g., primary validation, key association, core method)
    - Skip exhaustive coverage of all methods and edge cases
  - [ ] 1.2 Create [Model] with validations
    - Fields: [field1 (type, constraints), field2, field3]
    - Validations: [validation rules]
    - Reuse pattern from: [existing model if applicable]
  - [ ] 1.3 Create migration for [table_name]
    - Add indexes for: [frequently queried fields]
    - Foreign keys: [relationship fields]
    - Constraints: [NOT NULL, UNIQUE, etc.]
  - [ ] 1.4 Set up model associations
    - [Model] has_many [related]
    - [Model] belongs_to [parent]
    - [Other associations]
  - [ ] 1.5 Ensure database layer tests pass
    - Run ONLY the 2-8 tests written in 1.1
    - Verify migrations run successfully
    - Verify associations work correctly
    - Do NOT run the entire test suite at this stage

**Acceptance Criteria:**
- The 2-8 tests written in 1.1 pass
- Models pass validation tests
- Migrations run successfully without errors
- Associations work correctly

### API Layer

#### Task Group 2: API Endpoints
**Dependencies:** Task Group 1

- [ ] 2.0 Complete API layer
  - [ ] 2.1 Write 2-8 focused tests for API endpoints
    - Limit to 2-8 highly focused tests maximum
    - Test only critical controller actions (e.g., primary CRUD operation, auth check, key error case)
    - Skip exhaustive testing of all actions and scenarios
  - [ ] 2.2 Create [Resource] controller
    - Actions: [index, show, create, update, destroy] (or subset)
    - Follow pattern from: [existing controller]
    - Route path: [/api/v1/resource]
  - [ ] 2.3 Implement authentication and authorization
    - Use existing auth pattern: [reference to auth system]
    - Add permission checks: [specific permissions needed]
    - Handle unauthorized access: [401/403 responses]
  - [ ] 2.4 Add API response formatting
    - Success responses: [JSON structure]
    - Error responses: [standardized error format]
    - Status codes: [200, 201, 400, 401, 404, 422, 500]
  - [ ] 2.5 Ensure API layer tests pass
    - Run ONLY the 2-8 tests written in 2.1
    - Verify CRUD operations work correctly
    - Verify authentication/authorization enforced
    - Do NOT run the entire test suite at this stage

**Acceptance Criteria:**
- The 2-8 tests written in 2.1 pass
- All required CRUD operations work
- Proper authorization enforced on protected endpoints
- Consistent, documented response format

### Frontend Components

#### Task Group 3: UI Components and Pages
**Dependencies:** Task Group 2

- [ ] 3.0 Complete frontend UI
  - [ ] 3.1 Write 2-8 focused tests for UI components
    - Limit to 2-8 highly focused tests maximum
    - Test only critical component behaviors (e.g., primary user interaction, key form submission, main rendering case)
    - Skip exhaustive testing of all component states and interactions
  - [ ] 3.2 Create [Component] component
    - Location: [src/components/ComponentName.jsx]
    - Reuse: [existing component] as base if applicable
    - Props: [prop1, prop2, prop3]
    - State: [state variables needed]
  - [ ] 3.3 Implement [Feature] form
    - Fields: [field1, field2, field3]
    - Validation: client-side with [validation library]
    - Submit handling: API call to [endpoint]
    - Error display: [inline/toast/banner]
  - [ ] 3.4 Build [View] page
    - Location: [src/pages/ViewName.jsx]
    - Layout: [description of layout structure]
    - Components: [list of components used]
    - Data fetching: [API endpoints called]
    - Match mockup: `planning/visuals/[mockup-file.png]`
  - [ ] 3.5 Apply base styles
    - Follow existing design system: [path to design system]
    - Use CSS variables from: [style file path]
    - Components: [specific styling requirements]
  - [ ] 3.6 Implement responsive design
    - Mobile: 320px - 768px [specific adjustments]
    - Tablet: 768px - 1024px [specific adjustments]
    - Desktop: 1024px+ [specific adjustments]
  - [ ] 3.7 Add interactions and animations
    - Hover states: [buttons, links, cards]
    - Transitions: [specific transition requirements]
    - Loading states: [spinners, skeletons, progress indicators]
  - [ ] 3.8 Ensure UI component tests pass
    - Run ONLY the 2-8 tests written in 3.1
    - Verify critical component behaviors work
    - Verify form submission and validation
    - Do NOT run the entire test suite at this stage

**Acceptance Criteria:**
- The 2-8 tests written in 3.1 pass
- Components render correctly across breakpoints
- Forms validate and submit successfully
- UI matches visual design specifications
- Interactions and animations work smoothly

### Testing & QA

#### Task Group 4: Test Review & Gap Analysis
**Dependencies:** Task Groups 1-3

- [ ] 4.0 Review existing tests and fill critical gaps only
  - [ ] 4.1 Review tests from Task Groups 1-3
    - Review the 2-8 tests written for database layer (Task 1.1)
    - Review the 2-8 tests written for API layer (Task 2.1)
    - Review the 2-8 tests written for UI layer (Task 3.1)
    - Total existing tests: approximately 6-24 tests
  - [ ] 4.2 Analyze test coverage gaps for THIS feature only
    - Identify critical user workflows that lack test coverage
    - Focus ONLY on gaps related to this spec's feature requirements
    - Do NOT assess entire application test coverage
    - Prioritize end-to-end workflows over unit test gaps
  - [ ] 4.3 Write up to 10 additional strategic tests maximum
    - Add maximum of 10 new tests to fill identified critical gaps
    - Focus on integration points and end-to-end workflows
    - Example critical workflows: [list specific user flows]
    - Do NOT write comprehensive coverage for all scenarios
    - Skip edge cases, performance tests, and accessibility tests unless business-critical
  - [ ] 4.4 Run feature-specific tests only
    - Run ONLY tests related to this spec's feature (tests from 1.1, 2.1, 3.1, and 4.3)
    - Expected total: approximately 16-34 tests maximum
    - Do NOT run the entire application test suite
    - Verify all critical workflows pass

**Acceptance Criteria:**
- All feature-specific tests pass (approximately 16-34 tests total)
- Critical user workflows for this feature are covered
- No more than 10 additional tests added when filling in testing gaps
- Testing focused exclusively on this spec's feature requirements

## Execution Order

Recommended implementation sequence:

1. **Database Layer** (Task Group 1)
   - Reason: Foundation for all other layers
   - Estimated time: [X hours/days]

2. **API Layer** (Task Group 2)
   - Reason: Depends on database models
   - Estimated time: [X hours/days]

3. **Frontend UI** (Task Group 3)
   - Reason: Depends on API endpoints
   - Estimated time: [X hours/days]

4. **Testing & QA** (Task Group 4)
   - Reason: Validates complete feature flow
   - Estimated time: [X hours/days]

## Notes

- [Any special considerations]
- [External dependencies or blockers]
- [Integration points with other features]
- [Performance considerations]
- [Security considerations]
```

## Customization Guidelines

### For Backend-Only Features

Remove the "Frontend Components" section. You might add:

- **Background Jobs** task group
- **Email/Notifications** task group
- **Scheduled Tasks** task group

### For Frontend-Only Features

Remove the "Database Layer" section. You might add:

- **State Management** task group
- **Component Library** task group
- **Styling/Theming** task group

### For Integration Features

Add specific groups like:

- **Third-Party API Setup** task group
- **Webhook Handlers** task group
- **Data Synchronization** task group
- **Error Recovery** task group

### For Complex Features

Split large task groups into multiple smaller groups:

Instead of one "API Layer" group, create:

- **User Management API** task group
- **Authentication API** task group
- **Settings API** task group

## Field Descriptions

- **Total Tasks**: Count of all checkboxes (including sub-tasks)
- **Estimated Complexity**: Low (< 10 tasks), Medium (10-25 tasks), High (25+ tasks)
- **Primary Stack**: Main technologies used for this feature
- **Dependencies**: Which task groups must complete before this one can start
- **Acceptance Criteria**: Clear, measurable definition of "done" for this group
- **Reuse pattern from**: Reference to existing code that demonstrates the pattern to follow
- **Match mockup**: Path to visual design file in the repository

## Tips

1. **Be specific**: Include exact file paths, field names, component names
2. **Show patterns**: Reference existing code to follow
3. **Clear dependencies**: Make execution order obvious
4. **Realistic acceptance criteria**: Things you can actually verify
5. **Adapt freely**: This is a template, not a rigid structure
