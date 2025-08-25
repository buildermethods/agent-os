---
description: Wheels Framework Routing Patterns and Best Practices
version: 1.0
encoding: UTF-8
---

# Wheels Routing Patterns

Comprehensive routing patterns and best practices for Wheels framework applications.

## Table of Contents
- [Routing Fundamentals](#routing-fundamentals)
- [RESTful Routes](#restful-routes)
- [Route Namespaces](#route-namespaces)
- [API Versioning](#api-versioning)
- [Custom Routes](#custom-routes)
- [Route Constraints](#route-constraints)
- [Nested Resources](#nested-resources)
- [Route Parameters](#route-parameters)
- [Named Routes](#named-routes)
- [Route Scoping](#route-scoping)
- [Wildcard Routes](#wildcard-routes)
- [Route Testing](#route-testing)

## Routing Fundamentals

### Configuration Location
Routes are defined in `/config/routes.cfm` (Note: In Wheels 3.0, this moved from `/app/config/routes.cfm`)

### Basic Route Structure
```cfml
// /config/routes.cfm
mapper()
  .get(name="about", pattern="/about", to="pages##about")
  .post(name="contact", pattern="/contact", to="pages##contact")
  .root(to="pages##home")
.end();
```

### HTTP Verbs
```cfml
mapper()
  .get(name="show", pattern="/posts/:key", to="posts##show")
  .post(name="create", pattern="/posts", to="posts##create")
  .put(name="update", pattern="/posts/:key", to="posts##update")
  .patch(name="update", pattern="/posts/:key", to="posts##update")
  .delete(name="delete", pattern="/posts/:key", to="posts##delete")
.end();
```

## RESTful Routes

### Basic Resource
```cfml
mapper()
  // Creates all 7 RESTful routes
  .resources("posts")
  /*
    GET    /posts          posts##index
    GET    /posts/new      posts##new
    POST   /posts          posts##create
    GET    /posts/:key     posts##show
    GET    /posts/:key/edit posts##edit
    PUT    /posts/:key     posts##update
    DELETE /posts/:key     posts##delete
  */
.end();
```

### Limited Resources
```cfml
mapper()
  // Only specific actions
  .resources(name="posts", only="index,show,new,create")
  
  // Exclude specific actions
  .resources(name="comments", except="new,edit")
.end();
```

### Singular Resources
```cfml
mapper()
  // For single resource (like user profile)
  .resource("profile")
  /*
    GET    /profile/new    profile##new
    POST   /profile        profile##create
    GET    /profile        profile##show
    GET    /profile/edit   profile##edit
    PUT    /profile        profile##update
    DELETE /profile        profile##delete
  */
.end();
```

## Route Namespaces

### Admin Namespace
```cfml
mapper()
  .namespace("admin")
    // All routes in this block are prefixed with /admin
    .resources("users")      // /admin/users
    .resources("posts")      // /admin/posts
    .resources("settings")   // /admin/settings
    
    // Custom admin routes
    .get(name="dashboard", pattern="", to="dashboard##index")
    .get(name="reports", pattern="/reports", to="reports##index")
  .end()
.end();
```

### Multiple Nested Namespaces
```cfml
mapper()
  .namespace("api")
    .namespace("v1")
      .resources("users")    // /api/v1/users
      .resources("posts")    // /api/v1/posts
    .end()
    .namespace("v2")
      .resources("users")    // /api/v2/users
      .resources("posts")    // /api/v2/posts
      .resources("comments") // /api/v2/comments (new in v2)
    .end()
  .end()
.end();
```

## API Versioning

### Version in URL Path
```cfml
mapper()
  // API v1
  .namespace("api.v1")
    .resources(name="posts", controller="api.v1.posts", only="index,show")
    .resources(name="users", controller="api.v1.users", only="index,show")
  .end()
  
  // API v2 with breaking changes
  .namespace("api.v2")
    .resources(name="posts", controller="api.v2.posts")
    .resources(name="users", controller="api.v2.users")
    .resources(name="comments", controller="api.v2.comments")
  .end()
.end();
```

### Version with Format
```cfml
mapper()
  // Disable automatic format detection for API routes
  .namespace("api")
    .resources(name="posts", mapFormat=false)
    // Explicitly handle JSON format
    .get(name="posts.json", pattern="/posts.json", to="api.posts##index")
  .end()
.end();
```

## Custom Routes

### Complex Route Patterns
```cfml
mapper()
  // Blog post with date in URL
  .get(
    name="blogPost",
    pattern="/blog/:year/:month/:day/:slug",
    to="posts##show"
  )
  
  // User profile with username
  .get(
    name="userProfile",
    pattern="/@:username",
    to="users##profile"
  )
  
  // Search with optional filters
  .get(
    name="search",
    pattern="/search(/:category)(/:tag)",
    to="search##results"
  )
.end();
```

### Route with Constraints
```cfml
mapper()
  // Numeric year constraint
  .get(
    name="archive",
    pattern="/archive/:year",
    to="posts##archive",
    constraints={year="[0-9]{4}"}
  )
  
  // Alpha-only username
  .get(
    name="profile",
    pattern="/users/:username",
    to="users##show",
    constraints={username="[a-zA-Z]+"}
  )
.end();
```

## Nested Resources

### Basic Nesting
```cfml
mapper()
  .resources(name="posts", nested=true)
    .resources(name="comments")
  .end()
  /*
    GET    /posts/:postKey/comments           comments##index
    GET    /posts/:postKey/comments/new       comments##new
    POST   /posts/:postKey/comments           comments##create
    GET    /posts/:postKey/comments/:key      comments##show
    GET    /posts/:postKey/comments/:key/edit comments##edit
    PUT    /posts/:postKey/comments/:key      comments##update
    DELETE /posts/:postKey/comments/:key      comments##delete
  */
.end();
```

### Shallow Nesting
```cfml
mapper()
  .resources(name="posts", nested=true)
    .resources(name="comments", shallow=true)
  .end()
  /*
    GET    /posts/:postKey/comments     comments##index
    GET    /posts/:postKey/comments/new comments##new
    POST   /posts/:postKey/comments     comments##create
    GET    /comments/:key               comments##show
    GET    /comments/:key/edit         comments##edit
    PUT    /comments/:key               comments##update
    DELETE /comments/:key               comments##delete
  */
.end();
```

## Route Parameters

### Optional Parameters
```cfml
mapper()
  // Optional page parameter
  .get(
    name="posts",
    pattern="/posts(/:page)",
    to="posts##index"
  )
  
  // Multiple optional parameters
  .get(
    name="products",
    pattern="/products(/:category)(/:brand)",
    to="products##index"
  )
.end();
```

### Default Parameter Values
```cfml
mapper()
  .get(
    name="posts",
    pattern="/posts",
    to="posts##index",
    defaults={page=1, perPage=10}
  )
.end();
```

## Named Routes

### Using Named Routes
```cfml
// In routes.cfm
mapper()
  .get(name="userProfile", pattern="/users/:id", to="users##show")
  .post(name="userUpdate", pattern="/users/:id", to="users##update")
.end();

// In views
<cfoutput>
  <a href="#urlFor(route='userProfile', id=user.id)#">View Profile</a>
  
  <form action="#urlFor(route='userUpdate', id=user.id)#" method="post">
    <!-- form fields -->
  </form>
</cfoutput>

// In controllers
redirectTo(route="userProfile", id=user.id);
```

## Route Scoping

### Scope by Subdomain
```cfml
mapper()
  // Admin subdomain
  .scope(subdomain="admin")
    .resources("users")
    .resources("settings")
  .end()
  
  // API subdomain
  .scope(subdomain="api")
    .resources("posts", only="index,show")
  .end()
.end();
```

### Scope with Conditions
```cfml
mapper()
  // Mobile routes
  .scope(condition="isMobile()")
    .get(name="home", pattern="", to="mobile.pages##home")
    .resources(name="posts", controller="mobile.posts")
  .end()
  
  // Desktop routes
  .get(name="home", pattern="", to="pages##home")
  .resources("posts")
.end();
```

## Wildcard Routes

### Catch-all Routes
```cfml
mapper()
  // Specific routes first
  .resources("posts")
  .resources("users")
  
  // CMS pages catch-all (must be last)
  .get(
    name="cmsPage",
    pattern="/*",
    to="pages##show"
  )
.end();
```

### Wildcard Segments
```cfml
mapper()
  // Documentation with nested paths
  .get(
    name="docs",
    pattern="/docs/*",
    to="documentation##show"
  )
  
  // File browser
  .get(
    name="files",
    pattern="/files/*",
    to="files##browse"
  )
.end();
```

## Route Testing

### Testing Route Generation
```cfscript
// In test file
component extends="tests.BaseSpec" {
  function run() {
    describe("Route generation", () => {
      it("generates correct user profile URL", () => {
        var url = urlFor(route="userProfile", id=123);
        expect(url).toBe("/users/123");
      });
      
      it("generates correct API endpoint", () => {
        var url = urlFor(route="api.v1.posts", format="json");
        expect(url).toBe("/api/v1/posts.json");
      });
    });
  }
}
```

### Testing Route Matching
```cfscript
describe("Route matching", () => {
  it("matches blog post route with date", () => {
    var result = processRequest(
      url="/blog/2025/01/21/my-post",
      method="GET"
    );
    expect(result.controller).toBe("posts");
    expect(result.action).toBe("show");
    expect(params.year).toBe("2025");
    expect(params.slug).toBe("my-post");
  });
});
```

## Advanced Routing Patterns

### Redirect Routes
```cfml
mapper()
  // Permanent redirect
  .get(
    pattern="/old-path",
    redirect="/new-path",
    statusCode=301
  )
  
  // Temporary redirect
  .get(
    pattern="/maintenance",
    redirect="/coming-soon",
    statusCode=302
  )
.end();
```

### Route Middleware
```cfml
mapper()
  // Apply middleware to group of routes
  .scope(middleware="authenticate")
    .resources("posts")
    .resources("comments")
  .end()
  
  // Multiple middleware
  .scope(middleware="authenticate,authorize")
    .namespace("admin")
      .resources("users")
    .end()
  .end()
.end();
```

### Dynamic Route Loading
```cfml
// Load routes from plugins or modules
mapper()
  .includeRoutes("/plugins/blog/routes.cfm")
  .includeRoutes("/plugins/shop/routes.cfm")
  
  // Application routes
  .resources("pages")
.end();
```

## Best Practices

1. **Order Matters**: Place more specific routes before generic ones
2. **Use Resources**: Prefer RESTful resources over custom routes when possible
3. **Namespace APIs**: Always version your APIs using namespaces
4. **Name Your Routes**: Use named routes for maintainability
5. **Avoid Deep Nesting**: Limit nesting to 2 levels maximum
6. **Test Routes**: Write tests for complex routing logic
7. **Document Custom Routes**: Add comments for non-standard patterns
8. **Use Constraints**: Add regex constraints to validate parameters
9. **Consider Performance**: Minimize the number of route definitions
10. **Follow Conventions**: Stick to RESTful conventions when possible

## Common Pitfalls

1. **Route Order**: Routes are matched top to bottom - order matters!
2. **Namespace Controllers**: Controllers in namespaces need matching folder structure
3. **Format Handling**: Be explicit about format handling in API routes
4. **Parameter Names**: Avoid conflicts with reserved parameter names
5. **Wildcard Placement**: Wildcard routes should be placed last