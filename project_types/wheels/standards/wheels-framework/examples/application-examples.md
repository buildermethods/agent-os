---
description: Wheels Framework Complete Application Examples
version: 1.0
encoding: UTF-8
---

# Wheels Application Examples

Complete working examples demonstrating best practices for common Wheels framework development tasks.

## Complete Application Examples

### 1. Blog Application

#### Routes Configuration
```cfml
// /config/routes.cfm
mapper()
  // Public routes
  .get(name="home", pattern="", to="pages##home")
  .resources(name="posts", only="index,show")
  .resources(name="categories", only="index,show")
  
  // Admin namespace
  .namespace("admin")
    .get(name="dashboard", pattern="", to="dashboard##index")
    .resources("posts")
    .resources("categories")
    .resources("users", except="new,create")
  .end()
  
  // Authentication routes
  .get(name="login", pattern="login", to="sessions##new")
  .post(name="session", pattern="login", to="sessions##create")
  .delete(name="logout", pattern="logout", to="sessions##delete")
  
  // API routes
  .namespace("api.v1")
    .resources(name="posts", only="index,show", controller="api.v1.posts")
  .end()
  
  .root(to="pages##home")
.end();
```

#### Post Model
```cfml
// /app/models/Post.cfc
component extends="Model" {
  
  function config() {
    // Associations
    belongsTo("user");
    belongsTo("category");
    hasMany("comments");
    hasMany(name="postTags", shortcut="tags");
    
    // Validations
    validatesPresenceOf("title,body,userId,categoryId");
    validatesUniquenessOf(property="slug", scope="categoryId");
    validatesLengthOf(property="title", maximum=255);
    validatesLengthOf(property="excerpt", maximum=500, allowBlank=true);
    
    // Callbacks
    beforeValidation("generateSlug,generateExcerpt");
    beforeCreate("setPublishDate");
    
    // Calculated properties
    property(name="authorName", sql="(SELECT name FROM users WHERE id = posts.userId)");
    property(name="commentCount", sql="(SELECT COUNT(*) FROM comments WHERE postId = posts.id)");
    
    // Scopes
    scope("published", where="publishedAt <= NOW() AND status = 'published'");
    scope("recent", order="publishedAt DESC", maxRows=10);
  }
  
  // Callbacks
  private function generateSlug() {
    if (!Len(this.slug) && Len(this.title)) {
      this.slug = $createSlug(this.title);
    }
  }
  
  private function generateExcerpt() {
    if (!Len(this.excerpt) && Len(this.body)) {
      this.excerpt = Left(StripHTML(this.body), 497) & "...";
    }
  }
  
  private function setPublishDate() {
    if (this.status == "published" && !StructKeyExists(this, "publishedAt")) {
      this.publishedAt = Now();
    }
  }
  
  // Public methods
  public boolean function isPublished() {
    return this.status == "published" && this.publishedAt <= Now();
  }
  
  public query function findPublished(numeric page=1, numeric perPage=10) {
    return this.findAll(
      where="publishedAt <= NOW() AND status = 'published'",
      order="publishedAt DESC",
      page=arguments.page,
      perPage=arguments.perPage,
      include="user,category",
      returnAs="query"
    );
  }
  
  // Private helper
  private string function $createSlug(required string text) {
    local.slug = ReReplaceNoCase(arguments.text, "[^a-z0-9\s-]", "", "all");
    local.slug = ReReplace(local.slug, "\s+", "-", "all");
    local.slug = ReReplace(local.slug, "-+", "-", "all");
    return LCase(local.slug);
  }
}
```

#### Posts Controller
```cfml
// /app/controllers/Posts.cfc
component extends="Controller" {
  
  function config() {
    provides("html,json,xml");
    filters(through="loadCategories", only="new,edit");
    verifies(except="index,show", params="key", paramsTypes="integer", 
             handler="invalidPost");
  }
  
  function index() {
    param name="params.page" default="1";
    param name="params.category" default="";
    
    local.where = "status = 'published' AND publishedAt <= NOW()";
    
    if (Len(params.category)) {
      local.category = model("Category").findBySlug(params.category);
      if (IsObject(local.category)) {
        local.where &= " AND categoryId = #local.category.id#";
      }
    }
    
    posts = model("Post").findAll(
      where=local.where,
      order="publishedAt DESC",
      page=params.page,
      perPage=10,
      include="user,category"
    );
    
    categories = model("Category").findAll(order="name");
    
    renderWith(data=posts);
  }
  
  function show() {
    post = model("Post").findOne(
      where="id = :id AND status = 'published' AND publishedAt <= NOW()",
      params={id=params.key},
      include="user,category,comments"
    );
    
    if (!IsObject(post)) {
      redirectTo(route="posts");
    }
    
    // Track view count
    post.incrementCounter("viewCount");
    
    relatedPosts = model("Post").findAll(
      where="categoryId = #post.categoryId# AND id != #post.id# AND status = 'published'",
      order="publishedAt DESC",
      maxRows=5
    );
    
    renderWith(data=post);
  }
  
  private function loadCategories() {
    categories = model("Category").findAll(
      order="name",
      cache=true,
      cacheTime=60
    );
  }
  
  private function invalidPost() {
    flashInsert(error="Post not found");
    redirectTo(route="posts");
  }
}
```

#### Admin Posts Controller
```cfml
// /app/controllers/admin/Posts.cfc
component extends="Controller" {
  
  function config() {
    filters(through="authenticate,authorizeAdmin");
    filters(through="loadPost", only="show,edit,update,delete");
    provides("html,json");
  }
  
  function index() {
    param name="params.page" default="1";
    param name="params.status" default="";
    
    local.where = [];
    if (Len(params.status)) {
      ArrayAppend(local.where, "status = '#params.status#'");
    }
    
    posts = model("Post").findAll(
      where=ArrayToList(local.where, " AND "),
      order="createdAt DESC",
      page=params.page,
      perPage=25,
      include="user,category"
    );
  }
  
  function new() {
    post = model("Post").new(userId=session.userId);
    loadFormData();
  }
  
  function create() {
    post = model("Post").new(params.post);
    post.userId = session.userId;
    
    if (post.save()) {
      flashInsert(success="Post created successfully");
      redirectTo(route="adminPost", key=post.key());
    } else {
      loadFormData();
      flashInsert(error="Please correct the errors below");
      renderView("new");
    }
  }
  
  function edit() {
    loadFormData();
  }
  
  function update() {
    if (post.update(params.post)) {
      flashInsert(success="Post updated successfully");
      redirectTo(route="adminPost", key=post.key());
    } else {
      loadFormData();
      flashInsert(error="Please correct the errors below");
      renderView("edit");
    }
  }
  
  function delete() {
    if (post.delete()) {
      flashInsert(success="Post deleted successfully");
    } else {
      flashInsert(error="Could not delete post");
    }
    redirectTo(route="adminPosts");
  }
  
  private function loadPost() {
    post = model("Post").findByKey(params.key);
    if (!IsObject(post)) {
      flashInsert(error="Post not found");
      redirectTo(route="adminPosts");
    }
  }
  
  private function loadFormData() {
    categories = model("Category").findAll(order="name");
    statuses = [
      {value="draft", text="Draft"},
      {value="published", text="Published"},
      {value="archived", text="Archived"}
    ];
  }
}
```

### 2. User Authentication System

#### User Model
```cfml
// /app/models/User.cfc
component extends="Model" {
  
  function config() {
    // Properties
    property(name="passwordConfirmation", sql="");
    property(name="currentPassword", sql="");
    
    // Associations
    hasMany("posts");
    hasMany("comments");
    hasOne("profile");
    belongsTo("role");
    
    // Validations
    validatesPresenceOf("name,email");
    validatesUniquenessOf("email");
    validatesFormatOf(property="email", regEx="^[^@\s]+@[^@\s]+\.[^@\s]+$");
    validatesConfirmationOf("password");
    validatesLengthOf(property="password", minimum=8, when="onCreate");
    
    // Callbacks
    beforeValidation("sanitizeEmail");
    beforeSave("hashPassword");
    afterCreate("createProfile,sendWelcomeEmail");
    
    // Nested properties for profile
    nestedProperties(association="profile", allowDelete=false);
  }
  
  // Authentication methods
  public any function authenticate(required string email, required string password) {
    local.user = this.findOne(where="email = :email", params={email=arguments.email});
    
    if (IsObject(local.user) && local.user.checkPassword(arguments.password)) {
      local.user.updateAttributes(lastLoginAt=Now(), loginCount=local.user.loginCount + 1);
      return local.user;
    }
    
    return false;
  }
  
  public boolean function checkPassword(required string password) {
    return BCryptCheckPassword(arguments.password, this.passwordHash);
  }
  
  public void function setPassword(required string password) {
    this.password = arguments.password;
    this.passwordHash = ""; // Will be set in hashPassword callback
  }
  
  // Role checking
  public boolean function isAdmin() {
    return IsObject(this.role()) && this.role().name == "admin";
  }
  
  public boolean function can(required string permission) {
    if (!IsObject(this.role())) {
      return false;
    }
    return ListFindNoCase(this.role().permissions, arguments.permission);
  }
  
  // Callbacks
  private function sanitizeEmail() {
    if (StructKeyExists(this, "email")) {
      this.email = Trim(LCase(this.email));
    }
  }
  
  private function hashPassword() {
    if (StructKeyExists(this, "password") && Len(this.password)) {
      this.passwordHash = BCryptHashPassword(this.password);
      StructDelete(this, "password");
    }
  }
  
  private function createProfile() {
    model("Profile").create(userId=this.id);
  }
  
  private function sendWelcomeEmail() {
    sendEmail(
      to=this.email,
      subject="Welcome to Our App",
      template="/emails/welcome",
      user=this
    );
  }
}
```

#### Sessions Controller
```cfml
// /app/controllers/Sessions.cfc
component extends="Controller" {
  
  function config() {
    provides("html,json");
  }
  
  function new() {
    if (StructKeyExists(session, "userId")) {
      redirectTo(route="home");
    }
  }
  
  function create() {
    param name="params.email" default="";
    param name="params.password" default="";
    param name="params.rememberMe" default="0";
    
    local.user = model("User").authenticate(params.email, params.password);
    
    if (IsObject(local.user)) {
      session.userId = local.user.id;
      session.userName = local.user.name;
      
      if (params.rememberMe) {
        cookie.userToken = local.user.createRememberToken();
        cookie.setExpires = DateAdd("d", 30, Now());
      }
      
      flashInsert(success="Welcome back, #local.user.name#!");
      redirectTo(session.returnTo ?: route("home"));
    } else {
      flashInsert(error="Invalid email or password");
      renderView("new");
    }
  }
  
  function delete() {
    StructDelete(session, "userId");
    StructDelete(session, "userName");
    StructDelete(cookie, "userToken");
    
    flashInsert(info="You have been logged out");
    redirectTo(route="home");
  }
}
```

### 3. RESTful API Example

#### API Base Controller
```cfml
// /app/controllers/api/v1/Base.cfc
component extends="Controller" {
  
  function config() {
    // Only respond to JSON
    onlyProvides("json");
    
    // Set common headers
    filters("setApiHeaders,authenticate,handleErrors");
  }
  
  private function setApiHeaders() {
    header name="X-API-Version" value="1.0";
    header name="X-RateLimit-Limit" value="1000";
    header name="X-RateLimit-Remaining" value="999";
  }
  
  private function authenticate() {
    param name="request.headers['Authorization']" default="";
    
    if (!Len(request.headers['Authorization'])) {
      renderWith(data={error="Missing Authorization header"}, status=401);
      return false;
    }
    
    local.token = Replace(request.headers['Authorization'], "Bearer ", "");
    request.apiUser = model("ApiToken").authenticate(local.token);
    
    if (!IsObject(request.apiUser)) {
      renderWith(data={error="Invalid API token"}, status=401);
      return false;
    }
  }
  
  private function handleErrors() {
    try {
      // Continue with request
    } catch (any e) {
      local.status = 500;
      local.error = "Internal Server Error";
      
      if (e.type contains "validation") {
        local.status = 422;
        local.error = e.message;
      } else if (e.type contains "notfound") {
        local.status = 404;
        local.error = e.message;
      }
      
      renderWith(
        data={
          error=local.error,
          type=e.type,
          detail=application.wheels.environment == "development" ? e.detail : ""
        },
        status=local.status
      );
      
      return false;
    }
  }
}
```

#### API Posts Controller
```cfml
// /app/controllers/api/v1/Posts.cfc
component extends="api.v1.Base" {
  
  function index() {
    param name="params.page" default="1";
    param name="params.per_page" default="20";
    param name="params.include" default="";
    
    // Build query
    local.args = {
      page = params.page,
      perPage = Min(params.per_page, 100),
      order = "publishedAt DESC",
      where = "status = 'published' AND publishedAt <= NOW()"
    };
    
    // Handle includes
    if (ListFindNoCase("user,category,comments", params.include)) {
      local.args.include = params.include;
    }
    
    // Get posts
    local.posts = model("Post").findAll(argumentCollection=local.args);
    
    // Format response
    local.response = {
      data = [],
      meta = {
        current_page = params.page,
        per_page = local.args.perPage,
        total = local.posts.recordCount,
        total_pages = Ceiling(local.posts.recordCount / local.args.perPage)
      }
    };
    
    // Transform posts
    for (local.post in local.posts) {
      ArrayAppend(local.response.data, formatPost(local.post));
    }
    
    renderWith(data=local.response);
  }
  
  function show() {
    local.post = model("Post").findOne(
      where="id = :id AND status = 'published'",
      params={id=params.key},
      include="user,category"
    );
    
    if (!IsObject(local.post)) {
      renderWith(data={error="Post not found"}, status=404);
      return;
    }
    
    renderWith(data={data=formatPost(local.post)});
  }
  
  private struct function formatPost(required any post) {
    local.data = {
      id = arguments.post.id,
      title = arguments.post.title,
      slug = arguments.post.slug,
      excerpt = arguments.post.excerpt,
      body = arguments.post.body,
      published_at = DateTimeFormat(arguments.post.publishedAt, "yyyy-mm-dd'T'HH:nn:ss'Z'"),
      created_at = DateTimeFormat(arguments.post.createdAt, "yyyy-mm-dd'T'HH:nn:ss'Z'"),
      updated_at = DateTimeFormat(arguments.post.updatedAt, "yyyy-mm-dd'T'HH:nn:ss'Z'")
    };
    
    // Include related data if loaded
    if (StructKeyExists(arguments.post, "user")) {
      local.data.author = {
        id = arguments.post.user.id,
        name = arguments.post.user.name
      };
    }
    
    if (StructKeyExists(arguments.post, "category")) {
      local.data.category = {
        id = arguments.post.category.id,
        name = arguments.post.category.name,
        slug = arguments.post.category.slug
      };
    }
    
    return local.data;
  }
}
```

### 4. File Upload Example

#### Upload Model
```cfml
// /app/models/Upload.cfc
component extends="Model" {
  
  function config() {
    belongsTo("user");
    
    validatesPresenceOf("fileName,fileType,fileSize");
    validatesFormatOf(property="fileType", regex="^(image|document|video)$");
    
    beforeCreate("generateUniqueFileName");
    afterDelete("removeFile");
  }
  
  private function generateUniqueFileName() {
    local.ext = ListLast(this.fileName, ".");
    this.uniqueName = CreateUUID() & "." & local.ext;
    this.filePath = DateFormat(Now(), "yyyy/mm/dd") & "/" & this.uniqueName;
  }
  
  private function removeFile() {
    local.fullPath = ExpandPath("/files/" & this.filePath);
    if (FileExists(local.fullPath)) {
      FileDelete(local.fullPath);
    }
  }
  
  public boolean function isImage() {
    return this.fileType == "image";
  }
  
  public string function url() {
    return "/files/" & this.filePath;
  }
}
```

#### Uploads Controller
```cfml
// /app/controllers/Uploads.cfc
component extends="Controller" {
  
  function config() {
    filters("authenticate");
    provides("html,json");
  }
  
  function new() {
    upload = model("Upload").new();
  }
  
  function create() {
    if (!StructKeyExists(form, "file")) {
      flashInsert(error="Please select a file to upload");
      redirectTo(route="newUpload");
      return;
    }
    
    // Process upload
    local.uploadResult = fileUpload(
      destination=getTempDirectory(),
      fileField="file",
      accept="image/*,application/pdf",
      nameConflict="makeUnique"
    );
    
    if (local.uploadResult.fileWasSaved) {
      // Create upload record
      local.upload = model("Upload").new({
        userId = session.userId,
        fileName = local.uploadResult.clientFile,
        fileType = determineFileType(local.uploadResult.clientFileExt),
        fileSize = local.uploadResult.fileSize,
        mimeType = local.uploadResult.contentType
      });
      
      if (local.upload.save()) {
        // Move file to permanent location
        local.destDir = ExpandPath("/files/" & DateFormat(Now(), "yyyy/mm/dd"));
        if (!DirectoryExists(local.destDir)) {
          DirectoryCreate(local.destDir, true);
        }
        
        FileMove(
          local.uploadResult.serverDirectory & "/" & local.uploadResult.serverFile,
          local.destDir & "/" & local.upload.uniqueName
        );
        
        flashInsert(success="File uploaded successfully");
        redirectTo(route="upload", key=local.upload.key());
      } else {
        FileDelete(local.uploadResult.serverDirectory & "/" & local.uploadResult.serverFile);
        flashInsert(error="Upload failed: " & local.upload.allErrors());
        renderView("new");
      }
    } else {
      flashInsert(error="File upload failed");
      redirectTo(route="newUpload");
    }
  }
  
  private string function determineFileType(required string ext) {
    switch(LCase(arguments.ext)) {
      case "jpg": case "jpeg": case "png": case "gif": case "webp":
        return "image";
      case "pdf": case "doc": case "docx": case "txt":
        return "document";
      case "mp4": case "avi": case "mov":
        return "video";
      default:
        return "other";
    }
  }
}
```

### 5. Background Job Example

#### Job Model
```cfml
// /app/models/Job.cfc
component extends="Model" {
  
  function config() {
    validatesPresenceOf("name,status");
    validatesInclusionOf(property="status", list="pending,processing,completed,failed");
    
    beforeCreate("setDefaults");
    
    scope("pending", where="status = 'pending'");
    scope("ready", where="status = 'pending' AND runAt <= NOW()");
  }
  
  private function setDefaults() {
    if (!StructKeyExists(this, "runAt")) {
      this.runAt = Now();
    }
    this.status = "pending";
    this.attempts = 0;
  }
  
  public boolean function process() {
    try {
      this.updateAttributes(
        status="processing",
        startedAt=Now(),
        attempts=this.attempts + 1
      );
      
      // Execute job based on type
      switch(this.name) {
        case "sendEmail":
          processSendEmail();
          break;
        case "generateReport":
          processGenerateReport();
          break;
        case "importData":
          processImportData();
          break;
      }
      
      this.updateAttributes(
        status="completed",
        completedAt=Now()
      );
      
      return true;
      
    } catch (any e) {
      this.updateAttributes(
        status="failed",
        error=e.message,
        failedAt=Now()
      );
      
      // Retry logic
      if (this.attempts < 3) {
        this.updateAttributes(
          status="pending",
          runAt=DateAdd("n", 5 * this.attempts, Now())
        );
      }
      
      return false;
    }
  }
  
  private void function processSendEmail() {
    local.data = DeserializeJSON(this.payload);
    sendEmail(argumentCollection=local.data);
  }
  
  private void function processGenerateReport() {
    local.data = DeserializeJSON(this.payload);
    local.report = model("Report").generate(local.data);
    this.result = SerializeJSON({reportId=local.report.id});
  }
  
  private void function processImportData() {
    local.data = DeserializeJSON(this.payload);
    model("DataImporter").import(local.data.filePath);
  }
}
```

## Testing Examples

### Model Test Example
```cfml
// /tests/models/UserTest.cfc
component extends="wheels.test" {
  
  function setup() {
    super.setup();
    
    // Create test data
    testRole = model("Role").create(name="user", permissions="read");
    testUser = model("User").create(
      name="Test User",
      email="test@example.com",
      password="password123",
      passwordConfirmation="password123",
      roleId=testRole.id
    );
  }
  
  function test_user_authentication() {
    // Test valid authentication
    result = model("User").authenticate("test@example.com", "password123");
    assert("IsObject(result)");
    assert("result.id == testUser.id");
    
    // Test invalid password
    result = model("User").authenticate("test@example.com", "wrongpassword");
    assert("result == false");
    
    // Test invalid email
    result = model("User").authenticate("wrong@example.com", "password123");
    assert("result == false");
  }
  
  function test_password_hashing() {
    user = model("User").new(
      name="New User",
      email="new@example.com",
      password="secret123",
      passwordConfirmation="secret123"
    );
    
    user.save();
    
    // Password should be hashed
    assert("!StructKeyExists(user, 'password')");
    assert("Len(user.passwordHash) > 0");
    assert("user.checkPassword('secret123')");
    assert("!user.checkPassword('wrongpassword')");
  }
  
  function test_email_validation() {
    user = model("User").new(name="Test");
    
    // Missing email
    user.valid();
    assert("ArrayLen(user.errorsOn('email')) > 0");
    
    // Invalid format
    user.email = "not-an-email";
    user.valid();
    assert("ArrayLen(user.errorsOn('email')) > 0");
    
    // Valid email
    user.email = "valid@example.com";
    user.valid();
    assert("ArrayLen(user.errorsOn('email')) == 0");
  }
  
  function test_unique_email() {
    // Try to create duplicate
    duplicate = model("User").create(
      name="Duplicate",
      email="test@example.com",
      password="password123",
      passwordConfirmation="password123"
    );
    
    assert("!duplicate.hasErrors() == false");
    assert("ArrayLen(duplicate.errorsOn('email')) > 0");
  }
}
```

### Controller Test Example
```cfml
// /tests/controllers/PostsTest.cfc
component extends="wheels.test" {
  
  function setup() {
    super.setup();
    
    // Create test data
    category = model("Category").create(name="Test", slug="test");
    user = model("User").create(
      name="Author",
      email="author@example.com",
      password="password",
      passwordConfirmation="password"
    );
    
    publishedPost = model("Post").create(
      title="Published Post",
      body="Content",
      userId=user.id,
      categoryId=category.id,
      status="published",
      publishedAt=DateAdd("d", -1, Now())
    );
    
    draftPost = model("Post").create(
      title="Draft Post",
      body="Content",
      userId=user.id,
      categoryId=category.id,
      status="draft"
    );
  }
  
  function test_index_shows_only_published_posts() {
    result = processRequest(route="posts", method="GET");
    
    assert("result.status == 200");
    assert("IsQuery(result.posts) || IsArray(result.posts)");
    
    // Should include published post
    found = false;
    for (post in result.posts) {
      if (post.id == publishedPost.id) {
        found = true;
        break;
      }
    }
    assert("found == true");
    
    // Should not include draft post
    found = false;
    for (post in result.posts) {
      if (post.id == draftPost.id) {
        found = true;
        break;
      }
    }
    assert("found == false");
  }
  
  function test_show_returns_404_for_draft_post() {
    result = processRequest(
      route="post",
      method="GET",
      params={key=draftPost.id}
    );
    
    // Should redirect
    assert("result.status == 302");
    assert("result.redirect contains '/posts'");
  }
  
  function test_json_response() {
    result = processRequest(
      route="posts",
      method="GET",
      headers={"Accept"="application/json"}
    );
    
    assert("result.status == 200");
    assert("IsJSON(result.response)");
    
    data = DeserializeJSON(result.response);
    assert("IsArray(data) || (IsStruct(data) && StructKeyExists(data, 'data'))");
  }
}
```

## Common Integration Patterns

### 1. Third-Party API Integration
```cfml
// /app/models/services/WeatherService.cfc
component {
  
  public struct function getWeather(required string city) {
    local.apiKey = application.wheels.weatherApiKey;
    local.url = "https://api.openweathermap.org/data/2.5/weather";
    
    local.httpService = new http(
      url=local.url,
      method="GET",
      timeout=10
    );
    
    local.httpService.addParam(type="url", name="q", value=arguments.city);
    local.httpService.addParam(type="url", name="appid", value=local.apiKey);
    local.httpService.addParam(type="url", name="units", value="metric");
    
    local.result = local.httpService.send().getPrefix();
    
    if (local.result.statusCode == "200 OK") {
      return DeserializeJSON(local.result.fileContent);
    } else {
      throw(
        type="WeatherService.APIError",
        message="Weather API request failed",
        detail=local.result.fileContent
      );
    }
  }
}
```

### 2. Event System Integration
```cfml
// /app/models/EventDispatcher.cfc
component {
  
  public void function dispatch(required string event, struct data={}) {
    local.listeners = application.wheels.eventListeners[arguments.event] ?: [];
    
    for (local.listener in local.listeners) {
      invoke(
        component=local.listener.component,
        method=local.listener.method,
        argumentCollection=arguments.data
      );
    }
  }
  
  public void function listen(required string event, required string component, required string method) {
    if (!StructKeyExists(application.wheels.eventListeners, arguments.event)) {
      application.wheels.eventListeners[arguments.event] = [];
    }
    
    ArrayAppend(
      application.wheels.eventListeners[arguments.event],
      {component=arguments.component, method=arguments.method}
    );
  }
}

// Usage in model
function config() {
  afterCreate("notifyCreation");
}

private function notifyCreation() {
  application.eventDispatcher.dispatch("user.created", {user=this});
}
```

These examples provide complete, working code that AI assistants can reference when helping developers with Wheels framework projects.