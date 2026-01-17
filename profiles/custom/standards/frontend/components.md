## UI component best practices

- **Single Responsibility**: Each component should have one clear purpose and do it well. This applies to WordPress blocks, template parts, widgets, and shortcodes.
- **Reusability**: Design components to be reused across different contexts with configurable props/attributes. WordPress blocks use attributes; template parts use parameters; shortcodes use attributes.
- **Composability**: Build complex UIs by combining smaller, simpler components rather than monolithic structures. WordPress blocks can be composed together; template parts can be included in templates.
- **Clear Interface**: Define explicit, well-documented props/attributes with sensible defaults for ease of use. WordPress blocks should have clear attribute definitions; shortcodes should have documented parameters.
- **Encapsulation**: Keep internal implementation details private and expose only necessary APIs. WordPress blocks encapsulate their rendering logic; template parts should have clear input/output contracts.
- **Consistent Naming**: Use clear, descriptive names that indicate the component's purpose and follow team conventions. WordPress blocks use namespaced names (e.g., `myplugin/my-block`).
- **State Management**: Keep state as local as possible; lift it up only when needed by multiple components. For WordPress, consider using JavaScript state management for complex block interactions.
- **Minimal Props**: Keep the number of props/attributes manageable; if a component needs many props, consider composition or splitting it. WordPress blocks should have focused attribute sets.
- **Documentation**: Document component usage, props/attributes, and provide examples for easier adoption by team members
- **Kadence Blocks**: Leverage Kadence Blocks, Kadence Blocks Pro, and Kadence Conversions for site content. Most styling is configured through WordPress admin rather than custom code.
- **WordPress Block Patterns**: When creating WordPress blocks, follow block editor patterns and use Block API appropriately
- **Template Parts**: Use WordPress `get_template_part()` for reusable template components with clear parameter passing
- **Shortcodes**: Create WordPress shortcodes with clear attribute definitions and proper output sanitization
