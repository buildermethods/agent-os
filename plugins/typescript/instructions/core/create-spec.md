# create-spec (TypeScript Enhanced)

Create a comprehensive specification document for a TypeScript feature or component with stack-specific patterns.

## Usage

```
Use create-spec to design [feature/component name]
```

## Process

1. **Analyze Requirements**
   - Identify TypeScript-specific needs
   - Determine which stack variant applies (Default/MERN/MEAN)
   - Consider type safety requirements
   - Plan component architecture

2. **Create Specification Structure**
   - Overview and objectives
   - Technical requirements with TypeScript types
   - UI/UX specifications (React/Angular components)
   - API endpoints (Hono.js/Express patterns)
   - Database schema (Drizzle/Mongoose)
   - Implementation notes

3. **Stack-Specific Patterns**

   ### Default Stack (React + Hono.js + PostgreSQL)
   ```typescript
   // React Component Interface
   interface UserDashboardProps {
     userId: string;
     theme?: 'light' | 'dark';
   }

   // Hono.js Route Type
   app.get('/api/users/:id', async (c) => {
     const { id } = c.req.param();
     // Type-safe response
   });

   // Drizzle Schema
   export const users = pgTable('users', {
     id: serial('id').primaryKey(),
     email: varchar('email', { length: 255 }).notNull().unique(),
   });
   ```

   ### MERN Stack (MongoDB + Express + React)
   ```typescript
   // Mongoose Schema with TypeScript
   interface IUser extends Document {
     email: string;
     createdAt: Date;
   }

   // Express Route with Types
   router.get('/users/:id', async (req: Request, res: Response) => {
     const user = await User.findById(req.params.id);
     res.json(user);
   });
   ```

   ### MEAN Stack (MongoDB + Express + Angular)
   ```typescript
   // Angular Service
   @Injectable({
     providedIn: 'root'
   })
   export class UserService {
     constructor(private http: HttpClient) {}
     
     getUser(id: string): Observable<User> {
       return this.http.get<User>(`/api/users/${id}`);
     }
   }
   ```

4. **Include TypeScript-Specific Sections**
   - Type definitions and interfaces
   - Generic type constraints
   - Discriminated unions for state management
   - Error handling with custom error types
   - Type guards and assertions

5. **Testing Specifications**
   - Unit tests with Vitest
   - Component tests with React Testing Library
   - E2E tests with Playwright
   - Type coverage requirements

## Output Format

```markdown
# [Feature Name] Specification

## Overview
Brief description with TypeScript and stack context

## Technical Requirements

### TypeScript Configuration
- Strict mode settings
- Module resolution
- Build targets

### Type Definitions
```typescript
// Core interfaces and types
```

### Component Architecture
[React/Angular component structure based on stack]

### API Design
[Hono.js/Express endpoints based on stack]

### Database Schema
[Drizzle/Mongoose schema based on stack]

### State Management
[Zustand/Context API/NgRx patterns]

## Implementation Tasks
1. Define TypeScript interfaces
2. Create database schema
3. Implement API endpoints
4. Build UI components
5. Add comprehensive tests

## Testing Strategy
- Type safety validation
- Unit test coverage
- Integration tests
- E2E test scenarios
```

## Best Practices

1. **Type-First Development**
   - Define interfaces before implementation
   - Use strict TypeScript configuration
   - Avoid `any` types

2. **Stack-Specific Patterns**
   - Follow React/Angular conventions
   - Use appropriate ORM patterns
   - Implement proper error boundaries

3. **Code Organization**
   - Separate type definitions
   - Group related functionality
   - Use barrel exports

4. **Documentation**
   - JSDoc for complex types
   - README for each module
   - API documentation with examples

## Example

**Input**: "Use create-spec to design a user authentication system"

**Output**: Complete specification with:
- TypeScript interfaces for User, Session, AuthRequest
- React components for login/register (or Angular components for MEAN)
- Hono.js endpoints for auth (or Express for MERN/MEAN)
- Drizzle schema for users table (or Mongoose for MERN/MEAN)
- JWT token management with types
- Comprehensive test specifications