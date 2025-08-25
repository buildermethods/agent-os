---
description: Wheels Framework API Development Patterns
version: 1.0
encoding: UTF-8
---

# Wheels API Development Patterns

Comprehensive patterns for building RESTful APIs with the Wheels framework.

## Table of Contents
- [API Architecture](#api-architecture)
- [RESTful API Design](#restful-api-design)
- [JSON API Controllers](#json-api-controllers)
- [API Versioning](#api-versioning)
- [Request/Response Handling](#requestresponse-handling)
- [API Authentication](#api-authentication)
- [Rate Limiting](#rate-limiting)
- [Error Handling](#error-handling)
- [API Documentation](#api-documentation)
- [CORS Configuration](#cors-configuration)
- [Webhooks](#webhooks)
- [GraphQL Integration](#graphql-integration)
- [API Testing](#api-testing)

## API Architecture

### Base API Controller
```cfml
// /app/controllers/api/v1/Base.cfc
component extends="Controller" {
  
  function config() {
    // Only respond with JSON
    onlyProvides("json");
    
    // Common filters
    filters(through="setApiHeaders,authenticateApiRequest,logApiRequest");
    filters(through="checkRateLimit", except="options");
    
    // Disable layouts for API responses
    usesLayout(false);
  }
  
  // Set common API headers
  private void function setApiHeaders() {
    header name="X-API-Version" value="1.0";
    header name="X-RateLimit-Limit" value="1000";
    header name="X-RateLimit-Remaining" value=getRateLimitRemaining();
    header name="X-RateLimit-Reset" value=getRateLimitReset();
    cfcontent(type="application/json");
  }
  
  // API authentication
  private void function authenticateApiRequest() {
    local.token = extractAuthToken();
    
    if (!Len(local.token)) {
      renderErrorResponse("Missing authentication token", 401);
    }
    
    request.apiUser = authenticateToken(local.token);
    
    if (!IsObject(request.apiUser)) {
      renderErrorResponse("Invalid or expired token", 401);
    }
  }
  
  // Standardized error response
  private void function renderErrorResponse(
    required string message,
    numeric status=400,
    struct details={}
  ) {
    local.response = {
      "error": true,
      "message": arguments.message,
      "status": arguments.status,
      "timestamp": DateTimeFormat(Now(), "iso8601")
    };
    
    if (!StructIsEmpty(arguments.details)) {
      local.response["details"] = arguments.details;
    }
    
    renderWith(data=local.response, status=arguments.status);
    abort;
  }
  
  // Standardized success response
  private void function renderSuccessResponse(
    any data,
    numeric status=200,
    struct meta={}
  ) {
    local.response = {
      "success": true,
      "data": arguments.data,
      "status": arguments.status,
      "timestamp": DateTimeFormat(Now(), "iso8601")
    };
    
    if (!StructIsEmpty(arguments.meta)) {
      local.response["meta"] = arguments.meta;
    }
    
    renderWith(data=local.response, status=arguments.status);
  }
  
  // Extract auth token from headers
  private string function extractAuthToken() {
    // Check Authorization header
    if (StructKeyExists(request.headers, "Authorization")) {
      local.auth = request.headers["Authorization"];
      if (Left(local.auth, 7) == "Bearer ") {
        return Mid(local.auth, 8, Len(local.auth));
      }
    }
    
    // Check X-API-Key header
    if (StructKeyExists(request.headers, "X-API-Key")) {
      return request.headers["X-API-Key"];
    }
    
    return "";
  }
}
```

## RESTful API Design

### Resource Controller
```cfml
// /app/controllers/api/v1/Posts.cfc
component extends="api.v1.Base" {
  
  function config() {
    super.config();
    
    // Validate required parameters
    verifies(params="title,body", only="create");
    verifies(params="key", only="show,update,delete");
    
    // Set pagination defaults
    variables.defaultPerPage = 20;
    variables.maxPerPage = 100;
  }
  
  // GET /api/v1/posts
  function index() {
    // Parse query parameters
    local.page = Val(params.page ?: 1);
    local.perPage = Min(Val(params.perPage ?: variables.defaultPerPage), variables.maxPerPage);
    local.sort = params.sort ?: "createdAt DESC";
    
    // Build query
    local.queryParams = {
      page: local.page,
      perPage: local.perPage,
      order: local.sort,
      select: "id,title,slug,excerpt,publishedAt,author",
      returnAs: "query"
    };
    
    // Apply filters
    if (StructKeyExists(params, "status")) {
      local.queryParams.where = "status = '#params.status#'";
    }
    
    if (StructKeyExists(params, "category")) {
      local.queryParams.where = ListAppend(
        local.queryParams.where ?: "",
        "categoryId = #Val(params.category)#",
        " AND "
      );
    }
    
    // Search
    if (StructKeyExists(params, "q") && Len(params.q)) {
      local.queryParams.where = ListAppend(
        local.queryParams.where ?: "",
        "(title LIKE '%#params.q#%' OR body LIKE '%#params.q#%')",
        " AND "
      );
    }
    
    // Get posts
    local.posts = model("Post").findAll(argumentCollection=local.queryParams);
    
    // Transform to array of structs
    local.data = [];
    for (local.row in local.posts) {
      ArrayAppend(local.data, {
        "id": local.row.id,
        "title": local.row.title,
        "slug": local.row.slug,
        "excerpt": local.row.excerpt,
        "publishedAt": DateTimeFormat(local.row.publishedAt, "iso8601"),
        "author": local.row.author,
        "url": urlFor(route="api.v1.post", key=local.row.id, onlyPath=false)
      });
    }
    
    // Build pagination meta
    local.totalPages = Ceiling(local.posts.recordCount / local.perPage);
    local.meta = {
      "pagination": {
        "total": local.posts.recordCount,
        "perPage": local.perPage,
        "currentPage": local.page,
        "totalPages": local.totalPages,
        "from": (local.page - 1) * local.perPage + 1,
        "to": Min(local.page * local.perPage, local.posts.recordCount)
      }
    };
    
    // Add links
    local.meta.links = {
      "self": urlFor(route="api.v1.posts", params=params, onlyPath=false),
      "first": urlFor(route="api.v1.posts", page=1, onlyPath=false),
      "last": urlFor(route="api.v1.posts", page=local.totalPages, onlyPath=false)
    };
    
    if (local.page > 1) {
      local.meta.links["prev"] = urlFor(route="api.v1.posts", page=local.page-1, onlyPath=false);
    }
    
    if (local.page < local.totalPages) {
      local.meta.links["next"] = urlFor(route="api.v1.posts", page=local.page+1, onlyPath=false);
    }
    
    renderSuccessResponse(data=local.data, meta=local.meta);
  }
  
  // GET /api/v1/posts/:key
  function show() {
    local.post = model("Post").findByKey(
      key=params.key,
      include="category,author,tags"
    );
    
    if (!IsObject(local.post)) {
      renderErrorResponse("Post not found", 404);
    }
    
    // Check permissions
    if (!local.post.isPublished() && !canViewDraft(local.post)) {
      renderErrorResponse("Access denied", 403);
    }
    
    // Transform to API response
    local.data = {
      "id": local.post.id,
      "title": local.post.title,
      "slug": local.post.slug,
      "body": local.post.body,
      "excerpt": local.post.excerpt,
      "status": local.post.status,
      "publishedAt": DateTimeFormat(local.post.publishedAt, "iso8601"),
      "createdAt": DateTimeFormat(local.post.createdAt, "iso8601"),
      "updatedAt": DateTimeFormat(local.post.updatedAt, "iso8601"),
      "category": {
        "id": local.post.category.id,
        "name": local.post.category.name,
        "slug": local.post.category.slug
      },
      "author": {
        "id": local.post.author.id,
        "name": local.post.author.fullName(),
        "avatar": local.post.author.avatarUrl
      },
      "tags": []
    };
    
    // Add tags
    for (local.tag in local.post.tags) {
      ArrayAppend(local.data.tags, {
        "id": local.tag.id,
        "name": local.tag.name,
        "slug": local.tag.slug
      });
    }
    
    renderSuccessResponse(data=local.data);
  }
  
  // POST /api/v1/posts
  function create() {
    // Validate input
    local.errors = validatePostInput(params);
    if (!StructIsEmpty(local.errors)) {
      renderErrorResponse("Validation failed", 422, local.errors);
    }
    
    // Create post
    local.post = model("Post").new(params.post);
    local.post.userId = request.apiUser.id;
    
    if (local.post.save()) {
      // Add tags if provided
      if (StructKeyExists(params, "tags")) {
        local.post.setTags(params.tags);
      }
      
      // Return created resource
      params.key = local.post.id;
      show();
    } else {
      renderErrorResponse("Failed to create post", 422, local.post.allErrors());
    }
  }
  
  // PUT/PATCH /api/v1/posts/:key
  function update() {
    local.post = model("Post").findByKey(params.key);
    
    if (!IsObject(local.post)) {
      renderErrorResponse("Post not found", 404);
    }
    
    // Check permissions
    if (!canEdit(local.post)) {
      renderErrorResponse("Access denied", 403);
    }
    
    // Update post
    if (local.post.update(params.post)) {
      // Update tags if provided
      if (StructKeyExists(params, "tags")) {
        local.post.setTags(params.tags);
      }
      
      show();
    } else {
      renderErrorResponse("Failed to update post", 422, local.post.allErrors());
    }
  }
  
  // DELETE /api/v1/posts/:key
  function delete() {
    local.post = model("Post").findByKey(params.key);
    
    if (!IsObject(local.post)) {
      renderErrorResponse("Post not found", 404);
    }
    
    // Check permissions
    if (!canDelete(local.post)) {
      renderErrorResponse("Access denied", 403);
    }
    
    if (local.post.delete()) {
      renderSuccessResponse(data={message: "Post deleted successfully"}, status=204);
    } else {
      renderErrorResponse("Failed to delete post", 500);
    }
  }
  
  // Private helper methods
  private struct function validatePostInput(required struct input) {
    local.errors = {};
    
    if (!StructKeyExists(arguments.input, "title") || !Len(arguments.input.title)) {
      local.errors["title"] = "Title is required";
    }
    
    if (!StructKeyExists(arguments.input, "body") || !Len(arguments.input.body)) {
      local.errors["body"] = "Body is required";
    }
    
    if (StructKeyExists(arguments.input, "categoryId")) {
      local.category = model("Category").findByKey(arguments.input.categoryId);
      if (!IsObject(local.category)) {
        local.errors["categoryId"] = "Invalid category";
      }
    }
    
    return local.errors;
  }
}
```

## API Versioning

### Version Management
```cfml
// /config/routes.cfm
mapper()
  // API v1 routes
  .namespace("api")
    .namespace("v1")
      .resources(name="posts", controller="api.v1.posts")
      .resources(name="users", controller="api.v1.users", only="index,show")
      .resources(name="comments", controller="api.v1.comments")
    .end()
    
    // API v2 with breaking changes
    .namespace("v2")
      .resources(name="posts", controller="api.v2.posts")
      .resources(name="users", controller="api.v2.users")
      .resources(name="comments", controller="api.v2.comments")
      .resources(name="reactions", controller="api.v2.reactions") // New in v2
    .end()
  .end()
.end();
```

### Version-Specific Controllers
```cfml
// /app/controllers/api/v2/Base.cfc
component extends="api.v1.Base" {
  
  function config() {
    super.config();
    
    // v2 specific configuration
    variables.apiVersion = "2.0";
    
    // New v2 features
    filters(through="checkBetaFeatures");
  }
  
  // Override to set v2 headers
  private void function setApiHeaders() {
    super.setApiHeaders();
    header name="X-API-Version" value="2.0";
    header name="X-API-Deprecated" value="false";
  }
}
```

## Request/Response Handling

### Input Validation
```cfml
// /app/controllers/api/v1/Validators.cfc
component {
  
  public struct function validateRequest(
    required struct rules,
    required struct data
  ) {
    local.errors = {};
    
    for (local.field in arguments.rules) {
      local.rule = arguments.rules[local.field];
      local.value = arguments.data[local.field] ?: "";
      
      // Required validation
      if (StructKeyExists(local.rule, "required") && local.rule.required) {
        if (!StructKeyExists(arguments.data, local.field) || !Len(local.value)) {
          local.errors[local.field] = "#local.field# is required";
          continue;
        }
      }
      
      // Type validation
      if (StructKeyExists(local.rule, "type") && Len(local.value)) {
        switch(local.rule.type) {
          case "email":
            if (!IsValid("email", local.value)) {
              local.errors[local.field] = "#local.field# must be a valid email";
            }
            break;
          case "numeric":
            if (!IsNumeric(local.value)) {
              local.errors[local.field] = "#local.field# must be numeric";
            }
            break;
          case "date":
            if (!IsDate(local.value)) {
              local.errors[local.field] = "#local.field# must be a valid date";
            }
            break;
          case "uuid":
            if (!IsValid("uuid", local.value)) {
              local.errors[local.field] = "#local.field# must be a valid UUID";
            }
            break;
        }
      }
      
      // Length validation
      if (StructKeyExists(local.rule, "minLength") && Len(local.value) < local.rule.minLength) {
        local.errors[local.field] = "#local.field# must be at least #local.rule.minLength# characters";
      }
      
      if (StructKeyExists(local.rule, "maxLength") && Len(local.value) > local.rule.maxLength) {
        local.errors[local.field] = "#local.field# must be no more than #local.rule.maxLength# characters";
      }
      
      // Pattern validation
      if (StructKeyExists(local.rule, "pattern") && Len(local.value)) {
        if (!ReFind(local.rule.pattern, local.value)) {
          local.errors[local.field] = "#local.field# format is invalid";
        }
      }
      
      // Custom validation
      if (StructKeyExists(local.rule, "custom") && IsCustomFunction(local.rule.custom)) {
        local.customError = local.rule.custom(local.value, arguments.data);
        if (Len(local.customError)) {
          local.errors[local.field] = local.customError;
        }
      }
    }
    
    return local.errors;
  }
}
```

### Response Transformation
```cfml
// /app/helpers/ApiTransformer.cfc
component {
  
  public struct function transformModel(
    required any model,
    string fields="",
    boolean includeRelations=false
  ) {
    local.data = {};
    local.metadata = GetMetadata(arguments.model);
    
    // Get properties to include
    if (Len(arguments.fields)) {
      local.includeFields = ListToArray(arguments.fields);
    } else {
      local.includeFields = arguments.model.propertyNames();
    }
    
    // Transform properties
    for (local.field in local.includeFields) {
      if (StructKeyExists(arguments.model, local.field)) {
        local.value = arguments.model[local.field];
        
        // Transform dates to ISO 8601
        if (IsDate(local.value)) {
          local.data[local.field] = DateTimeFormat(local.value, "iso8601");
        }
        // Handle null values
        else if (!IsDefined("local.value") || IsNull(local.value)) {
          local.data[local.field] = JavaCast("null", "");
        }
        // Regular values
        else {
          local.data[local.field] = local.value;
        }
      }
    }
    
    // Include relations if requested
    if (arguments.includeRelations) {
      // Add related data
      local.associations = arguments.model.$classData().associations;
      for (local.assoc in local.associations) {
        if (local.assoc.type == "hasMany") {
          local.data[local.assoc.name] = transformCollection(
            arguments.model[local.assoc.name]()
          );
        } else if (local.assoc.type == "belongsTo" || local.assoc.type == "hasOne") {
          local.related = arguments.model[local.assoc.name]();
          if (IsObject(local.related)) {
            local.data[local.assoc.name] = transformModel(local.related);
          }
        }
      }
    }
    
    // Add HATEOAS links
    local.data["_links"] = {
      "self": buildResourceUrl(arguments.model)
    };
    
    return local.data;
  }
  
  public array function transformCollection(required any collection) {
    local.data = [];
    
    for (local.item in arguments.collection) {
      ArrayAppend(local.data, transformModel(local.item));
    }
    
    return local.data;
  }
}
```

## API Authentication

### JWT Authentication
```cfml
// /app/services/JWTService.cfc
component {
  
  variables.secret = getSetting("jwtSecret");
  variables.issuer = getSetting("jwtIssuer");
  variables.audience = getSetting("jwtAudience");
  
  public string function generateToken(required struct payload, numeric expiresIn=3600) {
    local.header = {
      "alg": "HS256",
      "typ": "JWT"
    };
    
    local.payload = Duplicate(arguments.payload);
    local.payload["iat"] = DateDiff("s", CreateDateTime(1970,1,1,0,0,0), Now());
    local.payload["exp"] = local.payload.iat + arguments.expiresIn;
    local.payload["iss"] = variables.issuer;
    local.payload["aud"] = variables.audience;
    
    local.headerBase64 = toBase64(SerializeJSON(local.header));
    local.payloadBase64 = toBase64(SerializeJSON(local.payload));
    
    local.signature = hmac(
      local.headerBase64 & "." & local.payloadBase64,
      variables.secret,
      "HmacSHA256"
    );
    
    return local.headerBase64 & "." & local.payloadBase64 & "." & local.signature;
  }
  
  public struct function verifyToken(required string token) {
    try {
      local.parts = ListToArray(arguments.token, ".");
      
      if (ArrayLen(local.parts) != 3) {
        return {valid: false, error: "Invalid token format"};
      }
      
      local.header = DeserializeJSON(toString(toBinary(local.parts[1])));
      local.payload = DeserializeJSON(toString(toBinary(local.parts[2])));
      local.signature = local.parts[3];
      
      // Verify signature
      local.expectedSignature = hmac(
        local.parts[1] & "." & local.parts[2],
        variables.secret,
        "HmacSHA256"
      );
      
      if (local.signature != local.expectedSignature) {
        return {valid: false, error: "Invalid signature"};
      }
      
      // Check expiration
      local.now = DateDiff("s", CreateDateTime(1970,1,1,0,0,0), Now());
      if (local.payload.exp < local.now) {
        return {valid: false, error: "Token expired"};
      }
      
      // Verify issuer and audience
      if (local.payload.iss != variables.issuer || local.payload.aud != variables.audience) {
        return {valid: false, error: "Invalid token claims"};
      }
      
      return {valid: true, payload: local.payload};
    } catch (any e) {
      return {valid: false, error: e.message};
    }
  }
}
```

## Rate Limiting

### Rate Limiter Implementation
```cfml
// /app/services/RateLimiter.cfc
component {
  
  public void function init() {
    variables.limits = {
      "default": {requests: 1000, window: 3600},
      "authenticated": {requests: 5000, window: 3600},
      "premium": {requests: 10000, window: 3600}
    };
  }
  
  public boolean function checkLimit(
    required string identifier,
    string tier="default"
  ) {
    local.limit = variables.limits[arguments.tier];
    local.key = "rate_limit_#arguments.identifier#_#arguments.tier#";
    
    // Get current count
    local.current = application.cache.get(local.key);
    
    if (!IsStruct(local.current)) {
      local.current = {
        count: 0,
        resetAt: DateAdd("s", local.limit.window, Now())
      };
    }
    
    // Check if window has expired
    if (local.current.resetAt <= Now()) {
      local.current = {
        count: 0,
        resetAt: DateAdd("s", local.limit.window, Now())
      };
    }
    
    // Check limit
    if (local.current.count >= local.limit.requests) {
      return false;
    }
    
    // Increment counter
    local.current.count++;
    application.cache.set(
      local.key,
      local.current,
      DateDiff("s", Now(), local.current.resetAt)
    );
    
    // Set rate limit headers
    request.rateLimitHeaders = {
      limit: local.limit.requests,
      remaining: local.limit.requests - local.current.count,
      reset: DateDiff("s", CreateDateTime(1970,1,1,0,0,0), local.current.resetAt)
    };
    
    return true;
  }
}
```

## Error Handling

### Global Error Handler
```cfml
// /app/controllers/api/ErrorHandler.cfc
component {
  
  public struct function handleApiError(required any exception) {
    local.response = {
      "error": true,
      "timestamp": DateTimeFormat(Now(), "iso8601")
    };
    
    // Determine error type and status code
    switch(arguments.exception.type) {
      case "Wheels.QueryNotFound":
        local.response["status"] = 404;
        local.response["message"] = "Resource not found";
        break;
        
      case "Wheels.ValidationFailed":
        local.response["status"] = 422;
        local.response["message"] = "Validation failed";
        local.response["errors"] = arguments.exception.errors;
        break;
        
      case "Authorization":
        local.response["status"] = 403;
        local.response["message"] = "Access denied";
        break;
        
      case "Authentication":
        local.response["status"] = 401;
        local.response["message"] = "Authentication required";
        break;
        
      case "RateLimit":
        local.response["status"] = 429;
        local.response["message"] = "Rate limit exceeded";
        break;
        
      default:
        local.response["status"] = 500;
        local.response["message"] = "Internal server error";
        
        // Log error for debugging
        writeLog(
          type="error",
          file="api_errors",
          text=SerializeJSON({
            exception: arguments.exception,
            request: {
              url: request.cgi.PATH_INFO,
              method: request.cgi.REQUEST_METHOD,
              params: params
            }
          })
        );
    }
    
    // Include error details in development
    if (get("environment") == "development") {
      local.response["debug"] = {
        "type": arguments.exception.type,
        "detail": arguments.exception.detail,
        "stacktrace": arguments.exception.tagContext
      };
    }
    
    return local.response;
  }
}
```

## CORS Configuration

### CORS Filter
```cfml
// /app/controllers/api/CORSFilter.cfc
component {
  
  public void function handleCORS() {
    // Get allowed origins from settings
    local.allowedOrigins = getSetting("corsAllowedOrigins");
    local.origin = request.headers["Origin"] ?: "";
    
    // Check if origin is allowed
    if (ListFind(local.allowedOrigins, local.origin) || local.allowedOrigins == "*") {
      header name="Access-Control-Allow-Origin" value=local.origin;
      header name="Access-Control-Allow-Credentials" value="true";
    }
    
    // Set other CORS headers
    header name="Access-Control-Allow-Methods" value="GET,POST,PUT,PATCH,DELETE,OPTIONS";
    header name="Access-Control-Allow-Headers" value="Content-Type,Authorization,X-API-Key";
    header name="Access-Control-Max-Age" value="86400";
    
    // Handle preflight requests
    if (request.cgi.REQUEST_METHOD == "OPTIONS") {
      renderWith(data="", status=204);
      abort;
    }
  }
}
```

## API Testing

### API Test Examples
```cfscript
// /tests/specs/api/PostsApiTest.cfc
component extends="tests.BaseSpec" {
  
  function beforeAll() {
    variables.apiKey = createTestApiKey();
    variables.baseUrl = "/api/v1";
  }
  
  function run() {
    describe("Posts API", () => {
      
      it("returns paginated posts", () => {
        var result = makeApiRequest(
          url="#variables.baseUrl#/posts",
          method="GET"
        );
        
        expect(result.status).toBe(200);
        expect(result.json.success).toBe(true);
        expect(result.json.data).toBeArray();
        expect(result.json.meta.pagination).toBeStruct();
      });
      
      it("creates a new post", () => {
        var postData = {
          title: "Test Post",
          body: "Test content",
          categoryId: 1
        };
        
        var result = makeApiRequest(
          url="#variables.baseUrl#/posts",
          method="POST",
          data=postData
        );
        
        expect(result.status).toBe(201);
        expect(result.json.data.title).toBe(postData.title);
      });
      
      it("handles validation errors", () => {
        var result = makeApiRequest(
          url="#variables.baseUrl#/posts",
          method="POST",
          data={}
        );
        
        expect(result.status).toBe(422);
        expect(result.json.error).toBe(true);
        expect(result.json.details).toHaveKey("title");
      });
      
      it("requires authentication", () => {
        var result = makeApiRequest(
          url="#variables.baseUrl#/posts",
          method="POST",
          data={title: "Test"},
          authenticate=false
        );
        
        expect(result.status).toBe(401);
      });
      
      it("respects rate limits", () => {
        // Make many requests quickly
        for (var i = 1; i <= 100; i++) {
          var result = makeApiRequest(
            url="#variables.baseUrl#/posts",
            method="GET"
          );
        }
        
        // Next request should be rate limited
        var result = makeApiRequest(
          url="#variables.baseUrl#/posts",
          method="GET"
        );
        
        expect(result.status).toBe(429);
      });
    });
  }
  
  private struct function makeApiRequest(
    required string url,
    string method="GET",
    struct data={},
    boolean authenticate=true
  ) {
    var headers = {};
    
    if (arguments.authenticate) {
      headers["X-API-Key"] = variables.apiKey;
    }
    
    return processRequest(
      url=arguments.url,
      method=arguments.method,
      params=arguments.data,
      headers=headers
    );
  }
}
```

## Best Practices

1. **Version Your API**: Always version your API from the start
2. **Use Consistent Naming**: Follow RESTful conventions for endpoints
3. **Implement Pagination**: Never return unlimited results
4. **Rate Limiting**: Protect your API from abuse
5. **Comprehensive Error Handling**: Return meaningful error messages
6. **API Documentation**: Keep documentation up-to-date
7. **Security First**: Always authenticate and authorize requests
8. **Use HTTPS**: Never expose APIs over plain HTTP in production
9. **Validate Input**: Never trust client input
10. **Monitor Performance**: Track API usage and response times
11. **Cache Responses**: Use caching for frequently accessed data
12. **Idempotent Operations**: Make PUT and DELETE idempotent
13. **Use Standard HTTP Status Codes**: Follow HTTP standards
14. **HATEOAS**: Include links to related resources
15. **Audit Logging**: Log all API access for security and debugging