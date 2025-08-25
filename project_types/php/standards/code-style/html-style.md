# HTML Style Guide

## Context

Global HTML style rules for Agent OS projects.

<conditional-block context-check="general-formatting">
IF this General Formatting section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using General Formatting rules already in context"
ELSE:
  READ: The following formatting rules

## General Formatting

### Indentation
- Use 2 spaces for indentation (never tabs)
- Place nested elements on new lines with proper indentation
- Content between tags should be on its own line when multi-line

### Attribute Formatting
- Place each HTML attribute on its own line
- Align attributes vertically
- Keep the closing `>` on the same line as the last attribute
- Use double quotes for attribute values
- Alphabetize custom attributes when possible

### Line Length
- Keep lines under 100 characters when possible
- Break long attribute lists appropriately
- Maintain readability across different screen sizes

### Whitespace
- Use consistent spacing around operators and values
- Remove unnecessary whitespace
- Use meaningful line breaks for complex structures
</conditional-block>

<conditional-block context-check="document-structure">
IF this Document Structure section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using Document Structure rules already in context"
ELSE:
  READ: The following document structure rules

## Document Structure

### Doctype and HTML Element
- Always use HTML5 doctype: `<!DOCTYPE html>`
- Include `lang` attribute on the `html` element
- Use proper meta tags for character encoding and viewport

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Page Title</title>
</head>
<body>
  <!-- Content -->
</body>
</html>
```

### Head Section
- Include proper meta tags
- Use descriptive page titles
- Add Open Graph and Twitter Card tags for social sharing
- Include favicon and touch icons
- Add proper meta description for SEO

```html
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="Page description for search engines">
  <meta name="keywords" content="relevant, keywords, here">
  <meta name="author" content="Author Name">
  
  <!-- Open Graph -->
  <meta property="og:title" content="Page Title">
  <meta property="og:description" content="Page description">
  <meta property="og:image" content="https://example.com/image.jpg">
  <meta property="og:url" content="https://example.com">
  <meta property="og:type" content="website">
  
  <!-- Twitter Card -->
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="Page Title">
  <meta name="twitter:description" content="Page description">
  <meta name="twitter:image" content="https://example.com/image.jpg">
  
  <title>Page Title - Site Name</title>
  <link rel="icon" href="/favicon.ico">
  <link rel="apple-touch-icon" href="/apple-touch-icon.png">
</head>
```

### Semantic HTML5
- Use semantic elements appropriately
- Choose the right element for the right purpose
- Avoid using divs when semantic elements are available

```html
<!-- Good - Semantic structure -->
<header>
  <nav>
    <ul>
      <li><a href="/">Home</a></li>
      <li><a href="/about">About</a></li>
    </ul>
  </nav>
</header>

<main>
  <article>
    <h1>Article Title</h1>
    <p>Article content...</p>
  </article>
  
  <aside>
    <h2>Related Links</h2>
    <ul>
      <li><a href="#">Related Link 1</a></li>
    </ul>
  </aside>
</main>

<footer>
  <p>&copy; 2024 Site Name</p>
</footer>
```
</conditional-block>

<conditional-block context-check="forms">
IF this Forms section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using Forms rules already in context"
ELSE:
  READ: The following forms rules

## Forms

### Form Structure
- Use appropriate form elements
- Include proper labels for all form controls
- Use fieldsets and legends for grouping related controls
- Add proper form validation attributes

```html
<form action="/submit" method="POST">
  <fieldset>
    <legend>User Information</legend>
    
    <div class="form-group">
      <label for="name">Name</label>
      <input type="text" id="name" name="name" required>
    </div>
    
    <div class="form-group">
      <label for="email">Email</label>
      <input type="email" id="email" name="email" required>
    </div>
    
    <div class="form-group">
      <label for="message">Message</label>
      <textarea id="message" name="message" rows="4" required></textarea>
    </div>
  </fieldset>
  
  <button type="submit">Submit</button>
</form>
```

### Form Accessibility
- Associate labels with inputs using `for` and `id`
- Use appropriate input types
- Include placeholder text sparingly
- Provide error messages and validation feedback

```html
<!-- Good accessible form -->
<div class="form-group">
  <label for="email">Email Address</label>
  <input 
    type="email" 
    id="email" 
    name="email" 
    placeholder="your.email@example.com"
    required
    aria-required="true"
    aria-describedby="email-error"
  >
  <div id="email-error" class="error-message" style="display: none;">
    Please enter a valid email address
  </div>
</div>
```
</conditional-block>

<conditional-block context-check="accessibility">
IF this Accessibility section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using Accessibility rules already in context"
ELSE:
  READ: The following accessibility rules

## Accessibility

### ARIA Attributes
- Use ARIA attributes when necessary
- Provide alternative text for images
- Ensure keyboard navigation works properly
- Use proper heading hierarchy

```html
<!-- Good accessibility practices -->
<img src="chart.png" alt="Sales chart showing quarterly growth" width="400" height="300">

<button aria-label="Close menu" aria-expanded="false">
  <svg aria-hidden="true" focusable="false">
    <!-- Menu icon -->
  </svg>
</button>

<nav aria-label="Main navigation">
  <ul>
    <li><a href="/">Home</a></li>
    <li><a href="/about">About</a></li>
  </ul>
</nav>

<!-- Skip to main content link -->
<a href="#main-content" class="skip-link">Skip to main content</a>

<main id="main-content">
  <!-- Main content -->
</main>
```

### Focus Management
- Ensure visible focus indicators
- Maintain logical tab order
- Provide keyboard shortcuts where appropriate
- Use `tabindex` sparingly and correctly

```html
<!-- Good focus management -->
<button 
  id="menu-toggle" 
  aria-controls="primary-menu" 
  aria-expanded="false"
  aria-label="Toggle navigation menu">
  Menu
</button>

<nav id="primary-menu" style="display: none;">
  <a href="/" class="focus:outline-none">Home</a>
  <a href="/about" class="focus:outline-none">About</a>
</nav>
```
</conditional-block>

<conditional-block context-check="responsive-design">
IF this Responsive Design section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using Responsive Design rules already in context"
ELSE:
  READ: The following responsive design rules

## Responsive Design

### Viewport Meta Tag
- Always include viewport meta tag
- Use appropriate initial scale
- Consider user-scalable settings

```html
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0">
```

### Mobile-First Approach
- Design for mobile first
- Use progressive enhancement
- Test on multiple devices and screen sizes

```html
<!-- Mobile-first responsive structure -->
<div class="container">
  <div class="grid grid-cols-1 gap-4">
    <!-- Mobile: single column -->
    <div class="order-1">Content 1</div>
    <div class="order-2">Content 2</div>
    
    <!-- Tablet: two columns -->
    <div class="md:col-span-1 md:order-1">Content 1</div>
    <div class="md:col-span-1 md:order-2">Content 2</div>
    
    <!-- Desktop: three columns -->
    <div class="lg:col-span-1 lg:order-1">Content 1</div>
    <div class="lg:col-span-1 lg:order-2">Content 2</div>
    <div class="lg:col-span-1 lg:order-3">Content 3</div>
  </div>
</div>
```

### Touch Targets
- Ensure touch targets are large enough (minimum 44x44 pixels)
- Provide adequate spacing between interactive elements
- Consider finger-friendly navigation

```html
<!-- Good touch targets -->
<button class="px-4 py-2 text-lg">Large Button</button>
<nav class="flex space-x-4">
  <a href="#" class="px-3 py-2">Link 1</a>
  <a href="#" class="px-3 py-2">Link 2</a>
</nav>
```
</conditional-block>

<conditional-block context-check="performance">
IF this Performance section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using Performance rules already in context"
ELSE:
  READ: The following performance rules

## Performance

### Optimized HTML
- Minimize DOM depth
- Use efficient selectors
- Avoid inline styles and scripts
- Optimize image loading

```html
<!-- Good performance practices -->
<!-- Use loading attribute for images -->
<img src="image.jpg" alt="Description" loading="lazy" width="400" height="300">

<!-- Use async/defer for scripts -->
<script src="analytics.js" async></script>
<script src="app.js" defer></script>

<!-- Use preconnect for critical resources -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://images.example.com">

<!-- Use resource hints -->
<link rel="dns-prefetch" href="https://api.example.com">
```

### Critical CSS
- Include critical CSS inline
- Use async loading for non-critical CSS
- Minimize render-blocking resources

```html
<head>
  <!-- Critical CSS inline -->
  <style>
    /* Critical styles above the fold */
    body { font-family: system-ui, sans-serif; }
    .header { background: white; }
  </style>
  
  <!-- Async CSS loading -->
  <link rel="stylesheet" href="styles.css" media="print" onload="this.media='all'">
</head>
```
</conditional-block>

## Example HTML Structure

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="Page description for search engines">
  <title>Page Title - Site Name</title>
  
  <!-- Preconnect for performance -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://images.example.com">
  
  <!-- Critical CSS -->
  <style>
    body { 
      margin: 0; 
      font-family: system-ui, -apple-system, sans-serif;
      line-height: 1.6;
    }
    .container { max-width: 1200px; margin: 0 auto; }
  </style>
  
  <!-- Async CSS -->
  <link rel="stylesheet" href="styles.css" media="print" onload="this.media='all'">
  
  <!-- Favicon -->
  <link rel="icon" href="/favicon.ico" type="image/x-icon">
</head>
<body>
  <!-- Skip to main content -->
  <a href="#main-content" class="skip-link">Skip to main content</a>
  
  <!-- Header -->
  <header class="bg-white shadow-sm">
    <div class="container">
      <nav aria-label="Main navigation" class="flex items-center justify-between py-4">
        <a href="/" class="text-xl font-bold">Site Name</a>
        
        <button 
          id="menu-toggle" 
          class="md:hidden p-2"
          aria-controls="primary-menu"
          aria-expanded="false"
          aria-label="Toggle menu">
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
          </svg>
        </button>
        
        <ul id="primary-menu" class="hidden md:flex space-x-6">
          <li><a href="/" class="hover:text-blue-600">Home</a></li>
          <li><a href="/about" class="hover:text-blue-600">About</a></li>
          <li><a href="/contact" class="hover:text-blue-600">Contact</a></li>
        </ul>
      </nav>
    </div>
  </header>
  
  <!-- Main Content -->
  <main id="main-content" class="container py-8">
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
      <!-- Primary Content -->
      <article class="lg:col-span-2">
        <h1 class="text-3xl font-bold mb-4">Page Title</h1>
        <p class="text-gray-600 mb-6">Introduction paragraph goes here...</p>
        
        <div class="bg-gray-50 p-6 rounded-lg">
          <h2 class="text-xl font-semibold mb-4">Section Title</h2>
          <p>Content section...</p>
        </div>
      </article>
      
      <!-- Sidebar -->
      <aside class="lg:col-span-1">
        <div class="bg-white p-6 rounded-lg shadow-sm">
          <h3 class="text-lg font-semibold mb-4">Related Links</h3>
          <ul class="space-y-2">
            <li><a href="#" class="text-blue-600 hover:underline">Related Link 1</a></li>
            <li><a href="#" class="text-blue-600 hover:underline">Related Link 2</a></li>
          </ul>
        </div>
      </aside>
    </div>
  </main>
  
  <!-- Footer -->
  <footer class="bg-gray-800 text-white py-8">
    <div class="container">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
        <div>
          <h4 class="font-semibold mb-4">About</h4>
          <p class="text-gray-300">Company description...</p>
        </div>
        <div>
          <h4 class="font-semibold mb-4">Links</h4>
          <ul class="space-y-2">
            <li><a href="#" class="text-gray-300 hover:text-white">Privacy Policy</a></li>
            <li><a href="#" class="text-gray-300 hover:text-white">Terms of Service</a></li>
          </ul>
        </div>
        <div>
          <h4 class="font-semibold mb-4">Contact</h4>
          <p class="text-gray-300">contact@example.com</p>
        </div>
      </div>
      <div class="border-t border-gray-700 mt-8 pt-8 text-center text-gray-300">
        <p>&copy; 2024 Site Name. All rights reserved.</p>
      </div>
    </div>
  </footer>
  
  <!-- Scripts -->
  <script src="app.js" defer></script>
</body>
</html>
```

## Best Practices Summary

1. **Semantic HTML**: Use appropriate HTML5 elements for their intended purpose
2. **Accessibility**: Ensure all content is accessible to users with disabilities
3. **Performance**: Optimize HTML for fast loading and rendering
4. **Responsive Design**: Create layouts that work across all devices
5. **Maintainability**: Write clean, well-organized HTML that's easy to maintain
6. **SEO**: Include proper meta tags and semantic structure for search engines
7. **Consistency**: Follow established patterns and conventions
8. **Validation**: Ensure HTML validates against standards
