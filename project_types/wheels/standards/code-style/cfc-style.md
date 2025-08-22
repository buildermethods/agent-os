# CFC Script-Based Style Guide

## Purpose
This guide defines standards for writing CFML Components (CFCs) using script syntax. Modern CFML development should use script syntax for all business logic, services, and components.

## General Rules
- Use script syntax exclusively in CFCs
- Use 4 spaces for indentation (or 2 if team prefers consistency)
- Follow camelCase for variables and methods
- Use PascalCase for component names
- Always use explicit scoping (`variables.`, `this.`, `arguments.`)
- Include comprehensive type hints

## Component Structure

### Basic Component
```cfscript
component 
    displayname="UserService"
    hint="Handles user-related business logic"
    output="false"
    accessors="true" {
    
    // Properties
    property name="userDAO" type="models.dao.UserDAO";
    property name="emailService" type="services.EmailService";
    property name="logger" type="services.Logger";
    
    // Constructor
    public UserService function init(
        required UserDAO userDAO,
        required EmailService emailService,
        Logger logger
    ) {
        variables.userDAO = arguments.userDAO;
        variables.emailService = arguments.emailService;
        variables.logger = arguments.logger ?: new services.Logger();
        
        return this;
    }
    
    // Public methods
    public struct function getUserById(required numeric userId) {
        try {
            var user = variables.userDAO.read(arguments.userId);
            
            if (isNull(user)) {
                throw(
                    type="UserNotFoundException",
                    message="User not found with ID: #arguments.userId#"
                );
            }
            
            return user;
        } catch (any e) {
            variables.logger.error("Error getting user: #e.message#", e);
            rethrow;
        }
    }
    
    // Private methods
    private boolean function validateEmail(required string email) {
        return reFindNoCase(
            "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$",
            arguments.email
        ) > 0;
    }
}
```

## Method Definitions

### Method Signature Format
```cfscript
// Full signature with all attributes
public array function findUsers(
    required string searchTerm,
    numeric maxResults = 50,
    string sortBy = "lastName",
    boolean includeInactive = false
) hint="Searches for users based on criteria" {
    // Method body
}
```

### Return Type Hints
```cfscript
// Always specify return types
public void function deleteUser(required numeric userId) {
    // No return
}

public boolean function isActive(required struct user) {
    return arguments.user.status == "active";
}

public array function getAllUsers() {
    return variables.userDAO.list();
}

public query function getUsersQuery() {
    return variables.userDAO.getQuery();
}

// Nullable returns
public any function findUserByEmail(required string email) {
    var user = variables.userDAO.findByEmail(arguments.email);
    return isNull(user) ? javaCast("null", "") : user;
}
```

## Variable Scoping

### Proper Scoping Examples
```cfscript
component {
    
    // Component properties
    variables.config = {};
    variables.cache = {};
    
    public void function configure(required struct settings) {
        // Always use explicit scoping
        variables.config = arguments.settings;
        
        // Local variables don't need var in function scope
        var tempValue = processSettings(arguments.settings);
        
        // Or use local scope explicitly
        local.processedValue = tempValue * 2;
    }
    
    public struct function getConfig() {
        // Return copy to prevent external modification
        return duplicate(variables.config);
    }
}
```

## Error Handling

### Try-Catch Patterns
```cfscript
public struct function saveUser(required struct userData) {
    try {
        // Validate
        if (!isValid("email", arguments.userData.email)) {
            throw(
                type="ValidationException",
                message="Invalid email address"
            );
        }
        
        // Process
        transaction {
            var userId = variables.userDAO.save(arguments.userData);
            variables.auditService.log("User saved", userId);
            
            return {
                success: true,
                userId: userId
            };
        }
        
    } catch (ValidationException e) {
        return {
            success: false,
            error: e.message,
            errorType: "validation"
        };
    } catch (database e) {
        variables.logger.error("Database error: #e.message#", e);
        return {
            success: false,
            error: "Database error occurred",
            errorType: "database"
        };
    } catch (any e) {
        variables.logger.error("Unexpected error: #e.message#", e);
        rethrow;
    }
}
```

## Dependency Injection

### Constructor Injection
```cfscript
component accessors="true" {
    
    property name="userRepository" type="repositories.UserRepository";
    property name="cacheService" type="services.CacheService";
    property name="eventBus" type="services.EventBus";
    
    public UserService function init(
        required repositories.UserRepository userRepository,
        required services.CacheService cacheService,
        services.EventBus eventBus = new services.EventBus()
    ) {
        variables.userRepository = arguments.userRepository;
        variables.cacheService = arguments.cacheService;
        variables.eventBus = arguments.eventBus;
        
        return this;
    }
}
```

## Collections and Iterations

### Array Operations
```cfscript
public array function processUsers(required array users) {
    return arguments.users
        .filter((user) => user.isActive)
        .map((user) => {
            return {
                id: user.id,
                name: user.firstName & " " & user.lastName,
                email: user.email
            };
        })
        .sort((a, b) => compare(a.name, b.name));
}

// Traditional loop when index needed
public void function updateUserStatuses(required array userIds) {
    for (var i = 1; i <= arrayLen(arguments.userIds); i++) {
        var userId = arguments.userIds[i];
        variables.userDAO.updateStatus(userId, "processed");
        
        if (i % 100 == 0) {
            variables.logger.info("Processed #i# users");
        }
    }
}
```

### Struct Operations
```cfscript
public struct function mergeSettings(
    required struct defaults,
    required struct overrides
) {
    var merged = duplicate(arguments.defaults);
    
    arguments.overrides.each((key, value) => {
        if (isStruct(value) && structKeyExists(merged, key)) {
            merged[key] = mergeSettings(merged[key], value);
        } else {
            merged[key] = value;
        }
    });
    
    return merged;
}
```

## Query Handling

### Query Building
```cfscript
public query function searchUsers(
    string name = "",
    string email = "",
    boolean activeOnly = true
) {
    var sql = "
        SELECT userId, firstName, lastName, email, status
        FROM users
        WHERE 1=1
    ";
    
    var params = [];
    
    if (len(trim(arguments.name))) {
        sql &= " AND (firstName LIKE :name OR lastName LIKE :name)";
        arrayAppend(params, {
            name: "name",
            value: "%#arguments.name#%",
            cfsqltype: "CF_SQL_VARCHAR"
        });
    }
    
    if (len(trim(arguments.email))) {
        sql &= " AND email LIKE :email";
        arrayAppend(params, {
            name: "email",
            value: "%#arguments.email#%",
            cfsqltype: "CF_SQL_VARCHAR"
        });
    }
    
    if (arguments.activeOnly) {
        sql &= " AND status = :status";
        arrayAppend(params, {
            name: "status",
            value: "active",
            cfsqltype: "CF_SQL_VARCHAR"
        });
    }
    
    return queryExecute(sql, params, {
        datasource: application.datasource,
        returntype: "query"
    });
}
```

## Async Operations

### Thread Usage
```cfscript
public void function processLargeDataset(required array items) {
    var batchSize = 100;
    var batches = [];
    
    // Create batches
    for (var i = 1; i <= arrayLen(arguments.items); i += batchSize) {
        var end = min(i + batchSize - 1, arrayLen(arguments.items));
        arrayAppend(batches, arguments.items.slice(i, end));
    }
    
    // Process batches in parallel
    batches.each((batch, index) => {
        thread name="batch_#index#" batch=batch {
            processBatch(attributes.batch);
        }
    });
    
    // Wait for all threads
    thread action="join" name=batches.map((b, i) => "batch_#i#").toList();
}
```

## Testing Support

### Testable Design
```cfscript
component {
    
    // Allow injection for testing
    public void function setUserDAO(required UserDAO userDAO) {
        variables.userDAO = arguments.userDAO;
    }
    
    // Separate validation from persistence
    public array function validateUserData(required struct userData) {
        var errors = [];
        
        if (!len(trim(arguments.userData.email ?: ""))) {
            arrayAppend(errors, "Email is required");
        }
        
        if (!len(trim(arguments.userData.firstName ?: ""))) {
            arrayAppend(errors, "First name is required");
        }
        
        return errors;
    }
    
    // Make methods testable
    public boolean function canUserPerformAction(
        required struct user,
        required string action
    ) {
        return variables.permissionService.check(
            arguments.user,
            arguments.action
        );
    }
}
```

## Best Practices

### Null Handling
```cfscript
// Safe navigation
var userName = user?.profile?.displayName ?: "Unknown";

// Null checking
if (isNull(arguments.optionalParam)) {
    arguments.optionalParam = getDefaultValue();
}

// Elvis operator
var config = arguments.config ?: application.defaultConfig;
```

### Method Chaining
```cfscript
component {
    
    public UserBuilder function setFirstName(required string firstName) {
        variables.firstName = arguments.firstName;
        return this;
    }
    
    public UserBuilder function setLastName(required string lastName) {
        variables.lastName = arguments.lastName;
        return this;
    }
    
    public User function build() {
        return new User(
            firstName: variables.firstName,
            lastName: variables.lastName
        );
    }
}

// Usage
var user = new UserBuilder()
    .setFirstName("John")
    .setLastName("Doe")
    .build();
```

### Configuration Objects
```cfscript
component {
    
    public struct function getDefaultConfig() {
        return {
            timeout: 30,
            retryCount: 3,
            enableCache: true,
            cacheTimeout: 300,
            logLevel: "INFO"
        };
    }
    
    public void function configure(struct config = {}) {
        variables.config = structCopy(getDefaultConfig());
        structAppend(variables.config, arguments.config, true);
        
        validateConfig(variables.config);
    }
}
```

## Anti-Patterns to Avoid
- Don't use `evaluate()` or dynamic variable names
- Avoid global variables
- Don't mix tag and script syntax in CFCs
- Never use `<cfscript>` tags in script-only CFCs
- Don't omit return types
- Avoid overly complex single methods (split into smaller functions)
- Don't ignore error handling
- Never hardcode configuration values
- Avoid circular dependencies
- Don't use outdated syntax (use modern member functions)

## File Organization
- One component per file
- File name matches component name: `UserService.cfc`
- Group related components in packages: `services/`, `models/`, `controllers/`
- Use meaningful package structures that reflect architecture