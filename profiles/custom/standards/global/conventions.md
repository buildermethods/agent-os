## General development conventions

- **Consistent Project Structure**: Organize files and directories in a predictable, logical structure that team members can navigate easily. Follow WordPress plugin/theme structure conventions when applicable.
- **Clear Documentation**: Maintain up-to-date README files with setup instructions, architecture overview, and contribution guidelines
- **Version Control Best Practices**: Use clear commit messages, feature branches, and meaningful pull/merge requests with descriptions. Maintain a "main" branch for production; use feature branches for dev/staging testing.
- **Environment Configuration**: Use environment variables for configuration; never commit secrets or API keys to version control. Use WordPress constants and configuration files appropriately.
- **Dependency Management**: Keep dependencies up-to-date and minimal; document why major dependencies are used. Use Composer for PHP dependencies (themes, plugins, libraries) and npm/Bun for JavaScript build tools.
- **Dependency Injection**: Use DI52 (dependency injection container) for all plugins. Utilize the container with providers pattern for organizing and registering services, classes, and dependencies.
- **Code Review Process**: Establish a consistent code review process with clear expectations for reviewers and authors
- **Testing Requirements**: Define what level of testing is required before merging (unit tests, integration tests, etc.)
- **Feature Flags**: Use feature flags for incomplete features rather than long-lived feature branches
- **Changelog Maintenance**: Keep a changelog or release notes to track significant changes and improvements
- **WordPress Hooks and Filters**: Use WordPress action and filter hooks appropriately for extensibility and maintainability
- **Site Architecture**: Separate marketing sites (custombrand.com) and commerce sites (my.custombrand.com) for better performance and separation of concerns
- **Shared Code**: Leverage shared libraries and common code across StellarWP brands where appropriate
