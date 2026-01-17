## Coding style best practices

- **WordPress Coding Standards**: Follow WordPress PHP and JavaScript coding standards as the foundation for all code (mostly followed)
- **Consistent Naming Conventions**: Establish and follow naming conventions for variables, functions, classes, and files across the codebase
- **Automated Formatting**: Maintain consistent code style (indenting, line breaks, etc.) using WordPress coding standards
- **Meaningful Names**: Choose descriptive names that reveal intent; avoid abbreviations and single-letter variables except in narrow contexts
- **Small, Focused Functions**: Keep functions small and focused on a single task for better readability and testability
- **Consistent Indentation**: Use consistent indentation (spaces or tabs) following WordPress standards and configure your editor/linter to enforce it
- **Remove Dead Code**: Delete unused code, commented-out blocks, and imports rather than leaving them as clutter
- **Backward compatibility only when required:** Unless specifically instructed otherwise, assume you do not need to write additional code logic to handle backward compatibility.
- **DRY Principle**: Avoid duplication by extracting common logic into reusable functions or modules
- **PHP Short Array Syntax**: Use short array syntax `[]` instead of `array()` in PHP code
- **JavaScript Framework**: Prefer vanilla JavaScript for new code. Use jQuery only when necessary for WordPress core interactions or legacy custom code compatibility.
