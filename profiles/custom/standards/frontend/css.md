## CSS best practices

- **SCSS Compilation**: Use SCSS for nesting and variables, compiled to CSS in build step. Use Gulp (preferred) or Webpack (legacy) for compilation.
- **BEM Methodology**: Prefer BEM (Block Element Modifier) naming convention for CSS classes. Use clear, semantic class names that follow BEM structure.
- **Tailwind CSS**: On sites using Tailwind, maintain consistency with utility classes. Note that utility frameworks can be challenging to enforce when working with third-party styles from external sources.
- **WordPress Admin Styling**: Most site content uses off-the-shelf Kadence Blocks, with styling primarily done through WordPress admin interface. Custom CSS should complement, not override, admin-configured styles.
- **Third-Party Component Styling**: When customizing third-party components with poorly structured selectors, document why specific CSS approaches are needed. Strive for maintainable solutions even when working around limitations.
- **Avoid Overriding Framework Styles**: Work with Kadence theme patterns and WordPress core styles rather than fighting against them with excessive overrides.
- **Maintain Design System**: Establish and document design tokens (colors, spacing, typography) for consistency. Use SCSS variables for design tokens.
- **Minimize Custom CSS**: Leverage Kadence Blocks and theme utilities to reduce custom CSS maintenance burden. Most styling should be handled through WordPress admin.
- **Performance Considerations**: Optimize for production with CSS minification in build process. WordPress themes should enqueue styles appropriately and avoid loading unused CSS.
- **WordPress Style Enqueuing**: Use `wp_enqueue_style()` to properly enqueue stylesheets with dependencies and versioning
- **WordPress Admin Styles**: When styling WordPress admin interfaces, use WordPress admin CSS classes and follow WordPress admin design patterns
- **Block Editor Styles**: For WordPress block editor styles, use block-specific stylesheets and editor stylesheets appropriately
- **CSS Specificity**: Maintain reasonable CSS specificity to avoid override conflicts. Use WordPress CSS class naming conventions when applicable.
