## Test coverage best practices

- **Write Minimal Tests During Development**: Do NOT write tests for every change or intermediate step. Focus on completing the feature implementation first, then add strategic tests only at logical completion points
- **Test Only Core User Flows**: Write tests exclusively for critical paths and primary user workflows. Skip writing tests for non-critical utilities and secondary workflows until if/when you're instructed to do so.
- **Defer Edge Case Testing**: Do NOT test edge cases, error states, or validation logic unless they are business-critical. These can be addressed in dedicated testing phases, not during feature development.
- **Test Behavior, Not Implementation**: Focus tests on what the code does, not how it does it, to reduce brittleness
- **Clear Test Names**: Use descriptive names that explain what's being tested and the expected outcome. WordPress PHPUnit tests should follow naming conventions (e.g., `test_function_returns_expected_value`).
- **Mock External Dependencies**: Isolate units by mocking databases, APIs, file systems, and other external services. WordPress testing uses factories and mocks for posts, users, etc.
- **Fast Execution**: Keep unit tests fast (milliseconds) so developers run them frequently during development
- **WordPress Testing Environment**: Use WordPress test suite setup (WP_UnitTestCase) for integration tests. Use proper test database setup and teardown.
- **WordPress Factories**: Use WordPress test factories (`$factory->post->create()`, etc.) to create test data rather than direct database manipulation
- **Test Isolation**: Ensure tests are isolated and don't depend on each other. Clean up test data after each test using `setUp()` and `tearDown()` methods.
- **PHPUnit Framework**: Use PHPUnit as the primary testing framework for PHP code. Follow PHPUnit best practices and WordPress testing patterns.
