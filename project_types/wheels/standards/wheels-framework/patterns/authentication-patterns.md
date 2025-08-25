---
description: Wheels Framework Authentication and Authorization Patterns with BCrypt Plugin
version: 1.1
encoding: UTF-8
---

# Wheels Authentication Patterns

Comprehensive authentication and authorization patterns for Wheels framework applications.

## Table of Contents
- [Authentication Overview](#authentication-overview)
- [Session-Based Authentication](#session-based-authentication)
- [Token-Based Authentication](#token-based-authentication)
- [OAuth Integration](#oauth-integration)
- [Role-Based Authorization](#role-based-authorization)
- [Two-Factor Authentication](#two-factor-authentication)
- [Password Management](#password-management)
- [Remember Me Functionality](#remember-me-functionality)
- [API Authentication](#api-authentication)
- [Security Best Practices](#security-best-practices)

## Authentication Overview

### Core Components
1. **User Model**: Stores credentials and profile information
2. **Session Management**: Tracks authenticated users
3. **Authentication Filters**: Protect routes and controllers
4. **Authorization Logic**: Control access to resources
5. **Password Security**: Hashing and validation

## Session-Based Authentication

### User Model with Authentication
```cfml
// /app/models/User.cfc
component extends="Model" {
  
  function config() {
    // Table configuration
    table("users");
    
    // Properties
    property(name="passwordHash", column="password");
    property(name="password", sql="", dataType="varchar"); // Virtual property
    property(name="passwordConfirmation", sql="", dataType="varchar"); // Virtual property
    
    // Associations
    hasMany("sessions");
    hasMany("roles");
    
    // Validations
    validatesPresenceOf("email,firstName,lastName");
    validatesUniquenessOf("email");
    validatesFormatOf(property="email", regex="^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$");
    
    // Password validations (only on create or when password is present)
    validatesConfirmationOf(property="password", when="onCreate");
    validatesLengthOf(property="password", minimum=8, when="onCreate", allowBlank=false);
    validatesLengthOf(property="password", minimum=8, when="onUpdate", allowBlank=true);
    
    // Callbacks
    beforeValidation("sanitizeEmail");
    beforeSave("hashPassword");
    afterCreate("sendWelcomeEmail");
  }
  
  // Authentication methods
  public any function authenticate(required string email, required string password) {
    local.user = this.findOne(where="email='#arguments.email#' AND active=1");
    
    if (IsObject(local.user) && local.user.checkPassword(arguments.password)) {
      local.user.updateLoginInfo();
      return local.user;
    }
    
    return false;
  }
  
  public boolean function checkPassword(required string password) {
    // Using CFWheels BCrypt plugin
    return bCryptCheckPW(arguments.password, this.passwordHash);
  }
  
  private void function hashPassword() {
    if (StructKeyExists(this, "password") && Len(this.password)) {
      // Using CFWheels BCrypt plugin with configurable work factor
      local.workFactor = getSetting("bcryptWorkFactor", 12);
      this.passwordHash = bCryptHashPW(this.password, bCryptGenSalt(local.workFactor));
      StructDelete(this, "password");
      StructDelete(this, "passwordConfirmation");
    }
  }
  
  private void function sanitizeEmail() {
    if (StructKeyExists(this, "email")) {
      this.email = LCase(Trim(this.email));
    }
  }
  
  private void function updateLoginInfo() {
    this.lastLoginAt = Now();
    this.loginCount = (this.loginCount ?: 0) + 1;
    this.save(validate=false);
  }
  
  public boolean function hasRole(required string roleName) {
    return this.roles().where("name='#arguments.roleName#'").count() > 0;
  }
  
  public boolean function can(required string permission) {
    // Check if user has permission through roles
    local.permissions = this.roles().include("permissions").findAll();
    for (local.role in local.permissions) {
      for (local.permission in local.role.permissions) {
        if (local.permission.name == arguments.permission) {
          return true;
        }
      }
    }
    return false;
  }
}
```

### Authentication Controller
```cfml
// /app/controllers/Sessions.cfc
component extends="Controller" {
  
  function config() {
    provides("html,json");
    verifies(params="email,password", only="create");
  }
  
  // Login form
  function new() {
    user = model("User").new();
  }
  
  // Process login
  function create() {
    local.user = model("User").authenticate(params.email, params.password);
    
    if (IsObject(local.user)) {
      // Set session
      session.userId = local.user.id;
      session.userEmail = local.user.email;
      session.userName = local.user.fullName();
      
      // Handle remember me
      if (StructKeyExists(params, "rememberMe") && params.rememberMe) {
        createRememberMeToken(local.user);
      }
      
      // Log login event
      logActivity("login", local.user.id);
      
      // Flash and redirect
      flashInsert(success="Welcome back, #local.user.firstName#!");
      
      // Redirect to intended URL or dashboard
      if (StructKeyExists(params, "returnUrl") && Len(params.returnUrl)) {
        redirectTo(url=params.returnUrl);
      } else {
        redirectTo(route="dashboard");
      }
    } else {
      // Failed login
      flashInsert(error="Invalid email or password");
      logActivity("failed_login", 0, params.email);
      
      // Increment failed attempts (for rate limiting)
      incrementFailedAttempts(params.email);
      
      user = model("User").new(email=params.email);
      renderView("new");
    }
  }
  
  // Logout
  function delete() {
    // Clear session
    if (StructKeyExists(session, "userId")) {
      logActivity("logout", session.userId);
    }
    
    StructDelete(session, "userId");
    StructDelete(session, "userEmail");
    StructDelete(session, "userName");
    
    // Clear remember me cookie
    clearRememberMeToken();
    
    flashInsert(success="You have been logged out");
    redirectTo(route="home");
  }
  
  // Private methods
  private void function createRememberMeToken(required user) {
    local.token = generateSecureToken();
    local.hashedToken = Hash(local.token, "SHA-256");
    
    // Store hashed token in database
    model("RememberToken").create(
      userId=arguments.user.id,
      tokenHash=local.hashedToken,
      expiresAt=DateAdd("d", 30, Now())
    );
    
    // Set cookie with actual token
    cookie.rememberToken = {
      value=local.token,
      expires=30,
      httpOnly=true,
      secure=request.isSecure,
      sameSite="Lax"
    };
  }
  
  private void function clearRememberMeToken() {
    if (StructKeyExists(cookie, "rememberToken")) {
      // Delete from database
      model("RememberToken").deleteAll(
        where="tokenHash='#Hash(cookie.rememberToken, 'SHA-256')#'"
      );
      
      // Clear cookie
      cookie.rememberToken = {
        value="",
        expires="now",
        httpOnly=true,
        secure=request.isSecure
      };
    }
  }
}
```

### Authentication Filters
```cfml
// /app/controllers/Controller.cfc
component extends="wheels.Controller" {
  
  function config() {
    // Make authentication methods available to all controllers
  }
  
  // Authentication filter
  public void function requireLogin() {
    if (!isLoggedIn()) {
      // Store intended URL
      session.returnUrl = request.cgi.PATH_INFO;
      if (Len(request.cgi.QUERY_STRING)) {
        session.returnUrl &= "?" & request.cgi.QUERY_STRING;
      }
      
      flashInsert(warning="Please log in to continue");
      redirectTo(route="login");
    }
  }
  
  // Authorization filter
  public void function requireRole(required string role) {
    requireLogin();
    
    if (!currentUser().hasRole(arguments.role)) {
      flashInsert(error="You don't have permission to access this page");
      redirectTo(route="dashboard");
    }
  }
  
  // Check if logged in
  public boolean function isLoggedIn() {
    // Check session
    if (StructKeyExists(session, "userId") && session.userId > 0) {
      return true;
    }
    
    // Check remember me token
    if (StructKeyExists(cookie, "rememberToken")) {
      return authenticateRememberToken();
    }
    
    return false;
  }
  
  // Get current user
  public any function currentUser() {
    if (!StructKeyExists(request, "currentUser")) {
      if (isLoggedIn()) {
        request.currentUser = model("User").findByKey(session.userId);
      } else {
        request.currentUser = false;
      }
    }
    return request.currentUser;
  }
  
  private boolean function authenticateRememberToken() {
    local.hashedToken = Hash(cookie.rememberToken, "SHA-256");
    local.rememberToken = model("RememberToken").findOne(
      where="tokenHash='#local.hashedToken#' AND expiresAt > NOW()",
      include="user"
    );
    
    if (IsObject(local.rememberToken)) {
      // Set session
      session.userId = local.rememberToken.user.id;
      session.userEmail = local.rememberToken.user.email;
      session.userName = local.rememberToken.user.fullName();
      
      // Refresh token expiry
      local.rememberToken.update(expiresAt=DateAdd("d", 30, Now()));
      
      return true;
    }
    
    return false;
  }
}
```

### Protected Controllers
```cfml
// /app/controllers/admin/Dashboard.cfc
component extends="Controller" {
  
  function config() {
    // Require authentication for all actions
    filters(through="requireLogin");
    
    // Require admin role for all actions
    filters(through="requireRole", role="admin");
  }
  
  function index() {
    // Dashboard logic - only accessible to admins
    stats = {
      users: model("User").count(),
      posts: model("Post").count(),
      revenue: model("Order").sum("total")
    };
  }
}
```

## Token-Based Authentication

### API Token Model
```cfml
// /app/models/ApiToken.cfc
component extends="Model" {
  
  function config() {
    table("api_tokens");
    belongsTo("user");
    
    validatesPresenceOf("userId,token,expiresAt");
    validatesUniquenessOf("token");
    
    beforeCreate("generateToken,setExpiry");
  }
  
  private void function generateToken() {
    this.token = generateSecureToken(40);
  }
  
  private void function setExpiry() {
    if (!StructKeyExists(this, "expiresAt")) {
      this.expiresAt = DateAdd("yyyy", 1, Now());
    }
  }
  
  public boolean function isValid() {
    return this.active && this.expiresAt > Now();
  }
  
  public void function refreshToken() {
    this.token = generateSecureToken(40);
    this.expiresAt = DateAdd("yyyy", 1, Now());
    this.save();
  }
}
```

### API Authentication Controller
```cfml
// /app/controllers/api/v1/Base.cfc
component extends="Controller" {
  
  function config() {
    onlyProvides("json");
    filters(through="authenticateApiRequest");
  }
  
  private void function authenticateApiRequest() {
    local.token = extractBearerToken();
    
    if (!Len(local.token)) {
      renderWith(data={error="Missing authentication token"}, status=401);
      abort;
    }
    
    local.apiToken = model("ApiToken").findOne(
      where="token='#local.token#' AND active=1",
      include="user"
    );
    
    if (!IsObject(local.apiToken) || !local.apiToken.isValid()) {
      renderWith(data={error="Invalid or expired token"}, status=401);
      abort;
    }
    
    // Set current user for the request
    request.apiUser = local.apiToken.user;
    
    // Update last used timestamp
    local.apiToken.update(lastUsedAt=Now(), validate=false);
  }
  
  private string function extractBearerToken() {
    local.authHeader = request.headers["Authorization"] ?: "";
    
    if (Left(local.authHeader, 7) == "Bearer ") {
      return Mid(local.authHeader, 8, Len(local.authHeader));
    }
    
    return "";
  }
}
```

## OAuth Integration

### OAuth Controller
```cfml
// /app/controllers/OAuth.cfc
component extends="Controller" {
  
  function config() {
    // OAuth configuration
    variables.providers = {
      google: {
        clientId: getSetting("googleOAuthClientId"),
        clientSecret: getSetting("googleOAuthClientSecret"),
        authUrl: "https://accounts.google.com/o/oauth2/v2/auth",
        tokenUrl: "https://oauth2.googleapis.com/token",
        scope: "email profile"
      },
      github: {
        clientId: getSetting("githubOAuthClientId"),
        clientSecret: getSetting("githubOAuthClientSecret"),
        authUrl: "https://github.com/login/oauth/authorize",
        tokenUrl: "https://github.com/login/oauth/access_token",
        scope: "user:email"
      }
    };
  }
  
  // Initiate OAuth flow
  function authorize() {
    local.provider = variables.providers[params.provider];
    local.state = generateSecureToken();
    
    // Store state in session for CSRF protection
    session.oauthState = local.state;
    
    local.authUrl = local.provider.authUrl & "?" & BuildURLParams({
      client_id: local.provider.clientId,
      redirect_uri: urlFor(route="oauthCallback", provider=params.provider, onlyPath=false),
      scope: local.provider.scope,
      state: local.state,
      response_type: "code"
    });
    
    redirectTo(url=local.authUrl);
  }
  
  // Handle OAuth callback
  function callback() {
    // Verify state for CSRF protection
    if (!StructKeyExists(params, "state") || params.state != session.oauthState) {
      flashInsert(error="Invalid OAuth state");
      redirectTo(route="login");
    }
    
    // Exchange code for token
    local.provider = variables.providers[params.provider];
    local.tokenResponse = exchangeCodeForToken(params.code, params.provider);
    
    if (StructKeyExists(local.tokenResponse, "access_token")) {
      // Get user info from provider
      local.userInfo = getUserInfoFromProvider(
        local.tokenResponse.access_token,
        params.provider
      );
      
      // Find or create user
      local.user = findOrCreateUserFromOAuth(local.userInfo, params.provider);
      
      // Log user in
      session.userId = local.user.id;
      session.userEmail = local.user.email;
      session.userName = local.user.fullName();
      
      flashInsert(success="Successfully logged in with #params.provider#");
      redirectTo(route="dashboard");
    } else {
      flashInsert(error="OAuth authentication failed");
      redirectTo(route="login");
    }
  }
  
  private struct function exchangeCodeForToken(required string code, required string provider) {
    local.provider = variables.providers[arguments.provider];
    
    local.http = new Http(
      url=local.provider.tokenUrl,
      method="POST"
    );
    
    local.http.addParam(type="formfield", name="client_id", value=local.provider.clientId);
    local.http.addParam(type="formfield", name="client_secret", value=local.provider.clientSecret);
    local.http.addParam(type="formfield", name="code", value=arguments.code);
    local.http.addParam(type="formfield", name="redirect_uri", 
      value=urlFor(route="oauthCallback", provider=arguments.provider, onlyPath=false));
    local.http.addParam(type="formfield", name="grant_type", value="authorization_code");
    
    local.result = local.http.send().getPrefix();
    return DeserializeJSON(local.result.fileContent);
  }
}
```

## Role-Based Authorization

### Role and Permission Models
```cfml
// /app/models/Role.cfc
component extends="Model" {
  
  function config() {
    table("roles");
    hasMany("userRoles");
    hasMany(name="users", through="userRoles");
    hasMany("rolePermissions");
    hasMany(name="permissions", through="rolePermissions");
    
    validatesPresenceOf("name");
    validatesUniquenessOf("name");
  }
  
  public boolean function hasPermission(required string permissionName) {
    return this.permissions().where("name='#arguments.permissionName#'").count() > 0;
  }
}

// /app/models/Permission.cfc
component extends="Model" {
  
  function config() {
    table("permissions");
    hasMany("rolePermissions");
    hasMany(name="roles", through="rolePermissions");
    
    validatesPresenceOf("name,resource,action");
    validatesUniquenessOf(property="name");
  }
}
```

### Authorization Helper
```cfml
// /app/helpers/AuthorizationHelper.cfc
component {
  
  public boolean function authorize(required string resource, required string action) {
    if (!isLoggedIn()) {
      return false;
    }
    
    local.user = currentUser();
    local.permission = "#arguments.resource#.#arguments.action#";
    
    // Super admin bypass
    if (local.user.hasRole("super_admin")) {
      return true;
    }
    
    // Check specific permission
    return local.user.can(local.permission);
  }
  
  public boolean function authorizeResource(required any resource, required string action) {
    if (!isLoggedIn()) {
      return false;
    }
    
    local.user = currentUser();
    
    // Check ownership
    if (StructKeyExists(arguments.resource, "userId") && 
        arguments.resource.userId == local.user.id) {
      return true;
    }
    
    // Check permission
    local.resourceName = ListLast(GetMetaData(arguments.resource).name, ".");
    return authorize(local.resourceName, arguments.action);
  }
}
```

## Two-Factor Authentication

### Two-Factor Model Methods
```cfml
// Add to User.cfc
component extends="Model" {
  
  function config() {
    // ... existing config ...
    property(name="twoFactorSecret", column="two_factor_secret");
    property(name="twoFactorEnabled", column="two_factor_enabled", defaultValue=false);
  }
  
  public string function generateTwoFactorSecret() {
    local.secret = generateSecureToken(16);
    this.update(twoFactorSecret=local.secret, validate=false);
    return local.secret;
  }
  
  public boolean function verifyTwoFactorCode(required string code) {
    if (!this.twoFactorEnabled || !Len(this.twoFactorSecret)) {
      return false;
    }
    
    // Generate TOTP codes for current and previous 30-second windows
    local.validCodes = [
      generateTOTP(this.twoFactorSecret, 0),
      generateTOTP(this.twoFactorSecret, -1),
      generateTOTP(this.twoFactorSecret, 1)
    ];
    
    return ArrayFind(local.validCodes, arguments.code) > 0;
  }
  
  private string function generateTOTP(required string secret, numeric offset=0) {
    local.time = Int(GetTickCount() / 30000) + arguments.offset;
    // Implementation of TOTP algorithm
    // ... TOTP generation logic ...
    return local.code;
  }
}
```

## Password Management

### BCrypt Plugin for Wheels

The CFWheels BCrypt plugin provides secure password hashing using the BCrypt algorithm, which is recommended for password storage due to its adaptive nature and resistance to brute-force attacks.

#### Installation
```bash
# Install via CommandBox
box install cfwheels-bcrypt
```

#### Plugin Configuration
```cfml
// /app/config/settings.cfm
// Set default BCrypt work factor (10-15 recommended, higher = more secure but slower)
set(bcryptWorkFactor=12);
```

#### BCrypt Plugin API

The plugin provides two main functions:

1. **bCryptHashPW(password, salt)** - Hash a password with a salt
2. **bCryptCheckPW(candidate, hashed)** - Verify a password against a hash
3. **bCryptGenSalt([workFactor])** - Generate a salt with optional work factor

#### Using BCrypt in User Model
```cfml
// /app/models/User.cfc
component extends="Model" {
  
  function config() {
    // Table configuration
    table("users");
    
    // Virtual properties for password handling
    property(name="passwordHash", column="password");
    property(name="password", sql="", dataType="varchar");
    property(name="passwordConfirmation", sql="", dataType="varchar");
    
    // Validations
    validatesPresenceOf("email,firstName,lastName");
    validatesUniquenessOf("email");
    validatesFormatOf(property="email", regex="^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$");
    
    // Password validations
    validatesConfirmationOf(property="password", when="onCreate");
    validatesLengthOf(property="password", minimum=8, when="onCreate", allowBlank=false);
    validatesLengthOf(property="password", minimum=8, when="onUpdate", allowBlank=true);
    
    // Callbacks
    beforeSave("hashPasswordWithBCrypt");
  }
  
  // Hash password using BCrypt plugin
  private void function hashPasswordWithBCrypt() {
    if (StructKeyExists(this, "password") && Len(this.password)) {
      // Use BCrypt plugin to hash password with configurable work factor
      local.workFactor = getSetting("bcryptWorkFactor", 12);
      this.passwordHash = bCryptHashPW(this.password, bCryptGenSalt(local.workFactor));
      
      // Remove plain text passwords from object
      StructDelete(this, "password");
      StructDelete(this, "passwordConfirmation");
    }
  }
  
  // Verify password using BCrypt plugin
  public boolean function checkPassword(required string candidatePassword) {
    // Use BCrypt plugin to check password
    return bCryptCheckPW(arguments.candidatePassword, this.passwordHash);
  }
  
  // Authenticate user with email and password
  public any function authenticate(required string email, required string password) {
    local.user = this.findOne(where="email='#arguments.email#' AND active=1");
    
    if (IsObject(local.user) && local.user.checkPassword(arguments.password)) {
      local.user.updateLoginInfo();
      return local.user;
    }
    
    return false;
  }
  
  // Update password with proper validation
  public boolean function updatePassword(required string currentPassword, 
                                       required string newPassword, 
                                       required string newPasswordConfirmation) {
    // Verify current password
    if (!this.checkPassword(arguments.currentPassword)) {
      this.addError(property="currentPassword", message="Current password is incorrect");
      return false;
    }
    
    // Set new password (will be hashed in callback)
    this.password = arguments.newPassword;
    this.passwordConfirmation = arguments.newPasswordConfirmation;
    
    return this.save();
  }
  
  // Force password reset (admin action)
  public boolean function resetPassword(required string newPassword) {
    this.password = arguments.newPassword;
    this.passwordConfirmation = arguments.newPassword;
    this.passwordResetRequired = true;
    this.passwordResetToken = "";
    
    return this.save(validate=false);
  }
}
```

#### BCrypt Work Factor Guidelines

The work factor determines the computational cost of hashing:

```cfml
// Work factor recommendations by use case
component {
  
  // Development/Testing: Lower factor for speed
  function development() {
    set(bcryptWorkFactor=10);
  }
  
  // Production: Standard security
  function production() {
    set(bcryptWorkFactor=12); // 2^12 iterations
  }
  
  // High Security: Financial, healthcare, etc.
  function highSecurity() {
    set(bcryptWorkFactor=14); // 2^14 iterations
  }
  
  // Performance benchmarks (approximate):
  // Factor 10: ~75ms per hash
  // Factor 12: ~300ms per hash  
  // Factor 14: ~1200ms per hash
  // Factor 15: ~2400ms per hash
}
```

#### Migration: Upgrading from Legacy Hashing

If migrating from MD5, SHA, or other legacy hashing:

```cfml
// /app/models/User.cfc - Migration strategy
component extends="Model" {
  
  function config() {
    property(name="passwordHash", column="password");
    property(name="legacyPassword", column="legacy_password", defaultValue=false);
  }
  
  public boolean function checkPassword(required string candidatePassword) {
    if (this.legacyPassword) {
      // Check against old hash format
      if (Hash(arguments.candidatePassword, "SHA-256") == this.passwordHash) {
        // Password is correct, upgrade to BCrypt
        this.upgradePasswordHash(arguments.candidatePassword);
        return true;
      }
      return false;
    } else {
      // Use BCrypt for newer passwords
      return bCryptCheckPW(arguments.candidatePassword, this.passwordHash);
    }
  }
  
  private void function upgradePasswordHash(required string password) {
    // Upgrade to BCrypt
    this.passwordHash = bCryptHashPW(arguments.password, bCryptGenSalt(12));
    this.legacyPassword = false;
    this.save(validate=false);
    
    // Log the upgrade for security audit
    writeLog(
      file="security",
      text="Password hash upgraded for user #this.id# from legacy to BCrypt"
    );
  }
}
```

#### Testing BCrypt Implementation

```cfscript
// /tests/specs/unit/UserBCryptTest.cfc
component extends="tests.BaseSpec" {
  
  function run() {
    describe("BCrypt Password Hashing", () => {
      
      it("hashes passwords with BCrypt", () => {
        var user = model("User").new(
          email: "bcrypt@test.com",
          password: "MySecurePass123!",
          passwordConfirmation: "MySecurePass123!",
          firstName: "BCrypt",
          lastName: "Test"
        );
        
        user.save();
        
        // Password should be hashed
        expect(user.passwordHash).notToBe("MySecurePass123!");
        expect(user.passwordHash).toMatch("^\$2[ayb]\$.{56}$"); // BCrypt format
        
        // Original password properties should be removed
        expect(user).notToHaveKey("password");
        expect(user).notToHaveKey("passwordConfirmation");
      });
      
      it("verifies passwords correctly", () => {
        var user = createUserWithBCrypt();
        
        // Correct password
        expect(user.checkPassword("TestPassword123!")).toBe(true);
        
        // Incorrect password
        expect(user.checkPassword("WrongPassword")).toBe(false);
        
        // Case sensitive
        expect(user.checkPassword("testpassword123!")).toBe(false);
      });
      
      it("handles work factor appropriately", () => {
        // Test with different work factors
        var salt10 = bCryptGenSalt(10);
        var salt12 = bCryptGenSalt(12);
        var salt14 = bCryptGenSalt(14);
        
        var password = "TestPassword123!";
        
        // Measure hashing time
        var start10 = GetTickCount();
        var hash10 = bCryptHashPW(password, salt10);
        var time10 = GetTickCount() - start10;
        
        var start12 = GetTickCount();
        var hash12 = bCryptHashPW(password, salt12);
        var time12 = GetTickCount() - start12;
        
        // Higher work factor should take longer
        expect(time12).toBeGT(time10);
        
        // All should verify correctly
        expect(bCryptCheckPW(password, hash10)).toBe(true);
        expect(bCryptCheckPW(password, hash12)).toBe(true);
      });
      
      it("generates unique salts", () => {
        var salt1 = bCryptGenSalt();
        var salt2 = bCryptGenSalt();
        
        expect(salt1).notToBe(salt2);
        
        // Same password, different salts = different hashes
        var password = "TestPassword123!";
        var hash1 = bCryptHashPW(password, salt1);
        var hash2 = bCryptHashPW(password, salt2);
        
        expect(hash1).notToBe(hash2);
        
        // Both should still verify
        expect(bCryptCheckPW(password, hash1)).toBe(true);
        expect(bCryptCheckPW(password, hash2)).toBe(true);
      });
    });
  }
  
  private function createUserWithBCrypt() {
    return model("User").create(
      email: "bcrypt.test@example.com",
      password: "TestPassword123!",
      passwordConfirmation: "TestPassword123!",
      firstName: "BCrypt",
      lastName: "User",
      active: true
    );
  }
}
```

#### Security Considerations for BCrypt

1. **Work Factor Selection**:
   - Start with 12 for most applications
   - Increase to 14-15 for high-security applications
   - Monitor authentication performance
   - Plan to increase over time as hardware improves

2. **Password Requirements with BCrypt**:
   ```cfml
   // Combine BCrypt with strong password policies
   validatesLengthOf(property="password", minimum=12, maximum=128);
   validate("passwordComplexity");
   
   private void function passwordComplexity() {
     if (StructKeyExists(this, "password") && Len(this.password)) {
       // Require at least 3 of: uppercase, lowercase, numbers, special chars
       local.hasUpper = ReFind("[A-Z]", this.password);
       local.hasLower = ReFind("[a-z]", this.password);
       local.hasNumber = ReFind("[0-9]", this.password);
       local.hasSpecial = ReFind("[^A-Za-z0-9]", this.password);
       
       local.complexity = 0;
       if (local.hasUpper) local.complexity++;
       if (local.hasLower) local.complexity++;
       if (local.hasNumber) local.complexity++;
       if (local.hasSpecial) local.complexity++;
       
       if (local.complexity < 3) {
         this.addError(
           property="password",
           message="Password must contain at least 3 of: uppercase, lowercase, numbers, special characters"
         );
       }
     }
   }
   ```

3. **BCrypt Limitations**:
   - Maximum password length: 72 bytes
   - For longer passwords, consider pre-hashing with SHA-256:
   ```cfml
   // Handle long passwords
   if (Len(password) > 72) {
     password = Hash(password, "SHA-256");
   }
   hashedPassword = bCryptHashPW(password, bCryptGenSalt(12));
   ```

### Password Reset Flow
```cfml
// /app/controllers/PasswordResets.cfc
component extends="Controller" {
  
  // Request password reset
  function new() {
    // Show reset request form
  }
  
  function create() {
    local.user = model("User").findOne(where="email='#params.email#'");
    
    if (IsObject(local.user)) {
      // Generate reset token
      local.token = generateSecureToken();
      local.hashedToken = Hash(local.token, "SHA-256");
      
      // Store token
      model("PasswordReset").create(
        userId=local.user.id,
        tokenHash=local.hashedToken,
        expiresAt=DateAdd("h", 2, Now())
      );
      
      // Send reset email
      sendEmail(
        to=local.user.email,
        subject="Password Reset Request",
        template="/emails/password_reset",
        resetUrl=urlFor(route="resetPassword", token=local.token, onlyPath=false)
      );
    }
    
    // Always show success message (don't reveal if email exists)
    flashInsert(success="If that email exists, we've sent password reset instructions");
    redirectTo(route="login");
  }
  
  // Reset password form
  function edit() {
    local.hashedToken = Hash(params.token, "SHA-256");
    local.reset = model("PasswordReset").findOne(
      where="tokenHash='#local.hashedToken#' AND expiresAt > NOW() AND usedAt IS NULL"
    );
    
    if (!IsObject(local.reset)) {
      flashInsert(error="Invalid or expired reset token");
      redirectTo(route="login");
    }
    
    user = model("User").findByKey(local.reset.userId);
  }
  
  // Process password reset
  function update() {
    local.hashedToken = Hash(params.token, "SHA-256");
    local.reset = model("PasswordReset").findOne(
      where="tokenHash='#local.hashedToken#' AND expiresAt > NOW() AND usedAt IS NULL",
      include="user"
    );
    
    if (!IsObject(local.reset)) {
      flashInsert(error="Invalid or expired reset token");
      redirectTo(route="login");
    }
    
    // Update password
    local.reset.user.password = params.password;
    local.reset.user.passwordConfirmation = params.passwordConfirmation;
    
    if (local.reset.user.save()) {
      // Mark token as used
      local.reset.update(usedAt=Now(), validate=false);
      
      // Log user in
      session.userId = local.reset.user.id;
      session.userEmail = local.reset.user.email;
      
      flashInsert(success="Password successfully reset");
      redirectTo(route="dashboard");
    } else {
      user = local.reset.user;
      renderView("edit");
    }
  }
}
```

## Security Best Practices

### 1. Password Security
```cfml
// Use CFWheels BCrypt plugin for password hashing
// First install: box install cfwheels-bcrypt
local.salt = bCryptGenSalt(12); // Work factor of 12
local.hashedPassword = bCryptHashPW(password, salt);

// Verify password
local.isValid = bCryptCheckPW(candidatePassword, hashedPassword);

// Never store plain text passwords
// Always use SSL/TLS in production
// Implement password complexity requirements
// Consider password history to prevent reuse
```

### 2. Session Security
```cfml
// Regenerate session ID on login
SessionRotate();

// Set secure session cookies
this.sessioncookie = {
  httponly: true,
  secure: true, // HTTPS only
  samesite: "Lax",
  timeout: CreateTimeSpan(0, 0, 30, 0) // 30 minutes
};

// Clear sensitive session data on logout
StructClear(session);
```

### 3. CSRF Protection
```cfml
// Automatically included in forms
#authenticityTokenField()#

// Verify in controller
verifies(authenticityToken=true);
```

### 4. Rate Limiting
```cfml
// Track failed login attempts
public boolean function checkRateLimit(required string identifier) {
  local.key = "rate_limit_#arguments.identifier#";
  local.attempts = application.cache.get(local.key, 0);
  
  if (local.attempts >= 5) {
    return false; // Too many attempts
  }
  
  application.cache.set(local.key, local.attempts + 1, CreateTimeSpan(0, 0, 15, 0));
  return true;
}
```

### 5. Input Validation
```cfml
// Always validate and sanitize input
params.email = sanitizeEmail(params.email);
params.username = reReplace(params.username, "[^a-zA-Z0-9_-]", "", "all");

// Use parameterized queries (automatic in Wheels ORM)
// Never concatenate user input into SQL
```

### 6. Secure Headers
```cfml
// Set security headers in Application.cfc
header name="X-Frame-Options" value="SAMEORIGIN";
header name="X-Content-Type-Options" value="nosniff";
header name="X-XSS-Protection" value="1; mode=block";
header name="Strict-Transport-Security" value="max-age=31536000; includeSubDomains";
```

## Testing Authentication

### Authentication Tests
```cfscript
component extends="tests.BaseSpec" {
  function run() {
    describe("Authentication", () => {
      beforeEach(() => {
        reload();
        createTestUser();
      });
      
      it("authenticates valid credentials", () => {
        var result = processRequest(
          route="session",
          method="POST",
          params={
            email: "test@example.com",
            password: "password123"
          }
        );
        
        expect(session.userId).toBeGT(0);
        expect(result.redirect).toBe(true);
      });
      
      it("rejects invalid credentials", () => {
        var result = processRequest(
          route="session",
          method="POST",
          params={
            email: "test@example.com",
            password: "wrongpassword"
          }
        );
        
        expect(session).notToHaveKey("userId");
        expect(flash("error")).toBe("Invalid email or password");
      });
      
      it("requires authentication for protected routes", () => {
        var result = processRequest(route="adminDashboard");
        
        expect(result.redirect).toBe(true);
        expect(result.redirectUrl).toInclude("/login");
      });
    });
  }
  
  private void function createTestUser() {
    model("User").create(
      email: "test@example.com",
      password: "password123",
      firstName: "Test",
      lastName: "User",
      active: true
    );
  }
}
```

This comprehensive authentication pattern guide provides everything needed to implement secure authentication and authorization in Wheels applications.