## Database model best practices

- **Clear Naming**: Use clear, descriptive names for custom post types, taxonomies, and custom database tables that indicate their purpose
- **Timestamps**: Include created and updated timestamps on all custom database tables for auditing and debugging. WordPress post types automatically include `post_date` and `post_modified` fields.
- **Data Integrity**: Use database constraints (NOT NULL, UNIQUE, foreign keys) to enforce data rules at the database level. For WordPress post types, use meta fields and taxonomies appropriately.
- **Appropriate Data Types**: Choose data types that match the data's purpose and size requirements. Use WordPress post meta, term meta, or custom tables as appropriate.
- **Indexes on Foreign Keys**: Index foreign key columns and other frequently queried fields for performance
- **Validation at Multiple Layers**: Implement validation at both data structure and database levels for defense in depth. Use WordPress sanitization and validation functions.
- **Relationship Clarity**: Define relationships clearly using WordPress taxonomies, post meta, or custom table relationships with appropriate cascade behaviors
- **Avoid Over-Normalization**: Balance normalization with practical query performance needs
- **Custom Post Types**: Register custom post types with `register_post_type()` using appropriate capabilities, supports, and labels
- **Custom Taxonomies**: Register custom taxonomies with `register_taxonomy()` and associate them with appropriate post types
- **Post Meta Usage**: Use post meta for additional data fields, but consider custom tables for complex relational data or high-performance needs
- **WordPress Data Structures**: Leverage WordPress's built-in data structures (posts, pages, custom post types, taxonomies, meta) before creating custom database tables
