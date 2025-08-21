# JavaScript Style Guide

## Specification-Compliant JavaScript Development

### Function Implementation Standards

```javascript
// Implements: auth-spec.md Section 2.1 - User Authentication
// Reference: functions.md::authenticateUser
async function authenticateUser(credentials) {
  // Validate according to spec requirements
  if (!credentials.email || !credentials.password) {
    throw new ValidationError('Email and password required', { 
      code: 'INVALID_CREDENTIALS',
      spec: 'auth-spec.md:2.1.2'
    });
  }
  
  // Implementation follows spec contract
  const result = await authService.validate(credentials);
  return {
    user: result.user,
    token: result.token,
    expiresAt: result.expiresAt
  }; // Matches AuthResult interface from spec
}
```

### Reference-Aware Development

```javascript
// Verified against: imports.md::auth utilities
import { validateToken, hashPassword } from '@/auth/utils';
// Functions confirmed in functions.md::validateToken:line:42, hashPassword:line:67

// Use existing patterns from codebase references
const userService = {
  // Follows pattern established in functions.md::UserService
  async createUser(userData) {
    // Reference existing validation patterns
    const validatedData = await this.validateUserData(userData);
    return await User.create(validatedData);
  }
};
```

### Error Handling Patterns

```javascript
// Error handling must match specification requirements
class APIError extends Error {
  constructor(message, options = {}) {
    super(message);
    this.name = 'APIError';
    this.code = options.code;
    this.statusCode = options.statusCode || 500;
    this.spec = options.spec; // Reference to spec section
  }
}

// Specification-driven error responses
function handleAuthError(error) {
  // Maps to error codes defined in auth-spec.md Section 3
  const errorMap = {
    'INVALID_CREDENTIALS': { status: 401, spec: 'auth-spec.md:3.1' },
    'TOKEN_EXPIRED': { status: 401, spec: 'auth-spec.md:3.2' },
    'ACCOUNT_LOCKED': { status: 423, spec: 'auth-spec.md:3.3' }
  };
  
  return errorMap[error.code] || { status: 500, spec: 'auth-spec.md:3.9' };
}
```

### Component Development (React/Vue)

```javascript
// Component props must match UI specifications
// Implements: ui-spec.md Section 4.2 - Button Component
const Button = ({ 
  variant = 'primary',    // Spec: ui-spec.md:4.2.1
  size = 'medium',        // Spec: ui-spec.md:4.2.2
  disabled = false,       // Spec: ui-spec.md:4.2.3
  onClick,
  children
}) => {
  // Validate props against specification
  const validVariants = ['primary', 'secondary', 'danger'];
  if (!validVariants.includes(variant)) {
    console.warn(`Invalid variant "${variant}". Spec: ui-spec.md:4.2.1`);
  }
  
  return (
    <button 
      className={`btn btn--${variant} btn--${size}`}
      disabled={disabled}
      onClick={onClick}
    >
      {children}
    </button>
  );
};
```

### API Integration Standards

```javascript
// API calls must conform to API specifications
// Implements: api-spec.md Section 1.3 - User Endpoints
class UserAPI {
  static async getUser(userId) {
    // Request format per api-spec.md:1.3.1
    const response = await fetch(`/api/users/${userId}`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${getToken()}`,
        'Content-Type': 'application/json'
      }
    });
    
    // Response validation per api-spec.md:1.3.2
    if (!response.ok) {
      throw new APIError('User fetch failed', {
        statusCode: response.status,
        spec: 'api-spec.md:1.3.3'
      });
    }
    
    const user = await response.json();
    // Validate response shape matches UserSchema from spec
    return this.validateUserSchema(user);
  }
}
```

### Testing Integration

```javascript
// Tests must validate specification compliance
// Test: auth-spec.md Section 2.1 requirements
describe('User Authentication', () => {
  it('should authenticate valid credentials per spec 2.1', async () => {
    const credentials = {
      email: 'user@example.com',
      password: 'validPassword123'
    };
    
    const result = await authenticateUser(credentials);
    
    // Assertions match spec requirements
    expect(result).toHaveProperty('user');
    expect(result).toHaveProperty('token');
    expect(result).toHaveProperty('expiresAt');
    expect(result.token).toMatch(/^[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+$/);
  });
  
  it('should reject invalid credentials per spec 2.1.2', async () => {
    await expect(authenticateUser({ email: '' }))
      .rejects
      .toThrow('Email and password required');
  });
});
```

### Code Documentation Standards

```javascript
/**
 * Validates user input according to specification requirements
 * @param {Object} userData - User data to validate
 * @param {string} userData.email - User email (spec: user-spec.md:1.1)
 * @param {string} userData.password - User password (spec: user-spec.md:1.2)
 * @returns {Promise<Object>} Validated user data
 * @throws {ValidationError} When data doesn't meet spec requirements
 * @spec user-spec.md:2.1 - User Data Validation
 * @reference functions.md::validateUserData:line:89
 */
async function validateUserData(userData) {
  // Implementation details...
}
```

### Import and Module Standards

```javascript
// Import organization (follows imports.md patterns)
// External dependencies first
import React from 'react';
import { Router } from 'express';

// Internal utilities (verified in imports.md)
import { validateInput } from '@/utils/validation';
import { DatabaseConnection } from '@/database/connection';

// Local modules
import './Component.styles.css';

// Export patterns that match codebase references
export { 
  authenticateUser,     // Referenced in functions.md:line:42
  validateUserData,     // Referenced in functions.md:line:89
  UserAPI              // Referenced in functions.md:line:156
};

// Default export follows established patterns
export default UserService;
```

### Performance and Optimization

```javascript
// Performance requirements from technical specifications
// Implements: performance-spec.md Section 1.2 - Response Times
const optimizedUserFetch = useMemo(() => {
  return async (userId) => {
    // Cache implementation per performance spec
    const cached = userCache.get(userId);
    if (cached && Date.now() - cached.timestamp < 300000) { // 5min cache
      return cached.data;
    }
    
    const user = await UserAPI.getUser(userId);
    userCache.set(userId, { data: user, timestamp: Date.now() });
    return user;
  };
}, []);
```

## Integration Guidelines

### Specification Compliance Checklist
- [ ] Function signatures match specification contracts
- [ ] Error handling covers all spec-defined scenarios  
- [ ] API requests/responses conform to API specifications
- [ ] Component props match UI specification requirements
- [ ] Performance meets technical specification benchmarks

### Codebase Reference Integration
- [ ] Check functions.md before creating new utilities
- [ ] Use import paths defined in imports.md
- [ ] Follow patterns established in existing codebase
- [ ] Update codebase references when adding new functions
- [ ] Verify function signatures match reference documentation

### Quality Assurance
- [ ] Code includes spec section references in comments
- [ ] Tests validate specification requirements
- [ ] Error messages reference relevant spec sections
- [ ] Documentation links to specification sources
- [ ] Implementation follows established codebase patterns