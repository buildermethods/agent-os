---
name: global-standards
description: Apply global development standards including coding style, error handling, validation, commenting, conventions, and tech stack alignment when implementing any code changes across the application
---

# Global Development Standards

This skill provides comprehensive development standards that apply across all code changes, regardless of frontend, backend, or testing context. Use these principles to ensure code quality, consistency, and maintainability.

## When to Use This Skill

Activate this skill when:

- Implementing any code changes (features, fixes, refactoring)
- Writing new functions, modules, or components
- Refactoring existing code for clarity or performance
- Making architectural or structural decisions
- Handling errors or validation logic
- Adding comments or documentation to code
- Setting up project conventions or configuration
- Defining or documenting tech stack choices

## Coding Style Best Practices

- **Consistent Naming Conventions**: Establish and follow naming conventions for variables, functions, classes, and files across the codebase
- **Automated Formatting**: Maintain consistent code style (indenting, line breaks, etc.)
- **Meaningful Names**: Choose descriptive names that reveal intent; avoid abbreviations and single-letter variables except in narrow contexts
- **Small, Focused Functions**: Keep functions small and focused on a single task for better readability and testability
- **Consistent Indentation**: Use consistent indentation (spaces or tabs) and configure your editor/linter to enforce it
- **Remove Dead Code**: Delete unused code, commented-out blocks, and imports rather than leaving them as clutter
- **Backward compatibility only when required:** Unless specifically instructed otherwise, assume you do not need to write additional code logic to handle backward compatibility.
- **DRY Principle**: Avoid duplication by extracting common logic into reusable functions or modules

## Error Handling Best Practices

- **User-Friendly Messages**: Provide clear, actionable error messages to users without exposing technical details or security information
- **Fail Fast and Explicitly**: Validate input and check preconditions early; fail with clear error messages rather than allowing invalid state
- **Specific Exception Types**: Use specific exception/error types rather than generic ones to enable targeted handling
- **Centralized Error Handling**: Handle errors at appropriate boundaries (controllers, API layers) rather than scattering try-catch blocks everywhere
- **Graceful Degradation**: Design systems to degrade gracefully when non-critical services fail rather than breaking entirely
- **Retry Strategies**: Implement exponential backoff for transient failures in external service calls
- **Clean Up Resources**: Always clean up resources (file handles, connections) in finally blocks or equivalent mechanisms

## Validation Best Practices

- **Validate on Server Side**: Always validate on the server; never trust client-side validation alone for security or data integrity
- **Client-Side for UX**: Use client-side validation to provide immediate user feedback, but duplicate checks server-side
- **Fail Early**: Validate input as early as possible and reject invalid data before processing
- **Specific Error Messages**: Provide clear, field-specific error messages that help users correct their input
- **Allowlists Over Blocklists**: When possible, define what is allowed rather than trying to block everything that's not
- **Type and Format Validation**: Check data types, formats, ranges, and required fields systematically
- **Sanitize Input**: Sanitize user input to prevent injection attacks (SQL, XSS, command injection)
- **Business Rule Validation**: Validate business rules (e.g., sufficient balance, valid dates) at the appropriate application layer
- **Consistent Validation**: Apply validation consistently across all entry points (web forms, API endpoints, background jobs)

## Code Commenting Best Practices

- **Self-Documenting Code**: Write code that explains itself through clear structure and naming
- **Minimal, helpful comments**: Add concise, minimal comments to explain large sections of code logic.
- **Don't comment changes or fixes**: Do not leave code comments that speak to recent or temporary changes or fixes. Comments should be evergreen informational texts that are relevant far into the future.

## General Development Conventions

- **Consistent Project Structure**: Organize files and directories in a predictable, logical structure that team members can navigate easily
- **Clear Documentation**: Maintain up-to-date README files with setup instructions, architecture overview, and contribution guidelines
- **Version Control Best Practices**: Use clear commit messages, feature branches, and meaningful pull/merge requests with descriptions
- **Environment Configuration**: Use environment variables for configuration; never commit secrets or API keys to version control
- **Dependency Management**: Keep dependencies up-to-date and minimal; document why major dependencies are used
- **Code Review Process**: Establish a consistent code review process with clear expectations for reviewers and authors
- **Testing Requirements**: Define what level of testing is required before merging (unit tests, integration tests, etc.)
- **Feature Flags**: Use feature flags for incomplete features rather than long-lived feature branches
- **Changelog Maintenance**: Keep a changelog or release notes to track significant changes and improvements

## Tech Stack Alignment

When implementing code, ensure it aligns with the project's defined tech stack. Reference the project's tech stack documentation to maintain consistency.

Check the project's `@agent-os/product/tech-stack.md` or similar documentation for the actual tech stack in use.

## Best Practices Summary

When implementing any code change:

1. **Start with naming** - Choose clear, descriptive names for everything
2. **Keep it small** - Write small, focused functions and modules
3. **Validate early** - Check inputs and preconditions at entry points
4. **Handle errors gracefully** - Provide clear error messages and fail fast
5. **Remove cruft** - Delete dead code, unused imports, and old comments
6. **Document sparingly** - Write self-documenting code; add minimal comments only when necessary
7. **Follow conventions** - Align with project structure, tech stack, and team standards
8. **Test strategically** - Define appropriate testing requirements for the change

## Integration with Other Skills

This skill works in conjunction with:

- **Backend Standards**: Apply when working on server-side code
- **Frontend Standards**: Apply when working on UI code
- **Testing Standards**: Apply when writing tests

The global standards serve as the foundation, while specialized standards provide domain-specific guidance.
