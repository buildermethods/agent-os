---
description: Wheels Framework Configuration and Environment Management Guide
version: 1.0
encoding: UTF-8
---

# Wheels Configuration Guide

Comprehensive guide for configuring Wheels framework applications across different environments.

## Table of Contents
- [Configuration Overview](#configuration-overview)
- [Directory Structure](#directory-structure)
- [Environment Configuration](#environment-configuration)
- [Application Settings](#application-settings)
- [Database Configuration](#database-configuration)
- [Caching Configuration](#caching-configuration)
- [Security Settings](#security-settings)
- [Email Configuration](#email-configuration)
- [Asset Configuration](#asset-configuration)
- [Plugin Configuration](#plugin-configuration)
- [Custom Settings](#custom-settings)
- [Environment Variables](#environment-variables)
- [Production Optimization](#production-optimization)

## Configuration Overview

### Configuration Hierarchy
1. **Environment Detection**: `/config/environment.cfm`
2. **Global Settings**: `/config/settings.cfm`
3. **Environment-Specific**: `/config/development/settings.cfm`, `/config/production/settings.cfm`
4. **Runtime Overrides**: Via `set()` function

### Important Note for Wheels 3.0
**Configuration files have moved from `/app/config/` to `/config/` at the root level in Wheels 3.0**

## Directory Structure

### Configuration Directory Layout
```
/config/                          # Root config directory (Wheels 3.0+)
  environment.cfm                 # Environment detection
  routes.cfm                      # Route definitions
  settings.cfm                    # Global settings
  /development/
    settings.cfm                  # Development-specific settings
    routes.cfm                    # Development-only routes (optional)
  /testing/
    settings.cfm                  # Testing environment settings
  /staging/
    settings.cfm                  # Staging environment settings
  /production/
    settings.cfm                  # Production settings
    routes.cfm                    # Production routes (optional)
  /maintenance/
    settings.cfm                  # Maintenance mode settings
```

## Environment Configuration

### Environment Detection
```cfml
<!--- /config/environment.cfm --->
<cfscript>
// Automatic environment detection
if (FindNoCase("localhost", cgi.server_name) || FindNoCase("127.0.0.1", cgi.server_name)) {
    set(environment="development");
} else if (FindNoCase("test.", cgi.server_name) || FindNoCase("staging.", cgi.server_name)) {
    set(environment="staging");
} else if (FindNoCase("www.", cgi.server_name) || FindNoCase(".com", cgi.server_name)) {
    set(environment="production");
} else {
    set(environment="development");
}

// Override with environment variable if set
if (StructKeyExists(server.system.environment, "WHEELS_ENV")) {
    set(environment=server.system.environment.WHEELS_ENV);
}

// Override with URL parameter in development only
if (get("environment") == "development" && StructKeyExists(url, "environment")) {
    set(environment=url.environment);
}
</cfscript>
```

### Environment-Specific Settings
```cfml
<!--- /config/development/settings.cfm --->
<cfscript>
// Development settings
set(dataSourceName="myapp_dev");

// Debugging
set(showDebugInformation=true);
set(showErrorInformation=true);
set(sendEmailOnError=false);

// Caching disabled for development
set(cacheFileChecking=false);
set(cacheImages=false);
set(cacheModelFiles=false);
set(cacheControllerFiles=false);
set(cacheRoutes=false);
set(cacheActions=false);
set(cacheDatabaseSchema=false);

// Development-specific features
set(allowTestRunner=true);
set(showTestResults=true);
set(deletePluginDirectories=false);
set(overwritePlugins=false);

// Asset handling
set(assetQueryString=false);
set(assetTimestamp=false);

// Session
set(sessionTimeout=CreateTimeSpan(0, 2, 0, 0)); // 2 hours

// Mail settings (use local mail catcher)
set(functionName="sendEmail", server="localhost", port=1025);
</cfscript>

<!--- /config/production/settings.cfm --->
<cfscript>
// Production settings
set(dataSourceName="myapp_prod");

// Debugging off
set(showDebugInformation=false);
set(showErrorInformation=false);
set(sendEmailOnError=true);
set(errorEmailAddress="errors@example.com");
set(errorEmailFromAddress="noreply@example.com");
set(errorEmailSubject="Production Error Alert");

// Caching enabled
set(cacheFileChecking=true);
set(cacheImages=true);
set(cacheModelFiles=true);
set(cacheControllerFiles=true);
set(cacheRoutes=true);
set(cacheActions=true);
set(cacheDatabaseSchema=true);
set(cacheQueries=true);
set(cachePartials=true);

// Cache configuration
set(cacheCullPercentage=10);
set(cacheCullInterval=5);
set(cacheDefaultTimeToLive=3600);
set(maximumItemsToCache=5000);

// Security
set(allowTestRunner=false);
set(showTestResults=false);
set(deletePluginDirectories=true);
set(overwritePlugins=false);

// Asset handling with CDN
set(assetQueryString=true);
set(assetTimestamp=true);
set(assetHost="https://cdn.example.com");

// Session (shorter for security)
set(sessionTimeout=CreateTimeSpan(0, 0, 30, 0)); // 30 minutes

// Production mail server
set(functionName="sendEmail", server="smtp.sendgrid.net", port=587, 
    username=server.system.environment.SENDGRID_USERNAME,
    password=server.system.environment.SENDGRID_PASSWORD);
</cfscript>
```

## Application Settings

### Core Application Settings
```cfml
<!--- /config/settings.cfm --->
<cfscript>
// Application identification
set(applicationName="MyWheelsApp");
set(hostName="example.com");

// URLs and paths
set(URLRewriting="partial"); // none, partial, on
set(obfuscateURLs=false);
set(uncountables="equipment,information,rice,money,species,series,fish,sheep,deer");

// Request handling
set(cacheControllerInitialization=true);
set(cacheModelInitialization=true);
set(cachePlugins=true);
set(cacheFileChecking=true);
set(cacheImages=true);

// Model settings
set(tableNamePrefix="");
set(pluralizeTableNames=true);
set(modelRequireConfig=false);
set(modelRequireInit=false);
set(automaticAssociations=true);
set(useExpandedColumnAliases=true);

// View settings
set(viewPath="/views");
set(existingLayoutFiles="");
set(nonExistingLayoutFiles="");
set(defaultLayout="layout");
set(cachePartialPath=true);

// Controller settings
set(controllerPath="/controllers");
set(excludeFromErrorEmail="password,passwordConfirmation,creditCard");
set(protectFromForgery=true);

// Validation settings
set(automaticValidations=true);
set(setUpdatedAtOnCreate=true);
set(setUpdatedAtOnUpdate=true);
set(softDeleteProperty="deletedAt");
set(timeStampOnCreate="createdAt");
set(timeStampOnUpdate="updatedAt");

// Error handling
set(errorEmailServer="");
set(errorBrowserPassword="");
set(includeErrorInEmailSubject=true);

// Asset paths
set(imagePath="/images");
set(javascriptPath="/javascripts");
set(stylesheetPath="/stylesheets");

// File uploads
set(allowedFileExtensions="jpg,jpeg,gif,png,pdf,doc,docx,xls,xlsx,zip");
set(maxFileSize=10485760); // 10MB in bytes
set(fileUploadPath="/files/uploads");

// Localization
set(defaultLocale="en");
set(availableLocales="en,es,fr,de");
set(localizeDataSource=true);
</cfscript>
```

## Database Configuration

### Database Connection Settings
```cfml
<cfscript>
// Primary database
set(dataSourceName="myapp");
set(dataSourceUserName="dbuser");
set(dataSourcePassword=server.system.environment.DB_PASSWORD);

// Database behavior
set(transactionMode="commit"); // commit, rollback, none
set(skipDatabaseByDefault=false);
set(useTransactions=true);
set(migrateDatabase=true);

// Query settings
set(quoteTableNames=false);
set(quoteColumnNames=false);
set(useExpandedColumnAliases=true);
set(tableNamePrefix="app_");

// Connection pool settings (if using custom datasource)
set(database={
    connectionLimit: 100,
    connectionTimeout: 120,
    connectionLifetime: 600,
    connectionIdleTimeout: 300,
    enablePooling: true
});

// Read replica configuration (optional)
set(readDataSourceName="myapp_read");
set(readDataSourceUserName="readonly_user");
set(readDataSourcePassword=server.system.environment.READ_DB_PASSWORD);

// Database-specific settings
switch(getDatabaseType()) {
    case "MySQL":
        set(mysqlOptions="allowMultiQueries=true&zeroDateTimeBehavior=convertToNull");
        break;
    case "PostgreSQL":
        set(postgresqlOptions="sslmode=require&sslcert=/path/to/cert");
        break;
    case "SQLServer":
        set(sqlserverOptions="encrypt=true;trustServerCertificate=false");
        break;
}
</cfscript>
```

## Caching Configuration

### Cache Settings
```cfml
<cfscript>
// Cache backend configuration
set(cacheAdapter="memory"); // memory, redis, memcached, file

// Memory cache settings
set(cacheQueriesSize=100);
set(cachePagesSize=30);
set(cachePartialsSize=30);
set(cacheActionsSize=30);
set(cacheImagesSize=100);
set(cacheModelFilesSize=100);
set(cacheControllerFilesSize=100);

// Redis cache configuration
if (get("cacheAdapter") == "redis") {
    set(redisHost="localhost");
    set(redisPort=6379);
    set(redisPassword=server.system.environment.REDIS_PASSWORD);
    set(redisDatabase=0);
    set(redisPrefix="wheels:");
    set(redisTimeout=5);
}

// Memcached configuration
if (get("cacheAdapter") == "memcached") {
    set(memcachedServers="localhost:11211");
    set(memcachedPrefix="wheels_");
}

// Cache key generation
set(cacheKeyCase="lower"); // lower, upper, none
set(cacheKeyDelimiter="_");

// Query cache settings
set(cacheQueriesDuringRequest=true);
set(clearQueryCacheOnReload=true);
set(autoCacheQueryResults=false);

// Action caching
set(cacheActions=true);
set(cacheActionElements="body"); // body, title, head, all
set(cacheActionsExclude="login,logout,admin");

// Partial caching
set(cachePartials=true);
set(cachePartialElements=true);
set(cachePartialExpires=3600);

// CDN configuration
set(cdnEnabled=false);
set(cdnHost="");
set(cdnProtocol="https");
</cfscript>
```

## Security Settings

### Security Configuration
```cfml
<cfscript>
// CSRF Protection
set(protectFromForgery=true);
set(csrfCookieName="_wheels_csrf");
set(csrfCookieEncryptionAlgorithm="AES");
set(csrfCookieEncryptionKey=generateSecretKey());
set(csrfCookieEncryptionEncoding="Base64");
set(csrfTokenExpiry=7200); // 2 hours in seconds

// Session security
set(sessionCookieSecure=true); // HTTPS only
set(sessionCookieHttpOnly=true);
set(sessionCookieSameSite="Lax");
set(sessionRotate=true); // Rotate session ID on login
set(sessionTimeout=CreateTimeSpan(0, 0, 30, 0));

// Password security
set(passwordHashAlgorithm="BCrypt");
set(passwordHashRounds=12);
set(passwordMinLength=8);
set(passwordRequireUppercase=true);
set(passwordRequireLowercase=true);
set(passwordRequireNumber=true);
set(passwordRequireSpecialChar=true);

// Request security
set(allowedMethods="GET,POST,PUT,PATCH,DELETE");
set(blockSuspiciousRequests=true);
set(maxRequestSize=10485760); // 10MB
set(requestTimeout=30); // seconds

// Content Security Policy
set(contentSecurityPolicy="default-src 'self'; script-src 'self' 'unsafe-inline' https://cdn.example.com; style-src 'self' 'unsafe-inline';");

// Security headers
set(securityHeaders={
    "X-Frame-Options": "SAMEORIGIN",
    "X-Content-Type-Options": "nosniff",
    "X-XSS-Protection": "1; mode=block",
    "Strict-Transport-Security": "max-age=31536000; includeSubDomains",
    "Referrer-Policy": "strict-origin-when-cross-origin"
});

// API security
set(apiRateLimitEnabled=true);
set(apiRateLimitRequests=1000);
set(apiRateLimitWindow=3600); // 1 hour
set(apiRequireHttps=true);
set(apiTokenExpiry=86400); // 24 hours

// File upload security
set(uploadVirusScan=true);
set(uploadAllowedMimeTypes="image/jpeg,image/png,image/gif,application/pdf");
set(uploadMaxFileSize=5242880); // 5MB
set(uploadDirectory="/uploads");
set(uploadQuarantine=true);
</cfscript>
```

## Email Configuration

### Email Settings
```cfml
<cfscript>
// Email server configuration
set(functionName="sendEmail");
set(emailServer="smtp.example.com");
set(emailPort=587);
set(emailUsername=server.system.environment.SMTP_USERNAME);
set(emailPassword=server.system.environment.SMTP_PASSWORD);
set(emailUseSSL=false);
set(emailUseTLS=true);

// Default email settings
set(emailDefaultFrom="noreply@example.com");
set(emailDefaultReplyTo="support@example.com");
set(emailDefaultSubjectPrefix="[MyApp] ");
set(emailLayout="email"); // Layout template for emails

// Email delivery settings
set(emailDeliveryMethod="smtp"); // smtp, sendgrid, ses, mailgun, test
set(emailTestRecipient="test@example.com"); // Used in test mode
set(emailBccAdmin=false);
set(emailAdminAddress="admin@example.com");

// Email queue settings
set(emailQueueEnabled=true);
set(emailQueueAdapter="database"); // database, redis, rabbitmq
set(emailQueueTableName="email_queue");
set(emailQueueWorkers=2);
set(emailQueueRetryAttempts=3);
set(emailQueueRetryDelay=300); // 5 minutes

// Template settings
set(emailTemplatePath="/views/emails");
set(emailTemplateFormat="html"); // html, text, both
set(emailInlineCSS=true);

// Service-specific settings
if (get("emailDeliveryMethod") == "sendgrid") {
    set(sendgridApiKey=server.system.environment.SENDGRID_API_KEY);
    set(sendgridWebhookVerificationKey=server.system.environment.SENDGRID_WEBHOOK_KEY);
}

if (get("emailDeliveryMethod") == "ses") {
    set(awsAccessKeyId=server.system.environment.AWS_ACCESS_KEY_ID);
    set(awsSecretAccessKey=server.system.environment.AWS_SECRET_ACCESS_KEY);
    set(awsRegion="us-east-1");
}
</cfscript>
```

## Asset Configuration

### Asset Management Settings
```cfml
<cfscript>
// Asset paths
set(imagePath="/assets/images");
set(javascriptPath="/assets/javascripts");
set(stylesheetPath="/assets/stylesheets");
set(fontPath="/assets/fonts");

// Asset compilation (production)
set(assetCompilation=true);
set(assetFingerprinting=true);
set(assetCompression=true);
set(assetMinification=true);
set(assetConcatenation=true);

// Asset pipeline
set(assetPipeline={
    enabled: true,
    processors: ["sass", "less", "coffeescript", "typescript"],
    sourceDirectory: "/assets/source",
    outputDirectory: "/assets/compiled",
    manifestFile: "/assets/manifest.json"
});

// CDN configuration
set(assetHost=""); // Leave empty for local, or set CDN URL
set(assetProtocol="https");
set(assetCDNFallback=true);

// Image processing
set(imageProcessor="cfimage"); // cfimage, imagemagick, graphicsmagick
set(imageThumbnailSizes="100x100,200x200,400x400");
set(imageQuality=85);
set(imageAutoOrient=true);

// Asset caching
set(assetCacheControl="public, max-age=31536000"); // 1 year
set(assetETag=true);
set(assetLastModified=true);

// Development asset settings
if (get("environment") == "development") {
    set(assetCompilation=false);
    set(assetFingerprinting=false);
    set(assetCompression=false);
    set(assetSourceMaps=true);
    set(assetLiveReload=true);
}
</cfscript>
```

## Plugin Configuration

### Plugin Settings
```cfml
<cfscript>
// Plugin system settings
set(loadPlugins=true);
set(pluginPath="/plugins");
set(deletePluginDirectories=false);
set(overwritePlugins=false);
set(pluginDatabase="skip"); // skip, create, update

// Plugin defaults
set(pluginDefaults={
    cacheTimeout: 3600,
    requireAuthentication: false,
    version: "1.0.0"
});

// Specific plugin configurations
set(plugins={
    authentication: {
        enabled: true,
        providers: ["local", "oauth", "ldap"],
        sessionTimeout: 1800,
        rememberMeDuration: 2592000 // 30 days
    },
    
    fileUpload: {
        enabled: true,
        storageAdapter: "local", // local, s3, azure
        maxFileSize: 10485760,
        allowedTypes: ["image", "document", "archive"]
    },
    
    search: {
        enabled: true,
        engine: "lucene", // lucene, elasticsearch, algolia
        indexPath: "/search/index",
        autoIndex: true
    },
    
    cache: {
        enabled: true,
        adapter: "redis",
        defaultTimeout: 3600
    }
});

// Plugin dependencies
set(pluginDependencies={
    "authentication": ["session", "crypto"],
    "fileUpload": ["validation"],
    "search": ["indexer"]
});
</cfscript>
```

## Custom Settings

### Application-Specific Settings
```cfml
<cfscript>
// Business logic settings
set(app={
    name: "My Application",
    version: "1.0.0",
    company: "Example Corp",
    supportEmail: "support@example.com",
    timezone: "America/New_York",
    locale: "en_US",
    currency: "USD"
});

// Feature flags
set(features={
    newDashboard: true,
    betaFeatures: false,
    maintenanceMode: false,
    readOnlyMode: false,
    apiV2: true,
    socialLogin: true
});

// Integration settings
set(integrations={
    stripe: {
        enabled: true,
        publishableKey: server.system.environment.STRIPE_PUBLISHABLE_KEY,
        secretKey: server.system.environment.STRIPE_SECRET_KEY,
        webhookSecret: server.system.environment.STRIPE_WEBHOOK_SECRET
    },
    
    twilio: {
        enabled: true,
        accountSid: server.system.environment.TWILIO_ACCOUNT_SID,
        authToken: server.system.environment.TWILIO_AUTH_TOKEN,
        fromNumber: server.system.environment.TWILIO_FROM_NUMBER
    },
    
    googleAnalytics: {
        enabled: true,
        trackingId: "UA-XXXXX-Y",
        anonymizeIp: true
    }
});

// Business rules
set(businessRules={
    maxLoginAttempts: 5,
    lockoutDuration: 900, // 15 minutes
    passwordExpiry: 90, // days
    sessionWarning: 300, // 5 minutes before timeout
    dataRetention: 365, // days
    auditLogRetention: 730 // days
});

// Notification settings
set(notifications={
    enableEmail: true,
    enableSMS: false,
    enablePush: false,
    enableWebhooks: true,
    queueNotifications: true
});
</cfscript>
```

## Environment Variables

### Using Environment Variables
```cfml
<cfscript>
// Reading environment variables
set(databaseServer=server.system.environment.DB_HOST ?: "localhost");
set(databaseName=server.system.environment.DB_NAME ?: "myapp");
set(databaseUsername=server.system.environment.DB_USER ?: "root");
set(databasePassword=server.system.environment.DB_PASSWORD ?: "");

// Using Java system properties
set(javaHeapSize=createObject("java", "java.lang.System").getProperty("java.heap.size"));

// Using .env file (requires dotenv plugin)
if (fileExists(expandPath("/.env"))) {
    loadEnvironmentFile("/.env");
}

// Helper function for environment variables
function getEnv(required string key, string defaultValue="") {
    if (StructKeyExists(server.system.environment, arguments.key)) {
        return server.system.environment[arguments.key];
    }
    return arguments.defaultValue;
}

// Use helper
set(apiKey=getEnv("API_KEY", "development-key"));
set(debugMode=getEnv("DEBUG", "false") == "true");
</cfscript>
```

## Production Optimization

### Performance Settings for Production
```cfml
<cfscript>
// Performance optimizations
set(performance={
    // Caching
    enableQueryCache: true,
    queryCacheTimeout: 300,
    enableRequestCache: true,
    enableSessionCache: true,
    
    // Database
    connectionPooling: true,
    connectionPoolSize: 20,
    preparedStatements: true,
    lazyLoading: true,
    
    // View rendering
    compileViews: true,
    viewCaching: true,
    compressOutput: true,
    removeWhitespace: true,
    
    // Assets
    bundleAssets: true,
    minifyCSS: true,
    minifyJS: true,
    gzipAssets: true,
    
    // Application
    threadPoolSize: 10,
    requestQueueSize: 100,
    asyncProcessing: true
});

// Monitoring
set(monitoring={
    enabled: true,
    service: "newrelic", // newrelic, datadog, cloudwatch
    apiKey: server.system.environment.MONITORING_API_KEY,
    appName: "MyApp-Production",
    trackErrors: true,
    trackPerformance: true,
    trackCustomEvents: true
});

// Logging
set(logging={
    level: "ERROR", // DEBUG, INFO, WARN, ERROR, FATAL
    destination: "file", // console, file, syslog, cloudwatch
    filePath: "/var/log/myapp/",
    maxFileSize: 10485760, // 10MB
    maxFiles: 10,
    format: "json",
    includeStackTrace: false
});

// Health checks
set(healthCheck={
    enabled: true,
    path: "/health",
    checks: ["database", "cache", "filesystem", "memory"],
    timeout: 5000,
    includeDetails: false
});
</cfscript>
```

## Best Practices

1. **Environment Separation**: Keep environment-specific settings in separate files
2. **Secure Secrets**: Never commit passwords or API keys to version control
3. **Use Environment Variables**: Store sensitive data in environment variables
4. **Cache in Production**: Enable all caching mechanisms in production
5. **Monitor Performance**: Set up monitoring and alerting for production
6. **Regular Reviews**: Periodically review and update configuration settings
7. **Document Changes**: Keep a changelog of configuration modifications
8. **Test Configurations**: Test configuration changes in staging first
9. **Backup Settings**: Keep backups of production configurations
10. **Automate Deployment**: Use configuration management tools for consistency