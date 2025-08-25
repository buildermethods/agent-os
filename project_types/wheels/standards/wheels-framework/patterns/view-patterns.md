---
description: Wheels Framework View Patterns and Helpers
version: 1.0
encoding: UTF-8
---

# Wheels View Patterns

Comprehensive view patterns, helpers, and rendering techniques for Wheels framework applications.

## Table of Contents
- [View Fundamentals](#view-fundamentals)
- [View Helpers](#view-helpers)
- [Form Helpers](#form-helpers)
- [Layout System](#layout-system)
- [Partial Views](#partial-views)
- [Content Negotiation](#content-negotiation)
- [Asset Management](#asset-management)
- [Pagination Views](#pagination-views)
- [Flash Messages](#flash-messages)
- [View Caching](#view-caching)
- [JavaScript and AJAX](#javascript-and-ajax)
- [Error Pages](#error-pages)

## View Fundamentals

### View File Structure
```
/app/views/
  /layouts/
    layout.cfm          # Default layout
    admin.cfm          # Admin layout
    api.cfm            # API layout
  /posts/
    index.cfm          # List view
    show.cfm           # Detail view
    new.cfm            # Create form
    edit.cfm           # Edit form
    _form.cfm          # Form partial
    _post.cfm          # Post partial
    index.json.cfm     # JSON response
    show.xml.cfm       # XML response
  /shared/
    _header.cfm        # Shared header
    _footer.cfm        # Shared footer
    _sidebar.cfm       # Shared sidebar
```

### Basic View Rendering
```cfml
<!-- /app/views/posts/show.cfm -->
<cfoutput>
  <article class="post">
    <h1>#encodeForHtml(post.title)#</h1>
    <div class="meta">
      By #encodeForHtml(post.author.name)# on #dateFormat(post.publishedAt, "mmmm d, yyyy")#
    </div>
    <div class="content">
      #post.body# <!-- Assuming HTML content is sanitized -->
    </div>
  </article>
</cfoutput>
```

## View Helpers

### Link Helpers
```cfml
<!-- Basic link -->
#linkTo(text="Home", route="home")#

<!-- Link with parameters -->
#linkTo(text=post.title, route="post", key=post.id)#

<!-- Link with CSS class -->
#linkTo(text="Edit", route="editPost", key=post.id, class="btn btn-primary")#

<!-- Link with confirmation -->
#linkTo(
  text="Delete",
  route="deletePost",
  key=post.id,
  method="delete",
  confirm="Are you sure?"
)#

<!-- External link -->
#linkTo(text="Visit Site", href="https://example.com", target="_blank")#

<!-- Mail link -->
#mailTo(emailAddress="info@example.com", name="Contact Us")#

<!-- Button link -->
#buttonTo(text="Delete", route="deletePost", key=post.id, method="delete", class="btn btn-danger")#
```

### URL Helpers
```cfml
<!-- Generate URL -->
<a href="#urlFor(route='post', key=post.id)#">View Post</a>

<!-- URL with anchor -->
<a href="#urlFor(route='post', key=post.id, anchor='comments')#">View Comments</a>

<!-- URL with query string -->
<a href="#urlFor(route='posts', params='page=2&sort=date')#">Page 2</a>

<!-- Only path (no protocol/host) -->
<a href="#urlFor(route='post', key=post.id, onlyPath=true)#">View</a>
```

### Text Helpers
```cfml
<!-- Truncate text -->
#truncate(text=post.body, length=200)#

<!-- Excerpt -->
#excerpt(text=post.body, phrase="important", radius=50)#

<!-- Highlight text -->
#highlight(text=post.body, phrases="cfwheels,framework", class="highlight")#

<!-- Simple format (converts line breaks to <br> and <p>) -->
#simpleFormat(post.description)#

<!-- Strip HTML tags -->
#stripTags(post.body)#

<!-- Title case -->
#titleize("hello world")# <!-- Output: Hello World -->

<!-- Humanize -->
#humanize("first_name")# <!-- Output: First name -->

<!-- Pluralize -->
#pluralize(count=postCount, singular="post", plural="posts")#
```

### Date/Time Helpers
```cfml
<!-- Time ago -->
#timeAgoInWords(post.createdAt)# <!-- "2 hours ago" -->

<!-- Distance of time -->
#distanceOfTimeInWords(post.createdAt, post.updatedAt)# <!-- "3 days" -->

<!-- Date select -->
#dateSelect(objectName="post", property="publishedAt", includeBlank=true)#

<!-- Time select -->
#timeSelect(objectName="post", property="publishedAt", minuteStep=15)#

<!-- Date time select -->
#dateTimeSelect(
  objectName="post",
  property="publishedAt",
  dateOrder="day,month,year",
  monthDisplay="abbreviations"
)#
```

## Form Helpers

### Basic Form
```cfml
<!-- Form for new object -->
#startFormTag(route="posts", method="post")#
  #textField(objectName="post", property="title", label="Title", class="form-control")#
  #textArea(objectName="post", property="body", label="Content", rows=10, class="form-control")#
  #submitTag(value="Create Post", class="btn btn-primary")#
#endFormTag()#

<!-- Form for existing object -->
#startFormTag(route="post", key=post.id, method="put")#
  #textField(objectName="post", property="title")#
  #textArea(objectName="post", property="body")#
  #submitTag(value="Update Post")#
#endFormTag()#
```

### Form Object Binding
```cfml
<!-- Automatically binds to object properties -->
<cfoutput>
#startFormTag(route="posts")#
  <div class="form-group">
    #textField(
      objectName="post",
      property="title",
      label="Post Title",
      labelClass="form-label",
      class="form-control",
      placeholder="Enter title",
      required=true
    )#
    #errorMessageOn(objectName="post", property="title", class="text-danger")#
  </div>
  
  <div class="form-group">
    #select(
      objectName="post",
      property="categoryId",
      options=categories,
      label="Category",
      includeBlank="-- Select Category --",
      class="form-select"
    )#
  </div>
  
  <div class="form-group">
    #checkBox(
      objectName="post",
      property="published",
      label="Publish immediately",
      checkedValue=1,
      uncheckedValue=0
    )#
  </div>
  
  #submitTag(value="Save Post", class="btn btn-success")#
  #linkTo(text="Cancel", route="posts", class="btn btn-secondary")#
#endFormTag()#
</cfoutput>
```

### Complex Form Elements
```cfml
<!-- File upload -->
#startFormTag(route="uploadFile", multipart=true)#
  #fileField(objectName="document", property="file", label="Choose File", accept=".pdf,.doc,.docx")#
  #submitTag(value="Upload")#
#endFormTag()#

<!-- Radio buttons -->
<div class="radio-group">
  #radioButton(objectName="user", property="gender", tagValue="M", label="Male")#
  #radioButton(objectName="user", property="gender", tagValue="F", label="Female")#
  #radioButton(objectName="user", property="gender", tagValue="O", label="Other")#
</div>

<!-- Checkbox list -->
<div class="checkbox-group">
  <cfloop array="#roles#" index="role">
    #checkBox(
      name="user[roleIds]",
      value=role.id,
      label=role.name,
      checked=ArrayFind(user.roleIds, role.id)
    )#
  </cfloop>
</div>

<!-- Hidden fields -->
#hiddenField(objectName="post", property="userId", value=session.userId)#
#hiddenField(name="returnUrl", value=params.returnUrl)#

<!-- CSRF token (automatic in forms) -->
#authenticityTokenField()#
```

## Layout System

### Default Layout
```cfml
<!-- /app/views/layouts/layout.cfm -->
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>#contentFor("title")# - My App</title>
  #styleSheetLinkTag("application")#
  #contentFor("head")#
</head>
<body>
  <header>
    #includePartial("/shared/header")#
  </header>
  
  <nav>
    #includePartial("/shared/navigation")#
  </nav>
  
  <main class="container">
    <cfif flashKeyExists("success")>
      <div class="alert alert-success">#flash("success")#</div>
    </cfif>
    <cfif flashKeyExists("error")>
      <div class="alert alert-danger">#flash("error")#</div>
    </cfif>
    
    #includeContent()# <!-- Main view content renders here -->
  </main>
  
  <footer>
    #includePartial("/shared/footer")#
  </footer>
  
  #javaScriptIncludeTag("application")#
  #contentFor("scripts")#
</body>
</html>
```

### Setting Content for Layout
```cfml
<!-- In view file -->
<cfoutput>
#contentFor(head='<meta name="description" content="Post about Wheels">')#
#contentFor(title=post.title)#

<article>
  <h1>#post.title#</h1>
  <!-- content -->
</article>

#contentFor(scripts='
  <script>
    // Page-specific JavaScript
  </script>
')#
</cfoutput>
```

## Partial Views

### Basic Partials
```cfml
<!-- Include a partial -->
#includePartial("form")# <!-- Looks for _form.cfm in current view folder -->

<!-- Partial with data -->
#includePartial(partial="post", post=post)#

<!-- Partial from another folder -->
#includePartial(partial="/shared/sidebar")#

<!-- Collection partial (automatically loops) -->
#includePartial(partial="post", posts=posts)#

<!-- Collection with spacer -->
#includePartial(partial="post", posts=posts, spacer="<hr>")#
```

### Partial File Example
```cfml
<!-- /app/views/posts/_post.cfm -->
<cfoutput>
<article class="post-item">
  <h3>#linkTo(text=post.title, route="post", key=post.id)#</h3>
  <p class="meta">
    By #post.author.name# | #timeAgoInWords(post.createdAt)#
  </p>
  <div class="excerpt">
    #truncate(stripTags(post.body), 200)#
  </div>
  #linkTo(text="Read more →", route="post", key=post.id, class="read-more")#
</article>
</cfoutput>
```

## Content Negotiation

### Format-Specific Views
```cfml
<!-- Controller -->
component extends="Controller" {
  function config() {
    provides("html,json,xml");
  }
  
  function show() {
    post = model("Post").findByKey(params.key);
    renderWith(post);
  }
}

<!-- /app/views/posts/show.cfm (HTML) -->
<h1>#post.title#</h1>
<div>#post.body#</div>

<!-- /app/views/posts/show.json.cfm (JSON) -->
<cfoutput>#serializeJSON({
  "id": post.id,
  "title": post.title,
  "body": post.body,
  "url": urlFor(route="post", key=post.id, onlyPath=false)
})#</cfoutput>

<!-- /app/views/posts/show.xml.cfm (XML) -->
<cfoutput>
<post>
  <id>#post.id#</id>
  <title>#xmlFormat(post.title)#</title>
  <body>#xmlFormat(post.body)#</body>
</post>
</cfoutput>
```

## Asset Management

### Stylesheets and JavaScript
```cfml
<!-- Include stylesheets -->
#styleSheetLinkTag("application")# <!-- Links to /stylesheets/application.css -->
#styleSheetLinkTag("application,admin")# <!-- Multiple files -->
#styleSheetLinkTag(source="https://cdn.example.com/styles.css")# <!-- External -->

<!-- Include JavaScript -->
#javaScriptIncludeTag("application")# <!-- Links to /javascripts/application.js -->
#javaScriptIncludeTag("jquery,application")# <!-- Multiple files -->
#javaScriptIncludeTag(source="https://cdn.example.com/script.js")# <!-- External -->

<!-- Image tags -->
#imageTag(source="logo.png", alt="Company Logo", class="logo")#
#imageTag(source="user.jpg", width=100, height=100)#

<!-- With asset fingerprinting -->
#imageTag(source="logo.png", appendQueryString=true)#
```

## Pagination Views

### Pagination Helper
```cfml
<!-- Controller -->
function index() {
  posts = model("Post").findAll(
    page=params.page,
    perPage=10,
    order="createdAt DESC"
  );
}

<!-- View -->
<cfoutput>
<div class="posts">
  <cfloop array="#posts.results#" index="post">
    #includePartial(partial="post", post=post)#
  </cfloop>
</div>

<nav class="pagination">
  #paginationLinks(
    route="posts",
    class="pagination-links",
    classForCurrent="active",
    linkToCurrentPage=false,
    prepend="<span>Page:</span>",
    append="",
    prependToPage="",
    appendToPage="",
    windowSize=5,
    alwaysShowAnchors=true
  )#
</nav>

<!-- Showing X of Y results -->
<p class="results-info">
  Showing #posts.currentPage * posts.perPage - posts.perPage + 1# 
  to #Min(posts.currentPage * posts.perPage, posts.totalRecords)# 
  of #posts.totalRecords# posts
</p>
</cfoutput>
```

## Flash Messages

### Flash Message Display
```cfml
<!-- In layout or view -->
<cfoutput>
<cfif flashKeyExists("success")>
  <div class="alert alert-success alert-dismissible fade show">
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    #flash("success")#
  </div>
</cfif>

<cfif flashKeyExists("info")>
  <div class="alert alert-info">
    #flash("info")#
  </div>
</cfif>

<cfif flashKeyExists("warning")>
  <div class="alert alert-warning">
    #flash("warning")#
  </div>
</cfif>

<cfif flashKeyExists("error")>
  <div class="alert alert-danger">
    #flash("error")#
  </div>
</cfif>
</cfoutput>

<!-- Flash message partial -->
<!-- /app/views/shared/_flash.cfm -->
<cfoutput>
<cfset flashTypes = ["success", "info", "warning", "error"]>
<cfloop array="#flashTypes#" index="type">
  <cfif flashKeyExists(type)>
    <div class="alert alert-#type# alert-dismissible" role="alert">
      #flash(type)#
      <button type="button" class="close" data-dismiss="alert">
        <span>&times;</span>
      </button>
    </div>
  </cfif>
</cfloop>
</cfoutput>
```

## View Caching

### Fragment Caching
```cfml
<!-- Cache expensive view fragment -->
<cfcache action="cache" timespan="#CreateTimeSpan(0,1,0,0)#" key="sidebar_#session.userId#">
  #includePartial("/shared/sidebar")#
</cfcache>

<!-- Conditional caching -->
<cfif NOT isDevelopment()>
  <cfcache action="cache" timespan="#CreateTimeSpan(0,0,30,0)#" key="homepage_content">
    #includePartial("homepage_content")#
  </cfcache>
<cfelse>
  #includePartial("homepage_content")#
</cfif>
```

## JavaScript and AJAX

### AJAX Forms
```cfml
<!-- Remote form -->
#startFormTag(
  route="comments",
  method="post",
  remote=true,
  success="handleSuccess",
  error="handleError"
)#
  #textArea(name="comment[body]", label="Comment")#
  #submitTag(value="Post Comment", class="btn btn-primary")#
#endFormTag()#

<script>
function handleSuccess(data) {
  // Append new comment to list
  document.getElementById('comments').insertAdjacentHTML('beforeend', data);
}

function handleError(xhr, status, error) {
  alert('Error posting comment: ' + error);
}
</script>
```

### Data Attributes
```cfml
<!-- Add data attributes for JavaScript -->
#linkTo(
  text="Load More",
  route="posts",
  params="page=2",
  data={
    remote=true,
    method="get",
    target="##posts-container"
  }
)#

<!-- Renders as: -->
<!-- <a href="/posts?page=2" data-remote="true" data-method="get" data-target="#posts-container">Load More</a> -->
```

## Error Pages

### Custom Error Views
```cfml
<!-- /app/views/errors/404.cfm -->
<cfoutput>
<div class="error-page">
  <h1>404 - Page Not Found</h1>
  <p>The page you're looking for doesn't exist.</p>
  #linkTo(text="Go to Homepage", route="home", class="btn btn-primary")#
</div>
</cfoutput>

<!-- /app/views/errors/500.cfm -->
<cfoutput>
<div class="error-page">
  <h1>500 - Internal Server Error</h1>
  <p>Something went wrong. We've been notified and are looking into it.</p>
  #linkTo(text="Go Back", href="javascript:history.back()", class="btn btn-primary")#
</div>
</cfoutput>
```

## Best Practices

1. **Always Encode Output**: Use `encodeForHtml()` for user-generated content
2. **Use Helpers**: Leverage built-in helpers instead of writing HTML manually
3. **Keep Views Simple**: Move complex logic to helpers or controllers
4. **Organize Partials**: Use clear naming and folder organization
5. **Cache Expensive Operations**: Use fragment caching for complex views
6. **Semantic HTML**: Use proper HTML5 elements and ARIA attributes
7. **Responsive Design**: Always consider mobile views
8. **Consistent Naming**: Follow naming conventions for views and partials
9. **Minimize Inline Styles**: Use CSS classes instead
10. **Test Views**: Write tests for complex view logic and helpers