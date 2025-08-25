---
description: Wheels Framework Testing Patterns with TestBox
version: 1.0
encoding: UTF-8
---

# Wheels Testing Patterns

Comprehensive testing patterns and best practices for Wheels framework applications using TestBox.

## Table of Contents
- [Testing Philosophy](#testing-philosophy)
- [Test Structure](#test-structure)
- [Common Testing Patterns](#common-testing-patterns)
- [Model Testing](#model-testing)
- [Controller Testing](#controller-testing)
- [Integration Testing](#integration-testing)
- [Test Factories](#test-factories)
- [Mocking and Stubbing](#mocking-and-stubbing)
- [Database Testing](#database-testing)
- [Testing Commands](#testing-commands)

## Testing Philosophy

Wheels follows BDD (Behavior Driven Development) principles using TestBox:
- Tests describe behavior, not implementation
- Use descriptive test names that explain what is being tested
- Test the public API, not private methods
- Each test should be independent and repeatable
- Tests run in transactions that automatically rollback

## Test Structure

### Basic Test File Structure

```cfscript
component extends="tests.BaseSpec" {
    function run() {
        describe("Component Being Tested", () => {
            beforeEach(() => {
                // Setup code that runs before each test
                reload();  // Reloads the Wheels application
            });

            afterEach(() => {
                // Cleanup code that runs after each test
            });

            it("should do something specific", () => {
                // Arrange
                var input = "test";
                
                // Act
                var result = myFunction(input);
                
                // Assert
                expect(result).toBe("expected output");
            });
        });
    }
}
```

### Test Organization

```
/tests/
  /specs/
    /unit/
      /models/
        UserTest.cfc
        PostTest.cfc
      /controllers/
        UsersControllerTest.cfc
    /integration/
      AuthenticationFlowTest.cfc
    /helpers/
      factories/
        UserFactory.cfc
```

## Common Testing Patterns

### Testing with BaseSpec

Always extend BaseSpec for Wheels integration:

```cfscript
component extends="tests.BaseSpec" {
    // Provides reload(), processRequest(), and other helpers
}
```

### Assertion Patterns

```cfscript
// Basic assertions
expect(value).toBe(expected);
expect(value).toBeTrue();
expect(value).toBeFalse();
expect(value).toBeNull();
expect(value).toBeNumeric();
expect(value).toBeString();
expect(value).toBeArray();
expect(value).toBeStruct();

// Array assertions
expect(array).toHaveLength(3);
expect(array).toContain("value");
expect(array).toBeEmpty();

// Struct assertions
expect(struct).toHaveKey("name");
expect(struct.name).toBe("John");

// Exception testing
expect(() => {
    invalidFunction();
}).toThrow();

expect(() => {
    model.save();
}).toThrow("Validation failed");

// Negative assertions
expect(value).notToBe(unexpected);
expect(array).notToContain("value");
```

## Model Testing

### Basic Model Test

```cfscript
component extends="tests.BaseSpec" {
    function run() {
        describe("User Model", () => {
            it("should validate required fields", () => {
                var user = model("User").new();
                expect(user.save()).toBeFalse();
                expect(user.hasErrors()).toBeTrue();
                expect(user.hasErrors("email")).toBeTrue();
                expect(user.hasErrors("username")).toBeTrue();
            });

            it("should save valid user", () => {
                var user = model("User").new(
                    email: "test@example.com",
                    username: "testuser",
                    password: "password123"
                );
                expect(user.save()).toBeTrue();
                expect(user.id).toBeNumeric();
            });
        });
    }
}
```

### Testing Associations

```cfscript
describe("User associations", () => {
    beforeEach(() => {
        local.user = createTestUser();
        local.post = model("Post").create(
            userId: local.user.id,
            title: "Test Post",
            content: "Content"
        );
    });

    it("should have many posts", () => {
        var posts = local.user.posts();
        expect(posts).toBeArray();
        expect(posts).toHaveLength(1);
        expect(posts[1].title).toBe("Test Post");
    });

    it("should belong to user", () => {
        var author = local.post.author();
        expect(author.id).toBe(local.user.id);
    });
});
```

### Testing Callbacks

```cfscript
describe("Model callbacks", () => {
    it("should hash password before save", () => {
        var user = model("User").new(
            email: "test@example.com",
            password: "plaintext"
        );
        user.save();
        
        expect(user.password).notToBe("plaintext");
        expect(user.password).toMatch("^\$2[ayb]\$.{56}$"); // BCrypt pattern
    });

    it("should set slug before create", () => {
        var post = model("Post").create(
            title: "My Test Post",
            content: "Content"
        );
        
        expect(post.slug).toBe("my-test-post");
    });
});
```

### Testing Validations

```cfscript
describe("User validations", () => {
    it("should require unique email", () => {
        var user1 = createTestUser(email: "test@example.com");
        var user2 = model("User").new(
            email: "test@example.com",
            username: "different"
        );
        
        expect(user2.save()).toBeFalse();
        expect(user2.errorMessageOn("email")).toContain("already taken");
    });

    it("should validate email format", () => {
        var user = model("User").new(
            email: "invalid-email",
            username: "test"
        );
        
        expect(user.save()).toBeFalse();
        expect(user.hasErrors("email")).toBeTrue();
    });

    it("should validate password length", () => {
        var user = model("User").new(
            email: "test@example.com",
            username: "test",
            password: "short"
        );
        
        expect(user.save()).toBeFalse();
        expect(user.errorMessageOn("password")).toContain("at least 8 characters");
    });
});
```

## Controller Testing

### Basic Controller Test

```cfscript
component extends="tests.BaseSpec" {
    function run() {
        describe("UsersController", () => {
            it("should show index page", () => {
                var result = processRequest(route: "/users", method: "GET");
                
                expect(result.status).toBe(200);
                expect(result.view).toContain("Users");
                expect(result.variables).toHaveKey("users");
                expect(result.variables.users).toBeArray();
            });

            it("should create user with valid data", () => {
                var result = processRequest(
                    route: "/users",
                    method: "POST",
                    params: {
                        user: {
                            email: "new@example.com",
                            username: "newuser",
                            password: "password123"
                        }
                    }
                );
                
                expect(result.status).toBe(302);
                expect(result.redirect).toBe("/users/profile");
                expect(model("User").findOneByEmail("new@example.com")).toBeObject();
            });
        });
    }
}
```

### Testing Authentication

```cfscript
describe("Authentication", () => {
    beforeEach(() => {
        local.user = createTestUser(
            email: "test@example.com",
            password: "password123"
        );
    });

    it("should login with valid credentials", () => {
        var result = processRequest(
            route: "/sessions",
            method: "POST",
            params: {
                email: "test@example.com",
                password: "password123"
            }
        );
        
        expect(result.status).toBe(302);
        expect(result.session.userId).toBe(local.user.id);
    });

    it("should reject invalid credentials", () => {
        var result = processRequest(
            route: "/sessions",
            method: "POST",
            params: {
                email: "test@example.com",
                password: "wrongpassword"
            }
        );
        
        expect(result.status).toBe(200);
        expect(result.flash.error).toContain("Invalid credentials");
        expect(result.session).notToHaveKey("userId");
    });
});
```

### Testing Filters

```cfscript
describe("Controller filters", () => {
    it("should require authentication for protected actions", () => {
        var result = processRequest(
            route: "/admin/dashboard",
            method: "GET"
        );
        
        expect(result.status).toBe(302);
        expect(result.redirect).toBe("/login");
    });

    it("should allow authenticated access", () => {
        var user = createTestUser(admin: true);
        
        var result = processRequest(
            route: "/admin/dashboard",
            method: "GET",
            session: { userId: user.id }
        );
        
        expect(result.status).toBe(200);
        expect(result.view).toContain("Dashboard");
    });
});
```

### Testing Content Negotiation

```cfscript
describe("API responses", () => {
    it("should return JSON for API requests", () => {
        var result = processRequest(
            route: "/api/users",
            method: "GET",
            headers: { "Accept": "application/json" }
        );
        
        expect(result.status).toBe(200);
        expect(result.type).toBe("application/json");
        expect(result.json).toBeStruct();
        expect(result.json.users).toBeArray();
    });

    it("should return XML when requested", () => {
        var result = processRequest(
            route: "/api/users/1",
            method: "GET",
            headers: { "Accept": "application/xml" }
        );
        
        expect(result.status).toBe(200);
        expect(result.type).toBe("application/xml");
        expect(result.body).toContain("<user>");
    });
});
```

## Integration Testing

### Full Request Cycle Test

```cfscript
component extends="tests.BaseSpec" {
    function run() {
        describe("User Registration Flow", () => {
            it("should complete full registration process", () => {
                // Visit registration page
                var result = processRequest(route: "/register", method: "GET");
                expect(result.status).toBe(200);
                expect(result.view).toContain("Sign Up");
                
                // Submit registration form
                result = processRequest(
                    route: "/register",
                    method: "POST",
                    params: {
                        user: {
                            email: "newuser@example.com",
                            username: "newuser",
                            password: "password123",
                            passwordConfirmation: "password123"
                        }
                    }
                );
                
                expect(result.status).toBe(302);
                expect(result.redirect).toBe("/welcome");
                
                // Verify email sent
                expect(result.email).toBeStruct();
                expect(result.email.to).toBe("newuser@example.com");
                expect(result.email.subject).toContain("Welcome");
                
                // Follow redirect
                result = processRequest(
                    route: "/welcome",
                    method: "GET",
                    session: result.session
                );
                
                expect(result.status).toBe(200);
                expect(result.view).toContain("Welcome newuser");
            });
        });
    }
}
```

## Test Factories

### Creating a Factory

```cfscript
// tests/helpers/factories/UserFactory.cfc
component {
    function create(struct attributes = {}) {
        var defaults = {
            email: "user#createUUID()#@example.com",
            username: "user#createUUID()#",
            password: "password123",
            firstName: "Test",
            lastName: "User",
            active: true
        };
        
        structAppend(defaults, attributes, true);
        
        return model("User").create(defaults);
    }
    
    function build(struct attributes = {}) {
        var defaults = {
            email: "user#createUUID()#@example.com",
            username: "user#createUUID()#",
            password: "password123"
        };
        
        structAppend(defaults, attributes, true);
        
        return model("User").new(defaults);
    }
}
```

### Using Factories in Tests

```cfscript
// In BaseSpec.cfc
function createTestUser(struct attributes = {}) {
    return new tests.helpers.factories.UserFactory().create(attributes);
}

// In tests
describe("Posts", () => {
    beforeEach(() => {
        local.author = createTestUser();
        local.post = createTestPost(userId: local.author.id);
    });
    
    it("should belong to author", () => {
        expect(local.post.author().id).toBe(local.author.id);
    });
});
```

## Mocking and Stubbing

### Basic Mocking

```cfscript
describe("Email service", () => {
    it("should send welcome email", () => {
        // Create a mock
        var emailService = createMock("services.EmailService");
        
        // Set expectation
        emailService.$("send").$args(
            to: "test@example.com",
            subject: "Welcome",
            template: "welcome"
        ).$returns(true);
        
        // Inject mock
        application.emailService = emailService;
        
        // Run test
        var user = model("User").create(
            email: "test@example.com",
            username: "test"
        );
        
        // Verify
        expect(emailService.$count("send")).toBe(1);
    });
});
```

### Stubbing External Services

```cfscript
describe("Payment processing", () => {
    beforeEach(() => {
        // Stub external API
        local.paymentGateway = createStub();
        local.paymentGateway.charge = function(amount, token) {
            return {
                success: true,
                transactionId: "test_trans_123",
                amount: arguments.amount
            };
        };
        
        application.paymentGateway = local.paymentGateway;
    });
    
    it("should process payment", () => {
        var order = model("Order").create(
            userId: createTestUser().id,
            total: 99.99
        );
        
        var result = order.processPayment("test_token");
        
        expect(result.success).toBeTrue();
        expect(order.paymentStatus).toBe("paid");
        expect(order.transactionId).toBe("test_trans_123");
    });
});
```

## Database Testing

### Transaction Rollback

```cfscript
// All tests automatically run in transactions
describe("Database operations", () => {
    it("should rollback after test", () => {
        var countBefore = model("User").count();
        
        // Create users in test
        createTestUser();
        createTestUser();
        createTestUser();
        
        expect(model("User").count()).toBe(countBefore + 3);
        
        // After test completes, transaction rolls back
        // and users are not persisted
    });
});
```

### Testing with Different Databases

```cfscript
describe("Cross-database compatibility", () => {
    it("should work with all supported databases", () => {
        // Test runs against datasource specified in test environment
        var user = model("User").create(
            email: "test@example.com",
            username: "test"
        );
        
        // Framework handles database-specific SQL
        var found = model("User").findByKey(user.id);
        expect(found.email).toBe("test@example.com");
    });
});
```

## Testing Commands

### Running Tests

```bash
# Run all tests
box testbox run

# Run specific test file
wheels test app UserTest

# Run test package
wheels test app testBundles=models

# Run specific test spec
wheels test app testBundles=models&testSpecs=shouldValidateEmail

# Run with coverage
box testbox run --coverage --coverageReporter=html

# Watch mode for TDD
box testbox watch

# Run tests in specific directory
box testbox run --directory=tests/specs/unit

# Run tests with specific labels
box testbox run --labels=critical

# Run tests excluding labels
box testbox run --excludeLabels=slow
```

### Docker Testing

```bash
# Test with Lucee
docker compose --profile lucee up -d

# Test with Adobe ColdFusion 2023
docker compose --profile adobe2023 up -d

# Run tests against all engines
docker compose up -d

# Access TestUI
# http://localhost:3000
```

## Best Practices

### DO:
- Use descriptive test names
- Test one thing per test
- Use factories for test data
- Test edge cases and error conditions
- Run tests frequently during development
- Use beforeEach for common setup
- Test the public API, not implementation details

### DON'T:
- Test framework code
- Use production data in tests
- Make tests dependent on each other
- Test private methods directly
- Hard-code test data when factories exist
- Skip writing tests for "simple" code
- Ignore failing tests

### Test Naming Conventions

```cfscript
// Good test names
it("should return 404 when user not found");
it("should validate email format");
it("should hash password before saving");
it("should redirect to login when not authenticated");

// Bad test names
it("test user");
it("works");
it("should work correctly");
it("test case 1");
```

### Test Data Management

```cfscript
// Good: Use factories with meaningful overrides
var admin = createTestUser(role: "admin", active: true);
var post = createTestPost(
    userId: admin.id,
    published: true,
    publishedAt: now()
);

// Bad: Hard-coded test data
var user = model("User").create(
    id: 1,
    email: "test@test.com",
    username: "test",
    password: "test"
);
```

## Common Testing Scenarios

### Testing File Uploads

```cfscript
it("should handle file upload", () => {
    var testFile = expandPath("/tests/fixtures/test-image.jpg");
    
    var result = processRequest(
        route: "/uploads",
        method: "POST",
        params: {
            title: "Test Upload"
        },
        files: {
            attachment: {
                file: testFile,
                type: "image/jpeg"
            }
        }
    );
    
    expect(result.status).toBe(302);
    expect(result.flash.success).toContain("uploaded successfully");
});
```

### Testing Background Jobs

```cfscript
it("should queue email job", () => {
    var jobQueue = createMock("services.JobQueue");
    jobQueue.$("push").$returns(true);
    application.jobQueue = jobQueue;
    
    var user = createTestUser();
    user.sendWelcomeEmail();
    
    expect(jobQueue.$count("push")).toBe(1);
    expect(jobQueue.$callLog().push[1].job).toBe("WelcomeEmailJob");
    expect(jobQueue.$callLog().push[1].data.userId).toBe(user.id);
});
```

### Testing Caching

```cfscript
describe("Caching", () => {
    beforeEach(() => {
        cacheRemove("test_cache_key");
    });
    
    it("should cache expensive operation", () => {
        var hitCount = 0;
        
        var expensiveOperation = function() {
            hitCount++;
            return "expensive result";
        };
        
        // First call
        var result1 = cacheGet("test_cache_key", expensiveOperation);
        expect(result1).toBe("expensive result");
        expect(hitCount).toBe(1);
        
        // Second call should use cache
        var result2 = cacheGet("test_cache_key", expensiveOperation);
        expect(result2).toBe("expensive result");
        expect(hitCount).toBe(1); // Not incremented
    });
});
```

This comprehensive guide should help AI assistants understand and write effective tests for Wheels applications using TestBox.