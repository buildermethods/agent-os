# Specification Templates

## Context

Template structures for generating comprehensive specifications from minimal input, organized by feature type and complexity level to enable smart spec generation.

## Overview

This document provides structured templates that the smart spec generator uses to create detailed, professional specifications that follow Agent OS standards while adapting to specific project contexts and user preferences.

---

## User Management Spec Templates

### User Authentication System Template
```yaml
Template: "user_authentication_spec"
Triggers: ["authentication", "auth", "login", "user management"]
Complexity: Medium-High

Spec Structure:
```markdown
# User Authentication System

## Overview
Implement a secure user authentication system that supports email/password registration and login, session management, and password recovery functionality. This system will enable personalized user experiences and secure access control throughout the application.

## User Stories

### Registration & Onboarding
- **As a new user**, I want to register with my email and password so that I can create an account and access personalized features
- **As a new user**, I want to receive an email verification so that I can confirm my account and ensure email deliverability
- **As a new user**, I want clear feedback during registration so that I understand any requirements or validation errors

### Authentication & Sessions
- **As a returning user**, I want to log in with my credentials so that I can access my account securely
- **As a user**, I want to stay logged in across browser sessions so that I don't need to re-authenticate frequently
- **As a user**, I want the option to log out from all devices so that I can secure my account if needed

### Password Recovery
- **As a user**, I want to reset my password if forgotten so that I can regain access to my account
- **As a user**, I want password reset links to expire after reasonable time so that my account remains secure
- **As a user**, I want confirmation when my password is successfully changed

### Security & Account Management
- **As a user**, I want to see my active sessions so that I can monitor account access
- **As a user**, I want to enable two-factor authentication so that my account has additional security
- **As a user**, I want to be notified of suspicious login attempts so that I can secure my account

## Technical Requirements

### Authentication Strategy
- JWT token-based authentication with refresh token rotation
- HTTP-only cookies for refresh token storage
- Access tokens with short expiration (15-30 minutes)
- Refresh tokens with longer expiration (7-30 days)

### Security Implementation
- Password hashing using bcrypt with minimum 12 salt rounds
- Rate limiting on authentication endpoints (5 attempts per 15 minutes per IP)
- Account lockout after failed attempts (temporary 30-minute lockout)
- Secure password requirements (minimum 8 characters, mixed case, numbers)

### Database Schema
```sql
-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  email_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  last_login TIMESTAMP,
  failed_login_attempts INTEGER DEFAULT 0,
  locked_until TIMESTAMP,
  two_factor_enabled BOOLEAN DEFAULT FALSE
);

-- Refresh tokens table
CREATE TABLE refresh_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  token_hash VARCHAR(255) NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  revoked_at TIMESTAMP
);

-- Email verification table
CREATE TABLE email_verifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  token VARCHAR(255) NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### API Endpoints
- `POST /auth/register` - User registration
- `POST /auth/login` - User authentication
- `POST /auth/refresh` - Token refresh
- `POST /auth/logout` - Single session logout
- `POST /auth/logout-all` - All sessions logout
- `POST /auth/forgot-password` - Password reset request
- `POST /auth/reset-password` - Password reset completion
- `GET /auth/verify-email/:token` - Email verification
- `GET /auth/me` - Get current user info

## Implementation Tasks

### Phase 1: Core Authentication (Week 1)
- [ ] **Task 1.1**: Set up database schema and migrations
  - Create users, refresh_tokens, and email_verifications tables
  - Add appropriate indexes for email lookups and token queries
  - Set up database constraints and relationships

- [ ] **Task 1.2**: Implement user registration endpoint
  - Create registration validation middleware
  - Implement password hashing with bcrypt
  - Generate email verification tokens
  - Send verification emails

- [ ] **Task 1.3**: Implement login and token management
  - Create login endpoint with credential validation
  - Generate JWT access and refresh tokens
  - Implement token refresh endpoint
  - Add logout functionality with token cleanup

### Phase 2: Security Features (Week 2)
- [ ] **Task 2.1**: Add rate limiting and account security
  - Implement rate limiting middleware for auth endpoints
  - Add account lockout after failed attempts
  - Create session management endpoints
  - Add login attempt logging

- [ ] **Task 2.2**: Implement password recovery system
  - Create forgot password endpoint
  - Generate secure password reset tokens
  - Implement reset password endpoint
  - Add email notifications for security events

### Phase 3: Advanced Features (Week 3)
- [ ] **Task 3.1**: Add two-factor authentication
  - Implement TOTP-based 2FA setup
  - Create 2FA verification endpoints
  - Add backup codes generation
  - Update login flow for 2FA validation

- [ ] **Task 3.2**: Session management and monitoring
  - Create active sessions display
  - Add device/location tracking
  - Implement session revocation
  - Add suspicious activity detection

## Acceptance Criteria

### Functional Requirements
- ✅ Users can register with email and password
- ✅ Email verification is required for account activation
- ✅ Users can log in with valid credentials
- ✅ JWT tokens are properly generated and validated
- ✅ Password reset flow works via email
- ✅ Two-factor authentication is available
- ✅ Users can view and manage active sessions

### Security Requirements
- ✅ Passwords are properly hashed and salted
- ✅ Rate limiting prevents brute force attacks
- ✅ Account lockout protects against persistent attacks
- ✅ JWT tokens expire appropriately and can be refreshed
- ✅ All authentication endpoints use HTTPS
- ✅ Session tokens are stored securely

### Performance Requirements
- ✅ Login completes within 2 seconds under normal load
- ✅ Token validation adds less than 100ms to protected requests
- ✅ Password hashing uses appropriate computational cost
- ✅ Database queries are optimized with proper indexes

## Quality Standards

### Testing Requirements
- Unit tests for all authentication utilities and services
- Integration tests for complete authentication flows
- Security tests for common attack vectors
- Performance tests for auth endpoints under load
- End-to-end tests for user registration and login journeys

### Security Validation
- Security audit of authentication implementation
- Penetration testing of auth endpoints
- Code review focused on security considerations
- Compliance check against security standards (OWASP)

### Documentation Requirements
- API documentation with authentication examples
- Security implementation documentation
- Deployment and configuration guide
- User guide for account management features
```

Integration Notes:
- Integrates with existing user profile management
- Supports future role-based authorization system
- Compatible with social login additions
- Designed for microservices architecture if needed
```
```

### Data Management Spec Template
```yaml
Template: "data_management_spec"
Triggers: ["export", "import", "backup", "data management"]
Complexity: Medium

Spec Structure:
```markdown
# Data Export/Import System

## Overview
Implement a comprehensive data management system that allows users to export their data in multiple formats and import data from external sources. This system ensures data portability, backup capabilities, and integration with external tools.

## User Stories

### Data Export
- **As a user**, I want to export my data to CSV format so that I can analyze it in spreadsheet applications
- **As a user**, I want to export data to JSON format so that I can integrate with other applications
- **As an admin**, I want to export system data in bulk so that I can perform backups and migrations
- **As a user**, I want to track export progress so that I know when large exports will complete

### Data Import
- **As a user**, I want to import data from CSV files so that I can migrate from other systems
- **As a user**, I want to validate data before import so that I can fix errors beforehand
- **As an admin**, I want to import large datasets efficiently so that system migration doesn't impact performance
- **As a user**, I want to see import results and error reports so that I can understand what was processed

## Technical Requirements

### Export Functionality
- Support for CSV, JSON, and Excel formats
- Streaming exports for large datasets
- Background processing for exports >10MB
- Progress tracking and status updates
- Configurable data filtering and selection

### Import Functionality
- CSV and JSON import with validation
- Batch processing with configurable chunk sizes
- Data transformation and mapping capabilities
- Duplicate detection and handling
- Rollback capability for failed imports

### Data Processing
```typescript
interface ExportOptions {
  format: 'csv' | 'json' | 'excel';
  filters: Record<string, any>;
  fields: string[];
  dateRange?: {
    start: Date;
    end: Date;
  };
}

interface ImportOptions {
  format: 'csv' | 'json';
  mapping: Record<string, string>;
  skipDuplicates: boolean;
  batchSize: number;
  validateOnly: boolean;
}
```

## Implementation Tasks

### Phase 1: Export System (Week 1)
- [ ] **Task 1.1**: Implement CSV export functionality
- [ ] **Task 1.2**: Add JSON export with configurable fields
- [ ] **Task 1.3**: Create Excel export with formatting
- [ ] **Task 1.4**: Add progress tracking for large exports

### Phase 2: Import System (Week 2)
- [ ] **Task 2.1**: Create CSV import with validation
- [ ] **Task 2.2**: Implement data mapping and transformation
- [ ] **Task 2.3**: Add duplicate detection and handling
- [ ] **Task 2.4**: Create import preview and validation

### Phase 3: Advanced Features (Week 3)
- [ ] **Task 3.1**: Add scheduled exports
- [ ] **Task 3.2**: Implement data versioning
- [ ] **Task 3.3**: Create audit trail for imports/exports
- [ ] **Task 3.4**: Add API access for programmatic data management

## Acceptance Criteria

### Export Requirements
- ✅ Data exports correctly in CSV, JSON, and Excel formats
- ✅ Large exports (>100MB) process in background
- ✅ Export progress is tracked and displayed to users
- ✅ Exported data maintains referential integrity
- ✅ Users can filter and customize export data

### Import Requirements
- ✅ CSV and JSON imports process correctly
- ✅ Data validation prevents corrupt imports
- ✅ Import errors are reported with specific details
- ✅ Failed imports can be rolled back
- ✅ Duplicate handling works as configured

## Quality Standards
- Data integrity validation for all operations
- Performance optimization for large datasets
- Comprehensive error handling and reporting
- Security controls for data access
- Audit logging for all data operations
```
```

---

## E-commerce Spec Templates

### Shopping Cart System Template
```yaml
Template: "shopping_cart_spec"
Triggers: ["cart", "shopping", "ecommerce", "basket"]
Complexity: Medium-High

Spec Structure:
```markdown
# Shopping Cart System

## Overview
Implement a comprehensive shopping cart system that supports adding/removing items, quantity management, price calculations, and inventory validation. The system will handle both guest and authenticated user carts with persistent storage.

## User Stories

### Cart Management
- **As a shopper**, I want to add products to my cart so that I can purchase multiple items together
- **As a shopper**, I want to modify quantities in my cart so that I can buy the exact amount I need
- **As a shopper**, I want to remove items from my cart so that I can change my mind about purchases
- **As a shopper**, I want to see cart totals in real-time so that I know the total cost before checkout

### Cart Persistence
- **As a logged-in user**, I want my cart saved across sessions so that I don't lose items when I return
- **As a guest user**, I want my cart maintained during my session so that I can browse and return to purchase
- **As a user switching devices**, I want my cart synchronized so that I can continue shopping seamlessly

### Inventory Integration
- **As a shopper**, I want to be warned if items become unavailable so that I can adjust my cart accordingly
- **As a shopper**, I want quantity limits enforced so that I don't accidentally order more than available
- **As a shopper**, I want price updates reflected in my cart so that I see current pricing

## Technical Requirements

### Cart Data Structure
```typescript
interface CartItem {
  productId: string;
  variantId?: string;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
  addedAt: Date;
  metadata?: Record<string, any>;
}

interface Cart {
  id: string;
  userId?: string;
  sessionId?: string;
  items: CartItem[];
  subtotal: number;
  tax: number;
  shipping: number;
  total: number;
  currency: string;
  createdAt: Date;
  updatedAt: Date;
  expiresAt?: Date;
}
```

### Storage Strategy
- Database storage for authenticated user carts
- Redis/session storage for guest carts
- Cart synchronization on user login
- Automatic cleanup of expired carts

### Price Calculation Engine
- Real-time price updates from product catalog
- Tax calculation based on location
- Shipping cost calculation
- Discount and coupon application
- Currency conversion support

## Implementation Tasks

### Phase 1: Core Cart Functionality (Week 1)
- [ ] **Task 1.1**: Design and implement cart data models
- [ ] **Task 1.2**: Create add/remove/update cart operations
- [ ] **Task 1.3**: Implement price calculation engine
- [ ] **Task 1.4**: Add cart validation and error handling

### Phase 2: Persistence & Sync (Week 2)
- [ ] **Task 2.1**: Implement database cart storage
- [ ] **Task 2.2**: Add Redis session cart management
- [ ] **Task 2.3**: Create cart synchronization for login
- [ ] **Task 2.4**: Add cart cleanup and maintenance

### Phase 3: Advanced Features (Week 3)
- [ ] **Task 3.1**: Add inventory validation and warnings
- [ ] **Task 3.2**: Implement cart sharing capabilities
- [ ] **Task 3.3**: Add cart abandonment recovery
- [ ] **Task 3.4**: Create cart analytics and tracking

## Acceptance Criteria

### Core Functionality
- ✅ Users can add products to cart with quantities
- ✅ Cart totals calculate correctly including tax and shipping
- ✅ Inventory limits are enforced
- ✅ Price changes are reflected in real-time
- ✅ Cart persists for logged-in users

### Performance & Reliability
- ✅ Cart operations complete within 500ms
- ✅ Concurrent cart updates handled correctly
- ✅ Cart state remains consistent across page loads
- ✅ System handles peak traffic without data loss

## Quality Standards
- Comprehensive unit tests for cart operations
- Integration tests for price calculations
- Performance tests for concurrent access
- Security tests for cart manipulation
- End-to-end tests for complete shopping flows
```
```

---

## API Development Spec Templates

### REST API System Template
```yaml
Template: "rest_api_spec"
Triggers: ["api", "rest", "endpoints", "service"]
Complexity: Medium-High

Spec Structure:
```markdown
# REST API Development

## Overview
Develop a comprehensive RESTful API that provides programmatic access to application functionality with proper authentication, validation, documentation, and error handling.

## User Stories

### API Access & Authentication
- **As a developer**, I want to authenticate API requests so that I can access protected resources securely
- **As an API consumer**, I want clear error messages so that I can debug integration issues effectively
- **As a developer**, I want rate limiting so that the API remains available under heavy load
- **As an API consumer**, I want comprehensive documentation so that I can integrate quickly

### Data Operations
- **As a developer**, I want to perform CRUD operations so that I can manage resources programmatically
- **As an API consumer**, I want to filter and paginate results so that I can efficiently retrieve large datasets
- **As a developer**, I want to batch operations so that I can perform multiple actions efficiently
- **As an API consumer**, I want versioning so that my integrations remain stable

## Technical Requirements

### API Design Standards
- RESTful resource-based URLs
- Consistent HTTP status codes
- JSON request/response format
- OpenAPI 3.0 specification
- Semantic versioning (v1, v2, etc.)

### Authentication & Security
- JWT bearer token authentication
- API key authentication for service-to-service
- Role-based access control
- Rate limiting (100 requests/minute/user)
- Request/response encryption (HTTPS)

### Core Endpoints Structure
```yaml
Users Resource:
  GET /api/v1/users - List users (paginated)
  POST /api/v1/users - Create user
  GET /api/v1/users/{id} - Get user by ID
  PUT /api/v1/users/{id} - Update user
  PATCH /api/v1/users/{id} - Partial update user
  DELETE /api/v1/users/{id} - Delete user

Products Resource:
  GET /api/v1/products - List products with filtering
  POST /api/v1/products - Create product
  GET /api/v1/products/{id} - Get product details
  PUT /api/v1/products/{id} - Update product
  DELETE /api/v1/products/{id} - Delete product
  GET /api/v1/products/{id}/reviews - Get product reviews
```

### Response Format Standards
```typescript
interface ApiResponse<T> {
  success: boolean;
  data?: T;
  message?: string;
  errors?: ValidationError[];
  meta?: {
    pagination?: PaginationMeta;
    rateLimit?: RateLimitInfo;
    version: string;
  };
}

interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
  hasNext: boolean;
  hasPrev: boolean;
}
```

## Implementation Tasks

### Phase 1: Core API Infrastructure (Week 1)
- [ ] **Task 1.1**: Set up Express.js with TypeScript
- [ ] **Task 1.2**: Implement authentication middleware
- [ ] **Task 1.3**: Create response standardization middleware
- [ ] **Task 1.4**: Add request validation with Joi/Yup
- [ ] **Task 1.5**: Set up error handling middleware

### Phase 2: Resource Endpoints (Week 2)
- [ ] **Task 2.1**: Implement user management endpoints
- [ ] **Task 2.2**: Create product management endpoints
- [ ] **Task 2.3**: Add filtering, sorting, and pagination
- [ ] **Task 2.4**: Implement batch operations
- [ ] **Task 2.5**: Add search functionality

### Phase 3: Advanced Features (Week 3)
- [ ] **Task 3.1**: Set up rate limiting and throttling
- [ ] **Task 3.2**: Add API versioning support
- [ ] **Task 3.3**: Implement caching for GET endpoints
- [ ] **Task 3.4**: Create webhook notification system
- [ ] **Task 3.5**: Add request/response logging

### Phase 4: Documentation & Testing (Week 4)
- [ ] **Task 4.1**: Generate OpenAPI specification
- [ ] **Task 4.2**: Set up Swagger UI documentation
- [ ] **Task 4.3**: Create Postman collection
- [ ] **Task 4.4**: Write integration tests
- [ ] **Task 4.5**: Add API performance monitoring

## Acceptance Criteria

### Functionality Requirements
- ✅ All CRUD operations work correctly for each resource
- ✅ Authentication and authorization work as specified
- ✅ Filtering, pagination, and sorting work correctly
- ✅ Error responses are consistent and helpful
- ✅ Rate limiting prevents API abuse

### Quality Requirements
- ✅ API responses are within 200ms for simple operations
- ✅ API handles 1000 concurrent requests without errors
- ✅ All endpoints have comprehensive test coverage
- ✅ API documentation is complete and accurate
- ✅ Security vulnerabilities are identified and addressed

## Quality Standards

### Testing Strategy
- Unit tests for all business logic
- Integration tests for complete API flows
- Contract tests for API specification compliance
- Load tests for performance validation
- Security tests for vulnerability assessment

### Documentation Requirements
- OpenAPI specification for all endpoints
- Interactive API documentation (Swagger UI)
- Code examples for common operations
- Authentication and authorization guides
- Rate limiting and error handling documentation
```
```

---

## Dashboard & Analytics Spec Templates

### Admin Dashboard Template
```yaml
Template: "admin_dashboard_spec"
Triggers: ["dashboard", "admin", "analytics", "reporting"]
Complexity: Medium-High

Spec Structure:
```markdown
# Admin Dashboard System

## Overview
Create a comprehensive admin dashboard that provides real-time insights, user management capabilities, system monitoring, and reporting features for application administrators.

## User Stories

### Analytics & Insights
- **As an admin**, I want to see key metrics at a glance so that I can quickly understand system performance
- **As an admin**, I want to view user activity trends so that I can identify usage patterns
- **As an admin**, I want to monitor system health so that I can proactively address issues
- **As a manager**, I want to generate reports so that I can analyze business performance

### User Management
- **As an admin**, I want to view and manage user accounts so that I can maintain system security
- **As an admin**, I want to handle user support requests so that I can provide timely assistance
- **As an admin**, I want to monitor user behavior so that I can identify potential issues

### System Administration
- **As an admin**, I want to configure system settings so that I can optimize performance
- **As an admin**, I want to view system logs so that I can troubleshoot problems
- **As an admin**, I want to manage content and data so that I can maintain data quality

## Technical Requirements

### Dashboard Architecture
- Real-time data updates using WebSockets
- Responsive design for desktop and tablet use
- Role-based access control for different admin levels
- Modular widget system for customizable layouts
- Caching for performance optimization

### Key Metrics & Widgets
```typescript
interface DashboardMetrics {
  overview: {
    totalUsers: number;
    activeUsers: number;
    revenue: number;
    conversionRate: number;
  };
  userActivity: {
    newSignups: TimeSeries[];
    userSessions: TimeSeries[];
    topPages: PageView[];
  };
  systemHealth: {
    responseTime: number;
    errorRate: number;
    uptime: number;
    serverLoad: number;
  };
}

interface Widget {
  id: string;
  type: 'chart' | 'table' | 'metric' | 'list';
  title: string;
  data: any;
  config: WidgetConfig;
  refreshRate: number;
}
```

### Data Visualization
- Interactive charts using Chart.js or D3.js
- Real-time updating charts and metrics
- Export capabilities for charts and reports
- Drill-down functionality for detailed analysis
- Mobile-responsive chart rendering

## Implementation Tasks

### Phase 1: Dashboard Infrastructure (Week 1)
- [ ] **Task 1.1**: Set up dashboard routing and layout
- [ ] **Task 1.2**: Implement authentication and role checking
- [ ] **Task 1.3**: Create responsive dashboard grid system
- [ ] **Task 1.4**: Set up WebSocket for real-time updates
- [ ] **Task 1.5**: Build widget framework

### Phase 2: Analytics Widgets (Week 2)
- [ ] **Task 2.1**: Create user analytics widgets
- [ ] **Task 2.2**: Build revenue and sales charts
- [ ] **Task 2.3**: Add system performance monitoring
- [ ] **Task 2.4**: Implement activity timeline
- [ ] **Task 2.5**: Add geographic user distribution

### Phase 3: Management Features (Week 3)
- [ ] **Task 3.1**: Build user management interface
- [ ] **Task 3.2**: Create content management tools
- [ ] **Task 3.3**: Add system configuration panels
- [ ] **Task 3.4**: Implement audit log viewer
- [ ] **Task 3.5**: Add notification management

### Phase 4: Reporting & Export (Week 4)
- [ ] **Task 4.1**: Create report generation system
- [ ] **Task 4.2**: Add scheduled report delivery
- [ ] **Task 4.3**: Implement data export functionality
- [ ] **Task 4.4**: Build custom dashboard builder
- [ ] **Task 4.5**: Add mobile app for key metrics

## Acceptance Criteria

### Dashboard Performance
- ✅ Dashboard loads within 3 seconds
- ✅ Real-time updates appear within 2 seconds
- ✅ Charts render smoothly with large datasets
- ✅ Mobile interface is fully functional
- ✅ Dashboard remains responsive under heavy load

### Functionality
- ✅ All metrics display accurate data
- ✅ User management operations work correctly
- ✅ Reports generate without errors
- ✅ Real-time updates work reliably
- ✅ Export features produce correct files

## Quality Standards
- Comprehensive testing of all dashboard features
- Performance testing with large datasets
- Security testing for admin access controls
- Usability testing for dashboard interface
- Accessibility compliance for all components
```
```

---

## Template Usage Guidelines

### Template Selection Logic
```yaml
Automatic Template Selection:
  keyword_matching:
    - Primary keywords trigger specific templates
    - Context keywords refine template selection
    - User preferences influence template choice
    
  complexity_assessment:
    - Simple requests use basic templates
    - Complex requests use comprehensive templates
    - User experience level affects detail level
    
  project_context_integration:
    - Existing architecture influences template choice
    - Technology stack determines implementation approach
    - Team size affects complexity and process recommendations
```

### Template Customization Process
```yaml
Base Template Application:
  1. Select appropriate template based on keywords and context
  2. Apply user's learned preferences and standards
  3. Integrate with existing project architecture
  4. Adjust complexity based on user's typical approaches
  
Content Personalization:
  1. Apply user's preferred naming conventions
  2. Include user's typical quality standards
  3. Use user's preferred technology stack
  4. Incorporate user's architectural patterns
  
Quality Adaptation:
  1. Apply user's testing approach preferences
  2. Include user's security requirements
  3. Use user's documentation standards
  4. Incorporate user's performance requirements
```

### Template Evolution
```yaml
Success Pattern Integration:
  - Track which template sections users modify most
  - Learn from successful implementations
  - Update templates based on proven approaches
  - Incorporate user feedback on template effectiveness

Template Refinement:
  - Improve templates based on implementation outcomes
  - Add new templates for emerging patterns
  - Retire templates that aren't effective
  - Continuously validate template accuracy and usefulness
```

These specification templates provide structured, comprehensive starting points for generating detailed specs while maintaining flexibility for customization based on project needs and user preferences. They ensure consistency while allowing for personalization and adaptation to specific contexts.