# CSS Style Guide

## Context

Global CSS style rules for Agent OS projects.

<conditional-block context-check="tailwindcss-usage">
IF this TailwindCSS Usage section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using TailwindCSS rules already in context"
ELSE:
  READ: The following TailwindCSS rules

## TailwindCSS Usage

### Core Principle
We always use the latest version of TailwindCSS for all CSS styling. TailwindCSS provides utility-first CSS classes that enable rapid development without writing custom CSS.

### Multi-line CSS Classes in Markup

We use a unique multi-line formatting style when writing Tailwind CSS classes in HTML markup and ERB tags, where the classes for each responsive size are written on their own dedicated line.

**Formatting Rules:**
- The top-most line should be the smallest size (no responsive prefix)
- Each line below it should be the next responsive size up
- Each line of CSS classes should be aligned vertically
- Focus and hover classes should be on their own additional dedicated lines
- We implement one additional responsive breakpoint size called 'xs' which represents 400px
- If there are any custom CSS classes being used, those should be included at the start of the first line

**Example of multi-line Tailwind CSS classes:**

```html
<div class="custom-cta bg-gray-50 dark:bg-gray-900 p-4 rounded cursor-pointer w-full
            hover:bg-gray-100 dark:hover:bg-gray-800
            xs:p-6
            sm:p-8 sm:font-medium
            md:p-10 md:text-lg
            lg:p-12 lg:text-xl lg:font-semibold lg:w-3/5
            xl:p-14 xl:text-2xl
            2xl:p-16 2xl:text-3xl 2xl:font-bold 2xl:w-3/4">
  I'm a call-to-action!
</div>
```

### Responsive Breakpoints
- **xs**: 400px (custom breakpoint)
- **sm**: 640px
- **md**: 768px
- **lg**: 1024px
- **xl**: 1280px
- **2xl**: 1536px

### State Variants
- **hover**: Hover state styles
- **focus**: Focus state styles
- **active**: Active/clicked state styles
- **disabled**: Disabled state styles
- **dark**: Dark mode styles

### Dark Mode
- Use `dark:` prefix for dark mode styles
- Ensure proper theme switching implementation
- Test both light and dark modes

```html
<!-- Dark mode example -->
<div class="bg-white dark:bg-gray-900 text-gray-900 dark:text-white p-4 rounded-lg">
  <p class="hover:text-blue-600 dark:hover:text-blue-400">
    This text changes color on hover and in dark mode
  </p>
</div>
```
</conditional-block>

<conditional-block context-check="custom-css">
IF this Custom CSS section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using Custom CSS rules already in context"
ELSE:
  READ: The following custom CSS rules

## Custom CSS

### When to Use Custom CSS
- When TailwindCSS utilities are insufficient
- For complex animations and transitions
- For brand-specific design patterns
- For reusable components with complex styling

### Custom CSS Organization
- Use CSS custom properties (variables) for theming
- Organize custom CSS in logical sections
- Use BEM methodology for component naming
- Keep custom CSS to a minimum

```css
/* Custom CSS Variables */
:root {
  --primary-color: #3b82f6;
  --secondary-color: #64748b;
  --background-color: #ffffff;
  --text-color: #1f2937;
  --border-color: #e5e7eb;
  --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

/* Dark mode variables */
.dark {
  --background-color: #111827;
  --text-color: #f9fafb;
  --border-color: #374151;
}

/* Component styles using BEM */
.card {
  background-color: var(--background-color);
  border: 1px solid var(--border-color);
  border-radius: 0.5rem;
  box-shadow: var(--shadow-sm);
  padding: 1.5rem;
}

.card__header {
  margin-bottom: 1rem;
}

.card__title {
  font-size: 1.25rem;
  font-weight: 600;
  color: var(--text-color);
}

.card__content {
  color: var(--text-color);
}

.card__footer {
  margin-top: 1.5rem;
  padding-top: 1rem;
  border-top: 1px solid var(--border-color);
}
```

### CSS Custom Properties
- Use meaningful variable names
- Organize variables by category
- Provide fallback values when necessary
- Document custom properties

```css
/* Color system */
:root {
  /* Primary colors */
  --color-primary-50: #eff6ff;
  --color-primary-100: #dbeafe;
  --color-primary-500: #3b82f6;
  --color-primary-600: #2563eb;
  --color-primary-700: #1d4ed8;
  
  /* Semantic colors */
  --color-success: #10b981;
  --color-warning: #f59e0b;
  --color-error: #ef4444;
  --color-info: #3b82f6;
}

/* Spacing system */
:root {
  --spacing-xs: 0.25rem;
  --spacing-sm: 0.5rem;
  --spacing-md: 1rem;
  --spacing-lg: 1.5rem;
  --spacing-xl: 2rem;
  --spacing-2xl: 3rem;
}

/* Typography */
:root {
  --font-size-xs: 0.75rem;
  --font-size-sm: 0.875rem;
  --font-size-base: 1rem;
  --font-size-lg: 1.125rem;
  --font-size-xl: 1.25rem;
  --font-size-2xl: 1.5rem;
  --font-size-3xl: 1.875rem;
  
  --font-weight-normal: 400;
  --font-weight-medium: 500;
  --font-weight-semibold: 600;
  --font-weight-bold: 700;
}
```
</conditional-block>

<conditional-block context-check="architecture">
IF this Architecture section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using Architecture rules already in context"
ELSE:
  READ: The following architecture rules

## CSS Architecture

### Methodology
- **Utility-First**: Use TailwindCSS utilities for rapid development
- **Component-Based**: Create reusable components with consistent styling
- **Mobile-First**: Design for mobile devices first, then enhance for larger screens
- **Progressive Enhancement**: Build basic styles first, then add enhancements

### File Organization
```
styles/
├── main.css                 # Main entry point
├── utilities/               # Custom utilities
│   ├── spacing.css
│   ├── typography.css
│   └── colors.css
├── components/              # Component styles
│   ├── buttons.css
│   ├── cards.css
│   ├── forms.css
│   └── navigation.css
├── layouts/                 # Layout styles
│   ├── header.css
│   ├── footer.css
│   └── grid.css
└── themes/                  # Theme styles
    ├── light.css
    └── dark.css
```

### CSS Architecture Patterns
- **Atomic Design**: Build from atoms to molecules to organisms
- **ITCSS**: Inverted Triangle CSS for scalable architecture
- **SMACSS**: Scalable and Modular Architecture for CSS

```css
/* ITCSS Structure */
/* 1. Settings - Variables and global settings */
:root {
  --primary-color: #3b82f6;
  --max-width: 1200px;
}

/* 2. Tools - Mixins and functions */
@mixin flex-center {
  display: flex;
  align-items: center;
  justify-content: center;
}

/* 3. Generic - Resets and base styles */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

/* 4. Elements - Base HTML element styles */
button {
  border: none;
  cursor: pointer;
  font-family: inherit;
}

/* 5. Objects - Undecorated design patterns */
.container {
  max-width: var(--max-width);
  margin: 0 auto;
  padding: 0 1rem;
}

/* 6. Components - Specific UI components */
.btn {
  @include flex-center;
  padding: 0.5rem 1rem;
  border-radius: 0.375rem;
  font-weight: 500;
  transition: all 0.2s;
}

.btn-primary {
  background-color: var(--primary-color);
  color: white;
}

.btn-primary:hover {
  background-color: #2563eb;
}

/* 7. Trumps - Helper classes and overrides */
.text-center {
  text-align: center;
}

.hidden {
  display: none;
}
```
</conditional-block>

<conditional-block context-check="performance">
IF this Performance section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using Performance rules already in context"
ELSE:
  READ: The following performance rules

## Performance Optimization

### CSS Loading Strategies
- Use critical CSS inline for above-the-fold content
- Load non-critical CSS asynchronously
- Minify and compress CSS files
- Use HTTP/2 for multiple CSS file requests

```html
<!-- Critical CSS inline -->
<head>
  <style>
    /* Critical styles for above the fold */
    body { font-family: system-ui, -apple-system, sans-serif; }
    .header { background: white; }
    .main-content { padding: 2rem; }
  </style>
  
  <!-- Async CSS loading -->
  <link rel="stylesheet" href="styles.css" media="print" onload="this.media='all'">
</head>
```

### CSS Optimization Techniques
- Remove unused CSS
- Use CSS custom properties for theming
- Implement CSS containment where appropriate
- Use will-change for animations

```css
/* CSS Containment */
.card {
  contain: content;
  contain-intrinsic-size: 200px;
}

/* Will-change for animations */
.animated-element {
  will-change: transform, opacity;
  transition: transform 0.3s ease, opacity 0.3s ease;
}

.animated-element:hover {
  transform: translateY(-2px);
  opacity: 0.9;
}
```

### Responsive Images and Media
- Use responsive image techniques
- Implement lazy loading for images
- Use appropriate image formats (WebP, AVIF)
- Optimize media queries

```css
/* Responsive images */
img {
  max-width: 100%;
  height: auto;
}

/* Art direction */
@media (max-width: 640px) {
  .hero-image {
    content: url('hero-mobile.jpg');
  }
}

@media (min-width: 641px) {
  .hero-image {
    content: url('hero-desktop.jpg');
  }
}
```
</conditional-block>

<conditional-block context-check="accessibility">
IF this Accessibility section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using Accessibility rules already in context"
ELSE:
  READ: The following accessibility rules

## Accessibility (A11y)

### Color Contrast
- Ensure sufficient color contrast (4.5:1 for normal text)
- Provide high contrast alternatives
- Test color blindness accessibility

```css
/* Good contrast ratios */
.text-primary {
  color: #1f2937; /* Dark gray */
}

.text-secondary {
  color: #6b7280; /* Medium gray */
}

.bg-primary {
  background-color: #ffffff;
  color: #1f2937;
}

/* Focus indicators */
:focus {
  outline: 2px solid #3b82f6;
  outline-offset: 2px;
}

:focus:not(:focus-visible) {
  outline: none;
}

button:focus-visible {
  outline: 2px solid #3b82f6;
  outline-offset: 2px;
}
```

### Keyboard Navigation
- Ensure all interactive elements are keyboard accessible
- Provide visible focus indicators
- Implement proper tab order

```css
/* Keyboard navigation styles */
button,
a,
input,
select,
textarea {
  &:focus-visible {
    outline: 2px solid #3b82f6;
    outline-offset: 2px;
  }
}

/* Skip to main content link */
.skip-link {
  position: absolute;
  top: -40px;
  left: 0;
  background: #3b82f6;
  color: white;
  padding: 8px;
  text-decoration: none;
  border-radius: 0 0 4px 0;
}

.skip-link:focus {
  top: 0;
}
```

### Screen Reader Support
- Hide content visually but keep it accessible to screen readers
- Use appropriate ARIA attributes
- Ensure proper heading hierarchy

```css
/* Screen reader only content */
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}

/* Focusable for screen readers */
.sr-only:focus {
  position: static;
  width: auto;
  height: auto;
  padding: 0;
  margin: 0;
  overflow: visible;
  clip: auto;
  white-space: normal;
}
```
</conditional-block>

<conditional-block context-check="animations">
IF this Animations section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using Animation rules already in context"
ELSE:
  READ: The following animation rules

## Animations and Transitions

### Animation Principles
- Use animations sparingly and purposefully
- Ensure animations are accessible and can be disabled
- Prefer CSS transitions over JavaScript animations
- Use hardware acceleration when appropriate

```css
/* Smooth transitions */
.btn {
  transition: all 0.2s ease-in-out;
}

.btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

/* Fade in animation */
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.fade-in {
  animation: fadeIn 0.3s ease-out;
}

/* Hardware acceleration */
.animated-element {
  transform: translateZ(0);
  backface-visibility: hidden;
  perspective: 1000px;
}
```

### Micro-interactions
- Add subtle hover effects
- Include loading states
- Provide feedback for user actions
- Ensure animations respect user preferences

```css
/* Button micro-interactions */
.btn {
  position: relative;
  overflow: hidden;
}

.btn::before {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  width: 0;
  height: 0;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.2);
  transform: translate(-50%, -50%);
  transition: width 0.6s, height 0.6s;
}

.btn:active::before {
  width: 300px;
  height: 300px;
}

/* Loading states */
.loading {
  position: relative;
  pointer-events: none;
}

.loading::after {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  width: 20px;
  height: 20px;
  margin: -10px 0 0 -10px;
  border: 2px solid #f3f3f3;
  border-top: 2px solid #3b82f6;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
```
</conditional-block>

## Best Practices Summary

1. **TailwindCSS First**: Use TailwindCSS utilities for rapid development
2. **Responsive Design**: Mobile-first approach with proper breakpoints
3. **Accessibility**: Ensure all styles are accessible and inclusive
4. **Performance**: Optimize CSS loading and rendering performance
5. **Maintainability**: Keep CSS organized and well-documented
6. **Consistency**: Follow established patterns and naming conventions
7. **Custom CSS**: Use custom CSS sparingly and strategically
8. **Animation**: Use purposeful animations that enhance user experience

## Complete Example

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>CSS Style Guide Example</title>
  
  <!-- Critical CSS -->
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    
    body {
      font-family: system-ui, -apple-system, sans-serif;
      line-height: 1.6;
      color: var(--text-color);
      background-color: var(--background-color);
    }
    
    .container {
      max-width: 1200px;
      margin: 0 auto;
      padding: 0 1rem;
    }
  </style>
  
  <!-- Async TailwindCSS -->
  <script src="https://cdn.tailwindcss.com"></script>
  
  <!-- Custom CSS -->
  <style>
    :root {
      --primary-color: #3b82f6;
      --secondary-color: #64748b;
      --background-color: #ffffff;
      --text-color: #1f2937;
      --border-color: #e5e7eb;
    }
    
    .dark {
      --background-color: #111827;
      --text-color: #f9fafb;
      --border-color: #374151;
    }
    
    .custom-card {
      background-color: var(--background-color);
      border: 1px solid var(--border-color);
      border-radius: 0.5rem;
      padding: 1.5rem;
      transition: all 0.2s ease;
    }
    
    .custom-card:hover {
      transform: translateY(-2px);
      box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
    }
  </style>
</head>
<body class="bg-gray-50 dark:bg-gray-900">
  <div class="container py-8">
    <!-- Header -->
    <header class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900 dark:text-white mb-2">
        CSS Style Guide Example
      </h1>
      <p class="text-gray-600 dark:text-gray-300">
        Demonstrating proper TailwindCSS usage and custom CSS patterns
      </p>
    </header>
    
    <!-- Main Content -->
    <main class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <!-- Card 1 -->
      <article class="custom-card">
        <div class="flex items-center mb-4">
          <div class="w-12 h-12 bg-blue-100 dark:bg-blue-900 rounded-full flex items-center justify-center mr-4">
            <svg class="w-6 h-6 text-blue-600 dark:text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
            </svg>
          </div>
          <h2 class="text-xl font-semibold text-gray-900 dark:text-white">
            Fast Performance
          </h2>
        </div>
        <p class="text-gray-600 dark:text-gray-300 mb-4">
          Optimized CSS loading strategies and performance best practices.
        </p>
        <a href="#" class="inline-flex items-center text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 font-medium">
          Learn more
          <svg class="w-4 h-4 ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
          </svg>
        </a>
      </article>
      
      <!-- Card 2 -->
      <article class="custom-card">
        <div class="flex items-center mb-4">
          <div class="w-12 h-12 bg-green-100 dark:bg-green-900 rounded-full flex items-center justify-center mr-4">
            <svg class="w-6 h-6 text-green-600 dark:text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4"></path>
            </svg>
          </div>
          <h2 class="text-xl font-semibold text-gray-900 dark:text-white">
            Responsive Design
          </h2>
        </div>
        <p class="text-gray-600 dark:text-gray-300 mb-4">
          Mobile-first approach with proper breakpoints and responsive utilities.
        </p>
        <a href="#" class="inline-flex items-center text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 font-medium">
          Learn more
          <svg class="w-4 h-4 ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
          </svg>
        </a>
      </article>
      
      <!-- Card 3 -->
      <article class="custom-card">
        <div class="flex items-center mb-4">
          <div class="w-12 h-12 bg-purple-100 dark:bg-purple-900 rounded-full flex items-center justify-center mr-4">
            <svg class="w-6 h-6 text-purple-600 dark:text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"></path>
            </svg>
          </div>
          <h2 class="text-xl font-semibold text-gray-900 dark:text-white">
            Accessibility
          </h2>
        </div>
        <p class="text-gray-600 dark:text-gray-300 mb-4">
          Inclusive design with proper contrast ratios and keyboard navigation.
        </p>
        <a href="#" class="inline-flex items-center text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 font-medium">
          Learn more
          <svg class="w-4 h-4 ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
          </svg>
        </a>
      </article>
    </main>
    
    <!-- Call to Action -->
    <section class="mt-12 text-center">
      <div class="bg-gradient-to-r from-blue-500 to-purple-600 dark:from-blue-600 dark:to-purple-700 rounded-lg p-8 text-white">
        <h2 class="text-2xl font-bold mb-4">
          Ready to Get Started?
        </h2>
        <p class="text-blue-100 mb-6">
          Follow our CSS style guide to build beautiful, accessible, and performant web applications.
        </p>
        <button class="bg-white text-blue-600 px-6 py-3 rounded-lg font-semibold hover:bg-gray-100 transition-colors duration-200 transform hover:scale-105">
          Get Started
        </button>
      </div>
    </section>
  </div>
</body>
</html>
