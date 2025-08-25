# JavaScript Style Guide

## Context

Global JavaScript style rules for Agent OS projects.

<conditional-block context-check="general-formatting">
IF this General Formatting section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using General Formatting rules already in context"
ELSE:
  READ: The following formatting rules

## General Formatting

### Indentation
- Use 2 spaces for indentation (never tabs)
- Maintain consistent indentation throughout files
- Align nested structures for readability

### Naming Conventions
- **Variables and Functions**: Use camelCase (e.g., `userName`, `calculateTotal`)
- **Classes and Constructors**: Use PascalCase (e.g., `UserProfile`, `PaymentProcessor`)
- **Constants**: Use UPPER_SNAKE_CASE (e.g., `MAX_RETRY_COUNT`)
- **Private Methods/Properties**: Use underscore prefix (e.g., `_internalMethod`)

### String Formatting
- Use single quotes for strings: `'Hello World'`
- Use double quotes only when interpolation is needed
- Use template literals for multi-line strings or complex interpolation

### Code Comments
- Add brief comments above non-obvious business logic
- Document complex algorithms or calculations
- Explain the "why" behind implementation choices
- Never remove existing comments unless removing the associated code
- Update comments when modifying code to maintain accuracy
- Keep comments concise and relevant
</conditional-block>

<conditional-block context-check="variable-declaration">
IF this Variable Declaration section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using Variable Declaration rules already in context"
ELSE:
  READ: The following variable declaration rules

## Variable Declaration

### Prefer const and let
- Always use `const` or `let` instead of `var`
- Use `const` by default, only use `let` when reassignment is needed
- Avoid `var` entirely due to function scoping and hoisting issues

### Example
```javascript
// Good
const userName = 'John';
let attempts = 0;

// Bad
var userName = 'John';
var attempts = 0;
```

### Destructuring
- Use destructuring for object and array properties
- Prefer object destructuring for function parameters

```javascript
// Good
function getUser({ id, name, email }) {
  return { id, name, email };
}

const { id, name } = getUser(user);

// Bad
function getUser(user) {
  return { id: user.id, name: user.name };
}
```
</conditional-block>

<conditional-block context-check="functions">
IF this Functions section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using Function rules already in context"
ELSE:
  READ: The following function rules

## Functions

### Arrow Functions
- Prefer arrow functions for callbacks and anonymous functions
- Use arrow functions for methods when `this` binding is not needed
- Keep arrow functions concise but readable

```javascript
// Good
const numbers = [1, 2, 3, 4, 5];
const doubled = numbers.map(n => n * 2);

// Good for simple returns
const add = (a, b) => a + b;

// Good for complex logic
const processUser = user => {
  if (!user) throw new Error('User is required');
  return { ...user, processed: true };
};
```

### Function Parameters
- Use default parameters instead of checking for `undefined`
- Use rest parameters for variable arguments
- Keep function parameters to a minimum (ideally 3 or fewer)

```javascript
// Good
function createUser(name, age = 18, role = 'user') {
  return { name, age, role };
}

// Good
function logMessages(...messages) {
  messages.forEach(msg => console.log(msg));
}
```

### Async/Await
- Prefer `async/await` over `.then()` chains
- Use `try/catch` for error handling
- Always handle errors in async functions

```javascript
// Good
async function fetchUserData(userId) {
  try {
    const response = await fetch(`/api/users/${userId}`);
    if (!response.ok) throw new Error('Network response was not ok');
    return await response.json();
  } catch (error) {
    console.error('Error fetching user:', error);
    throw error;
  }
}
```
</conditional-block>

<conditional-block context-check="objects-and-arrays">
IF this Objects and Arrays section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using Objects and Arrays rules already in context"
ELSE:
  READ: The following objects and arrays rules

## Objects and Arrays

### Object Creation
- Use object literals instead of `new Object()`
- Use computed property names when needed
- Prefer object shorthand for properties with same name as variable

```javascript
// Good
const user = {
  id,
  name,
  email,
  [key]: value,
  isActive: true
};

// Bad
const user = new Object();
user.id = id;
user.name = name;
```

### Array Methods
- Use appropriate array methods (`map`, `filter`, `reduce`, `forEach`)
- Prefer functional programming style over imperative loops
- Chain methods when it improves readability

```javascript
// Good
const activeUsers = users
  .filter(user => user.isActive)
  .map(user => ({ id: user.id, name: user.name }));

// Bad
const activeUsers = [];
for (let i = 0; i < users.length; i++) {
  if (users[i].isActive) {
    activeUsers.push({
      id: users[i].id,
      name: users[i].name
    });
  }
}
```

### Spread and Rest Operators
- Use spread operator for copying arrays and objects
- Use rest operator for function parameters
- Prefer spread over `concat` and `slice` for copying

```javascript
// Good
const newArray = [...oldArray];
const newObject = { ...oldObject };
const { a, b, ...rest } = obj;

// Bad
const newArray = oldArray.slice();
const newObject = Object.assign({}, oldObject);
```
</conditional-block>

<conditional-block context-check="error-handling">
IF this Error Handling section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using Error Handling rules already in context"
ELSE:
  READ: The following error handling rules

## Error Handling

### Custom Errors
- Create custom error classes for specific error types
- Use error codes for programmatic error handling
- Include relevant context in error messages

```javascript
// Good
class ValidationError extends Error {
  constructor(message, field) {
    super(message);
    this.name = 'ValidationError';
    this.field = field;
    this.code = 'VALIDATION_ERROR';
  }
}

// Usage
if (!user.email) {
  throw new ValidationError('Email is required', 'email');
}
```

### Error Boundaries
- Implement error boundaries in client-side applications
- Log errors appropriately
- Provide fallback UI when possible

### Promise Rejection
- Always handle promise rejections
- Use `async/await` with try/catch for better error handling
- Avoid unhandled promise rejections

```javascript
// Good
async function fetchData() {
  try {
    const data = await fetch('/api/data');
    return await data.json();
  } catch (error) {
    console.error('Fetch failed:', error);
    throw new Error('Failed to fetch data');
  }
}

// Good
fetch('/api/data')
  .then(response => response.json())
  .then(data => console.log(data))
  .catch(error => console.error('Error:', error));
```
</conditional-block>

<conditional-block context-check="modules">
IF this Modules section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using Module rules already in context"
ELSE:
  READ: The following module rules

## Modules

### Import/Export
- Use ES6 modules (`import`/`export`)
- Prefer named exports over default exports
- Group imports logically

```javascript
// Good
import { useState, useEffect } from 'react';
import { apiService } from './services/api';
import { logger } from './utils/logger';

// Good - named export
export const config = {
  apiUrl: 'https://api.example.com',
  timeout: 5000
};

// Good - default export for main functionality
export default function App() {
  // ...
}
```

### Module Organization
- Keep modules focused on a single responsibility
- Use index files for clean imports
- Avoid circular dependencies

### Dynamic Imports
- Use dynamic imports for code splitting
- Load non-critical modules asynchronously

```javascript
// Good
if (featureEnabled) {
  const { heavyModule } = await import('./heavyModule');
  heavyModule.initialize();
}
```
</conditional-block>

<conditional-block context-check="testing">
IF this Testing section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using Testing rules already in context"
ELSE:
  READ: The following testing rules

## Testing

### Test Structure
- Write tests for all public APIs
- Use descriptive test names
- Follow AAA pattern (Arrange, Act, Assert)

```javascript
// Good
describe('UserService', () => {
  describe('createUser', () => {
    it('should create a user with valid data', () => {
      // Arrange
      const userData = { name: 'John', email: 'john@example.com' };
      
      // Act
      const user = userService.createUser(userData);
      
      // Assert
      expect(user).toHaveProperty('id');
      expect(user.name).toBe('John');
      expect(user.email).toBe('john@example.com');
    });
  });
});
```

### Mocking and Spies
- Mock external dependencies
- Use spies for function calls
- Avoid implementation details in tests

### Test Coverage
- Aim for high test coverage
- Include edge cases and error scenarios
- Use snapshot testing for UI components
</conditional-block>

<conditional-block context-check="performance">
IF this Performance section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using Performance rules already in context"
ELSE:
  READ: The following performance rules

## Performance

### Memory Management
- Avoid memory leaks by cleaning up event listeners
- Use weak references when appropriate
- Be cautious with closures

### Optimization
- Use efficient algorithms and data structures
- Profile code to identify bottlenecks
- Implement lazy loading for heavy operations

```javascript
// Good - memoization
const memoize = (fn) => {
  const cache = new Map();
  return (...args) => {
    const key = JSON.stringify(args);
    if (cache.has(key)) return cache.get(key);
    const result = fn(...args);
    cache.set(key, result);
    return result;
  };
};

// Usage
const expensiveFunction = memoize((n) => {
  // Heavy computation
  return n * 2;
});
```

### Asynchronous Operations
- Use `Promise.all` for parallel operations
- Implement proper cancellation for long-running operations
- Use debouncing and throttling for event handlers
</conditional-block>

<conditional-block context-check="security">
IF this Security section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using Security rules already in context"
ELSE:
  READ: The following security rules

## Security

### Input Validation
- Validate all user inputs
- Sanitize data before processing
- Use parameterized queries for database operations

### XSS Prevention
- Escape user-generated content
- Use Content Security Policy (CSP)
- Avoid `innerHTML`, use `textContent` or `createElement`

### Data Protection
- Never expose sensitive data in client-side code
- Use HTTPS for all API calls
- Implement proper authentication and authorization

```javascript
// Good - input validation
function validateEmail(email) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    throw new Error('Invalid email format');
  }
  return email;
}

// Good - secure API call
async function fetchSecureData(token) {
  const response = await fetch('/api/secure-data', {
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    }
  });
  return response.json();
}
```
</conditional-block>

## Best Practices Summary

1. **Code Quality**: Write clean, readable, and maintainable code
2. **Error Handling**: Handle errors gracefully and consistently
3. **Testing**: Write comprehensive tests for all functionality
4. **Performance**: Optimize for performance without sacrificing readability
5. **Security**: Follow security best practices to prevent vulnerabilities
6. **Documentation**: Document code thoroughly and consistently
7. **Consistency**: Follow established patterns and conventions
8. **Modularity**: Keep code modular and focused on single responsibilities
