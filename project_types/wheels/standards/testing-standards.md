# Testing Standards

## E2E Testing with Puppeteer

### Setup and Configuration

#### Installation
```bash
npm install --save-dev puppeteer
```

#### Project Structure
```
tests/
├── ui/
│   ├── test-auth-pages.js       # Authentication UI tests
│   ├── test-bootstrap-styling.js # Framework validation tests
│   └── test-report.json          # Generated test reports
└── screenshots/
    ├── login-current-state.png   # Visual documentation
    └── register-current-state.png
```

### Test Implementation Guidelines

#### 1. Document Current State
Always capture the current state before making changes:
```javascript
// Capture broken UI state for documentation
await page.screenshot({ 
    path: 'screenshots/broken-state.png', 
    fullPage: true 
});
```

#### 2. Framework Detection
Test for CSS/JS framework conflicts:
```javascript
const frameworks = await page.evaluate(() => {
    return {
        bootstrap: !!document.querySelector('link[href*="bootstrap"]'),
        tailwind: !!document.querySelector('script[src*="tailwind"]'),
        alpine: typeof window.Alpine !== 'undefined',
        htmx: typeof window.htmx !== 'undefined'
    };
});
```

#### 3. Responsive Testing
Test all major breakpoints:
```javascript
const viewports = [
    { name: 'mobile', width: 375, height: 667 },
    { name: 'tablet', width: 768, height: 1024 },
    { name: 'desktop', width: 1920, height: 1080 }
];

for (const viewport of viewports) {
    await page.setViewport(viewport);
    await page.screenshot({ 
        path: `screenshots/${testName}-${viewport.name}.png` 
    });
}
```

#### 4. Visual Validation
Check computed styles to verify CSS is applied:
```javascript
const cardStyles = await page.evaluate(() => {
    const card = document.querySelector('.card');
    if (!card) return null;
    
    const styles = window.getComputedStyle(card);
    return {
        display: styles.display,
        backgroundColor: styles.backgroundColor,
        borderRadius: styles.borderRadius,
        width: card.offsetWidth,
        height: card.offsetHeight
    };
});
```

### Test Scenarios

#### Authentication Pages
- Login form visibility and styling
- Register form with all fields
- Password strength indicators
- Error message display
- Success redirects

#### UI Components
- Card containers and shadows
- Form control styling
- Button states (normal, hover, disabled)
- Alert messages
- Progress bars

#### Framework Integration
- Bootstrap CSS loading
- Alpine.js reactivity
- HTMX form submissions
- Icon libraries (Bootstrap Icons)

### Reporting

#### JSON Report Structure
```javascript
const testReport = {
    timestamp: new Date().toISOString(),
    url: testUrl,
    frameworks: detectedFrameworks,
    issues: [],
    recommendations: [],
    screenshots: []
};

fs.writeFileSync('test-report.json', JSON.stringify(testReport, null, 2));
```

#### Markdown Reports
Generate human-readable reports:
```markdown
# UI Test Report
## Issues Found
- Framework conflict: TailwindCSS vs Bootstrap
- Missing card styling
- Form controls not styled

## Fixes Applied
- Replaced TailwindCSS with Bootstrap 5.3.0
- Added custom auth styles
- Fixed ColdFusion hash escaping
```

### CI/CD Integration

#### GitHub Actions Example
```yaml
- name: Run UI Tests
  run: |
    npm install
    HEADLESS=true npm run test:ui
```

#### Environment Variables
```javascript
const BASE_URL = process.env.BASE_URL || 'http://localhost:8080';
const HEADLESS = process.env.HEADLESS === 'true';
```

### Common Pitfalls to Avoid

1. **Not waiting for dynamic content**
   ```javascript
   // Bad
   await page.goto(url);
   
   // Good
   await page.goto(url, { waitUntil: 'networkidle0' });
   await new Promise(resolve => setTimeout(resolve, 2000));
   ```

2. **Hardcoding timeouts**
   ```javascript
   // Use configurable timeouts
   const TIMEOUT = process.env.TEST_TIMEOUT || 30000;
   ```

3. **Not handling errors gracefully**
   ```javascript
   try {
       await page.goto(url);
   } catch (error) {
       console.error(`Failed to load ${url}:`, error.message);
       testResults.issues.push(`Page failed to load: ${error.message}`);
   }
   ```

4. **Forgetting to close browser**
   ```javascript
   try {
       // Run tests
   } finally {
       await browser.close();
   }
   ```

### Best Practices Summary

1. **Always capture before/after screenshots**
2. **Test on multiple viewports**
3. **Validate framework loading**
4. **Check computed styles, not just classes**
5. **Generate comprehensive reports**
6. **Use headless mode for CI/CD**
7. **Handle errors gracefully**
8. **Clean up resources properly**