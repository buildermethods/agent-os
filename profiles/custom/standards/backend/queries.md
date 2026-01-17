## Database query best practices

- **Prevent SQL Injection**: Always use WordPress `$wpdb->prepare()` for parameterized queries or use WordPress query classes (WP_Query, WP_User_Query, etc.) that handle sanitization automatically. Never interpolate user input into SQL strings.
- **Avoid N+1 Queries**: Use eager loading with WordPress query classes. For post meta, use `update_postmeta_cache()` or `get_post_meta()` with `$single = false` to fetch all meta at once. For taxonomies, use `wp_get_object_terms()` or `get_the_terms()` appropriately.
- **Select Only Needed Data**: Request only the fields you need. Use `WP_Query` with `fields` parameter, or specify columns in `$wpdb` queries rather than using SELECT *.
- **Index Strategic Columns**: Index columns used in WHERE, JOIN, and ORDER BY clauses for query optimization. WordPress core tables are already indexed, but ensure custom tables have appropriate indexes. Consider MariaDB-specific indexing strategies.
- **Use Transactions for Related Changes**: Wrap related database operations in transactions using `$wpdb->query('START TRANSACTION')` and `COMMIT`/`ROLLBACK` to maintain data consistency
- **Set Query Timeouts**: Implement timeouts to prevent runaway queries from impacting system performance. WordPress has built-in query limits, but be mindful of complex queries.
- **Cache Expensive Queries**: Cache results of complex or frequently-run queries when appropriate using WordPress transients, object cache (Redis via Object Cache Pro), or custom caching mechanisms
- **Use WordPress Query Classes**: Prefer WordPress query classes (`WP_Query`, `WP_User_Query`, `WP_Term_Query`, etc.) over direct SQL when possible for better security, caching, and compatibility
- **Query Performance**: Use `WP_Query` parameters like `no_found_rows`, `update_post_meta_cache`, and `update_post_term_cache` to optimize query performance
- **Meta Queries**: When querying by post meta, use `WP_Query` meta_query parameters rather than custom SQL for better performance and compatibility
- **Object Cache Pro**: Leverage Object Cache Pro with Redis for persistent object caching. Ensure queries are cache-friendly and take advantage of Redis caching for frequently accessed data.
- **MariaDB Optimization**: Consider MariaDB-specific query optimizations and features when writing complex queries.
