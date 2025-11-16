---
name: testing-standards
description: Apply testing standards when writing or modifying test code, including test coverage practices, testing strategies, and test quality guidelines
---

# Testing Standards

This skill provides focused testing standards that emphasize strategic, minimal testing during development. Use these principles when writing tests to ensure code quality without over-testing or creating brittle test suites.

## When to Use This Skill

Activate this skill when:

- Writing new test files or test cases
- Modifying existing tests
- Deciding what to test and what to skip
- Implementing test coverage for a feature
- Reviewing test quality and effectiveness
- Setting up testing infrastructure
- Defining testing requirements for a feature

## Core Testing Philosophy

Follow a **minimal, strategic testing approach**:

- Focus on completing features first, then add strategic tests
- Test only core user flows and critical paths
- Defer edge case testing until dedicated testing phases
- Avoid over-testing during development
- Write tests that verify behavior, not implementation

This philosophy prioritizes **developer velocity** while maintaining **adequate quality assurance** through focused testing.

## Test Coverage Best Practices

- **Write Minimal Tests During Development**: Do NOT write tests for every change or intermediate step. Focus on completing the feature implementation first, then add strategic tests only at logical completion points
- **Test Only Core User Flows**: Write tests exclusively for critical paths and primary user workflows. Skip writing tests for non-critical utilities and secondary workflows until if/when you're instructed to do so.
- **Defer Edge Case Testing**: Do NOT test edge cases, error states, or validation logic unless they are business-critical. These can be addressed in dedicated testing phases, not during feature development.
- **Test Behavior, Not Implementation**: Focus tests on what the code does, not how it does it, to reduce brittleness
- **Clear Test Names**: Use descriptive names that explain what's being tested and the expected outcome
- **Mock External Dependencies**: Isolate units by mocking databases, APIs, file systems, and other external services
- **Fast Execution**: Keep unit tests fast (milliseconds) so developers run them frequently during development

## When to Write Tests

### ✅ Do Write Tests For

- **Core user flows**: Main features that users directly interact with
- **Critical business logic**: Revenue-impacting or data-sensitive operations
- **Public APIs**: External interfaces that others depend on
- **Complex algorithms**: Non-trivial logic that's hard to verify manually
- **Bug fixes**: Regression tests for confirmed bugs (when specified)

### ❌ Don't Write Tests For

- **Intermediate development steps**: Code that will change before completion
- **Non-critical utilities**: Helper functions for internal use only
- **Edge cases**: Unless business-critical or explicitly requested
- **Error states**: Unless they're critical failure scenarios
- **Validation logic**: Unless it's core business validation
- **Every code change**: Save testing for logical completion points

## Test Quality Guidelines

### Test Structure

Follow the **Arrange-Act-Assert** pattern:

```python
# Arrange: Set up test data and conditions
# Act: Execute the code being tested
# Assert: Verify the expected outcome
```

### Test Naming

Use descriptive names that explain:

- What is being tested
- Under what conditions
- What the expected outcome is

Examples:

- `test_user_login_with_valid_credentials_succeeds`
- `test_checkout_with_empty_cart_shows_error`
- `test_search_returns_results_sorted_by_relevance`

### Test Independence

Each test should:

- Run independently without depending on other tests
- Clean up after itself (reset state, clear mocks)
- Produce the same result every time (deterministic)
- Run in any order without affecting others

### Mocking Strategy

Mock external dependencies:

- Database calls → Use in-memory DB or mocks
- API requests → Mock HTTP responses
- File system → Mock file operations
- Third-party services → Mock service responses
- Time/dates → Mock clock for predictable tests

Keep mocks simple and focused on the test scenario.

## Testing Anti-Patterns

### ❌ Avoid These Patterns

- **Testing implementation details**: Tests that break when you refactor without changing behavior
- **Excessive mocking**: Mocking so much that tests don't verify real behavior
- **Brittle assertions**: Tests that depend on exact string matches or fragile selectors
- **Slow tests**: Tests that take seconds instead of milliseconds
- **Testing frameworks**: Testing library code instead of your code
- **Duplicate coverage**: Multiple tests covering the same scenario
- **Test-first everything**: Writing tests before understanding requirements

### ✅ Prefer These Patterns

- **Behavior-focused tests**: Tests that verify outcomes, not implementation
- **Minimal mocking**: Mock only external dependencies, not internal code
- **Resilient assertions**: Tests that verify core behavior, not presentation details
- **Fast feedback**: Tests that run in milliseconds for rapid iteration
- **Integration tests**: Tests that verify real component interactions
- **Unique coverage**: Each test verifies a distinct scenario
- **Feature-first development**: Implement features, then add strategic tests

## Testing Levels

### Unit Tests

Test individual functions or components:

- Fast execution (milliseconds)
- Isolated from external dependencies
- Focus on single units of code
- Mock all external calls

### Integration Tests

Test component interactions:

- Slower than unit tests (but still fast)
- Use real or realistic dependencies
- Verify data flow between components
- Test critical user flows end-to-end

### When to Use Each

- **Unit tests**: For complex algorithms, business logic, utility functions
- **Integration tests**: For user flows, API endpoints, database operations

Prefer **integration tests for user-facing features** and **unit tests for isolated logic**.

## Test Coverage Targets

During feature development:

- **Minimum**: Test core user flow (1-2 integration tests)
- **Recommended**: Test main scenarios + 1-2 error cases (3-5 tests total)
- **Maximum**: Add edge cases only if business-critical (5-10 tests max)

**Do not aim for high percentage coverage during development** - focus on critical path testing.

## Best Practices Summary

When writing tests:

1. **Complete features first** - Don't write tests for incomplete code
2. **Test behavior, not implementation** - Verify outcomes, not internal details
3. **Focus on critical paths** - Test main user flows, skip edge cases initially
4. **Keep tests fast** - Unit tests in milliseconds, integration tests in seconds
5. **Mock external dependencies** - Isolate code from databases, APIs, file systems
6. **Use clear test names** - Describe what's tested, conditions, and expected outcome
7. **Ensure test independence** - Tests shouldn't depend on each other
8. **Avoid over-testing** - More tests ≠ better quality; strategic tests matter

## Integration with Other Skills

This skill works in conjunction with:

- **Global Standards**: Foundation for code quality and validation approaches
- **Backend Standards**: Testing strategies for API endpoints, database code
- **Frontend Standards**: Testing strategies for UI components, user interactions

Apply testing standards specifically when writing test code, not during feature implementation.

## Testing Workflow

Recommended testing workflow:

1. **Implement the feature** - Focus on getting it working first
2. **Identify critical paths** - Determine what must be tested
3. **Write minimal tests** - Cover core user flows only
4. **Verify tests pass** - Ensure tests are reliable and fast
5. **Move forward** - Don't add more tests unless requested

Testing is **strategic**, not **exhaustive**. Quality comes from testing the right things, not testing everything.

## Common Testing Scenarios

### Testing API Endpoints

- Test happy path (valid input → expected response)
- Test authentication/authorization
- Test critical error cases (invalid input, missing data)
- Skip edge cases unless business-critical

### Testing UI Components

- Test main user interactions (clicks, form submissions)
- Test conditional rendering (show/hide based on state)
- Test critical user flows (login, checkout, etc.)
- Skip testing framework behavior or library code

### Testing Business Logic

- Test core calculations and transformations
- Test critical validation rules
- Test main decision branches
- Skip testing trivial getters/setters

### Testing Database Operations

- Test CRUD operations for main entities
- Test critical queries and relationships
- Test data integrity constraints
- Skip testing ORM framework behavior

## Final Reminder

**Test strategically, not exhaustively.**

The goal is **adequate confidence** in critical functionality, not **perfect coverage** of all code paths. Focus testing effort where it provides the most value: core user flows and critical business logic.
