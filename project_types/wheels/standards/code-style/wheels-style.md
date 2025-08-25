# Wheels Framework Style Guide

## Purpose
This guide defines standards for building applications with the Wheels.dev framework, covering MVC patterns, conventions, and best practices specific to Wheels development.

## Framework Philosophy
- Convention over configuration
- RESTful by default
- Database-driven development
- Rapid prototyping with production-ready code

## Directory Structure (Wheels 3.0)

### Standard Wheels 3.0 Layout
```
/
├── app/                          # Main application directory
│   ├── controllers/              # MVC Controllers
│   │   └── Controller.cfc        # Base controller with CSRF protection
│   ├── models/                   # MVC Models
│   │   └── Model.cfc             # Base model
│   ├── views/                    # MVC Views
│   │   ├── layout.cfm            # Main layout template
│   │   └── helpers.cfm           # View helper functions
│   ├── events/                   # Application event handlers
│   │   ├── onerror/              # Error handling views
│   │   └── onmaintenance/        # Maintenance mode views
│   ├── jobs/                     # Background job classes (NEW)
│   │   └── ProcessOrdersJob.cfc  # Example job implementation
│   ├── mailers/                  # Email handling classes (NEW)
│   │   └── UserNotificationsMailer.cfc
│   ├── global/                   # Global functions and utilities
│   ├── lib/                      # Custom libraries
│   ├── migrator/                 # Database migration system
│   │   └── migrations/           # Migration files
│   ├── plugins/                  # Wheels plugins
│   └── snippets/                 # Code generation templates (NEW)
│       ├── crud/                 # CRUD view templates
│       ├── dbmigrate/            # Migration templates
│       └── tests/                # Test templates
├── config/                       # Configuration files
│   ├── app.cfm                   # Application-level config, what would normally go into Application.cfc
│   ├── settings.cfm              # Framework settings
│   ├── routes.cfm                # URL routing configuration
│   ├── environment.cfm           # Environment detection
│   └── [environment]/            # Environment-specific configs
│       └── settings.cfm          # Override settings per environment
├── public/                       # Web-accessible directory
│   ├── Application.cfc           # Advanced Application.cfc
│   ├── index.cfm                 # Entry point
│   ├── files/                    # User uploads
│   ├── images/                   # Static images
│   ├── javascripts/              # JavaScript files
│   ├── stylesheets/              # CSS files
│   └── urlrewrite.xml            # URL rewriting rules
├── tests/                        # TestBox test suite
│   ├── Application.cfc           
│   ├── index.cfm                 
│   └── specs/                    # Test specifications
├── vendor/                       # Dependencies (managed by box.json)
├── db/                          # Database files (H2 default)
├── .env                         # Environment variables
├── box.json                     # CommandBox package config
└── server.json                  # Server configuration
```

## Controllers

### Authentication vs Parameter Verification

**IMPORTANT:** Use the correct function for each purpose:

#### filters() - For Authentication and Pre-action Logic
Use `filters()` to run functions before controller actions, such as authentication checks:

```cfscript
function config() {
    // CORRECT - Use filters() for authentication
    filters(through="requireLogin");
    filters(except="index,show", through="requireLogin");
    filters(only="edit,update,delete", through="requireLogin");
    
    // Filters can chain multiple functions
    filters(through="requireLogin,loadUserData,checkPermissions");
}

private function requireLogin() {
    if (!structKeyExists(session, "user") || !isObject(session.user)) {
        flashInsert(error="Please log in to continue.");
        redirectTo(controller="sessions", action="new");
    }
}
```

#### verifies() - For Parameter Validation
Use `verifies()` ONLY to check if required parameters exist in the request:

```cfscript
function config() {
    // CORRECT - Use verifies() to check parameters exist
    verifies(except="index,new,create", params="key", handler="objectNotFound");
    verifies(only="update", params="user", handler="missingParams");
    
    // WRONG - Do NOT use verifies() for authentication
    // verifies(params="authenticatedUser", handler="requireLogin"); // INCORRECT!
}

private function objectNotFound() {
    flashInsert(error="Record not found.");
    redirectTo(action="index");
}
```

#### Common Mistake to Avoid
```cfscript
// WRONG - This will cause authentication to fail
function config() {
    verifies(params="authenticatedUser", handler="requireLogin");
}

// CORRECT - Use filters() for authentication
function config() {
    filters(through="requireLogin");
}
```

### Model Property Initialization
When creating new model instances in controller actions, always initialize properties to avoid "no accessible Member" errors in views:

```cfscript
// CORRECT - Initialize properties when creating new instances
public function new() {
    user = model("User").new({
        firstName: "",
        lastName: "",
        email: "",
        password: ""
    });
}

// WRONG - Will cause errors when accessing properties in views
public function new() {
    user = model("User").new();  // ERROR: Properties not accessible in view
}

// For edit actions, properties are already populated from database
public function edit() {
    user = model("User").findByKey(params.key);  // Properties already exist
}
```

This is required because CFWheels models don't automatically create accessible properties for new instances unless they're explicitly initialized or loaded from the database.

### Basic Controller Structure (Wheels 3.0)
```cfscript
component extends="Controller" {
    
    function config() {
        // CSRF protection (enabled by default in base Controller.cfc)
        protectsFromForgery();
        
        // Filters run before actions - USE filters() for authentication checks
        filters(through="authenticate", except="index,show");
        filters(through="findUser", only="show,edit,update,delete");
        
        // Parameter verification - USE verifies() ONLY for parameter checking
        verifies(except="index,new,create", params="key", paramsTypes="integer", handler="objectNotFound");
        
        // Response formats
        provides("html,json,xml");
    }
    
    // RESTful actions
    function index() {
        users = model("User").findAll(
            order="createdAt DESC",
            page=params.page ?: 1,
            perPage=25
        );
    }
    
    function show() {
        // User already set by findUser filter
    }
    
    function new() {
        user = model("User").new();
    }
    
    function create() {
        user = model("User").create(params.user);
        
        if (user.hasErrors()) {
            renderView(action="new");
        } else {
            flashInsert(success="User created successfully!");
            redirectTo(route="user", key=user.id);
        }
    }
    
    function edit() {
        // User already set by findUser filter
    }
    
    function update() {
        if (user.update(params.user)) {
            flashInsert(success="User updated successfully!");
            redirectTo(route="user", key=user.id);
        } else {
            renderView(action="edit");
        }
    }
    
    function delete() {
        if (user.delete()) {
            flashInsert(success="User deleted successfully!");
            redirectTo(route="users");
        } else {
            flashInsert(error="Could not delete user.");
            redirectTo(back=true);
        }
    }
    
    // Private filter methods
    private function authenticate() {
        if (!isLoggedIn()) {
            flashInsert(warning="Please log in to continue.");
            redirectTo(controller="sessions", action="new");
        }
    }
    
    private function findUser() {
        user = model("User").findByKey(params.key);
        
        if (!isObject(user)) {
            flashInsert(error="User not found.");
            redirectTo(route="users");
        }
    }
}
```

### Nested Resources Controller
```cfscript
component extends="Controller" {
    
    function config() {
        filters(through="findPost");
    }
    
    function index() {
        comments = post.comments(order="createdAt DESC");
    }
    
    function new() {
        // Initialize with empty properties for nested resource
        comment = post.newComment({
            content: "",
            authorName: "",
            authorEmail: ""
        });
    }
    
    function create() {
        comment = post.createComment(params.comment);
        
        if (comment.hasErrors()) {
            renderView(action="new");
        } else {
            flashInsert(success="Comment added!");
            redirectTo(route="post", key=post.id);
        }
    }
    
    private function findPost() {
        post = model("Post").findByKey(params.postKey);
        
        if (!isObject(post)) {
            flashInsert(error="Post not found.");
            redirectTo(route="posts");
        }
    }
}
```

### Common Model Initialization Patterns
```cfscript
component extends="Controller" {
    
    // Pattern 1: Simple initialization with all properties
    function new() {
        product = model("Product").new({
            name: "",
            description: "",
            price: 0,
            inStock: true,
            categoryId: ""
        });
        categories = model("Category").findAll();
    }
    
    // Pattern 2: Initialize with default values
    function new() {
        event = model("Event").new({
            title: "",
            description: "",
            startDate: now(),
            endDate: dateAdd("h", 1, now()),
            isPublic: true,
            maxAttendees: 100
        });
    }
    
    // Pattern 3: Initialize from query params with defaults
    function new() {
        // Use params if available, otherwise use defaults
        user = model("User").new({
            firstName: params.firstName ?: "",
            lastName: params.lastName ?: "",
            email: params.email ?: "",
            roleId: params.roleId ?: 1
        });
    }
    
    // Pattern 4: Clone existing record for duplication
    function duplicate() {
        originalProduct = model("Product").findByKey(params.key);
        
        // Create new instance with values from original
        product = model("Product").new({
            name: originalProduct.name & " (Copy)",
            description: originalProduct.description,
            price: originalProduct.price,
            categoryId: originalProduct.categoryId
        });
        
        renderView(action="new");
    }
}
```

## Models

### Basic Model Structure
```cfscript
component extends="Model" {
    
    function config() {
        // Table configuration
        table("users");
        
        // Associations
        hasMany("posts", dependent="destroy");
        hasMany("comments");
        belongsTo("role");
        hasOne("profile", dependent="destroy");
        
        // Validations
        validatesPresenceOf("email,firstName,lastName");
        validatesUniquenessOf("email");
        validatesFormatOf(property="email", regEx="^[^@]+@[^@]+\.[^@]+$");
        validatesLengthOf(property="password", minimum=8, allowBlank=true);
        validatesConfirmationOf("password");
        
        // IMPORTANT: When using named parameters, property must be explicitly named
        validatesNumericalityOf(property="age", greaterThanOrEqualTo=18);  // Correct
        // validatesNumericalityOf("age", greaterThanOrEqualTo=18);        // WRONG - will error
        
        // Callbacks
        beforeCreate("setDefaults,hashPassword");
        beforeUpdate("updateTimestamp");
        afterFind("decryptSensitiveData");
        
        // Properties
        property(name="fullName", sql="firstName + ' ' + lastName");
        
        // Nested properties
        nestedProperties(association="profile", allowDelete=true);
    }
    
    // Custom validations
    private function customValidation() {
        if (this.age < 18 && this.accountType == "premium") {
            addError(property="accountType", message="Premium accounts require age 18+");
        }
    }
    
    // Callback methods
    private function setDefaults() {
        if (!structKeyExists(this, "status")) {
            this.status = "pending";
        }
        this.createdAt = now();
    }
    
    private function hashPassword() {
        if (structKeyExists(this, "password") && len(this.password)) {
            this.passwordHash = hashPassword(this.password);
            structDelete(this, "password");
        }
    }
    
    // Instance methods
    public boolean function activate() {
        this.status = "active";
        this.activatedAt = now();
        return this.save(validate=false);
    }
    
    public boolean function isActive() {
        return this.status == "active";
    }
    
    // Class methods (scopes)
    public query function findActive() {
        return this.findAll(where="status='active'");
    }
    
    public query function findRecent(numeric days=7) {
        return this.findAll(
            where="createdAt >= :date",
            whereParameters={date=dateAdd("d", -arguments.days, now())}
        );
    }
}
```

### Authentication with BCrypt (Using authenticateThis Plugin)
```cfscript
// First install the plugin: box install cfwheels-authenticateThis

component extends="Model" {
    
    function config() {
        // Enable BCrypt authentication
        authenticateThis();  // Adds password hashing and authentication methods
        
        // Associations
        hasMany("posts");
        
        // Validations
        validatesPresenceOf("email");
        validatesUniquenessOf("email");
        validatesPresenceOf(property="password", when="onCreate");
        validatesLengthOf(property="password", minimum=8, when="onSave", 
            condition="structKeyExists(this, 'password') && len(this.password)");
    }
    
    // The plugin provides these methods automatically:
    // - hashPassword() - called automatically before save
    // - checkPassword(password) - verify password against hash
    // - resetPassword(newPassword) - update password
    // - generateRandomPassword() - create random password
    
    public function authenticate(required string password) {
        // Use the checkPassword method provided by authenticateThis
        return this.checkPassword(arguments.password);
    }
    
    public function updatePassword(required string newPassword) {
        // Set password property - authenticateThis handles hashing
        this.password = arguments.newPassword;
        return this.save();
    }
}
```

### Complex Model Patterns
```cfscript
component extends="Model" {
    
    function config() {
        // Composite primary key
        primaryKey("userId,roleId");
        
        // Soft deletes
        softDeletes(true);
        
        // Automatic timestamps
        timeStamps(true);
        
        // Property mappings
        property(name="isAdmin", sql="roleId = 1");
        property(name="displayName", sql="COALESCE(nickname, firstName)");
        
        // Calculated properties
        property(
            name="postCount",
            sql="(SELECT COUNT(*) FROM posts WHERE posts.userId = users.id)"
        );
    }
    
    // Scope methods for common queries
    public function scopeActive(required query query) {
        return arguments.query.where("status = :status AND deletedAt IS NULL", {
            status="active"
        });
    }
    
    public function scopeWithPosts(required query query) {
        return arguments.query.include("posts");
    }
    
    // Chainable scopes
    public query function findActiveWithPosts() {
        return this.findAll().active().withPosts().orderBy("createdAt DESC");
    }
}
```

## Views

### Query vs Array Handling in Views

**IMPORTANT:** CFWheels `findAll()` returns a Query object by default, not an Array. Views must handle queries properly:

```cfml
<!-- CORRECT - Using query in views -->
<cfif qrcodes.recordCount>
    <cfloop query="qrcodes">
        <div>#qrcodes.title#</div>
        <div>#qrcodes.description#</div>
    </cfloop>
<cfelse>
    <p>No records found</p>
</cfif>

<!-- WRONG - Treating query as array -->
<cfif arrayLen(qrcodes)>  <!-- ERROR: Can't cast Query to Array -->
    <cfloop array="#qrcodes#" index="qrcode">  <!-- ERROR -->
        <div>#qrcode.title#</div>
    </cfloop>
</cfif>
```

#### Key Differences:
- **Query**: Use `.recordCount` to check for records, `<cfloop query="queryName">`
- **Array**: Use `arrayLen()` to check length, `<cfloop array="#arrayName#" index="item">`
- In query loops, reference columns directly with the query name (e.g., `qrcodes.title`)
- In array loops, use the index variable (e.g., `qrcode.title`)

#### Converting Query to Array (if needed):
```cfscript
// In controller, if you need an array:
qrcodes = model("QRCode").findAll().toArray();  // Converts query to array

// Or use returnAs parameter:
qrcodes = model("QRCode").findAll(returnAs="array");
```

### Layout Structure
```cfml
<!--- /views/layout.cfm --->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>#contentFor("title")# - MyApp</title>
    #styleSheetLinkTag("application")#
    #contentFor("head")#
</head>
<body>
    <header>
        <nav>
            #linkTo(text="Home", route="root")#
            #linkTo(text="Users", route="users")#
            <cfif isLoggedIn()>
                #linkTo(text="Profile", route="profile")#
                #linkTo(text="Logout", route="logout", method="delete")#
            <cfelse>
                #linkTo(text="Login", route="login")#
            </cfif>
        </nav>
    </header>
    
    <main>
        <cfif flashKeyExists("success")>
            <div class="alert alert-success">
                #flash("success")#
            </div>
        </cfif>
        
        <cfif flashKeyExists("error")>
            <div class="alert alert-error">
                #flash("error")#
            </div>
        </cfif>
        
        #includeContent()#
    </main>
    
    <footer>
        #contentFor("footer")#
    </footer>
    
    #javaScriptIncludeTag("application")#
    #contentFor("scripts")#
</body>
</html>
```

### View Templates
```cfml
<!--- /views/users/index.cfm --->
<cfoutput>

#contentFor(title="Users")#

<h1>Users</h1>

#linkTo(text="New User", route="newUser", class="btn btn-primary")#

<table class="table">
    <thead>
        <tr>
            <th>Name</th>
            <th>Email</th>
            <th>Status</th>
            <th>Actions</th>
        </tr>
    </thead>
    <tbody>
        <cfloop array="#users.data#" index="user">
            <tr>
                <td>#linkTo(text=user.fullName, route="user", key=user.id)#</td>
                <td>#user.email#</td>
                <td>
                    <span class="badge badge-#user.status#">
                        #user.status#
                    </span>
                </td>
                <td>
                    #linkTo(text="Edit", route="editUser", key=user.id, class="btn btn-sm")#
                    #linkTo(
                        text="Delete",
                        route="user",
                        key=user.id,
                        method="delete",
                        confirm="Are you sure?",
                        class="btn btn-sm btn-danger"
                    )#
                </td>
            </tr>
        </cfloop>
    </tbody>
</table>

#paginationLinks(route="users", windowSize=5)#

</cfoutput>
```

### Form Helpers
```cfml
<!--- /views/users/_form.cfm --->
<cfoutput>

#errorMessagesFor("user")#

#startFormTag(route=formRoute, key=user.id)#
    
    #textField(
        objectName="user",
        property="firstName",
        label="First Name",
        required=true,
        class="form-control"
    )#
    
    #textField(
        objectName="user",
        property="lastName",
        label="Last Name",
        required=true,
        class="form-control"
    )#
    
    #textField(
        objectName="user",
        property="email",
        label="Email",
        type="email",
        required=true,
        class="form-control"
    )#
    
    #select(
        objectName="user",
        property="roleId",
        options=roles,
        label="Role",
        includeBlank="Select a role",
        class="form-control"
    )#
    
    #checkBox(
        objectName="user",
        property="isActive",
        label="Active",
        checkedValue=1,
        uncheckedValue=0
    )#
    
    #dateSelect(
        objectName="user",
        property="birthDate",
        label="Birth Date",
        startYear=1900,
        endYear=year(now()),
        includeBlank=true
    )#
    
    <div class="form-group">
        #submitTag(value="Save User", class="btn btn-primary")#
        #linkTo(text="Cancel", route="users", class="btn btn-secondary")#
    </div>
    
#endFormTag()#

</cfoutput>
```

## Routes Configuration

### RESTful Routes
```cfscript
// config/routes.cfm
mapper()
    // Root route
    .root(to="pages##home")
    
    // RESTful resources
    .resources("users")
    .resources("posts") do
        .resources("comments", only="index,create,destroy")
    end
    
    // Namespaced routes
    .namespace("admin") do
        .resources("users")
        .resources("settings", only="index,update")
    end
    
    // Custom routes
    .get(name="login", to="sessions##new")
    .post(name="sessions", to="sessions##create")
    .delete(name="logout", to="sessions##destroy")
    
    // Member routes
    .get(name="activateUser", pattern="users/[key]/activate", to="users##activate")
    
    // Collection routes
    .get(name="activeUsers", pattern="users/active", to="users##active")
    
    // Wildcards
    .wildcard()
.end();
```

## Background Jobs (NEW in Wheels 3.0)

### Job Implementation
```cfscript
component extends="wheels.Job" {
    
    // Job configuration properties
    property name="queue" default="default";
    property name="priority" default="normal";
    property name="retries" default="3";
    property name="timeout" default="300"; // seconds
    
    function perform(struct data = {}) {
        // Job logic here
        try {
            // Process the job
            var orders = model("Order").findAll(where="status='pending'");
            
            for (var order in orders) {
                processOrder(order);
                logProgress("Processed order #order.id#");
            }
            
            return {
                success: true,
                processedCount: arrayLen(orders)
            };
            
        } catch (any e) {
            // Error handling with retry logic
            logError("Job failed: #e.message#");
            
            if (this.retries > 0) {
                this.retries--;
                throw e; // Will trigger retry
            }
            
            return {
                success: false,
                error: e.message
            };
        }
    }
    
    private function processOrder(required struct order) {
        // Business logic
        order.status = "processed";
        order.save();
    }
}
```

### Scheduling Jobs
```cfscript
// In controller or service
job = new app.jobs.ProcessOrdersJob();
job.schedule(data={batchId: 123}, runAt=dateAdd("n", 5, now()));

// Or enqueue immediately
job.enqueue(data={orderId: 456});
```

## Mailers (NEW in Wheels 3.0)

### Mailer Implementation
```cfscript
component extends="wheels.Mailer" {
    
    function sendWelcomeEmail(required string userEmail, required string userName) {
        // Configure email
        to(arguments.userEmail);
        from("noreply@example.com");
        subject("Welcome to Our Application!");
        
        // Set template variables
        set(userName=arguments.userName);
        set(activationLink=generateActivationLink(arguments.userEmail));
        
        // Use template (looks for /views/mailers/usernotifications/sendWelcomeEmail.cfm)
        template("/mailers/usernotifications/sendWelcomeEmail");
        
        // Send email
        return deliver();
    }
    
    function sendPasswordReset(required struct user, required string resetToken) {
        to(user.email);
        from("support@example.com");
        subject("Password Reset Request");
        
        // Pass data to template
        set(user=user);
        set(resetLink=buildResetLink(resetToken));
        set(expiresIn="24 hours");
        
        template("/mailers/usernotifications/sendPasswordReset");
        
        // Optional: attach files
        attachment(filePath="/path/to/instructions.pdf");
        
        return deliver();
    }
}
```

### Using Mailers in Controllers
```cfscript
// In controller action
function create() {
    user = model("User").create(params.user);
    
    if (!user.hasErrors()) {
        // Send welcome email
        mailer = new app.mailers.UserNotificationsMailer();
        mailer.sendWelcomeEmail(user.email, user.firstName);
        
        flashInsert(success="Account created! Check your email.");
        redirectTo(route="login");
    } else {
        renderView(action="new");
    }
}
```

## API Controllers (Enhanced in Wheels 3.0)

### Modern API Pattern
```cfscript
component extends="wheels.Controller" {
    
    function init() {
        // API-specific configuration
        provides("json");
        filters(through="setJsonResponse");
        filters(through="requireApiKey", except="");
    }
    
    // RESTful JSON endpoints
    function index() {
        local.users = model("User").findAll(
            select="id,firstName,lastName,email,createdAt",
            order="createdAt DESC",
            page=params.page ?: 1,
            perPage=params.perPage ?: 25
        );
        
        renderWith(data={
            users: local.users.data,
            pagination: {
                currentPage: local.users.currentPage,
                totalPages: local.users.totalPages,
                totalRecords: local.users.recordCount
            }
        });
    }
    
    function show() {
        local.user = model("User").findByKey(params.key);
        
        if (!isObject(local.user)) {
            renderWith(data={error: "User not found"}, status=404);
        } else {
            renderWith(data={user: local.user});
        }
    }
    
    function create() {
        local.user = model("User").create(params.user);
        
        if (local.user.hasErrors()) {
            renderWith(data={
                errors: local.user.allErrors(),
                message: "Validation failed"
            }, status=422);
        } else {
            renderWith(data={
                user: local.user,
                message: "User created successfully"
            }, status=201);
        }
    }
    
    // Private filter methods
    private function setJsonResponse() {
        params.format = "json";
        response.setContentType("application/json");
    }
    
    private function requireApiKey() {
        if (!structKeyExists(request.headers, "X-API-Key") || 
            request.headers["X-API-Key"] != application.apiKey) {
            renderWith(data={error: "Invalid API key"}, status=401);
            return false;
        }
    }
}
```

## Testing

### Model Tests (TestBox)
```cfscript
component extends="wheels.Test" {
    
    function setup() {
        super.setup();
        user = model("User").new();
    }
    
    function test_validates_presence_of_email() {
        user.firstName = "John";
        user.lastName = "Doe";
        
        assert(!user.valid());
        assert(arrayLen(user.errors()) > 0);
        assert(structKeyExists(user.errors(), "email"));
    }
    
    function test_creates_user_with_valid_data() {
        user.firstName = "John";
        user.lastName = "Doe";
        user.email = "john@example.com";
        user.password = "securepass123";
        user.passwordConfirmation = "securepass123";
        
        assert(user.save());
        assert(user.id > 0);
    }
}
```

### Controller Tests
```cfscript
component extends="wheels.Test" {
    
    function test_index_returns_users() {
        result = processRequest(route="users", returnAs="struct");
        
        assert(result.status == 200);
        assert(structKeyExists(result.variables, "users"));
    }
    
    function test_create_redirects_on_success() {
        params = {
            user: {
                firstName: "Jane",
                lastName: "Smith",
                email: "jane@example.com"
            }
        };
        
        result = processRequest(
            route="users",
            method="POST",
            params=params,
            returnAs="struct"
        );
        
        assert(result.status == 302);
        assert(findNoCase("User created", result.flash.success));
    }
}
```

## Best Practices

### Database Migrations (Wheels 3.0)

#### Migration Structure
```cfscript
// app/migrator/migrations/001_create_users_table.cfc
component extends="wheels.migrator.Migration" hint="create users table" {
    
    function up() {
        transaction {
            t = createTable("users");
            t.string(columnNames="firstName,lastName", limit=100, null=false);
            t.string(columnNames="email", limit=255, null=false);
            t.string(columnNames="passwordHash", limit=60, null=false);  // BCrypt hash length
            t.integer(columnNames="roleId", null=true);
            t.boolean(columnNames="isActive", default=true);
            t.timestamps();
            t.create();
            
            // Always use named indexes for better database management
            addIndex(table="users", columnNames="email", unique=true, indexName="idx_users_email_unique");
            addIndex(table="users", columnNames="roleId", indexName="idx_users_role_id");
        }
    }
    
    function down() {
        transaction {
            // Remove indexes by name
            removeIndex(table="users", indexName="idx_users_role_id");
            removeIndex(table="users", indexName="idx_users_email_unique");
            dropTable("users");
        }
    }
}
```

#### Migration Best Practices  

1. **Script-Based Syntax in Migrations**:
   Wheels migrations support both tag-based and script-based syntax. Script-based is preferred:
   ```cfscript
   // CORRECT - Script-based syntax in migrations
   component extends="wheels.migrator.Migration" {
       function up() {
           transaction {
               try {
                   // migration code
               } catch (any e) {
                   local.exception = e;
               }
               
               if (StructKeyExists(local, "exception")) {
                   transaction action="rollback";
                   Throw(...);
               } else {
                   transaction action="commit";
               }
           }
       }
   }
   ```

2. **Password Hash Field Sizing**:
   - SHA-256 hashes require VARCHAR(64): `t.string(columnNames="password_hash", limit=64)`
   - BCrypt hashes require VARCHAR(60): `t.string(columnNames="password_hash", limit=60)`

3. **Index Naming Convention**:
   - Format: `idx_[table_name]_[column_name(s)]`
   - Unique indexes: Add `_unique` suffix
   - Examples:
     ```cfscript
     // Regular index
     addIndex(table="posts", columnNames="userId", indexName="idx_posts_user_id");
     
     // Unique index
     addIndex(table="users", columnNames="email", unique=true, indexName="idx_users_email_unique");
     
     // Composite index
     addIndex(table="user_roles", columnNames="userId,roleId", indexName="idx_user_roles_user_id_role_id");
     ```

2. **Column Type Considerations**:
   - Use `string` instead of `char` (CFWheels doesn't have a char method)
   - For BCrypt password hashes: `t.string(columnNames="passwordHash", limit=60, null=false)`
   - For UUIDs: `t.string(columnNames="uuid", limit=36)`
   - For timestamps: Use `t.timestamps()` for automatic createdAt/updatedAt

3. **Foreign Key References**:
   ```cfscript
   // Creating foreign key columns
   t.integer(columnNames="userId", null=false);
   t.integer(columnNames="postId", null=false);
   
   // Add indexes for foreign keys
   addIndex(table="comments", columnNames="userId", indexName="idx_comments_user_id");
   addIndex(table="comments", columnNames="postId", indexName="idx_comments_post_id");
   ```

4. **Removing Indexes in down() Method**:
   ```cfscript
   function down() {
       transaction {
           // Always remove indexes by name, not by column
           removeIndex(table="users", indexName="idx_users_email_unique");
           removeIndex(table="users", indexName="idx_users_role_id");
           
           // Then drop the table
           dropTable("users");
       }
   }
   ```

5. **Wheels Timestamp Field Conventions**:
   CFWheels uses specific naming conventions for timestamp fields (no underscores):
   - `createdat` (not created_at or createdAt)
   - `updatedat` (not updated_at or updatedAt)  
   - `deletedat` (not deleted_at or deletedAt)
   
   These are automatically managed when using `t.timestamps()` in migrations.

6. **Migration File Naming**:
   - Use sequential numbering: `001_`, `002_`, `003_`
   - Descriptive names: `001_create_users_table.cfc`, `002_add_email_to_users.cfc`
   - Always include hint attribute: `component extends="wheels.migrator.Migration" hint="create users table"`

### Configuration Management
```cfscript
// config/settings.cfm
// Environment-specific settings
switch(get("environment")) {
    case "development":
        set(dataSourceName="myapp_dev");
        set(reloadPassword="development");
        set(showDebugInformation=true);
        break;
        
    case "production":
        set(dataSourceName="myapp_prod");
        set(reloadPassword=getSystemSetting("RELOAD_PASSWORD"));
        set(showDebugInformation=false);
        set(cacheQueries=true);
        break;
}

// Common settings
set(URLRewriting="partial");
set(softDeleteProperty="deletedAt");
set(timeStampOnCreate="createdAt");
set(timeStampOnUpdate="updatedAt");
```

## Integration with Other Style Guides

### Using CFML Tag Style (cfml-style.md)
- Views follow tag-based markup patterns from cfml-style.md
- Use Wheels helpers where possible, fall back to standard CFML tags
- Maintain consistent indentation and formatting

### Using CFC Script Style (cfc-style.md)
- Controllers and models follow script-based patterns from cfc-style.md
- Extend Wheels base classes while maintaining clean script syntax
- Use proper scoping and type hints

### Framework-Specific Conventions
- Prefer Wheels helpers over raw CFML in views
- Use Wheels validations instead of custom validation logic
- Leverage Wheels callbacks instead of manual hook implementation
- Follow RESTful naming conventions for actions and routes

## CLI Commands (Wheels 3.0)

### Code Generation
```bash
# Generate model with attributes
wheels g model User name:string,email:string:index,active:boolean

# Generate controller with actions
wheels g controller Users index,show,new,create,edit,update,delete

# Generate full scaffold (model + controller + views)
wheels g scaffold Product name:string,price:decimal,inStock:boolean

# Generate API controller
wheels g controller api/Users --api

# Generate migration
wheels g migration CreateUsersTable
wheels g migration AddEmailToUsers
wheels g migration RemovePasswordFromUsers

# Generate mailer
wheels g mailer UserNotifications welcome,passwordReset

# Generate job
wheels g job ProcessOrders --queue=high
```

### Database Management
```bash
# Run migrations
wheels dbmigrate latest

# Rollback last migration
wheels dbmigrate down

# Reset database
wheels db reset --force

# Database console
wheels db shell
wheels db shell --web  # H2 web console

# Check migration status
wheels db status
```

### Testing
```bash
# Run all tests
wheels test run
box testbox run

# Run specific test  
box testbox run --directory=tests/Testbox/specs

# Run tests for specific spec file
box testbox run --testBundles=tests.Testbox.specs.models.User

# Watch mode for TDD
box testbox watch
```

## TestBox Integration

### Test Location for Wheels Projects
Tests should be placed in `/tests/Testbox/specs/` directory:
```
/tests/
├── Testbox/
│   └── specs/
│       ├── models/
│       │   └── User.cfc
│       ├── controllers/
│       └── integration/
```

### TestBox Spec Structure (Non-Nested Describes)
**IMPORTANT:** TestBox does not support nested `describe()` blocks. Use multiple describe blocks at the same level:

```cfscript
// CORRECT - Multiple describe blocks at same level
component extends="testbox.system.BaseSpec" {
    
    function run() {
        // Shared setup/teardown
        beforeEach(() => {
            // Reset test state
        });
        
        afterEach(() => {
            // Clean up
        });
        
        describe("User Model - Table Structure", () => {
            it("should have users table", () => {
                // test code
            });
        });
        
        describe("User Model - Validations", () => {
            it("should require email", () => {
                // test code  
            });
        });
        
        describe("User Model - Authentication", () => {
            it("should authenticate valid credentials", () => {
                // test code
            });
        });
    }
}

// WRONG - Nested describe blocks will fail
component extends="testbox.system.BaseSpec" {
    function run() {
        describe("User Model", () => {
            describe("Validations", () => {  // ERROR: Cannot nest describes
                it("should validate email", () => {});
            });
        });
    }
}
```

## Code Generation Templates (Wheels 3.0)

### Template Location
Templates are stored in `/app/snippets/` and used by the CLI generators:
- `ControllerContent.txt` - Basic controller template
- `ModelContent.txt` - Basic model template
- `ApiControllerContent.txt` - API controller with JSON responses
- `CRUDContent.txt` - Full CRUD controller
- `crud/*.txt` - CRUD view templates
- `dbmigrate/*.txt` - Migration templates
- `tests/*.txt` - Test templates

### Customizing Templates
You can customize code generation by modifying templates in `/app/snippets/`:

```cfscript
// Example: Custom controller template
// /app/snippets/ControllerContent.txt
component extends="Controller" {
    
    function config() {
        // Your custom defaults
        protectsFromForgery();
        filters(through="logRequest");
    }
    
    // {{methods}} placeholder for generated actions
}
```

## Critical Best Practices (From Production Experience)

### HTML Output Security
```cfml
<!-- ALWAYS escape output with e() unless using specific formatters -->
#e(user.firstName)#              <!-- Correct: escaped output -->
#numberFormat(price, "0.00")#    <!-- Correct: formatted output -->
#dateFormat(createdAt, "mm/dd")# <!-- Correct: formatted output -->
#yesNoFormat(isActive)#          <!-- Correct: formatted output -->
#user.firstName#                  <!-- WRONG: unescaped, vulnerable to XSS -->
```

### URL and Parameter Encoding
```cfml
<!-- Always encode URL parameters -->
#linkTo(text="View", action="show", params="search=#encodeForUrl(params.search)#")#

<!-- Or use the helper that auto-encodes -->
#linkTo(text="View", action="show", params=structToParams({search: params.search}))#
```

### Navigation Best Practices
```cfml
<!-- Links: use linkTo() for complete links -->
#linkTo(text="Edit User", route="editUser", key=user.id)#

<!-- For <a> tags, use urlFor() in href, NOT linkTo() -->
<a href="#urlFor(route='editUser', key=user.id)#" class="btn">Edit</a>  <!-- Correct -->
<a href="#linkTo(route='editUser', key=user.id)#">Edit</a>              <!-- WRONG -->

<!-- Forms: use startFormTag() or urlFor() in action -->
#startFormTag(action="update", key=user.id)#                           <!-- Correct -->
<form action="#urlFor(action='update', key=user.id)#" method="post">   <!-- Correct -->
<form action="#linkTo(action='update', key=user.id)#" method="post">   <!-- WRONG -->
```

### Flash Messages and Redirects
```cfml
<!-- Preferred: pass flash as redirect parameter -->
redirectTo(action="index", success="User created successfully");

<!-- NOT recommended: separate flash and redirect -->
flashInsert(success="User created successfully");
redirectTo(action="index");
```

### Required Field Indicators
```cfml
<!-- Fields with validatesPresenceOf() MUST show required indicator -->
#textField(
    objectName="user",
    property="email",
    labelDataRequired="true",    <!-- Shows required indicator -->
    class="form-control"
)#
```

### Form Value Preservation
```cfml
<!-- Always preserve values during validation cycles -->
#textField(
    objectName="user",
    property="email",
    value="#user.email ?: ''#"   <!-- Preserves value on validation error -->
)#
```

### Pagination Implementation
```cfml
<!-- ALWAYS use the shared pagination partial -->
#includePartial("/shared/searchPagination")#

<!-- NEVER manually build pagination links -->
<!-- WRONG: Building pagination manually -->
<cfloop from="1" to="#pages#" index="i">
    <a href="?page=#i#">#i#</a>
</cfloop>
```

### Controller Inheritance
```cfml
<!-- Always call super.config() in controllers and models -->
component extends="app.controllers.Controller" {
    function config() {
        super.config();  <!-- REQUIRED for framework features -->
        filters(through="authenticate");
    }
}
```

### Guard Statements Pattern
```cfml
<!-- Use guard statements, avoid unnecessary else blocks -->
function edit() {
    user = model("User").findByKey(params.key);
    
    if (!isObject(user)) {
        redirectTo(action="index", error="User not found");
        return;  <!-- Guard return -->
    }
    
    <!-- Main logic here, no else needed -->
    renderView(data={user: user});
}
```

### Hash Escaping in Strings
```cfml
<!-- Always escape # symbols in CFML strings -->
<a href="##section">Jump to section</a>         <!-- Correct: ## -->
<div id="item-##123">Item ##123</div>           <!-- Correct: ## -->
<a href="#section">Jump to section</a>          <!-- WRONG: unescaped -->
```

### Error Display Patterns
```cfml
<!-- Use errorMessagesFor() helper for model errors -->
#errorMessagesFor("user")#

<!-- Don't mix flash() and errorMessagesFor() -->
<!-- Pick one approach per form -->
```

### Delete Links
```cfml
<!-- Use linkTo() with method="delete" for delete actions -->
#linkTo(
    text="Delete",
    action="delete",
    key=user.id,
    method="delete",
    confirm="Are you sure?"
)#

<!-- NOT plain <a> tags with method attribute -->
<a href="/users/delete/1" method="delete">Delete</a>  <!-- WRONG -->
```

## Model Validation Best Practices

### Named Parameter Requirements
When using validation methods with additional parameters, the `property` parameter must be explicitly named:

```cfscript
// CORRECT - property parameter is named when using other parameters
validatesNumericalityOf(property="price", greaterThanOrEqualTo=0);
validatesInclusionOf(property="status", list="active,pending,cancelled");
validatesLengthOf(property="username", minimum=3, maximum=20);
validatesFormatOf(property="email", regEx="^[^@]+@[^@]+\.[^@]+$");

// WRONG - Missing property parameter name will cause error
validatesNumericalityOf("price", greaterThanOrEqualTo=0);  // ERROR!
validatesInclusionOf("status", list="active,pending");      // ERROR!

// CORRECT - Can omit 'property=' only when it's the sole parameter
validatesPresenceOf("firstName,lastName,email");
validatesUniquenessOf("email");
validatesConfirmationOf("password");
```

### Common Validation Patterns
```cfscript
component extends="Model" {
    function config() {
        // Required fields
        validatesPresenceOf("email,firstName,lastName");
        
        // Unique constraints
        validatesUniquenessOf("email");
        validatesUniquenessOf(property="slug", scope="categoryId");  // Scoped uniqueness
        
        // Format validations
        validatesFormatOf(property="email", regEx="^[^@]+@[^@]+\.[^@]+$");
        validatesFormatOf(property="phone", regEx="^\d{3}-\d{3}-\d{4}$");
        
        // Numeric validations
        validatesNumericalityOf(property="price", greaterThanOrEqualTo=0);
        validatesNumericalityOf(property="quantity", onlyInteger=true, greaterThan=0);
        
        // Length validations
        validatesLengthOf(property="password", minimum=8);
        validatesLengthOf(property="bio", maximum=500);
        validatesLengthOf(property="zipCode", is=5);
        
        // Inclusion validations
        validatesInclusionOf(property="status", list="active,pending,cancelled");
        validatesExclusionOf(property="username", list="admin,root,system");
        
        // Conditional validations
        validatesPresenceOf(property="password", when="onCreate");
        validatesLengthOf(property="password", minimum=8, when="onSave", 
            condition="structKeyExists(this, 'password') && len(this.password)");
    }
}
```

## Flash Messages in CFWheels

### Available Flash Functions
CFWheels provides `flashInsert()` for setting flash messages, NOT `flashNow()`:

```cfscript
// CORRECT - Use flashInsert() for flash messages
flashInsert(success="User created successfully!");
flashInsert(error="There was an error processing your request.");
flashInsert(warning="Please complete all required fields.");
flashInsert(info="Your session will expire in 5 minutes.");

// WRONG - flashNow() does not exist in CFWheels
flashNow(error="Error message");  // ERROR: No matching function [FLASHNOW] found
```

### Flash Message Patterns in Controllers

```cfscript
component extends="Controller" {
    
    function create() {
        user = model("User").new(params.user);
        
        if (user.save()) {
            // Success - redirect with flash
            flashInsert(success="Account created successfully!");
            redirectTo(action="show", key=user.id);
        } else {
            // Error - render view with flash
            flashInsert(error="There was an error creating your account.");
            renderView(action="new");
        }
    }
    
    function update() {
        user = model("User").findByKey(params.key);
        
        if (user.update(params.user)) {
            // Success message
            flashInsert(success="Profile updated successfully!");
            redirectTo(action="show", key=user.id);
        } else {
            // Error message with render
            flashInsert(error="There was an error updating your profile.");
            renderView(action="edit");
        }
    }
    
    function delete() {
        user = model("User").findByKey(params.key);
        
        if (user.delete()) {
            flashInsert(success="User deleted successfully!");
        } else {
            flashInsert(error="Could not delete user.");
        }
        
        redirectTo(action="index");
    }
}
```

### Displaying Flash Messages in Views

```cfml
<!-- In layout or view -->
<cfif flashKeyExists("success")>
    <div class="alert alert-success">
        #flash("success")#
    </div>
</cfif>

<cfif flashKeyExists("error")>
    <div class="alert alert-error">
        #flash("error")#
    </div>
</cfif>

<cfif flashKeyExists("warning")>
    <div class="alert alert-warning">
        #flash("warning")#
    </div>
</cfif>

<cfif flashKeyExists("info")>
    <div class="alert alert-info">
        #flash("info")#
    </div>
</cfif>
```

### Flash Message Best Practices

1. **Use the correct function**: Always use `flashInsert()`, never `flashNow()`
2. **Standard keys**: Use standard keys like `success`, `error`, `warning`, `info`
3. **Clear messages**: Write user-friendly, actionable messages
4. **Timing**: Set flash before redirects or renders
5. **Check existence**: Use `flashKeyExists()` before displaying

## CSRF Protection in Wheels

### Built-in CSRF Protection
Wheels provides built-in CSRF protection that should be used instead of custom implementations:

```cfscript
// In controller config()
function config() {
    super.config();
    // Enable CSRF protection for all actions except specific ones
    protectsFromForgery(with = "exception", except = "checkEmail");
}
```

### Using authenticityToken in Forms
```cfml
<!-- CORRECT - Use Wheels' built-in authenticityToken field -->
<form action="#urlFor(route='createUser')#" method="post">
    #authenticityTokenField()#
    <!-- form fields -->
</form>

<!-- WRONG - Custom CSRF implementation -->
<input type="hidden" name="csrfToken" value="#csrfToken#">
```

The field name must be `authenticityToken`, not `csrfToken` or any other variation.

## Handling Database Connection Issues

### Mock Mode Pattern for Development
When database isn't available, implement a mock mode for testing:

```cfscript
function create() {
    // Temporary mock for testing without database
    if (structKeyExists(params, "mockSuccess") && params.mockSuccess == "true") {
        session.userId = 999;
        session.userEmail = params.email ?: "test@example.com";
        flashInsert(success = "Mock registration successful!");
        redirectTo(route = "dashboard");
        return;
    }
    
    // Normal database operations
    try {
        user = model("User").new(params.user);
        // ... rest of implementation
    } catch (any e) {
        // Handle database errors gracefully
        errors.general = "Database connection error.";
        renderView(action = "register");
    }
}
```

## View Rendering and Redirects

### Always Provide Views or Redirect
Every controller action must either:
1. Redirect to another action
2. Render a view explicitly
3. Have a corresponding view file

```cfscript
// CORRECT - Explicit redirect on success
if (user.save()) {
    flashInsert(success = "User created!");
    redirectTo(route = "dashboard");
}

// CORRECT - Explicit render on error
if (user.hasErrors()) {
    renderView(action = "register");
}

// WRONG - No redirect or render (will look for create.cfm)
function create() {
    user = model("User").create(params.user);
    // Missing redirect or render!
}
```

## Alpine.js Integration with Forms

### Handling Form Submission
When using Alpine.js with forms, be careful not to prevent legitimate form submission:

```cfml
<!-- Be careful with @submit.prevent -->
<form @submit="handleSubmit" method="post">
    <!-- Alpine.js may prevent submission if validation fails -->
</form>

<!-- Consider allowing native submission as fallback -->
<form @submit="validateBeforeSubmit" method="post">
    <!-- Return true/false from Alpine handler -->
</form>
```

## HTMX Integration

### Email Availability Checking Pattern
```cfml
<!-- HTMX attributes for async validation -->
<input 
    type="email" 
    name="email" 
    hx-post="/auth/check-email"
    hx-trigger="input changed delay:500ms"
    hx-target="#email-availability"
    hx-indicator="#email-spinner">
<div id="email-availability"></div>
<div id="email-spinner" class="htmx-indicator">
    <span class="spinner-border spinner-border-sm"></span>
</div>
```

### Controller Handling for HTMX
```cfscript
function checkEmail() {
    var headers = getHTTPRequestData().headers;
    var isHTMX = structKeyExists(headers, "HX-Request");
    
    if (isHTMX) {
        // Return HTML fragment for HTMX
        return '<small class="text-success">Email available</small>';
    } else {
        // Return JSON for API calls
        response.headers["Content-Type"] = "application/json";
        return serializeJSON({available: true});
    }
}
```

## Rate Limiting Implementation

### Application-Scoped Rate Limiting
```cfscript
// Initialize in config()
function config() {
    if (!structKeyExists(application, "rateLimits")) {
        application.rateLimits = {};
    }
}

// Helper function for rate limiting
private function checkRateLimit(required string identifier, required string action, required numeric limit, required numeric windowSeconds) {
    var key = arguments.action & "_" & arguments.identifier;
    var now = getTickCount();
    var windowMillis = arguments.windowSeconds * 1000;
    
    if (!structKeyExists(application.rateLimits, key)) {
        application.rateLimits[key] = {
            attempts: [],
            cleanupTime: now + (windowMillis * 2)
        };
    }
    
    // Clean old attempts
    var cutoffTime = now - windowMillis;
    var validAttempts = [];
    for (var attempt in application.rateLimits[key].attempts) {
        if (attempt > cutoffTime) {
            validAttempts.append(attempt);
        }
    }
    application.rateLimits[key].attempts = validAttempts;
    
    // Check limit
    if (arrayLen(application.rateLimits[key].attempts) >= arguments.limit) {
        return false;
    }
    
    // Add current attempt
    application.rateLimits[key].attempts.append(now);
    return true;
}
```

## E2E Testing with Puppeteer

### Testing Registration Forms
When testing forms with Puppeteer:
1. Remove Alpine.js handlers that might prevent submission
2. Fill forms using direct value assignment
3. Handle asynchronous operations with proper waits

```javascript
// Remove Alpine handler and submit
const form = document.querySelector('form');
form.removeAttribute('@submit');
form.submit();

// Direct value assignment
document.querySelector('#email').value = 'test@example.com';
document.querySelector('#password').value = 'Password123!';
```

## Common Pitfalls
- Don't bypass Wheels ORM for simple queries
- Avoid putting business logic in views
- Don't skip validations with save(validate=false) unless necessary
- Always use named `property` parameter when using validation methods with additional parameters
- Remember to use filters for common controller logic
- Don't forget to add indexes in migrations
- Avoid N+1 queries - use include() for associations
- Configuration files are now in `/config` (not `/app/config`) in Wheels 3.0
- Always use CLI generators for migrations to ensure proper structure
- Use `config()` method for initialization, not `init()` in controllers and models
- Never use `whereParams` in `findAll()` - use `where` parameter instead
- Use `get("datasourceName")` instead of `application.wheels.dataSourceName`
- Always scope controller extends to `app.controllers.` to avoid ambiguity
- Add `CLAUDE TODO:` prefix to distinguish AI-generated TODO comments
- **Always initialize model properties when creating new instances in controller actions**
- **Use `flashInsert()` for flash messages, NOT `flashNow()` which doesn't exist**
- **Use `filters()` for authentication, NOT `verifies()` which is only for parameter checking**
- **Remember that `findAll()` returns a Query, not an Array - use `.recordCount` and `<cfloop query>`**
- **Use Wheels' built-in CSRF protection with `authenticityToken`, not custom implementations**
- **Always provide a view or redirect in controller actions to avoid ViewNotFound errors**
- **Handle database connection issues gracefully with try/catch blocks**
- **Test HTMX endpoints for both HTML and JSON responses**
- **Implement rate limiting at application scope for shared state**

## Comprehensive Wheels Documentation

For detailed framework documentation beyond this style guide, refer to the following resources in the agent-os standards:

### Main Documentation Dispatcher
- **@~/.agent-os/standards/wheels-framework.md** - Main entry point with conditional loading

### Available Documentation
- **Framework Architecture** - Request lifecycle, component relationships, internal workings
- **Code Patterns** - Reusable patterns for controllers, models, views, and routing
- **Migration Patterns** - Database migration best practices and complete examples
- **Testing Patterns** - TestBox testing strategies and examples
- **CLI Reference** - Complete command reference for all Wheels CLI operations
- **Error Catalog** - Common errors with diagnosis and solutions
- **Troubleshooting Guide** - Problem-solving for development issues
- **Application Examples** - Complete working examples of common implementations

These resources provide comprehensive coverage of all aspects of Wheels framework development, from architecture understanding to practical implementation patterns.