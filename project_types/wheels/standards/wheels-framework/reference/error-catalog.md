---
description: Wheels Framework Error Catalog and Solutions
version: 1.0
encoding: UTF-8
---

# Wheels Error Catalog

Comprehensive error diagnosis and resolution guide for common Wheels framework errors. Each error includes symptoms, causes, and solutions.

## Table of Contents
- [Framework Errors](#framework-errors)
- [Model Errors](#model-errors)
- [Controller Errors](#controller-errors)
- [View Errors](#view-errors)
- [Database Errors](#database-errors)
- [Routing Errors](#routing-errors)
- [Testing Errors](#testing-errors)
- [Configuration Errors](#configuration-errors)
- [Migration Errors](#migration-errors)

## Framework Errors

### Error: "The method config was not found in component"

**Symptoms:**
```
The method config was not found in component controllers.Users
```

**Cause:** Using `init()` instead of `config()` for initialization

**Solution:**
```cfscript
// Wrong
component extends="Controller" {
    function init() {
        // This won't work
    }
}

// Correct
component extends="Controller" {
    function config() {
        // Initialization code here
    }
}
```

### Error: "Variable APPLICATION is undefined"

**Symptoms:**
```
Variable APPLICATION is undefined
```

**Cause:** Wheels framework not properly initialized

**Solutions:**
1. Ensure Application.cfc extends Wheels:
```cfscript
component extends="vendor.wheels.models.Wheels" {
    this.name = "MyApp";
}
```

2. Check that vendor/wheels directory exists
3. Run `box install` to install dependencies

### Error: "Cannot find vendor/wheels/Wheels.cfc"

**Symptoms:**
```
Could not find the ColdFusion component or interface vendor.wheels.models.Wheels
```

**Cause:** Wheels not installed or path incorrect

**Solution:**
```bash
# Install Wheels
box install

# Verify installation
ls vendor/wheels/
```

## Model Errors

### Error: "Table 'users' doesn't exist"

**Symptoms:**
```
[Macromedia][SQLServer JDBC Driver][SQLServer]Invalid object name 'users'
```

**Cause:** Database table doesn't exist or wrong table name

**Solutions:**
1. Run migrations:
```bash
wheels dbmigrate latest
```

2. Check table naming convention:
```cfscript
// Model expects plural table name by default
component extends="Model" {
    function config() {
        // Override if needed
        table("user_accounts");
    }
}
```

### Error: "Property X is not a valid property"

**Symptoms:**
```
Property 'emailAddress' is not a valid property for model User
```

**Cause:** Column doesn't exist in database or wrong property name

**Solutions:**
1. Check database column exists
2. Use property mapping:
```cfscript
component extends="Model" {
    function config() {
        property(name: "emailAddress", column: "email");
    }
}
```

### Error: "Association X not found"

**Symptoms:**
```
Association 'posts' was not found on model 'User'
```

**Cause:** Association not defined or named incorrectly

**Solution:**
```cfscript
component extends="Model" {
    function config() {
        // Define association
        hasMany("posts");
        // Or with custom options
        hasMany(name: "posts", foreignKey: "author_id");
    }
}
```

### Error: Validation Failed

**Symptoms:**
```
Validation failed for the following properties: email, username
```

**Cause:** Model validation rules not met

**Solution:**
```cfscript
// Check validation errors
if (!user.save()) {
    // Get all errors
    var errors = user.allErrors();
    
    // Get specific field error
    var emailError = user.errorMessageOn("email");
    
    // Check if field has error
    if (user.hasErrors("email")) {
        // Handle error
    }
}
```

### Error: "Duplicate entry for key"

**Symptoms:**
```
Duplicate entry 'john@example.com' for key 'email_unique'
```

**Cause:** Unique constraint violation

**Solution:**
```cfscript
// Add validation to prevent database error
component extends="Model" {
    function config() {
        validatesUniquenessOf("email");
    }
}
```

## Controller Errors

### Error: "Action X was not found"

**Symptoms:**
```
The action 'show' was not found in controller 'Users'
```

**Cause:** Action method doesn't exist or is private

**Solution:**
```cfscript
component extends="Controller" {
    // Action must be public
    function show() {
        user = model("User").findByKey(params.key);
    }
    
    // Private methods won't work as actions
    private function privateMethod() {
        // This can't be called as an action
    }
}
```

### Error: "Wheels.ViewNotFound"

**Symptoms:**
```
Could not find the view file for the 'index' action in the 'users' controller
```

**Cause:** View file missing or named incorrectly

**Solution:**
1. Create view file at correct location:
```
/app/views/users/index.cfm
```

2. Or explicitly render different view:
```cfscript
function index() {
    users = model("User").findAll();
    renderView("customview");
}
```

### Error: "Filter X not found"

**Symptoms:**
```
Filter method 'authenticate' was not found in controller 'Admin'
```

**Cause:** Filter method doesn't exist

**Solution:**
```cfscript
component extends="Controller" {
    function config() {
        filters("authenticate");
    }
    
    // Filter method must exist
    private function authenticate() {
        if (!structKeyExists(session, "userId")) {
            redirectTo(route: "login");
        }
    }
}
```

### Error: "Render/Redirect already performed"

**Symptoms:**
```
You have already performed a render or redirect in this request
```

**Cause:** Multiple render/redirect calls

**Solution:**
```cfscript
function update() {
    user = model("User").findByKey(params.key);
    
    if (user.update(params.user)) {
        redirectTo(route: "users");
    } else {
        // Check if already rendered/redirected
        if (!$performedRenderOrRedirect()) {
            renderView("edit");
        }
    }
}
```

## View Errors

### Error: "Variable X is undefined"

**Symptoms:**
```
Variable 'user' is undefined in view
```

**Cause:** Variable not set in controller

**Solution:**
```cfscript
// In controller
function show() {
    // Set variable for view
    user = model("User").findByKey(params.key);
    
    // Or explicitly pass variables
    renderView(variables: {user: userObject});
}
```

### Error: "Invalid tag nesting"

**Symptoms:**
```
Invalid tag nesting: form tag inside another form tag
```

**Cause:** Nested form tags in view

**Solution:**
```html
<!-- Wrong -->
#startFormTag(route: "users")#
    #startFormTag(route: "nested")#
    #endFormTag()#
#endFormTag()#

<!-- Correct - use one form -->
#startFormTag(route: "users")#
    <!-- form fields -->
#endFormTag()#
```

### Error: "Helper function not found"

**Symptoms:**
```
Function 'linkTo' not found
```

**Cause:** Helper not available or typo

**Solution:**
1. Check helper name is correct
2. Ensure you're in a view context
3. For custom helpers, ensure they're loaded:
```cfscript
// In /app/helpers/functions.cfm
function myHelper() {
    return "helper output";
}
```

## Database Errors

### Error: "Datasource X not found"

**Symptoms:**
```
Datasource 'myapp' not found
```

**Cause:** Datasource not configured

**Solutions:**
1. Configure in Application.cfc:
```cfscript
this.datasources["myapp"] = {
    class: "com.mysql.cj.jdbc.Driver",
    connectionString: "jdbc:mysql://localhost:3306/myapp",
    username: "root",
    password: "password"
};
this.datasource = "myapp";
```

2. Or use CommandBox server.json:
```json
{
    "app": {
        "cfconfig": {
            "datasources": {
                "myapp": {
                    "host": "localhost",
                    "database": "myapp",
                    "class": "com.mysql.cj.jdbc.Driver"
                }
            }
        }
    }
}
```

### Error: "Connection refused"

**Symptoms:**
```
Connection refused: connect
```

**Cause:** Database server not running

**Solution:**
```bash
# Start database with Docker
docker compose up -d mysql

# Or check local database service
sudo systemctl status mysql
sudo systemctl start mysql
```

### Error: "Column count doesn't match"

**Symptoms:**
```
Column count doesn't match value count at row 1
```

**Cause:** Mismatch between columns and values in query

**Solution:**
```cfscript
// Check model properties match database columns
component extends="Model" {
    function config() {
        // Exclude calculated properties from database operations
        property(name: "fullName", sql: "first_name || ' ' || last_name");
    }
}
```

## Routing Errors

### Error: "Route not found"

**Symptoms:**
```
Route 'userProfile' was not found
```

**Cause:** Route not defined or named incorrectly

**Solution:**
```cfscript
// In config/routes.cfm
mapper()
    .namespace("admin")
        .resources("users")
    .end()
    .get(name: "userProfile", pattern: "/profile/[username]", to: "users##profile")
.end();
```

### Error: "Ambiguous route match"

**Symptoms:**
```
Multiple routes match the pattern '/users/123'
```

**Cause:** Overlapping route patterns

**Solution:**
```cfscript
// Order matters - specific routes first
mapper()
    .get(pattern: "/users/new", to: "users##new")
    .get(pattern: "/users/[key]", to: "users##show")
.end();
```

### Error: "Invalid route pattern"

**Symptoms:**
```
Invalid route pattern: '/users/:id'
```

**Cause:** Using wrong parameter syntax

**Solution:**
```cfscript
// Wrong - Rails/Express syntax
.get(pattern: "/users/:id", to: "users##show")

// Correct - Wheels syntax
.get(pattern: "/users/[key]", to: "users##show")
```

## Testing Errors

### Error: "BaseSpec not found"

**Symptoms:**
```
Could not find the ColdFusion component or interface tests.BaseSpec
```

**Cause:** Test not extending BaseSpec or path issue

**Solution:**
```cfscript
// Correct test setup
component extends="tests.BaseSpec" {
    function run() {
        describe("My Test", () => {
            it("should work", () => {
                expect(true).toBeTrue();
            });
        });
    }
}
```

### Error: "Test database not configured"

**Symptoms:**
```
Datasource 'wheelstestdb' not found
```

**Cause:** Test datasource not set up

**Solution:**
1. Create test database:
```sql
CREATE DATABASE wheelstestdb;
```

2. Configure datasource in test environment

### Error: "Transaction rollback failed"

**Symptoms:**
```
Cannot rollback transaction, no transaction active
```

**Cause:** Transaction management issue in tests

**Solution:**
```cfscript
// Tests automatically use transactions when extending BaseSpec
component extends="tests.BaseSpec" {
    // Don't manually manage transactions
}
```

## Configuration Errors

### Error: "Environment not found"

**Symptoms:**
```
Environment 'staging' not found
```

**Cause:** Environment configuration missing

**Solution:**
1. Create environment file:
```
/config/staging/settings.cfm
```

2. Set environment:
```bash
wheels set environment staging
```

### Error: "Invalid configuration value"

**Symptoms:**
```
Invalid value for setting 'cacheQueries'
```

**Cause:** Wrong data type or value

**Solution:**
```cfscript
// In config/settings.cfm
// Check documentation for valid values
set(cacheQueries: true); // boolean, not string
```

### Error: "Plugin not found"

**Symptoms:**
```
Plugin 'MyPlugin' not found
```

**Cause:** Plugin not installed or loaded

**Solution:**
1. Install plugin:
```bash
box install my-plugin
```

2. Configure in settings:
```cfscript
set(plugins: "MyPlugin");
```

## Migration Errors

### Error: "Migration has already been run"

**Symptoms:**
```
Migration '001_create_users' has already been run
```

**Cause:** Trying to run migration twice

**Solution:**
```bash
# Check migration status
wheels dbmigrate info

# Rollback if needed
wheels dbmigrate down

# Then run again
wheels dbmigrate latest
```

### Error: "Column already exists"

**Symptoms:**
```
Column 'email' already exists in table 'users'
```

**Cause:** Migration trying to add existing column

**Solution:**
```cfscript
// In migration, check if column exists
component extends="Migration" {
    function up() {
        if (!hasColumn("users", "email")) {
            addColumn(table: "users", column: "email", type: "string");
        }
    }
}
```

### Error: "Foreign key constraint fails"

**Symptoms:**
```
Cannot add or update a child row: a foreign key constraint fails
```

**Cause:** Referential integrity violation

**Solution:**
```cfscript
// In migration, create foreign key properly
component extends="Migration" {
    function up() {
        addColumn(
            table: "posts",
            column: "user_id",
            type: "integer",
            references: "users(id)",
            onDelete: "cascade"
        );
    }
}
```

## Prevention Tips

### Always:
- Use `config()` not `init()` for initialization
- Extend BaseSpec for tests
- Check `$performedRenderOrRedirect()` before rendering
- Use proper Wheels syntax for routes `[param]` not `:param`
- Run migrations before testing
- Set up test datasource

### Never:
- Call framework methods starting with `$` from application code
- Use multiple render/redirect in same action
- Manually manage transactions in tests
- Mix positional and named arguments in CLI
- Assume file paths are relative
- Skip error checking on save/update operations

## Debugging Techniques

### Enable Debugging
```cfscript
// In config/development/settings.cfm
set(debug: true);
set(showDebugInformation: true);
```

### Check SQL Queries
```cfscript
// Enable query logging
set(logQueries: true);

// In model
result = model("User").findAll(returnAs: "query");
writeDump(result.sql);
```

### Inspect Object State
```cfscript
// Dump model state
writeDump(user.properties());
writeDump(user.errors());
writeDump(user.changedProperties());
```

### Use Try/Catch
```cfscript
try {
    user.save();
} catch (any e) {
    writeDump(e);
    writeLog(text: e.message, file: "wheels-errors");
}
```

This error catalog should help AI assistants quickly identify and resolve common Wheels framework issues.