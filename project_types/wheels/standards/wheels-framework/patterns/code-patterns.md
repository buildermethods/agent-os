---
description: Wheels Framework Code Patterns and Best Practices
version: 2.0
encoding: UTF-8
---

# Wheels Code Patterns

Comprehensive code patterns and best practices for Wheels framework development with real-world examples.

## Table of Contents
- [Controller Patterns](#controller-patterns)
- [Model Patterns](#model-patterns)
- [Service Layer Patterns](#service-layer-patterns)
- [Repository Pattern](#repository-pattern)
- [Event-Driven Patterns](#event-driven-patterns)
- [Caching Patterns](#caching-patterns)
- [Background Job Patterns](#background-job-patterns)
- [Testing Patterns](#testing-patterns)
- [Error Handling Patterns](#error-handling-patterns)
- [Performance Patterns](#performance-patterns)

## Controller Patterns

### Basic CRUD Controller
```cfml
component extends="Controller" {
  
  function config() {
    // Always use config() for initialization, NOT init()
    provides("html,json");
    filters("authenticate", except="index,show");
    filters("findPost", only="show,edit,update,delete");
  }
  
  // GET /posts
  function index() {
    posts = model("Post").findAll(
      page=params.page,
      perPage=20,
      order="createdAt DESC",
      include="author,category"
    );
    renderWith(posts);
  }
  
  // GET /posts/:key
  function show() {
    // post is set by findPost filter
    renderWith(post);
  }
  
  // GET /posts/new
  function new() {
    post = model("Post").new();
    categories = model("Category").findAll(order="name");
  }
  
  // POST /posts
  function create() {
    post = model("Post").create(params.post);
    if (post.hasErrors()) {
      categories = model("Category").findAll(order="name");
      renderView("new");
    } else {
      flashInsert(success="Post created successfully!");
      redirectTo(route="post", key=post.key());
    }
  }
  
  // GET /posts/:key/edit
  function edit() {
    categories = model("Category").findAll(order="name");
  }
  
  // PUT/PATCH /posts/:key
  function update() {
    if (post.update(params.post)) {
      flashInsert(success="Post updated successfully!");
      redirectTo(route="post", key=post.key());
    } else {
      categories = model("Category").findAll(order="name");
      renderView("edit");
    }
  }
  
  // DELETE /posts/:key
  function delete() {
    post.delete();
    flashInsert(success="Post deleted successfully!");
    redirectTo(route="posts");
  }
  
  // Filter to find post
  private void function findPost() {
    post = model("Post").findByKey(params.key);
    if (!IsObject(post)) {
      flashInsert(error="Post not found");
      redirectTo(route="posts");
    }
  }
}
```

### API Controller with Content Negotiation
```cfml
component extends="Controller" {
  
  function config() {
    // Only respond to JSON requests
    onlyProvides("json");
    
    // Set common variables for all actions
    filters("setApiHeaders,checkApiToken");
    filters("setRateLimits", except="options");
  }
  
  function setApiHeaders() {
    header name="X-API-Version" value="1.0";
    header name="X-RateLimit-Limit" value="1000";
    header name="X-RateLimit-Remaining" value=getRateLimitRemaining();
  }
  
  function checkApiToken() {
    if (!StructKeyExists(request.headers, "X-API-Token")) {
      renderWith(data={error: "Missing API token"}, status=401);
      abort;
    }
    
    local.token = model("ApiToken").findOne(
      where="token='#request.headers['X-API-Token']#' AND active=1"
    );
    
    if (!IsObject(local.token) || local.token.isExpired()) {
      renderWith(data={error: "Invalid or expired token"}, status=401);
      abort;
    }
    
    request.apiUser = local.token.user();
  }
  
  // GET /api/users
  function index() {
    local.users = model("User").findAll(
      select="id,name,email,createdAt",
      order="name ASC",
      page=params.page ?: 1,
      perPage=params.perPage ?: 20
    );
    renderWith(local.users);
  }
  
  // POST /api/users
  function create() {
    local.user = model("User").create(params.user);
    if (local.user.hasErrors()) {
      renderWith(data=local.user.allErrors(), status=422);
    } else {
      renderWith(data=local.user, status=201);
    }
  }
}
```

### Admin Controller with Authorization
```cfml
component extends="Controller" {
  
  function config() {
    filters("requireAdmin");
    filters("logAdminAction", except="index,show");
  }
  
  private void function requireAdmin() {
    if (!isLoggedIn() || !currentUser().hasRole("admin")) {
      flashInsert(error="Access denied");
      redirectTo(route="home");
    }
  }
  
  private void function logAdminAction() {
    model("AdminLog").create({
      userId: currentUser().id,
      action: params.action,
      controller: params.controller,
      params: SerializeJSON(params),
      ipAddress: request.remoteAddress
    });
  }
  
  function dashboard() {
    stats = {
      users: model("User").count(),
      posts: model("Post").count(),
      comments: model("Comment").count(),
      revenue: model("Order").sum("total")
    };
  }
}
```

## Model Patterns

### Model with Associations and Validations
```cfml
component extends="Model" {
  
  function config() {
    // Table configuration
    table("users");
    
    // Associations
    hasMany("posts", dependent="destroy");
    hasMany("comments");
    belongsTo("role");
    hasOne("profile", dependent="destroy");
    hasMany(name="friendships", foreignKey="userId");
    hasMany(name="friends", through="friendships");
    
    // Validations
    validatesPresenceOf("firstName,lastName,email");
    validatesUniquenessOf("email", message="Email already taken");
    validatesFormatOf(
      property="email",
      regex="^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$",
      message="Invalid email format"
    );
    validatesLengthOf(property="firstName", minimum=2, maximum=50);
    validatesLengthOf(property="lastName", minimum=2, maximum=50);
    validatesConfirmationOf(property="password", when="onCreate");
    validatesLengthOf(property="password", minimum=8, when="onCreate");
    
    // Custom validation
    validate("validateAge");
    
    // Callbacks
    beforeValidation("sanitizeInput");
    beforeCreate("hashPassword,setDefaults");
    afterCreate("sendWelcomeEmail,createDefaultProfile");
    beforeUpdate("updateTimestamp");
    afterSave("clearCache");
    
    // Calculated properties
    property(name="fullName", sql="CONCAT(firstName, ' ', lastName)");
    property(name="postCount", sql="(SELECT COUNT(*) FROM posts WHERE userId = users.id)");
    property(name="age", sql="TIMESTAMPDIFF(YEAR, birthDate, CURDATE())");
    
    // Scopes
    scope("active", where="status='active' AND emailVerified=1");
    scope("recent", where="createdAt >= DATE_SUB(NOW(), INTERVAL 30 DAY)");
    scope("withPosts", include="posts");
  }
  
  // Custom validation
  private void function validateAge() {
    if (StructKeyExists(this, "birthDate") && this.birthDate != "") {
      local.age = DateDiff("yyyy", this.birthDate, Now());
      if (local.age < 13) {
        addError(property="birthDate", message="Must be at least 13 years old");
      }
    }
  }
  
  // Callbacks
  private void function sanitizeInput() {
    if (StructKeyExists(this, "email")) {
      this.email = Trim(LCase(this.email));
    }
    if (StructKeyExists(this, "firstName")) {
      this.firstName = Trim(this.firstName);
    }
    if (StructKeyExists(this, "lastName")) {
      this.lastName = Trim(this.lastName);
    }
  }
  
  private void function hashPassword() {
    if (StructKeyExists(this, "password") && Len(this.password)) {
      this.passwordHash = BCryptHashPassword(this.password);
      StructDelete(this, "password");
    }
  }
  
  private void function setDefaults() {
    if (!StructKeyExists(this, "status")) {
      this.status = "pending";
    }
    if (!StructKeyExists(this, "roleId")) {
      this.roleId = model("Role").findOne(where="name='user'").id;
    }
  }
  
  private void function sendWelcomeEmail() {
    // Queue welcome email
    application.emailQueue.add({
      to: this.email,
      subject: "Welcome to Our App!",
      template: "welcome",
      data: {user: this}
    });
  }
  
  // Public instance methods
  public boolean function isActive() {
    return this.status == "active" && this.emailVerified;
  }
  
  public boolean function canEdit(required any resource) {
    if (this.hasRole("admin")) return true;
    if (StructKeyExists(arguments.resource, "userId")) {
      return arguments.resource.userId == this.id;
    }
    return false;
  }
  
  public boolean function hasRole(required string roleName) {
    if (!StructKeyExists(this, "role")) {
      this.role = this.role(); // Load association if not loaded
    }
    return this.role.name == arguments.roleName;
  }
  
  // Custom finders
  public query function findActive() {
    return this.findAll(
      where="status='active' AND emailVerified=1",
      order="lastName ASC, firstName ASC"
    );
  }
  
  public any function findByEmail(required string email) {
    return this.findOne(where="email='#LCase(arguments.email)#'");
  }
}
```

### Model with Complex Business Logic
```cfml
component extends="Model" {
  
  function config() {
    table("orders");
    belongsTo("user");
    hasMany("orderItems", dependent="destroy");
    hasMany(name="products", through="orderItems");
    
    // Allow nested attributes for order items
    nestedProperties(
      association="orderItems",
      allowDelete=true,
      rejectIf="isBlank"
    );
    
    // State machine
    beforeSave("validateStateTransition");
  }
  
  // State machine implementation
  public boolean function canTransitionTo(required string newStatus) {
    local.transitions = {
      "pending": ["processing", "cancelled"],
      "processing": ["shipped", "cancelled"],
      "shipped": ["delivered", "returned"],
      "delivered": ["returned"],
      "cancelled": [],
      "returned": ["refunded"]
    };
    
    if (!StructKeyExists(local.transitions, this.status)) {
      return false;
    }
    
    return ArrayFind(local.transitions[this.status], arguments.newStatus) > 0;
  }
  
  private void function validateStateTransition() {
    if (StructKeyExists(this, "status") && this.propertyIsChanged("status")) {
      local.oldStatus = this.changedFrom("status");
      if (!canTransitionTo(this.status)) {
        addError(
          property="status",
          message="Cannot transition from #local.oldStatus# to #this.status#"
        );
      }
    }
  }
  
  // Business logic methods
  public numeric function calculateTotal() {
    local.total = 0;
    for (local.item in this.orderItems()) {
      local.total += local.item.quantity * local.item.price;
    }
    return local.total;
  }
  
  public numeric function calculateTax(numeric rate=0.08) {
    return Round(calculateSubtotal() * arguments.rate * 100) / 100;
  }
  
  public numeric function calculateSubtotal() {
    return this.orderItems().reduce(function(total, item) {
      return arguments.total + (arguments.item.quantity * arguments.item.price);
    }, 0);
  }
  
  public boolean function ship(required string trackingNumber) {
    if (this.status != "processing") {
      return false;
    }
    
    this.status = "shipped";
    this.trackingNumber = arguments.trackingNumber;
    this.shippedAt = Now();
    
    if (this.save()) {
      // Send shipping notification
      sendShippingNotification();
      return true;
    }
    return false;
  }
  
  private boolean function isBlank(required struct properties) {
    return !StructKeyExists(arguments.properties, "productId") ||
           !Len(arguments.properties.productId) ||
           Val(arguments.properties.quantity ?: 0) <= 0;
  }
}
```

## Service Layer Patterns

### Service Object Pattern
```cfml
// /app/services/UserRegistrationService.cfc
component {
  
  property name="userModel" inject="model:User";
  property name="emailService" inject="EmailService";
  property name="logger" inject="LogService";
  property name="eventBus" inject="EventBus";
  
  public struct function register(required struct userData) {
    transaction {
      try {
        // Validate input
        local.errors = validateRegistrationData(arguments.userData);
        if (!StructIsEmpty(local.errors)) {
          return {success: false, errors: local.errors};
        }
        
        // Check for existing user
        if (userExists(arguments.userData.email)) {
          return {success: false, error: "Email already registered"};
        }
        
        // Create user
        local.user = variables.userModel.create(arguments.userData);
        
        if (local.user.hasErrors()) {
          transaction action="rollback";
          return {success: false, errors: local.user.allErrors()};
        }
        
        // Create profile
        local.profile = createUserProfile(local.user);
        
        // Send verification email
        local.verificationToken = generateVerificationToken(local.user);
        variables.emailService.sendVerificationEmail(local.user, local.verificationToken);
        
        // Log registration
        variables.logger.info("User registered: #local.user.email#");
        
        // Dispatch event
        variables.eventBus.dispatch("user.registered", {user: local.user});
        
        transaction action="commit";
        return {success: true, user: local.user, profile: local.profile};
        
      } catch (any e) {
        transaction action="rollback";
        variables.logger.error("Registration failed: #e.message#", e);
        return {success: false, error: "Registration failed. Please try again."};
      }
    }
  }
  
  private struct function validateRegistrationData(required struct data) {
    local.errors = {};
    
    // Email validation
    if (!StructKeyExists(arguments.data, "email") || !IsValid("email", arguments.data.email)) {
      local.errors.email = "Valid email address required";
    }
    
    // Password validation
    if (!StructKeyExists(arguments.data, "password") || Len(arguments.data.password) < 8) {
      local.errors.password = "Password must be at least 8 characters";
    }
    
    // Password complexity
    if (StructKeyExists(arguments.data, "password")) {
      if (!ReFind("[A-Z]", arguments.data.password)) {
        local.errors.password = "Password must contain uppercase letter";
      }
      if (!ReFind("[0-9]", arguments.data.password)) {
        local.errors.password = "Password must contain number";
      }
    }
    
    // Terms acceptance
    if (!StructKeyExists(arguments.data, "acceptTerms") || !arguments.data.acceptTerms) {
      local.errors.acceptTerms = "You must accept the terms and conditions";
    }
    
    return local.errors;
  }
  
  private boolean function userExists(required string email) {
    return variables.userModel.count(where="email='#arguments.email#'") > 0;
  }
  
  private any function createUserProfile(required any user) {
    return model("Profile").create({
      userId: arguments.user.id,
      displayName: arguments.user.firstName & " " & arguments.user.lastName,
      bio: "",
      avatarUrl: "/images/default-avatar.png"
    });
  }
  
  private string function generateVerificationToken(required any user) {
    local.token = CreateUUID();
    model("VerificationToken").create({
      userId: arguments.user.id,
      token: local.token,
      expiresAt: DateAdd("d", 7, Now())
    });
    return local.token;
  }
}
```

### Command Pattern
```cfml
// /app/commands/ProcessOrderCommand.cfc
component implements="ICommand" {
  
  property name="orderId" type="numeric";
  property name="orderService" inject="OrderService";
  property name="inventoryService" inject="InventoryService";
  property name="paymentService" inject="PaymentService";
  
  public void function init(required numeric orderId) {
    variables.orderId = arguments.orderId;
  }
  
  public struct function execute() {
    local.order = model("Order").findByKey(variables.orderId);
    
    if (!IsObject(local.order)) {
      return {success: false, error: "Order not found"};
    }
    
    try {
      // Validate order can be processed
      if (!local.order.canProcess()) {
        return {success: false, error: "Order cannot be processed in current state"};
      }
      
      // Reserve inventory
      local.reservationResult = variables.inventoryService.reserveItems(local.order.orderItems());
      if (!local.reservationResult.success) {
        return {success: false, error: "Insufficient inventory"};
      }
      
      // Process payment
      local.paymentResult = variables.paymentService.chargeOrder(local.order);
      if (!local.paymentResult.success) {
        // Release inventory reservation
        variables.inventoryService.releaseReservation(local.reservationResult.reservationId);
        return {success: false, error: "Payment failed: #local.paymentResult.error#"};
      }
      
      // Update order status
      local.order.update({
        status: "processing",
        paymentId: local.paymentResult.paymentId,
        processedAt: Now()
      });
      
      // Commit inventory
      variables.inventoryService.commitReservation(local.reservationResult.reservationId);
      
      // Send confirmation email
      sendOrderConfirmation(local.order);
      
      return {success: true, order: local.order};
      
    } catch (any e) {
      // Rollback any changes
      if (IsDefined("local.reservationResult")) {
        variables.inventoryService.releaseReservation(local.reservationResult.reservationId);
      }
      if (IsDefined("local.paymentResult")) {
        variables.paymentService.refund(local.paymentResult.paymentId);
      }
      
      return {success: false, error: e.message};
    }
  }
  
  public void function undo() {
    // Implement undo logic for command pattern
    local.order = model("Order").findByKey(variables.orderId);
    if (IsObject(local.order) && local.order.status == "processing") {
      // Refund payment
      if (Len(local.order.paymentId)) {
        variables.paymentService.refund(local.order.paymentId);
      }
      
      // Return inventory
      variables.inventoryService.returnItems(local.order.orderItems());
      
      // Update order status
      local.order.update({status: "cancelled", cancelledAt: Now()});
    }
  }
}
```

## Repository Pattern

### Repository Implementation
```cfml
// /app/repositories/UserRepository.cfc
component singleton {
  
  property name="cache" inject="CacheService";
  property name="logger" inject="LogService";
  
  public any function findById(required numeric id) {
    local.cacheKey = "user_#arguments.id#";
    
    // Try cache first
    local.cached = variables.cache.get(local.cacheKey);
    if (!IsNull(local.cached)) {
      variables.logger.debug("Cache hit for user #arguments.id#");
      return local.cached;
    }
    
    // Load from database
    local.user = model("User").findByKey(
      key=arguments.id,
      include="role,profile"
    );
    
    if (IsObject(local.user)) {
      variables.cache.set(local.cacheKey, local.user, 300);
    }
    
    return local.user;
  }
  
  public array function findActiveUsers(
    numeric page=1,
    numeric perPage=20,
    string sortBy="lastName"
  ) {
    local.cacheKey = "active_users_#arguments.page#_#arguments.perPage#_#arguments.sortBy#";
    
    local.cached = variables.cache.get(local.cacheKey);
    if (!IsNull(local.cached)) {
      return local.cached;
    }
    
    local.users = model("User").findAll(
      where="status='active' AND emailVerified=1",
      order="#arguments.sortBy# ASC",
      page=arguments.page,
      perPage=arguments.perPage,
      include="role,profile",
      returnAs="objects"
    );
    
    variables.cache.set(local.cacheKey, local.users, 60);
    return local.users;
  }
  
  public struct function search(
    required string query,
    numeric limit=50
  ) {
    local.searchTerm = "%" & arguments.query & "%";
    
    local.results = model("User").findAll(
      where="(firstName LIKE :term OR lastName LIKE :term OR email LIKE :term) AND status='active'",
      params={term: local.searchTerm},
      order="lastName ASC, firstName ASC",
      maxRows=arguments.limit,
      select="id,firstName,lastName,email,avatarUrl"
    );
    
    return {
      results: local.results,
      count: ArrayLen(local.results),
      query: arguments.query
    };
  }
  
  public boolean function save(required any user) {
    local.result = arguments.user.save();
    
    if (local.result) {
      // Invalidate caches
      invalidateUserCache(arguments.user.id);
      variables.logger.info("User #arguments.user.id# saved");
    }
    
    return local.result;
  }
  
  public boolean function delete(required any user) {
    local.userId = arguments.user.id;
    local.result = arguments.user.delete();
    
    if (local.result) {
      invalidateUserCache(local.userId);
      variables.logger.info("User #local.userId# deleted");
    }
    
    return local.result;
  }
  
  private void function invalidateUserCache(required numeric userId) {
    variables.cache.delete("user_#arguments.userId#");
    variables.cache.deletePattern("active_users_*");
    variables.cache.deletePattern("user_search_*");
  }
}
```

## Event-Driven Patterns

### Event Bus Implementation
```cfml
// /app/services/EventBus.cfc
component singleton {
  
  property name="listeners" type="struct";
  property name="logger" inject="LogService";
  
  public void function init() {
    variables.listeners = {};
    variables.asyncMode = false;
  }
  
  public void function subscribe(
    required string event,
    required any handler,
    numeric priority=5
  ) {
    if (!StructKeyExists(variables.listeners, arguments.event)) {
      variables.listeners[arguments.event] = [];
    }
    
    ArrayAppend(variables.listeners[arguments.event], {
      handler: arguments.handler,
      priority: arguments.priority
    });
    
    // Sort by priority
    ArraySort(variables.listeners[arguments.event], function(a, b) {
      return a.priority - b.priority;
    });
    
    variables.logger.debug("Subscribed handler to event: #arguments.event#");
  }
  
  public void function dispatch(
    required string event,
    struct data={},
    boolean async=false
  ) {
    variables.logger.info("Dispatching event: #arguments.event#");
    
    if (!StructKeyExists(variables.listeners, arguments.event)) {
      return;
    }
    
    for (local.listener in variables.listeners[arguments.event]) {
      if (arguments.async) {
        thread name="event_#CreateUUID()#" listener=local.listener data=arguments.data {
          handleEvent(attributes.listener.handler, attributes.data);
        }
      } else {
        handleEvent(local.listener.handler, arguments.data);
      }
    }
  }
  
  private void function handleEvent(required any handler, required struct data) {
    try {
      if (IsCustomFunction(arguments.handler)) {
        arguments.handler(arguments.data);
      } else if (IsObject(arguments.handler)) {
        if (StructKeyExists(arguments.handler, "handle")) {
          arguments.handler.handle(arguments.data);
        }
      } else if (IsStruct(arguments.handler)) {
        invoke(
          arguments.handler.component,
          arguments.handler.method,
          {data: arguments.data}
        );
      }
    } catch (any e) {
      variables.logger.error("Event handler error: #e.message#", e);
    }
  }
}

// Event handler example
component implements="IEventHandler" {
  
  public void function handle(required struct data) {
    if (StructKeyExists(arguments.data, "user")) {
      // Handle user-related event
      sendWelcomeEmail(arguments.data.user);
      createAuditLog("user.registered", arguments.data.user.id);
    }
  }
}
```

## Caching Patterns

### Multi-Level Cache Implementation
```cfml
// /app/services/CacheService.cfc
component singleton {
  
  property name="memoryCache" type="struct";
  property name="redisClient" inject="RedisClient";
  property name="stats" type="struct";
  
  public void function init() {
    variables.memoryCache = {};
    variables.stats = {hits: 0, misses: 0};
    variables.ttlDefault = 3600; // 1 hour
  }
  
  public any function get(required string key) {
    // L1 Cache: Memory
    if (StructKeyExists(variables.memoryCache, arguments.key)) {
      local.cached = variables.memoryCache[arguments.key];
      if (local.cached.expires > Now()) {
        variables.stats.hits++;
        return local.cached.value;
      } else {
        StructDelete(variables.memoryCache, arguments.key);
      }
    }
    
    // L2 Cache: Redis
    local.redisValue = variables.redisClient.get(arguments.key);
    if (!IsNull(local.redisValue)) {
      // Promote to L1 cache
      variables.memoryCache[arguments.key] = {
        value: local.redisValue,
        expires: DateAdd("n", 5, Now()) // 5 minutes in memory
      };
      variables.stats.hits++;
      return local.redisValue;
    }
    
    variables.stats.misses++;
    return JavaCast("null", "");
  }
  
  public void function set(
    required string key,
    required any value,
    numeric ttl=0
  ) {
    local.ttl = arguments.ttl > 0 ? arguments.ttl : variables.ttlDefault;
    local.expires = DateAdd("s", local.ttl, Now());
    
    // Set in L1 cache
    variables.memoryCache[arguments.key] = {
      value: arguments.value,
      expires: local.expires
    };
    
    // Set in L2 cache
    variables.redisClient.setex(arguments.key, local.ttl, arguments.value);
  }
  
  public void function delete(required string key) {
    StructDelete(variables.memoryCache, arguments.key);
    variables.redisClient.del(arguments.key);
  }
  
  public void function deletePattern(required string pattern) {
    // Clear from memory cache
    for (local.key in variables.memoryCache) {
      if (ReFindNoCase(arguments.pattern, local.key)) {
        StructDelete(variables.memoryCache, local.key);
      }
    }
    
    // Clear from Redis
    local.keys = variables.redisClient.keys(arguments.pattern);
    if (ArrayLen(local.keys)) {
      variables.redisClient.del(local.keys);
    }
  }
  
  public void function flush() {
    variables.memoryCache = {};
    variables.redisClient.flushdb();
  }
  
  public struct function getStats() {
    local.stats = Duplicate(variables.stats);
    local.stats.hitRate = local.stats.hits > 0 
      ? (local.stats.hits / (local.stats.hits + local.stats.misses)) * 100 
      : 0;
    local.stats.memoryCacheSize = StructCount(variables.memoryCache);
    return local.stats;
  }
}
```

## Background Job Patterns

### Job Queue with Retry Logic
```cfml
// /app/jobs/EmailJob.cfc
component extends="BaseJob" {
  
  property name="to" type="string";
  property name="subject" type="string";
  property name="template" type="string";
  property name="data" type="struct";
  
  public void function perform() {
    try {
      // Send email
      local.result = sendEmail(
        to=variables.to,
        subject=variables.subject,
        template="/emails/#variables.template#",
        argumentCollection=variables.data
      );
      
      if (!local.result.success) {
        throw(message="Email delivery failed: #local.result.error#");
      }
      
      // Log success
      logInfo("Email sent successfully to #variables.to#");
      
    } catch (any e) {
      // Log error
      logError("Email job failed: #e.message#");
      
      // Determine if we should retry
      if (shouldRetry(e)) {
        throw; // Re-throw to trigger retry
      } else {
        // Mark as permanently failed
        markAsFailed(e.message);
      }
    }
  }
  
  private boolean function shouldRetry(required any exception) {
    // Don't retry for permanent failures
    local.permanentErrors = [
      "Invalid email address",
      "Template not found",
      "Blacklisted recipient"
    ];
    
    for (local.error in local.permanentErrors) {
      if (FindNoCase(local.error, arguments.exception.message)) {
        return false;
      }
    }
    
    return true;
  }
}

// Job processor
component {
  
  property name="logger" inject="LogService";
  
  public void function processQueue(string queue="default", numeric limit=10) {
    local.jobs = model("Job").findAll(
      where="queue='#arguments.queue#' AND status IN ('pending','retry') AND runAt <= NOW()",
      order="priority DESC, createdAt ASC",
      maxRows=arguments.limit
    );
    
    for (local.job in local.jobs) {
      thread name="job_#local.job.id#" job=local.job {
        processJob(attributes.job);
      }
    }
  }
  
  private void function processJob(required any job) {
    try {
      // Update status
      arguments.job.update({
        status: "processing",
        startedAt: Now(),
        attempts: arguments.job.attempts + 1
      });
      
      // Create job instance
      local.jobClass = CreateObject("component", arguments.job.className);
      StructAppend(local.jobClass, DeserializeJSON(arguments.job.payload));
      
      // Execute job
      local.jobClass.perform();
      
      // Mark as completed
      arguments.job.update({
        status: "completed",
        completedAt: Now()
      });
      
      variables.logger.info("Job #arguments.job.id# completed successfully");
      
    } catch (any e) {
      handleJobFailure(arguments.job, e);
    }
  }
  
  private void function handleJobFailure(required any job, required any exception) {
    local.maxAttempts = arguments.job.maxAttempts ?: 3;
    
    if (arguments.job.attempts < local.maxAttempts) {
      // Calculate exponential backoff
      local.delay = (2 ^ arguments.job.attempts) * 60; // Minutes
      
      arguments.job.update({
        status: "retry",
        runAt: DateAdd("n", local.delay, Now()),
        lastError: arguments.exception.message
      });
      
      variables.logger.warn("Job #arguments.job.id# failed, will retry in #local.delay# minutes");
    } else {
      arguments.job.update({
        status: "failed",
        failedAt: Now(),
        lastError: arguments.exception.message
      });
      
      variables.logger.error("Job #arguments.job.id# permanently failed after #local.maxAttempts# attempts");
      
      // Send alert for critical jobs
      if (arguments.job.alertOnFailure) {
        sendJobFailureAlert(arguments.job);
      }
    }
  }
}
```

## Testing Patterns

### Unit Test Example
```cfscript
component extends="tests.BaseSpec" {
  
  function beforeAll() {
    variables.userService = createMock("services.UserService");
    variables.emailService = createMock("services.EmailService");
  }
  
  function run() {
    describe("UserService", () => {
      
      beforeEach(() => {
        // Reset database to known state
        resetDatabase();
        variables.testUser = createTestUser();
      });
      
      describe("registration", () => {
        it("registers valid user", () => {
          var userData = {
            email: "newuser@example.com",
            password: "SecurePass123!",
            firstName: "John",
            lastName: "Doe",
            acceptTerms: true
          };
          
          var result = variables.userService.register(userData);
          
          expect(result.success).toBe(true);
          expect(result.user).toBeObject();
          expect(result.user.email).toBe(userData.email);
        });
        
        it("rejects duplicate email", () => {
          var userData = {
            email: variables.testUser.email,
            password: "SecurePass123!",
            firstName: "Jane",
            lastName: "Doe",
            acceptTerms: true
          };
          
          var result = variables.userService.register(userData);
          
          expect(result.success).toBe(false);
          expect(result.error).toInclude("already registered");
        });
        
        it("validates password complexity", () => {
          var userData = {
            email: "test@example.com",
            password: "weak",
            firstName: "Test",
            lastName: "User",
            acceptTerms: true
          };
          
          var result = variables.userService.register(userData);
          
          expect(result.success).toBe(false);
          expect(result.errors).toHaveKey("password");
        });
        
        it("sends verification email", () => {
          var userData = getValidUserData();
          
          // Setup mock expectation
          variables.emailService
            .$("sendVerificationEmail")
            .$times(1)
            .$results(true);
          
          var result = variables.userService.register(userData);
          
          expect(result.success).toBe(true);
          expect(variables.emailService.$times()).toBe(1);
        });
      });
    });
  }
  
  private struct function getValidUserData() {
    return {
      email: "test_#CreateUUID()#@example.com",
      password: "SecurePass123!",
      firstName: "Test",
      lastName: "User",
      acceptTerms: true
    };
  }
  
  private any function createTestUser() {
    return model("User").create(getValidUserData());
  }
  
  private void function resetDatabase() {
    model("User").deleteAll(where="email LIKE 'test_%'");
  }
}
```

## Error Handling Patterns

### Global Error Handler
```cfml
// /app/controllers/Controller.cfc
component extends="wheels.Controller" {
  
  function config() {
    filters(through="errorHandler");
  }
  
  private void function errorHandler() {
    try {
      // Continue with request processing
    } catch (ValidationException e) {
      handleValidationError(e);
    } catch (NotFoundException e) {
      handleNotFound(e);
    } catch (UnauthorizedException e) {
      handleUnauthorized(e);
    } catch (RateLimitException e) {
      handleRateLimit(e);
    } catch (any e) {
      handleGenericError(e);
    }
  }
  
  private void function handleValidationError(required any exception) {
    logError("Validation error", arguments.exception);
    
    if (isApiRequest()) {
      renderWith(data={
        error: true,
        message: "Validation failed",
        errors: arguments.exception.errors
      }, status=422);
    } else {
      flashInsert(error="Please correct the errors below");
      renderView(arguments.exception.view ?: "edit");
    }
  }
  
  private void function handleNotFound(required any exception) {
    logError("Resource not found", arguments.exception);
    
    if (isApiRequest()) {
      renderWith(data={
        error: true,
        message: "Resource not found"
      }, status=404);
    } else {
      renderView("/errors/404");
    }
  }
  
  private void function handleUnauthorized(required any exception) {
    logError("Unauthorized access attempt", arguments.exception);
    
    if (isApiRequest()) {
      renderWith(data={
        error: true,
        message: "Authentication required"
      }, status=401);
    } else {
      flashInsert(warning="Please log in to continue");
      redirectTo(route="login", returnUrl=request.cgi.PATH_INFO);
    }
  }
  
  private void function handleGenericError(required any exception) {
    // Log detailed error
    logError("Application error", arguments.exception);
    
    // Send error notification in production
    if (get("environment") == "production") {
      sendErrorNotification(arguments.exception);
    }
    
    if (isApiRequest()) {
      renderWith(data={
        error: true,
        message: "An error occurred processing your request",
        reference: arguments.exception.errorCode ?: CreateUUID()
      }, status=500);
    } else {
      renderView("/errors/500");
    }
  }
  
  private void function logError(required string message, required any exception) {
    writeLog(
      type="error",
      file="application",
      text="#arguments.message#: #arguments.exception.message# | #arguments.exception.detail#"
    );
  }
  
  private boolean function isApiRequest() {
    return FindNoCase("/api/", request.cgi.PATH_INFO) || 
           request.cgi.HTTP_ACCEPT == "application/json";
  }
}
```

## Performance Patterns

### Query Optimization
```cfml
// Prevent N+1 queries with eager loading
component extends="Model" {
  
  function config() {
    hasMany("comments");
    belongsTo("author");
  }
  
  // Bad: N+1 queries
  public array function getPostsWithCommentCountBad() {
    local.posts = this.findAll();
    for (local.post in local.posts) {
      local.post.commentCount = local.post.comments().count(); // Extra query per post!
    }
    return local.posts;
  }
  
  // Good: Single query with calculated property
  public array function getPostsWithCommentCountGood() {
    return this.findAll(
      select="posts.*, (SELECT COUNT(*) FROM comments WHERE postId = posts.id) as commentCount"
    );
  }
  
  // Better: Eager loading for complex data
  public array function getPostsWithFullData() {
    return this.findAll(
      include="author,comments",
      order="createdAt DESC"
    );
  }
}
```

### Database Connection Pooling
```cfml
// Application.cfc configuration
component {
  
  this.datasources["myapp"] = {
    driver: "MySQL",
    host: "localhost",
    database: "myapp",
    username: "dbuser",
    password: getEnv("DB_PASSWORD"),
    
    // Connection pool settings
    connectionLimit: 100,
    connectionTimeout: 30,
    
    // Performance settings
    clob: false,
    blob: false,
    
    // MySQL specific
    custom: {
      useUnicode: true,
      characterEncoding: "UTF-8",
      serverTimezone: "UTC",
      cachePrepStmts: true,
      prepStmtCacheSize: 250,
      prepStmtCacheSqlLimit: 2048,
      useServerPrepStmts: true,
      useLocalSessionState: true,
      rewriteBatchedStatements: true,
      maintainTimeStats: false
    }
  };
}
```

## Best Practices Summary

1. **Always use `config()` for initialization** - Never use `init()` in models or controllers
2. **Implement service layer** for complex business logic
3. **Use repository pattern** for data access abstraction
4. **Cache strategically** with multi-level caching
5. **Handle errors gracefully** with comprehensive exception handling
6. **Prevent N+1 queries** through eager loading or calculated properties
7. **Use transactions** for data consistency
8. **Implement background jobs** for time-consuming operations
9. **Write comprehensive tests** for critical functionality
10. **Follow RESTful conventions** for API design
11. **Use dependency injection** for loose coupling
12. **Implement proper logging** for debugging and monitoring
13. **Version your APIs** from the start
14. **Validate input thoroughly** at all layers
15. **Monitor performance** and optimize bottlenecks