# Common Feature Patterns

## Context

Library of common feature patterns that can be used by the smart spec generator to create comprehensive specifications from minimal user input.

## Overview

This document contains templates and patterns for frequently requested features, allowing the smart spec generator to rapidly create detailed, context-aware specifications based on proven approaches.

---

## Authentication & User Management

### User Authentication System
```yaml
Pattern: "user_authentication"
Keywords: ["auth", "authentication", "login", "user management", "sign in"]
Complexity: Medium-High
Estimated Effort: 15-25 hours

Core Components:
  - User registration and login
  - Password security and hashing
  - Session/token management
  - Password reset functionality
  - Optional social login integration

Technical Requirements:
  - Secure password hashing (bcrypt, scrypt, or similar)
  - JWT or session-based authentication
  - Rate limiting for auth endpoints
  - Input validation and sanitization
  - HTTPS enforcement

Common Integrations:
  - OAuth providers (Google, GitHub, etc.)
  - Email service for verification
  - Database for user storage
  - Frontend auth state management

Quality Standards:
  - Comprehensive security testing
  - Input validation testing  
  - Session management testing
  - Password policy enforcement
  - Audit logging for security events
```

### User Profile Management
```yaml
Pattern: "user_profiles"
Keywords: ["profile", "user profile", "account settings", "user data"]
Complexity: Medium
Estimated Effort: 10-18 hours

Core Components:
  - Profile creation and editing
  - Avatar/image upload
  - Privacy settings
  - Account preferences
  - Profile validation

Technical Requirements:
  - Form validation and sanitization
  - File upload handling
  - Image processing and storage
  - Privacy controls implementation
  - Data export capabilities

Common Features:
  - Profile picture upload
  - Personal information fields
  - Privacy visibility controls
  - Account deletion options
  - Data export functionality

Quality Standards:
  - File upload security
  - Privacy compliance (GDPR, etc.)
  - Input validation testing
  - Image optimization
  - Data integrity validation
```

---

## E-commerce Features

### Shopping Cart System
```yaml
Pattern: "shopping_cart"
Keywords: ["cart", "shopping", "basket", "add to cart", "checkout"]
Complexity: Medium-High
Estimated Effort: 20-30 hours

Core Components:
  - Add/remove items functionality
  - Quantity management
  - Cart persistence
  - Price calculations
  - Inventory validation

Technical Requirements:
  - Session or database cart storage
  - Real-time price updates
  - Inventory checking
  - Tax calculation logic
  - Coupon/discount system

Common Features:
  - Guest cart functionality
  - Saved carts for logged-in users
  - Cart abandonment recovery
  - Shipping calculations
  - Multi-currency support

Quality Standards:
  - Price calculation accuracy
  - Inventory synchronization
  - Performance under load
  - Security for price manipulation
  - Cross-browser compatibility
```

### Payment Processing
```yaml
Pattern: "payment_system"
Keywords: ["payment", "checkout", "billing", "stripe", "paypal"]
Complexity: High
Estimated Effort: 25-40 hours

Core Components:
  - Payment method collection
  - Transaction processing
  - Payment confirmation
  - Refund handling
  - Receipt generation

Technical Requirements:
  - PCI compliance considerations
  - Secure payment data handling
  - Webhook processing
  - Error handling and retry logic
  - Transaction logging

Common Integrations:
  - Stripe, PayPal, Square APIs
  - Currency conversion services
  - Fraud detection services
  - Accounting system integration
  - Email receipt services

Quality Standards:
  - Security audit requirements
  - Payment flow testing
  - Error scenario handling
  - Compliance validation
  - Transaction reconciliation
```

---

## Dashboard & Analytics

### Admin Dashboard
```yaml
Pattern: "admin_dashboard"
Keywords: ["dashboard", "admin", "analytics", "metrics", "overview"]
Complexity: Medium-High
Estimated Effort: 20-35 hours

Core Components:
  - Key metrics display
  - Data visualization
  - User management interface
  - System monitoring
  - Reports generation

Technical Requirements:
  - Real-time data updates
  - Chart/graph libraries
  - Role-based access control
  - Export functionality
  - Mobile responsiveness

Common Features:
  - User analytics
  - Revenue/sales metrics
  - System health monitoring
  - Activity logs
  - Custom report building

Quality Standards:
  - Performance with large datasets
  - Real-time update accuracy
  - Access control testing
  - Mobile responsiveness
  - Data accuracy validation
```

### Analytics Tracking
```yaml
Pattern: "analytics_system"
Keywords: ["analytics", "tracking", "metrics", "events", "reporting"]
Complexity: Medium
Estimated Effort: 15-25 hours

Core Components:
  - Event tracking system
  - Data collection APIs
  - Report generation
  - Custom metrics
  - Data visualization

Technical Requirements:
  - Event batching and queuing
  - Data aggregation logic
  - Privacy compliance
  - Performance optimization
  - Data retention policies

Common Features:
  - User behavior tracking
  - Conversion funnel analysis
  - A/B testing support
  - Custom event definitions
  - Automated reporting

Quality Standards:
  - Privacy compliance (GDPR, CCPA)
  - Data accuracy validation
  - Performance impact testing
  - Security for sensitive data
  - Scalability testing
```

---

## Content Management

### Content Management System
```yaml
Pattern: "cms_system"
Keywords: ["cms", "content", "blog", "articles", "publishing"]
Complexity: Medium-High
Estimated Effort: 25-40 hours

Core Components:
  - Content creation interface
  - Rich text editing
  - Media management
  - Publishing workflow
  - Content organization

Technical Requirements:
  - Rich text editor integration
  - File upload and storage
  - Content versioning
  - SEO optimization
  - Content scheduling

Common Features:
  - WYSIWYG editor
  - Image and video upload
  - Draft and publish states
  - Content categories/tags
  - SEO metadata management

Quality Standards:
  - Content security (XSS prevention)
  - Performance optimization
  - SEO compliance
  - Accessibility standards
  - Mobile responsiveness
```

### File Upload System
```yaml
Pattern: "file_upload"
Keywords: ["upload", "file", "media", "attachment", "documents"]
Complexity: Medium
Estimated Effort: 12-20 hours

Core Components:
  - File selection interface
  - Upload progress tracking
  - File validation
  - Storage management
  - Download functionality

Technical Requirements:
  - File type validation
  - Size limit enforcement
  - Virus scanning
  - Storage optimization
  - CDN integration

Common Features:
  - Drag and drop interface
  - Multiple file selection
  - Upload progress indicators
  - File preview generation
  - Bulk operations

Quality Standards:
  - Security scanning
  - File type validation
  - Storage efficiency
  - Performance optimization
  - Error handling
```

---

## Communication Features

### Messaging System
```yaml
Pattern: "messaging_system"
Keywords: ["messages", "chat", "communication", "inbox", "notifications"]
Complexity: High
Estimated Effort: 30-50 hours

Core Components:
  - Message composition
  - Real-time messaging
  - Message threading
  - Notification system
  - Message search

Technical Requirements:
  - WebSocket connections
  - Message queuing
  - Real-time synchronization
  - Push notifications
  - Message encryption

Common Features:
  - Direct messaging
  - Group conversations
  - Message history
  - File attachments
  - Message reactions

Quality Standards:
  - Real-time performance
  - Message delivery guarantees
  - Privacy and encryption
  - Scalability testing
  - Cross-device synchronization
```

### Notification System
```yaml
Pattern: "notification_system"
Keywords: ["notifications", "alerts", "email", "push", "reminders"]
Complexity: Medium
Estimated Effort: 15-25 hours

Core Components:
  - Notification creation
  - Delivery mechanisms
  - User preferences
  - Notification history
  - Delivery tracking

Technical Requirements:
  - Multi-channel delivery
  - Template management
  - Scheduling system
  - Delivery confirmation
  - Rate limiting

Common Features:
  - Email notifications
  - Push notifications
  - In-app notifications
  - SMS notifications
  - Notification preferences

Quality Standards:
  - Delivery reliability
  - Template consistency
  - User preference respect
  - Performance optimization
  - Spam prevention
```

---

## API & Integration Features

### REST API Development
```yaml
Pattern: "rest_api"
Keywords: ["api", "rest", "endpoints", "integration", "service"]
Complexity: Medium-High
Estimated Effort: 20-35 hours

Core Components:
  - Endpoint definition
  - Request/response handling
  - Authentication middleware
  - Data validation
  - Error handling

Technical Requirements:
  - OpenAPI/Swagger documentation
  - Input validation
  - Rate limiting
  - Authentication/authorization
  - Logging and monitoring

Common Features:
  - CRUD operations
  - Filtering and pagination
  - Bulk operations
  - Data relationships
  - API versioning

Quality Standards:
  - Comprehensive testing
  - Security validation
  - Performance testing
  - Documentation completeness
  - Error handling consistency
```

### Third-Party Integrations
```yaml
Pattern: "third_party_integration"
Keywords: ["integration", "api", "webhook", "external", "service"]
Complexity: Medium
Estimated Effort: 15-30 hours

Core Components:
  - API client implementation
  - Authentication handling
  - Data synchronization
  - Error recovery
  - Webhook processing

Technical Requirements:
  - API client libraries
  - Rate limit handling
  - Retry mechanisms
  - Data mapping
  - Security considerations

Common Integrations:
  - Payment processors
  - Email services
  - Cloud storage
  - Social media APIs
  - Analytics services

Quality Standards:
  - Error handling robustness
  - Rate limit compliance
  - Data consistency
  - Security best practices
  - Integration testing
```

---

## Search & Discovery

### Search Functionality
```yaml
Pattern: "search_system"
Keywords: ["search", "find", "filter", "query", "discovery"]
Complexity: Medium-High
Estimated Effort: 20-30 hours

Core Components:
  - Search interface
  - Query processing
  - Result ranking
  - Filtering options
  - Search suggestions

Technical Requirements:
  - Search engine integration
  - Index management
  - Query optimization
  - Result caching
  - Analytics tracking

Common Features:
  - Full-text search
  - Faceted search
  - Autocomplete
  - Search history
  - Advanced filters

Quality Standards:
  - Search accuracy
  - Performance optimization
  - Relevance tuning
  - Index maintenance
  - User experience testing
```

---

## Utility Functions

### Data Export/Import
```yaml
Pattern: "data_export_import"
Keywords: ["export", "import", "csv", "excel", "backup"]
Complexity: Medium
Estimated Effort: 10-18 hours

Core Components:
  - Export functionality
  - Import processing
  - Format validation
  - Data transformation
  - Progress tracking

Technical Requirements:
  - File format support
  - Large dataset handling
  - Data validation
  - Error reporting
  - Background processing

Common Features:
  - CSV export/import
  - Excel file support
  - JSON data transfer
  - Bulk operations
  - Data mapping

Quality Standards:
  - Data integrity validation
  - Performance with large files
  - Error handling
  - Security considerations
  - Progress feedback
```

### Audit Logging
```yaml
Pattern: "audit_logging"
Keywords: ["audit", "logging", "history", "tracking", "compliance"]
Complexity: Medium
Estimated Effort: 12-20 hours

Core Components:
  - Event capture
  - Log storage
  - Query interface
  - Report generation
  - Retention management

Technical Requirements:
  - Structured logging
  - Secure storage
  - Query optimization
  - Data retention
  - Access controls

Common Features:
  - User action tracking
  - Data change logging
  - System event capture
  - Compliance reporting
  - Log analysis

Quality Standards:
  - Data integrity
  - Security compliance
  - Performance impact
  - Storage efficiency
  - Query performance
```

---

## Pattern Usage Guidelines

### When to Use These Patterns
1. **Direct Match**: User input directly matches pattern keywords
2. **Contextual Relevance**: Project context suggests pattern applicability
3. **Architectural Fit**: Pattern aligns with existing codebase architecture
4. **Complexity Appropriate**: Pattern complexity matches project scope

### Customization Approach
1. **Base Pattern**: Start with core pattern structure
2. **Context Adaptation**: Modify based on project-specific requirements
3. **User Preferences**: Apply learned user preferences and standards
4. **Quality Overlay**: Add user's typical quality requirements

### Integration Considerations
- Patterns often work together (auth + profiles, cart + payment)
- Consider data flow between pattern implementations
- Maintain consistency across pattern applications
- Plan for pattern evolution and enhancement

These patterns provide a foundation for intelligent spec generation, allowing the system to quickly create comprehensive specifications while maintaining the flexibility to adapt to specific project needs and user preferences.