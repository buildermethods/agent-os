---
name: backend-standards
description: Apply backend development standards for APIs, database models, migrations, and queries when implementing backend code, server-side logic, database operations, or API endpoints
---

# Backend Development Standards

This skill provides comprehensive standards for backend development including API design, database modeling, migration management, and query optimization. Use these principles when implementing server-side logic, data models, or API endpoints.

## When to Use This Skill

Activate this skill when:

- Implementing or modifying API endpoints
- Creating or updating database models/schemas
- Writing database migrations
- Writing database queries or ORM code
- Designing backend architecture or data flow
- Implementing server-side business logic
- Working with database relationships and constraints
- Optimizing backend performance

## API Endpoint Standards and Conventions

- **RESTful Design**: Follow REST principles with clear resource-based URLs and appropriate HTTP methods (GET, POST, PUT, PATCH, DELETE)
- **Consistent Naming**: Use consistent, lowercase, hyphenated or underscored naming conventions for endpoints across the API
- **Versioning**: Implement API versioning strategy (URL path or headers) to manage breaking changes without disrupting existing clients
- **Plural Nouns**: Use plural nouns for resource endpoints (e.g., `/users`, `/products`) for consistency
- **Nested Resources**: Limit nesting depth to 2-3 levels maximum to keep URLs readable and maintainable
- **Query Parameters**: Use query parameters for filtering, sorting, pagination, and search rather than creating separate endpoints
- **HTTP Status Codes**: Return appropriate, consistent HTTP status codes that accurately reflect the response (200, 201, 400, 404, 500, etc.)
- **Rate Limiting Headers**: Include rate limit information in response headers to help clients manage their usage

## Database Model Best Practices

- **Clear Naming**: Use singular names for models and plural for tables following your framework's conventions
- **Timestamps**: Include created and updated timestamps on all tables for auditing and debugging
- **Data Integrity**: Use database constraints (NOT NULL, UNIQUE, foreign keys) to enforce data rules at the database level
- **Appropriate Data Types**: Choose data types that match the data's purpose and size requirements
- **Indexes on Foreign Keys**: Index foreign key columns and other frequently queried fields for performance
- **Validation at Multiple Layers**: Implement validation at both model and database levels for defense in depth
- **Relationship Clarity**: Define relationships clearly with appropriate cascade behaviors and naming conventions
- **Avoid Over-Normalization**: Balance normalization with practical query performance needs

## Database Migration Best Practices

- **Reversible Migrations**: Always implement rollback/down methods to enable safe migration reversals
- **Small, Focused Changes**: Keep each migration focused on a single logical change for clarity and easier troubleshooting
- **Zero-Downtime Deployments**: Consider deployment order and backwards compatibility for high-availability systems
- **Separate Schema and Data**: Keep schema changes separate from data migrations for better rollback safety
- **Index Management**: Create indexes on large tables carefully, using concurrent options when available to avoid locks
- **Naming Conventions**: Use clear, descriptive names that indicate what the migration does
- **Version Control**: Always commit migrations to version control and never modify existing migrations after deployment

## Database Query Best Practices

- **Prevent SQL Injection**: Always use parameterized queries or ORM methods; never interpolate user input into SQL strings
- **Avoid N+1 Queries**: Use eager loading or joins to fetch related data in a single query instead of multiple queries
- **Select Only Needed Data**: Request only the columns you need rather than using SELECT * for better performance
- **Index Strategic Columns**: Index columns used in WHERE, JOIN, and ORDER BY clauses for query optimization
- **Use Transactions for Related Changes**: Wrap related database operations in transactions to maintain data consistency
- **Set Query Timeouts**: Implement timeouts to prevent runaway queries from impacting system performance
- **Cache Expensive Queries**: Cache results of complex or frequently-run queries when appropriate

## Best Practices Summary

When implementing backend code:

1. **Design RESTful APIs** - Use resource-based URLs, proper HTTP methods and status codes
2. **Model with integrity** - Use database constraints, appropriate types, and clear relationships
3. **Migrate carefully** - Write reversible, focused migrations with backwards compatibility
4. **Query efficiently** - Prevent SQL injection, avoid N+1 queries, select only needed data
5. **Index strategically** - Index foreign keys and frequently queried columns
6. **Validate thoroughly** - Validate at both model and database levels
7. **Use transactions** - Wrap related operations in transactions for consistency
8. **Plan for scale** - Consider caching, timeouts, and performance from the start

## Integration with Other Skills

This skill works in conjunction with:

- **Global Standards**: Foundation for coding style, error handling, and validation
- **Testing Standards**: Guide testing approaches for backend code
- **Frontend Standards**: Coordinate API contracts with frontend implementations

Apply global standards as the foundation, then layer these backend-specific practices for server-side development.

## Common Backend Patterns

### API Response Structure

Maintain consistent response formats:

- Success responses with data
- Error responses with clear messages and codes
- Pagination metadata for list endpoints
- Rate limit headers for all endpoints

### Database Access Patterns

Follow these patterns:

- Repository pattern for data access abstraction
- Service layer for business logic
- Models for data structure and basic validation
- Migrations for all schema changes

### Error Handling

Implement consistent error handling:

- Catch exceptions at API boundaries
- Log errors with context for debugging
- Return user-friendly error messages
- Use appropriate HTTP status codes

## Performance Considerations

When implementing backend code:

- **Eager load** related data to avoid N+1 queries
- **Use indexes** on columns used in WHERE, JOIN, ORDER BY
- **Cache** expensive computations and queries
- **Paginate** large result sets
- **Set timeouts** on external service calls and queries
- **Monitor** query performance and slow endpoints
