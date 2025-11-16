---
name: frontend-standards
description: Apply frontend development standards for components, CSS, accessibility, and responsive design when implementing UI code, client-side logic, visual elements, or user interfaces
---

# Frontend Development Standards

This skill provides comprehensive standards for frontend development including component design, CSS methodology, accessibility practices, and responsive design. Use these principles when implementing user interfaces, client-side logic, or visual elements.

## When to Use This Skill

Activate this skill when:

- Building or modifying UI components
- Writing CSS or styling code
- Implementing responsive layouts
- Adding accessibility features
- Creating forms or interactive elements
- Designing component APIs or props
- Implementing client-side state management
- Working with frontend frameworks (React, Vue, Svelte, etc.)
- Optimizing frontend performance

## UI Component Best Practices

- **Single Responsibility**: Each component should have one clear purpose and do it well
- **Reusability**: Design components to be reused across different contexts with configurable props
- **Composability**: Build complex UIs by combining smaller, simpler components rather than monolithic structures
- **Clear Interface**: Define explicit, well-documented props with sensible defaults for ease of use
- **Encapsulation**: Keep internal implementation details private and expose only necessary APIs
- **Consistent Naming**: Use clear, descriptive names that indicate the component's purpose and follow team conventions
- **State Management**: Keep state as local as possible; lift it up only when needed by multiple components
- **Minimal Props**: Keep the number of props manageable; if a component needs many props, consider composition or splitting it
- **Documentation**: Document component usage, props, and provide examples for easier adoption by team members

## CSS Best Practices

- **Consistent Methodology**: Apply and stick to the project's consistent CSS methodology (Tailwind, BEM, utility classes, CSS modules, etc.) across the entire project
- **Avoid Overriding Framework Styles**: Work with your framework's patterns rather than fighting against them with excessive overrides
- **Maintain Design System**: Establish and document design tokens (colors, spacing, typography) for consistency
- **Minimize Custom CSS**: Leverage framework utilities and components to reduce custom CSS maintenance burden
- **Performance Considerations**: Optimize for production with CSS purging/tree-shaking to remove unused styles

## Responsive Design Best Practices

- **Mobile-First Development**: Start with mobile layout and progressively enhance for larger screens
- **Standard Breakpoints**: Consistently use standard breakpoints across the application (e.g., mobile, tablet, desktop)
- **Fluid Layouts**: Use percentage-based widths and flexible containers that adapt to screen size
- **Relative Units**: Prefer rem/em units over fixed pixels for better scalability and accessibility
- **Test Across Devices**: Test and verify UI changes across multiple screen sizes from mobile to tablet to desktop screen sizes and ensure a balanced, user-friendly viewing and reading experience on all
- **Touch-Friendly Design**: Ensure tap targets are appropriately sized (minimum 44x44px) for mobile users
- **Performance on Mobile**: Optimize images and assets for mobile network conditions and smaller screens
- **Readable Typography**: Maintain readable font sizes across all breakpoints without requiring zoom
- **Content Priority**: Show the most important content first on smaller screens through thoughtful layout decisions

## UI Accessibility Best Practices

- **Semantic HTML**: Use appropriate HTML elements (nav, main, button, etc.) that convey meaning to assistive technologies
- **Keyboard Navigation**: Ensure all interactive elements are accessible via keyboard with visible focus indicators
- **Color Contrast**: Maintain sufficient contrast ratios (4.5:1 for normal text) and don't rely solely on color to convey information
- **Alternative Text**: Provide descriptive alt text for images and meaningful labels for all form inputs
- **Screen Reader Testing**: Test and verify that all views are accessible on screen reading devices.
- **ARIA When Needed**: Use ARIA attributes to enhance complex components when semantic HTML isn't sufficient
- **Logical Heading Structure**: Use heading levels (h1-h6) in proper order to create a clear document outline
- **Focus Management**: Manage focus appropriately in dynamic content, modals, and single-page applications

## Best Practices Summary

When implementing frontend code:

1. **Design composable components** - Build small, reusable pieces with clear props
2. **Follow CSS methodology** - Stick to project's chosen approach (Tailwind, BEM, etc.)
3. **Start mobile-first** - Design for mobile, then enhance for larger screens
4. **Ensure accessibility** - Use semantic HTML, keyboard navigation, proper contrast
5. **Test responsiveness** - Verify layouts work across all device sizes
6. **Optimize performance** - Minimize custom CSS, optimize assets, purge unused styles
7. **Manage state locally** - Keep state as close to usage as possible
8. **Document components** - Provide clear prop documentation and usage examples

## Integration with Other Skills

This skill works in conjunction with:

- **Global Standards**: Foundation for coding style, error handling, and validation
- **Backend Standards**: Coordinate API contracts and data structures
- **Testing Standards**: Guide testing approaches for frontend code

Apply global standards as the foundation, then layer these frontend-specific practices for UI development.

## Common Frontend Patterns

### Component Structure

Organize components with clear separation:

- Presentational components (pure UI)
- Container components (logic + data)
- Layout components (structure)
- Utility components (reusable pieces)

### State Management Hierarchy

Follow this hierarchy:

1. Local component state (useState, data)
2. Lifted state (shared between siblings)
3. Context (shared across component tree)
4. Global state (app-wide state management)

### Accessibility Checklist

For every UI component:

- [ ] Uses semantic HTML elements
- [ ] Keyboard accessible (Tab, Enter, Escape)
- [ ] Visible focus indicators
- [ ] Sufficient color contrast (4.5:1)
- [ ] Descriptive labels and alt text
- [ ] Screen reader tested
- [ ] Proper heading hierarchy
- [ ] ARIA attributes where needed

### Responsive Design Checklist

For every layout:

- [ ] Mobile-first CSS/styling
- [ ] Standard breakpoints used
- [ ] Fluid layouts with flexible containers
- [ ] Relative units (rem/em) for sizing
- [ ] Tested on mobile, tablet, desktop
- [ ] Touch targets ≥ 44x44px
- [ ] Optimized images for mobile
- [ ] Readable typography at all sizes
- [ ] Important content prioritized on mobile

## Performance Considerations

When implementing frontend code:

- **Bundle size**: Keep JavaScript bundles small with code splitting
- **CSS efficiency**: Use framework utilities, purge unused styles
- **Image optimization**: Use appropriate formats, lazy loading, responsive images
- **Render performance**: Minimize re-renders, use memoization strategically
- **Accessibility**: Don't sacrifice performance for accessibility (or vice versa)
- **Mobile experience**: Test on real devices, optimize for slower networks

## Design System Integration

Align with project design system:

- Use established design tokens (colors, spacing, typography)
- Leverage existing component library before creating new components
- Follow documented patterns for common UI elements
- Contribute new components back to design system when appropriate
