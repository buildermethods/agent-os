## Database migration best practices

- **Database Version Tracking**: Track database schema versions using WordPress options (e.g., `get_option('myplugin_db_version')`) to manage schema changes
- **Activation Hooks**: Use plugin/theme activation hooks to run database setup and migrations when needed
- **Small, Focused Changes**: Keep each database change focused on a single logical change for clarity and easier troubleshooting
- **Zero-Downtime Deployments**: Consider deployment order and backwards compatibility for high-availability systems. Test database changes on staging before production.
- **Separate Schema and Data**: Keep schema changes separate from data migrations for better rollback safety
- **Index Management**: Create indexes on large tables carefully to avoid locks. Use WordPress `$wpdb` methods appropriately. Consider MariaDB-specific optimizations.
- **Naming Conventions**: Use clear, descriptive names for database tables and columns that indicate their purpose. Follow WordPress table naming conventions (prefix with `$wpdb->prefix`).
- **Version Control**: Always commit database change scripts to version control and document the changes
- **Reversible Changes**: When possible, design database changes to be reversible or provide rollback scripts
- **WordPress Database API**: Use WordPress `$wpdb` global object and its methods (`prepare()`, `get_results()`, etc.) for all database operations to ensure security and compatibility
- **Custom Table Creation**: When creating custom tables, use `dbDelta()` function or direct SQL with proper schema definition following WordPress conventions
- **MariaDB Compatibility**: Ensure all database operations are compatible with MariaDB. Test queries and migrations on MariaDB before deployment.
