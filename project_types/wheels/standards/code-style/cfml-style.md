# CFML Tag-Based Markup Style Guide

## Purpose
This guide defines standards for writing CFML tag-based markup in view files and partials. Tag-based syntax should be used for presentation logic and HTML generation.

## General Rules
- Use 2 spaces for indentation
- Use lowercase for all CFML tags (`<cfif>`, not `<CFIF>`)
- Place nested elements on new lines with proper indentation
- Keep logic minimal in views - complex logic belongs in CFCs
- Always close tags properly (`</cfif>`, `</cfloop>`, etc.)

## Tag Formatting

### Attributes
- Place each attribute on its own line for complex tags
- Align attributes vertically
- Keep the closing `>` on the same line as the last attribute
- Use double quotes for attribute values

### Variables and Output
- Use `<cfoutput>` sparingly - wrap entire sections rather than individual variables
- Use `encodeForHTML()` when outputting user-generated content
- Prefer `#variable#` syntax within `<cfoutput>` blocks

## Common Patterns

### Basic Structure
```cfml
<cfoutput>
  <div class="container">
    <h1>#encodeForHTML(pageTitle)#</h1>
    
    <cfif structKeyExists(variables, "message")>
      <div class="alert alert-info">
        #encodeForHTML(message)#
      </div>
    </cfif>
  </div>
</cfoutput>
```

### Loops
```cfml
<cfoutput>
  <ul class="list-items">
    <cfloop array="#items#" index="item">
      <li class="list-item"
          data-id="#item.id#">
        <span class="item-name">
          #encodeForHTML(item.name)#
        </span>
        <span class="item-date">
          #dateFormat(item.createdDate, "mm/dd/yyyy")#
        </span>
      </li>
    </cfloop>
  </ul>
</cfoutput>
```

### Conditional Rendering
```cfml
<cfif isUserLoggedIn>
  <cfoutput>
    <nav class="user-menu">
      <span class="username">
        Welcome, #encodeForHTML(user.firstName)#
      </span>
      <a href="/logout"
         class="btn btn-secondary">
        Logout
      </a>
    </nav>
  </cfoutput>
<cfelse>
  <cfoutput>
    <div class="login-prompt">
      <a href="/login"
         class="btn btn-primary">
        Login
      </a>
    </div>
  </cfoutput>
</cfif>
```

### Including Partials
```cfml
<cfinclude template="partials/_header.cfm">

<div class="main-content">
  <cfinclude template="partials/_sidebar.cfm">
  
  <cfoutput>
    <section class="content">
      #renderContent()#
    </section>
  </cfoutput>
</div>

<cfinclude template="partials/_footer.cfm">
```

### Forms
```cfml
<cfoutput>
  <form action="/users/save"
        method="post"
        class="user-form">
    
    <cfif structKeyExists(errors, "general")>
      <div class="alert alert-danger">
        #encodeForHTML(errors.general)#
      </div>
    </cfif>
    
    <div class="form-group">
      <label for="firstName">
        First Name
      </label>
      <input type="text"
             id="firstName"
             name="firstName"
             value="#encodeForHTMLAttribute(form.firstName ?: '')#"
             class="form-control"
             required>
      <cfif structKeyExists(errors, "firstName")>
        <span class="error-message">
          #encodeForHTML(errors.firstName)#
        </span>
      </cfif>
    </div>
    
    <div class="form-group">
      <label for="email">
        Email
      </label>
      <input type="email"
             id="email"
             name="email"
             value="#encodeForHTMLAttribute(form.email ?: '')#"
             class="form-control"
             required>
    </div>
    
    <button type="submit"
            class="btn btn-primary">
      Save User
    </button>
  </form>
</cfoutput>
```

### Complex Data Display
```cfml
<cfoutput>
  <table class="data-table">
    <thead>
      <tr>
        <th>Order ID</th>
        <th>Customer</th>
        <th>Date</th>
        <th>Total</th>
        <th>Status</th>
      </tr>
    </thead>
    <tbody>
      <cfloop query="orders">
        <tr class="order-row
                   <cfif orders.status eq 'urgent'>order-urgent</cfif>">
          <td>
            <a href="/orders/#orders.id#">
              ###orders.id#
            </a>
          </td>
          <td>
            #encodeForHTML(orders.customerName)#
          </td>
          <td>
            #dateFormat(orders.orderDate, "mm/dd/yyyy")#
          </td>
          <td class="text-right">
            #dollarFormat(orders.total)#
          </td>
          <td>
            <span class="status status-#lcase(orders.status)#">
              #encodeForHTML(orders.status)#
            </span>
          </td>
        </tr>
      </cfloop>
    </tbody>
  </table>
</cfoutput>
```

## Best Practices

### Security
- Always encode output: `encodeForHTML()`, `encodeForHTMLAttribute()`, `encodeForJavaScript()`, `encodeForURL()`
- Never trust user input
- Use `<cfqueryparam>` in queries (though queries should be in CFCs)
- Validate all form inputs

### Performance
- Minimize `<cfoutput>` blocks - use one per section
- Cache frequently used data when appropriate
- Use `<cfinclude>` for reusable components
- Avoid nested loops when possible

### Maintainability
- Keep views focused on presentation
- Move business logic to CFCs
- Use meaningful variable names
- Comment complex conditional logic
- Group related sections together

### Error Handling
```cfml
<cftry>
  <cfinclude template="partials/_dynamic_content.cfm">
  
  <cfcatch type="any">
    <cfoutput>
      <div class="alert alert-danger">
        <cfif application.environment eq "development">
          Error: #encodeForHTML(cfcatch.message)#
        <cfelse>
          An error occurred. Please try again later.
        </cfif>
      </div>
    </cfoutput>
    
    <cflog file="view_errors"
           text="Error in view: #cfcatch.message#">
  </cfcatch>
</cftry>
```

## Anti-Patterns to Avoid
- Don't mix business logic with presentation
- Don't use inline SQL in views
- Don't create variables with `<cfset>` unnecessarily in views
- Don't use deprecated tags like `<cfform>`
- Don't output unencoded user data
- Avoid deeply nested conditional logic
- Don't use `evaluate()` or dynamic variable creation

## File Naming
- Use lowercase with underscores: `user_profile.cfm`
- Prefix partials with underscore: `_header.cfm`
- Group related views in folders: `users/edit.cfm`