---
description: Wheels Framework Architecture and Core Concepts
version: 3.0
encoding: UTF-8
---

# Wheels Framework Architecture

This guide provides comprehensive understanding of the Wheels framework architecture, core concepts, and internal workings for effective development.

## Wheels 3.0 Changes

### Major Updates in Version 3.0
- **Configuration Location**: Config files moved from `/app/config/` to `/config/` at root level
- **BoxLang Support**: Full support for BoxLang runtime alongside Lucee and Adobe CF
- **Enhanced CLI**: New deployment, security, and optimization commands
- **Improved Performance**: Better caching strategies and query optimization
- **Modern Security**: Enhanced CSRF protection, JWT support, and security headers
- **API First**: Better API development support with versioning and rate limiting

## Framework Request Lifecycle

```
1. Request arrives at /public/index.cfm
   ↓
2. Application.cfc initializes
   - Sets up mappings (/app, /vendor, /wheels, /wirebox, /testbox)
   - Loads environment configuration
   - Creates WireBox injector
   ↓
3. onRequestStart() executes
   - Checks for reload parameter
   - Initializes framework if needed
   - Sets up request variables
   ↓
4. Dispatch.cfc processes request
   - Matches URL to routes (Mapper.cfc)
   - Creates params struct from URL/form/JSON
   - Determines controller and action
   ↓
5. Controller instantiation
   - $createControllerObject() called
   - Controller's config() method runs
   - Filters execute (before filters)
   ↓
6. Action execution
   - Controller action method runs
   - Model operations performed
   - Data prepared for view
   ↓
7. View rendering
   - Automatic unless $performedRenderOrRedirect()
   - Content negotiation via provides()
   - Layout wrapping for HTML
   ↓
8. Response sent
   - After filters execute
   - onRequestEnd() cleanup
```

## Component Dependency Map

```
Application.cfc
├── WireBox (DI Container)
│   ├── Global.cfc (utility functions)
│   ├── Plugins.cfc (plugin system)
│   └── EventMethods.cfc (event handling)
│
├── Dispatch.cfc (request routing)
│   ├── Mapper.cfc (route definitions)
│   └── Global.cfc (inherited utilities)
│
├── Controller.cfc (base controller)
│   ├── wheels.controller.* (component mixins)
│   ├── wheels.view.* (view helpers)
│   └── Global.cfc (inherited utilities)
│
├── Model.cfc (base model)
│   ├── wheels.model.* (component mixins)
│   └── Global.cfc (inherited utilities)
│
└── CLI Module (CommandBox Integration)
    ├── commands/wheels/* (CLI commands)
    ├── models/* (Service layer)
    └── templates/* (Code generation)
```

## Method Signature Reference

### Controller Methods

```cfml
// Configuration (called automatically)
public void function config()

// Filters
public void function filters(
  string through,
  string type="before",
  string only="",
  string except=""
)

// Content negotiation
public void function provides(string formats)
public void function onlyProvides(string formats)

// Rendering
public any function renderView(string template, string layout)
public any function renderText(string text, string status)
public any function renderWith(any data, string status)
public any function renderNothing(string status)

// Redirecting
public void function redirectTo(
  string route,
  string controller,
  string action,
  string key,
  string url,
  string anchor,
  boolean addToken,
  numeric statusCode
)

// Flash messages
public void function flashInsert(string success, string info, string warning, string error)
public any function flash(string key)
public void function flashClear()

// Verification
public void function verifies(
  string except,
  string only,
  string params,
  string session,
  string cookie,
  string paramsTypes,
  string handler
)
```

### Model Methods

```cfml
// Configuration (called automatically)
public void function config()

// Table configuration
public void function table(string name)
public void function setTableNamePrefix(string prefix)

// Properties
public void function property(
  string name,
  string column,
  string sql,
  string label,
  string defaultValue,
  string dataType
)

// Associations
public void function hasMany(
  string name,
  string modelName,
  string foreignKey,
  string joinKey,
  string joinType,
  string dependent,
  string shortcut
)

public void function belongsTo(
  string name,
  string modelName,
  string foreignKey,
  string joinKey,
  string joinType
)

public void function hasOne(
  string name,
  string modelName,
  string foreignKey,
  string joinKey,
  string joinType,
  string dependent
)

// Validations
public void function validatesPresenceOf(
  string properties,
  string message,
  string when,
  string condition,
  string unless
)

public void function validatesUniquenessOf(
  string properties,
  string message,
  string when,
  string scope,
  string condition,
  string unless
)

public void function validatesFormatOf(
  string property,
  string regex,
  string message,
  string when,
  boolean allowBlank,
  string condition,
  string unless
)

// CRUD Operations
public any function findAll(
  string where,
  string order,
  string group,
  string select,
  string include,
  numeric maxRows,
  numeric page,
  numeric perPage,
  boolean count,
  boolean cache,
  numeric cacheTime,
  string returnAs
)

public any function findOne(
  string where,
  string order,
  string select,
  string include,
  boolean cache,
  numeric cacheTime,
  string returnAs
)

public any function findByKey(
  any key,
  string select,
  string include,
  boolean cache,
  numeric cacheTime,
  string returnAs
)

public any function create(struct properties, boolean parameterize, boolean reload)
public boolean function update(struct properties, boolean parameterize, boolean reload)
public boolean function save(boolean parameterize, boolean reload)
public boolean function delete()

// Validation
public boolean function valid()
public array function errors()
public array function errorsOn(string property)
public array function allErrors()
public boolean function hasErrors()

// Callbacks
public void function beforeValidation(string methods)
public void function afterValidation(string methods)
public void function beforeSave(string methods)
public void function afterSave(string methods)
public void function beforeCreate(string methods)
public void function afterCreate(string methods)
public void function beforeUpdate(string methods)
public void function afterUpdate(string methods)
public void function beforeDelete(string methods)
public void function afterDelete(string methods)
```

## Internal Framework Methods ($ prefix)

**Important**: These methods are for framework internal use only. Application code should not call them directly.

### Common Internal Methods
- `$init()` - Component initialization
- `$config()` - Configuration processing
- `$invoke()` - Dynamic method invocation
- `$include()` - Template inclusion
- `$createObjectFromRoot()` - Object instantiation
- `$get()` - Get framework settings
- `$set()` - Set framework settings

### Controller Internal Methods
- `$callAction()` - Execute controller action
- `$performedRenderOrRedirect()` - Check if response sent
- `$requestContentType()` - Get request content type
- `$acceptableFormats()` - Get acceptable response formats
- `$generateToken()` - Create CSRF token
- `$verifyToken()` - Validate CSRF token

### Model Internal Methods
- `$initModelClass()` - Initialize model class
- `$query()` - Execute database query
- `$performedSave()` - Check if save executed
- `$buildQueryParamValues()` - Build query parameters
- `$propertyInfo()` - Get property metadata

## Environment Variables

### Application Scope
```cfml
application.wheels = {
  applicationName: "MyApp",
  applicationPath: "/path/to/app",
  configPath: "/config", // Wheels 3.0: moved from /app/config
  dataSourceName: "myDatasource",
  dataSourceUserName: "dbuser",
  dataSourcePassword: "dbpass",
  environment: "development|testing|staging|production|maintenance",
  reloadPassword: "myReloadPassword",
  showDebugInformation: true|false,
  showErrorInformation: true|false,
  sendEmailOnError: true|false,
  errorEmailAddress: "errors@example.com",
  cacheFileChecking: true|false,
  cacheImages: true|false,
  cacheModelFiles: true|false,
  cacheControllerFiles: true|false,
  cacheRoutes: true|false,
  cacheActions: true|false,
  cacheCullPercentage: 10,
  cacheCullInterval: 5,
  cacheDefaultTimeToLive: 3600,
  csrfCookieName: "_wheels_csrf",
  csrfCookieEncryptionKey: "key",
  routes: [], // Array of route structs
  mapper: {}, // Mapper instance
  models: {}, // Cached model instances
  controllers: {}, // Cached controller instances
  existingHelperFiles: "", // List of found helpers
  nonExistingHelperFiles: "" // List of not found helpers
}
```

### Request Scope
```cfml
request.wheels = {
  params: {}, // Merged params from all sources
  route: {}, // Matched route information
  controller: "", // Current controller name
  action: "", // Current action name
  key: "", // Primary key value if present
  format: "html|json|xml", // Response format
  contentType: "", // Request content type
  method: "GET|POST|PUT|PATCH|DELETE", // HTTP method
  isAjax: true|false, // Ajax request indicator
  isSecure: true|false, // HTTPS indicator
  remoteAddress: "", // Client IP
  userAgent: "", // Client user agent
  referrer: "" // HTTP referrer
}
```

## Database Adapter Interface

All database operations go through adapter classes that implement:

```cfml
interface DatabaseAdapter {
  // Query execution
  public query function $query(
    required string sql,
    array parameterList,
    numeric limit,
    numeric offset,
    datasource,
    username,
    password
  );
  
  // Schema information
  public array function $getColumns(required string table);
  public string function $primaryKey(required string table);
  
  // SQL generation
  public string function $tableAlias(required string table, required string alias);
  public string function $columnAlias(required string column, required string alias);
  public string function $limit(required numeric limit, numeric offset);
  
  // Data type handling
  public string function $dateTimeColumnType();
  public string function $binaryColumnType();
  public string function $booleanColumnType();
  
  // Feature support
  public boolean function $supportsIdentityColumns();
  public boolean function $supportsTransactions();
  public boolean function $supportsMigrations();
}
```

## Plugin Architecture

### Plugin Structure
```
/plugins/MyPlugin/
├── MyPlugin.cfc (main plugin file)
├── /config/
│   └── settings.cfm
├── /controllers/
├── /models/
├── /views/
└── /wheels/
    └── plugins.cfm (metadata)
```

### Plugin Interface
```cfml
component {
  
  public function init() {
    this.version = "1.0";
    this.wheelsVersion = "3.0";
    return this;
  }
  
  // Override framework methods
  public function overrideMethod() {
    // Call core method
    local.result = core.overrideMethod(argumentCollection=arguments);
    // Add plugin functionality
    return local.result;
  }
}
```

## Testing Infrastructure

### Test Base Classes

```cfml
// For unit/integration tests
component extends="wheels.test" {
  // Automatic transaction rollback
  // Helper methods available
  // Access to framework internals
}

// For BDD-style tests
component extends="testbox.system.BaseSpec" {
  // Use with TestBox runner
  // Describe/it syntax
  // Lifecycle methods
}
```

### Test Helpers
- `processRequest()` - Simulate HTTP requests
- `model()` - Get model instance
- `controller()` - Get controller instance
- `params()` - Set request parameters
- `session()` - Set session variables
- `flash()` - Set flash messages

## Performance Considerations

### Caching Layers
1. **Query Cache**: `findAll(cache=true, cacheTime=60)`
2. **Action Cache**: `caches(action="show", time=60)`
3. **View Cache**: Built-in fragment caching
4. **Route Cache**: Compiled routes cached in production
5. **File Cache**: Controller/model file checking cached

### Optimization Techniques
1. Use `select` to limit columns
2. Use `include` to prevent N+1 queries
3. Use `returnAs="query"` for read-only data
4. Enable caching in production
5. Use calculated properties for derived data
6. Index foreign keys in database

## Security Features

### Built-in Protection
1. **CSRF Protection**: Automatic for forms
2. **SQL Injection**: Parameterized queries
3. **XSS Prevention**: Auto HTML encoding
4. **Password Hashing**: BCrypt by default
5. **Secure Cookies**: Encryption available
6. **Request Forgery**: Token validation

### Security Best Practices
1. Always validate user input
2. Use strong parameter filtering
3. Implement proper authentication
4. Restrict file upload types
5. Sanitize file names
6. Use HTTPS in production
7. Keep framework updated

## Framework Extension Points

### 1. Custom Validators
```cfml
// In model config()
validate("customValidation");

private void function customValidation() {
  if (condition) {
    addError(property="field", message="Custom error");
  }
}
```

### 2. Global Helpers
```cfml
// /app/global/functions.cfm
public string function myHelper(required string text) {
  return UCase(arguments.text);
}
```

### 3. View Helpers
```cfml
// /app/views/helpers.cfm
public string function formatPrice(required numeric price) {
  return "$" & NumberFormat(arguments.price, ",.00");
}
```

### 4. Event Handlers
```cfml
// /app/events/onapplicationstart.cfm
// Custom initialization code
```

### 5. Middleware (New in 3.0)
```cfml
// /app/middleware/RateLimiter.cfc
component {
  public void function handle(required struct params, required function next) {
    // Check rate limits
    if (checkRateLimit(request.remoteAddress)) {
      arguments.next();
    } else {
      throw(type="RateLimit", message="Too many requests");
    }
  }
}
```

### 6. Custom Commands (CLI)
```cfml
// /app/commands/MyCommand.cfc
component extends="commandbox.system.BaseCommand" {
  function run() {
    print.line("Custom command executed");
  }
}
```

## New Features in Wheels 3.0

### Enhanced Security
- Automatic security headers in production
- Built-in JWT authentication support
- Enhanced CSRF protection with SameSite cookies
- Content Security Policy (CSP) configuration

### Performance Improvements
- Query result caching with automatic invalidation
- Improved lazy loading for associations
- Asset pipeline with fingerprinting
- HTTP/2 push support for assets

### Developer Experience
- Hot reload in development without restart
- Better error messages with code context
- Interactive console (wheels console)
- Database migration rollback with data preservation

### Deployment Features
- Zero-downtime deployments
- Blue-green deployment support
- Automatic SSL certificate management
- Container-ready with Docker support

### API Development
- Built-in API versioning
- Rate limiting per API key
- OpenAPI/Swagger documentation generation
- GraphQL support (via plugin)

This structured context helps AI assistants understand the framework's architecture, patterns, and best practices when providing assistance to developers.