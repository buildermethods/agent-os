## API endpoint standards and conventions

- **RESTful Design**: Follow REST principles with clear resource-based URLs and appropriate HTTP methods (GET, POST, PUT, PATCH, DELETE). For WordPress, use the WordPress REST API when possible.
- **Consistent Naming**: Use consistent, lowercase, hyphenated or underscored naming conventions for endpoints across the API. WordPress REST API uses namespaces like `wp/v2` for core endpoints.
- **Versioning**: Implement API versioning strategy (URL path or headers) to manage breaking changes without disrupting existing clients. WordPress REST API uses namespaced routes for versioning (e.g., `/wp/v2/`, `/myplugin/v1/`).
- **Plural Nouns**: Use plural nouns for resource endpoints (e.g., `/users`, `/products`) for consistency
- **Nested Resources**: Limit nesting depth to 2-3 levels maximum to keep URLs readable and maintainable
- **Query Parameters**: Use query parameters for filtering, sorting, pagination, and search rather than creating separate endpoints. WordPress REST API supports standard query parameters like `per_page`, `page`, `search`, etc.
- **HTTP Status Codes**: Return appropriate, consistent HTTP status codes that accurately reflect the response (200, 201, 400, 404, 500, etc.)
- **Rate Limiting Headers**: Include rate limit information in response headers to help clients manage their usage
- **WordPress REST API Registration**: Register custom REST API endpoints using `register_rest_route()` with proper namespace, route, and arguments
- **Permission Callbacks**: Always define permission callbacks for REST API endpoints to control access appropriately
- **Schema Definition**: Define response schemas for REST API endpoints to provide clear documentation and validation
