---
name: test-check
description: "Run tests and analyze failures after implementing code changes. Auto-invoke this skill after writing or modifying code to verify tests pass, and provide actionable failure analysis."
allowed-tools: Bash, Read, Grep, Glob
---

# Test Verification Skill

Automatically run tests and provide focused failure analysis after code changes. Helps ensure code quality through continuous test verification.

## When to Use This Skill

Claude should automatically invoke this skill:
- **After implementing feature code** (mandatory)
- **After fixing bugs**
- **When tests are mentioned in task requirements**
- **Before committing changes** (in conjunction with build-check)

## Workflow

### 1. Identify Test Command
```bash
# Check for common test frameworks
if [ -f "package.json" ]; then
  npm test  # or npm run test
elif [ -f "Gemfile" ]; then
  bundle exec rspec
elif [ -f "pytest.ini" ] || [ -f "setup.py" ]; then
  pytest
fi
```

### 2. Run Tests
Execute the test command and capture output.

### 3. Analyze Results
For failures, extract:
- Test name and file location
- Expected vs actual result
- Most likely fix location
- One-line suggestion for fix approach

## Output Format

```
✅ Passing: X tests
❌ Failing: Y tests

Failed Test 1: test_name (file:line)
Expected: [brief description]
Actual: [brief description]
Fix location: path/to/file:line
Suggested approach: [one line]

[Additional failures...]

Returning control for fixes.
```

## Key Principles

1. **Run Exactly What's Needed**: Specific tests, test files, or full suite based on context
2. **Concise Analysis**: Avoid verbose stack traces - focus on actionable information
3. **Never Modify Files**: Only analyze and report
4. **Return Promptly**: After analysis, return control for fixes

## Example Triggers

- After implementing a new feature function
- After modifying existing code
- When task description includes test requirements
- Before running git commit workflow
