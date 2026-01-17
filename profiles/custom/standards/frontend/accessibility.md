## UI accessibility best practices

- **Semantic HTML**: Use appropriate HTML elements (nav, main, button, etc.) that convey meaning to assistive technologies. WordPress themes should use proper semantic HTML structure.
- **Keyboard Navigation**: Ensure all interactive elements are accessible via keyboard with visible focus indicators. WordPress admin and frontend should be fully keyboard navigable.
- **Color Contrast**: Maintain sufficient contrast ratios (4.5:1 for normal text) and don't rely solely on color to convey information. Follow WCAG 2.1 AA standards.
- **Alternative Text**: Provide descriptive alt text for images and meaningful labels for all form inputs. Use WordPress media library alt text fields appropriately.
- **Screen Reader Testing**: Test and verify that all views are accessible on screen reading devices. Test with screen readers like NVDA, JAWS, or VoiceOver.
- **ARIA When Needed**: Use ARIA attributes to enhance complex components when semantic HTML isn't sufficient. WordPress core uses ARIA appropriately; follow similar patterns.
- **Logical Heading Structure**: Use heading levels (h1-h6) in proper order to create a clear document outline. WordPress themes should maintain proper heading hierarchy.
- **Focus Management**: Manage focus appropriately in dynamic content, modals, and single-page applications. WordPress uses focus management in admin; apply similar patterns to custom interfaces.
- **WordPress Accessibility Standards**: Follow WordPress accessibility coding standards and ensure compatibility with WordPress accessibility features and plugins
