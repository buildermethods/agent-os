---
description: Wheels Framework Troubleshooting Guide
version: 1.0
encoding: UTF-8
---

# Wheels Troubleshooting Guide

Common issues and solutions for Wheels framework development problems.

## Common Issues and Solutions

### 1. Controller Issues

#### Issue: "Controller not found" error
```
Error: Could not find the controller "Posts"
```

**Possible Causes & Solutions:**
1. **File naming mismatch**
   - Check: Controller file should be `/app/controllers/Posts.cfc`
   - Fix: Ensure filename matches controller name exactly (case-sensitive on Linux/Mac)

2. **Incorrect extends**
   - Check: `component extends="Controller"`
   - Fix: Must extend "Controller" not "wheels.Controller"

3. **Routing issue**
   - Check: Routes in `/config/routes.cfm`
   - Fix: Add proper route: `mapper().resources("posts").end()`

#### Issue: "View not found" error
```
Error: Could not find the view "posts/index.cfm"
```

**Solutions:**
1. Create view file at `/app/views/posts/index.cfm`
2. Or use `renderWith()` for JSON/XML responses
3. Or explicitly render different view: `renderView("shared/list")`

#### Issue: Filters not executing
```cfml
// Filter not running
function config() {
  filters("authenticate");
}
```

**Solutions:**
1. Check filter method exists in controller
2. Ensure no typos in filter name
3. Check if action is excluded: `filters("authenticate", except="index,show")`
4. Verify filter returns true/false or performs action

### 2. Model Issues

#### Issue: "Table not found" error
```
Error: Table "users" doesn't exist in database
```

**Solutions:**
1. Run migrations: `wheels dbmigrate latest`
2. Check table name: `table("custom_table_name")` in model config()
3. Verify datasource configuration in `/config/app.cfm`
4. Check database connection settings

#### Issue: Validations not working
```cfml
// Validation not triggering
validatesPresenceOf("email");
```

**Solutions:**
1. Ensure validation is in `config()` method
2. Call `valid()` or save-related methods to trigger
3. Check property name matches database column
4. Use `errorsOn("email")` to see specific errors

#### Issue: Associations not loading
```cfml
// Related data not included
user = model("User").findOne();
// user.posts is undefined
```

**Solutions:**
1. Use include parameter: `findOne(include="posts")`
2. Check association defined in model: `hasMany("posts")`
3. Verify foreign key convention: `userId` in posts table
4. Or specify custom key: `hasMany(name="posts", foreignKey="authorId")`

### 3. Routing Issues

#### Issue: "Route not found" error
```
Error: Could not find a route that matches this request
```

**Solutions:**
1. Check route definition in `/config/routes.cfm`
2. Verify HTTP method matches route (GET, POST, etc.)
3. Use `wheels routes` command to list all routes
4. Check route parameter patterns match request

#### Issue: RESTful routes not working
```cfml
mapper().resources("posts").end();
// POST to /posts not working
```

**Solutions:**
1. Ensure controller has standard action names (index, show, new, create, edit, update, delete)
2. Check form method: `method="post"` for create
3. Verify CSRF token if protection enabled
4. Use correct route helpers: `route="posts"` for index, `route="post"` for show

### 4. View/Form Issues

#### Issue: Form not submitting data
```cfm
#startFormTag(route="posts")#
  #textField(objectName="post", property="title")#
#endFormTag()#
```

**Solutions:**
1. Check params structure: `params.post.title`
2. Ensure objectName matches param key
3. Add method for non-GET: `method="post"`
4. Check for JavaScript errors blocking submission

#### Issue: Select box not showing options
```cfm
#select(objectName="user", property="roleId", options=roles)#
```

**Solutions:**
1. Ensure `roles` variable exists in view
2. Check options format: query or array of structs
3. Specify value/text columns: `valueField="id", textField="name"`
4. Use `includeBlank` for empty option

### 5. Database/Migration Issues

#### Issue: Migration failing
```
Error: Error running migration 001_create_users.cfc
```

**Solutions:**
1. Wrap migration in transaction block
2. Check SQL syntax for your database type
3. Verify column types supported by database
4. Look for typos in table/column names
5. Run with `--verbose` flag for details

#### Issue: H2 database issues
```
Error: Column "ID" not found
```

**Solutions:**
1. H2 is case-sensitive, use lowercase: `id` not `ID`
2. Set mode in connection string: `MODE=MySQL`
3. Use standard SQL types: `VARCHAR` not `STRING`
4. Check H2 console at `/h2-console` for debugging

### 6. Testing Issues

#### Issue: Tests not running
```
Error: Test file not found
```

**Solutions:**
1. Place tests in `/tests/` directory
2. Extend proper base class: `wheels.test` or TestBox specs
3. Name test methods starting with "test"
4. Run specific test: `wheels test app testName`

#### Issue: Test data persisting
```cfml
// Data from previous test affecting current test
```

**Solutions:**
1. Tests automatically run in transactions
2. Use `setup()` and `teardown()` methods
3. Create fresh test data for each test
4. Don't rely on test execution order

### 7. CLI Issues

#### Issue: CLI command not found
```
Error: Command "wheels generate model" not found
```

**Solutions:**
1. Install CLI: `install wheels-cli`
2. Reload CommandBox: `reload` or restart
3. Check you're in project root directory
4. Use correct syntax: named parameters

#### Issue: Generated code not working
```
Error after running: wheels g resource posts
```

**Solutions:**
1. Run migrations after generating: `wheels dbmigrate latest`
2. Reload application: `wheels reload`
3. Check generated files for syntax errors
4. Ensure database connection configured

### 8. Performance Issues

#### Issue: Slow page loads
**Solutions:**
1. Enable query caching: `findAll(cache=true)`
2. Use select to limit columns: `select="id,name"`
3. Add database indexes on foreign keys
4. Check for N+1 queries, use `include`
5. Enable view caching in production

#### Issue: Memory issues
**Solutions:**
1. Use pagination: `findAll(page=1, perPage=25)`
2. Don't load unnecessary associations
3. Clear query cache if needed
4. Check for circular references in models

### 9. Environment Issues

#### Issue: Wrong environment loading
**Solutions:**
1. Check `/config/environment.cfm`
2. Set URL variable: `?reload=true&environment=development`
3. Verify environment-specific settings in `/config/[env]/settings.cfm`
4. Check server configuration

#### Issue: Configuration not updating
**Solutions:**
1. Reload application: `?reload=true&password=[your-password]`
2. Clear template cache in CFML admin
3. Restart application server
4. Check for syntax errors in config files

### 10. Common Error Messages

#### "Variable X is undefined"
1. Check variable scoping: use `local.` prefix
2. Ensure variable set before use
3. Use `StructKeyExists()` to check
4. Initialize variables in `config()`

#### "Invalid CFML construct"
1. Check for missing semicolons in CFScript
2. Verify bracket/parenthesis matching
3. Ensure quotes are closed
4. Look for reserved word usage

#### "The required parameter X was not provided"
1. Check method signature matches call
2. Provide all required parameters
3. Use argumentCollection for dynamic args
4. Check for typos in parameter names

## Debugging Tools & Techniques

### 1. Enable Debug Output
```cfml
// In /config/development/settings.cfm
set(showDebugInformation=true);
```

### 2. Dump Variables
```cfml
writeDump(var=params, abort=true);
// Or in views
<cfdump var="#posts#" abort="true">
```

### 3. Check SQL Queries
```cfml
// See generated SQL
result = model("Post").findAll(returnAs="query");
writeDump(result.getResult().getSQL());
```

### 4. Log Custom Messages
```cfml
$log(message="Debug info", data=params);
// Check logs in CFML admin
```

### 5. Use Browser DevTools
- Check Network tab for requests
- Look for JavaScript errors in Console
- Verify form data being sent
- Check response headers

## Prevention Tips

1. **Always use transactions in migrations**
2. **Check for object existence before using**
3. **Use proper scoping (local, variables, this)**
4. **Follow naming conventions consistently**
5. **Test on multiple CFML engines**
6. **Use version control for rollbacks**
7. **Keep error messages for debugging**
8. **Document non-standard configurations**

## Getting Help

When issues persist:
1. Check Wheels documentation
2. Search GitHub issues
3. Ask in community forums
4. Provide minimal reproduction case
5. Include error messages and stack traces
6. Mention Wheels version and CFML engine