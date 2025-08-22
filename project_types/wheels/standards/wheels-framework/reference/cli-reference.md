---
description: Wheels Framework CLI Command Reference
version: 1.0
encoding: UTF-8
---

# Wheels CLI Command Reference

Comprehensive CLI command reference for the Wheels framework, including syntax, examples, and common patterns.

## Table of Contents
- [CommandBox Basics](#commandbox-basics)
- [Wheels CLI Commands](#wheels-cli-commands)
- [Generator Commands](#generator-commands)
- [Database Commands](#database-commands)
- [Testing Commands](#testing-commands)
- [Environment Commands](#environment-commands)
- [Configuration Commands](#configuration-commands)
- [Development Commands](#development-commands)
  - [Server Management](#server-management)
  - [Code Formatting](#code-formatting)
  - [Development Workflow](#development-workflow)
- [Plugin Management](#plugin-management)
- [Maintenance Commands](#maintenance-commands)
  - [Maintenance Mode](#maintenance-mode)
  - [Cleanup Commands](#cleanup-commands)
- [Analysis and Optimization Commands](#analysis-and-optimization-commands)
- [Application Utilities](#application-utilities)
- [Asset and Cache Management Commands](#asset-and-cache-management-commands)
  - [Asset Management](#asset-management)
  - [Cache Management](#cache-management)
  - [Log Management](#log-management)
  - [Temporary Files](#temporary-files)
- [Docker Commands](#docker-commands)
- [Deployment Commands](#deployment-commands)
- [Security Commands](#security-commands)
- [Documentation Commands](#documentation-commands)
- [Continuous Integration Commands](#continuous-integration-commands)
- [Interactive Console and Runner](#interactive-console-and-runner)
- [Destroy Commands](#destroy-commands)
- [Additional Generators](#additional-generators)
- [Reload Command](#reload-command)
- [Common Command Sequences](#common-command-sequences)
- [Parameter Inconsistencies](#parameter-inconsistencies)
- [Troubleshooting](#troubleshooting)
- [Advanced Usage](#advanced-usage)

## CommandBox Basics

### Installation and Setup

```bash
# Install CommandBox (if not installed)
brew install commandbox  # macOS
# or
curl -fsSl https://downloads.ortussolutions.com/debs/gpg | sudo apt-key add -
echo "deb https://downloads.ortussolutions.com/debs/noarch /" | sudo tee -a /etc/apt/sources.list.d/commandbox.list
sudo apt-get update && sudo apt-get install commandbox  # Ubuntu/Debian

# Install Wheels dependencies
box install

# Start CommandBox shell
box

# Check to see if Commandbox is installed
box version

# Exit CommandBox shell
exit
```

### Key CommandBox Concepts

1. **Named Parameters**: CommandBox requires named parameters (key=value)
2. **Boolean Shortcuts**: Use `--flag` as shortcut for `flag=true`
3. **Working Directory**: Commands run in current directory
4. **Reload Requirement**: After modifying CLI code, run `box reload`

## Server Requirements

### Commands That Require a Running Server

Many Wheels CLI commands interact with the application runtime and therefore require a running CommandBox server. These commands will fail with errors like "Unable to determine server port" if no server is running.

**Commands requiring a server:**
- `wheels dbmigrate` (all subcommands) - Database migrations need active database connection
- `wheels test` (all subcommands) - Tests run in application context
- `wheels routes` - Reads runtime route configuration
- `wheels reload` - Reloads the running application
- `wheels runner` - Executes code in application context
- `wheels console` - Interactive REPL needs application context

**Commands that work without a server:**
- All generator commands (`wheels g ...`)
- `wheels version`, `wheels info`, `wheels about`
- `wheels environment` (read/set)
- `wheels doctor` - Checks file system only
- `wheels stats`, `wheels notes` - Static code analysis
- `wheels cache clear` - Clears file-based caches
- `wheels secret` - Generates random secrets

### Starting a Server

```bash
# Start server in current directory
server start

# Start with specific name
server start name=myapp

# Start on specific port
server start port=8080

# Start without opening browser
server start openBrowser=false

# Check server status
server status

# Stop server
server stop
```

## Wheels CLI Commands

### Running Wheels CLI commands
The Wheels CLI commands need to be run in the bash/command shell. They can be run from the main OS shell by
prefixing the commands with the box command i.e. box wheels version from the os shell or you can launch
commandbox by entering box and then entering the Wheels CLI command in the box shell i.e. box followed by
wheels version.

### Installation

```bash
# Check to see if Wheels CLI module is installed
box wheels version

# Install Wheels CLI module (usually automatic with box install)
box install cfwheels-cli

# Verify installation
wheels version

# Get help
wheels help
wheels help [command]
```

## Generator Commands

### Generate Application

```bash
# Basic app generation
wheels g app myapp

# With template
wheels g app myapp template=wheels-base-template@BE

# In specific directory
wheels g app name=myapp directory=./projects/

# With datasource
wheels g app myapp datasourceName=mydb

# With Bootstrap and H2 database
wheels g app myapp --useBootstrap --setupH2

# With custom CFML engine
wheels g app myapp cfmlEngine=adobe2023
```

### Generate Application Wizard

```bash
# Interactive wizard for creating new app (recommended for beginners)
wheels new

# Alternative commands (all call the same wizard)
wheels g app-wizard
wheels generate app-wizard

# Force installation in non-empty directory
wheels new --force
```

The wizard will interactively ask for:
- Application name
- Template to use
- Reload password
- Datasource name
- CFML engine preference
- H2 database setup (Lucee only)
- Bootstrap setup
- Package initialization

### Generate Controller

```bash
# Basic controller
wheels g controller Users

# With actions
wheels g controller Users index,show,new,create,edit,update,delete

# Namespaced controller
wheels g controller name=Admin/Users actions=index,show

# RESTful controller with CRUD actions
wheels g controller Users --rest

# API controller (no view actions)
wheels g controller Api/Users --api
```

### Generate Model

```bash
# Basic model
wheels g model User

# With properties
wheels g model User name:string,email:string,password:string

# With associations
wheels g model Post title:string,content:text,userId:integer

# Skip migration
wheels g model User --migration=false

# Force overwrite
wheels g model User --force

# With relationships
wheels g model Post --belongsTo=User --hasMany=Comments

# With custom table name
wheels g model User --tableName=app_users
```

### Generate Scaffold

```bash
# Complete CRUD scaffold
wheels g scaffold Product name:string,price:decimal,description:text

# With namespace
wheels g scaffold name=Admin/Product properties=name:string,price:decimal

# API scaffold (no views)
wheels g scaffold Product --properties="name:string,price:decimal" --api

# With relationships
wheels g scaffold Post --properties="title:string,content:text" --belongsTo=User --hasMany=Comments

# With migration auto-run
wheels g scaffold Product --properties="name:string,price:decimal" --migrate
```

### Generate View

```bash
# Single view
wheels g view users index

# Multiple views
wheels g view users index,show,edit,new

# With layout
wheels g view users index layout=admin

# Partial
wheels g view users _form
```

### Generate Migration

```bash
# Create table migration
wheels dbmigrate create table name=users

# Add column migration
wheels dbmigrate create column name=AddEmailToUsers

# Create blank migration
wheels dbmigrate create blank name=UpdateUserData

# Remove table migration
wheels dbmigrate remove table name=old_users
```

### Generate Test

```bash
# Model test
wheels g test model User

# Controller test
wheels g test controller Users

# Integration test
wheels g test integration UserRegistration

# Helper test
wheels g test helper Format
```

### Generate Snippets

```bash
# Copy template snippets to app/snippets/ directory
wheels g snippets

# Alternative command
wheels generate snippets
```

This command copies template snippets to your application that can be used as templates for generating code. The snippets are placed in the `app/snippets/` directory.

### Generate Migration (Enhanced)

```bash
# Create table migration
wheels g migration CreateUsersTable
wheels g migration CreateUsersTable --create=users
wheels g migration CreateProductsTable --attributes="name:string,price:decimal,inStock:boolean"

# Add column migration
wheels g migration AddEmailToUsers
wheels g migration AddEmailToUsers --table=users --attributes="email:string:index,verified:boolean"

# Remove column migration
wheels g migration RemoveAgeFromUsers
wheels g migration RemoveAgeFromUsers --table=users

# Change column migration
wheels g migration ChangeNameInUsers --table=users

# Add index migration
wheels g migration CreateIndexOnUsersEmail --table=users

# Custom migration
wheels g migration CustomDataMigration --up="/* custom up code */" --down="/* custom down code */"
```

### Generate Mailer

```bash
# Basic mailer
wheels g mailer Welcome

# With multiple methods
wheels g mailer UserNotifications --methods="accountCreated,passwordReset,orderConfirmation"

# With configuration
wheels g mailer OrderMailer --from="orders@example.com" --layout="email"

# Skip view creation
wheels g mailer NotificationMailer --createViews=false
```

### Generate Service

```bash
# Basic service object
wheels g service Payment

# With methods
wheels g service UserAuthentication --methods="login,logout,register,verify"

# With dependencies
wheels g service OrderProcessing --dependencies="PaymentService,EmailService"

# As singleton
wheels g service CacheManager --type=singleton

# With description
wheels g service DataExport --description="Handles CSV and Excel exports"
```

### Generate Helper

```bash
# Basic helper
wheels g helper Format

# With specific functions
wheels g helper StringUtils --functions="truncate,highlight,slugify"

# Global helper
wheels g helper DateHelpers --global=true

# View-specific helper
wheels g helper ViewHelpers --type=view

# Controller-specific helper
wheels g helper AuthHelpers --type=controller
```

### Generate Job

```bash
# Basic background job
wheels g job ProcessOrders

# With queue configuration
wheels g job SendNewsletters --queue=emails --priority=high

# Scheduled job (cron expression)
wheels g job CleanupOldRecords --schedule="0 0 * * *"

# With delay
wheels g job DataSync --delay=3600

# With retries and timeout
wheels g job ImportData --retries=5 --timeout=600
```

### Generate Plugin

```bash
# Basic plugin scaffold
wheels g plugin Authentication

# With version and author
wheels g plugin ImageProcessor --version="1.0.0" --author="John Doe"

# With methods
wheels g plugin CacheManager --methods="init,configure,process"

# With dependencies
wheels g plugin APIConnector --dependencies="wheels-http-client"

# With mixin types
wheels g plugin FormValidation --mixin="controller,model"
```

## Database Commands

### Database Management

```bash
# Create database
wheels db create
wheels db create --datasource=myapp_dev
wheels db create --environment=production

# Drop database (with confirmation)
wheels db drop
wheels db drop --datasource=myapp_dev
wheels db drop --force  # Skip confirmation

# Setup database (create + migrate + seed)
wheels db setup
wheels db setup --skip-seed
wheels db setup --seed-count=10

# Reset database (drop + create + migrate + seed)
wheels db reset
wheels db reset --force  # Skip confirmation
wheels db reset --skip-seed
wheels db reset --environment=production

# Seed database with test data
wheels db seed
wheels db seed --count=10  # Records per model
wheels db seed --models=user,post  # Specific models
wheels db seed --dataFile=seeds.json  # From file

# Show migration status
wheels db status
wheels db status --format=json
wheels db status --pending  # Only pending migrations

# Show current database version
wheels db version
wheels db version --detailed

# Rollback migrations
wheels db rollback  # Rollback one migration
wheels db rollback --steps=3  # Rollback 3 migrations
wheels db rollback --target=20231201120000  # To specific version

# Export database
wheels db dump
wheels db dump --output=backup.sql
wheels db dump --schema-only  # Structure only
wheels db dump --data-only  # Data only
wheels db dump --tables=users,posts  # Specific tables
wheels db dump --compress  # Gzip compression

# Restore database
wheels db restore backup.sql
wheels db restore backup.sql.gz --compressed
wheels db restore backup.sql --clean  # Drop existing objects
wheels db restore backup.sql --force  # Skip confirmation

# Launch interactive database shell
wheels db shell  # CLI shell
wheels db shell --web  # Web console (H2 only)
wheels db shell --datasource=myapp_dev
wheels db shell --command="SELECT COUNT(*) FROM users"  # Execute single command
```

### Database Shell Details

The `wheels db shell` command provides direct database access:

**H2 Database (Lucee default):**
```bash
# CLI shell - uses java -cp org.lucee.h2-*.jar org.h2.tools.Shell
wheels db shell

# Web console - launches browser interface
wheels db shell --web

# The H2 JAR is typically found in Lucee bundles as org.lucee.h2-*.jar
```

**MySQL/MariaDB:**
```bash
# Launches mysql client
wheels db shell
# Equivalent to: mysql -h host -P port -u user -p database
```

**PostgreSQL:**
```bash
# Launches psql client
wheels db shell
# Equivalent to: psql -h host -p port -U user -d database
```

**SQL Server:**
```bash
# Launches sqlcmd client
wheels db shell
# Equivalent to: sqlcmd -S server -d database -U user
```

**Requirements:**
- H2: No additional installation (included with Lucee)
- MySQL: Requires `mysql` client installed
- PostgreSQL: Requires `psql` client installed
- SQL Server: Requires `sqlcmd` client installed

### Migration Management

```bash
# Run all pending migrations
wheels dbmigrate latest

# Run next migration
wheels dbmigrate up

# Run specific migration version
wheels dbmigrate exec 001

# Show migration status
wheels dbmigrate info
```

### Rollback Migrations

```bash
# Rollback last migration
wheels dbmigrate down

# Reset all migrations (rollback all)
wheels dbmigrate reset
```

### Database Schema Utilities

```bash
# Export database schema
wheels db schema
```

## Testing Commands

### Running Tests

```bash
# DEPRECATED: The 'wheels test' command is deprecated. Use 'wheels test run' instead.

# Run all tests (new command)
wheels test run

# Run all tests (deprecated)
wheels test app

# Run specific test file
wheels test run --filter=UserTest

# Run test group
wheels test run --group=models

# Run with coverage
wheels test run --coverage

# Run with different reporter
wheels test run --reporter=junit

# Watch mode
wheels test run --watch

# Stop on first failure
wheels test run --failFast
```

### Advanced Testing (TestBox CLI Wrappers)

These commands require TestBox CLI to be installed: `box install commandbox-testbox-cli`

#### Run All Tests
```bash
# Run all tests with TestBox CLI
wheels test:all

# With specific reporter
wheels test:all --reporter=spec

# With coverage
wheels test:all --coverage --coverageReporter=html

# With filters
wheels test:all --filter=UserTest --verbose
```

#### Run Unit Tests
```bash
# Run only unit tests
wheels test:unit

# With specific reporter
wheels test:unit --reporter=spec

# Filter specific tests
wheels test:unit --filter=UserModelTest
```

#### Run Integration Tests
```bash
# Run only integration tests
wheels test:integration

# With verbose output
wheels test:integration --verbose

# Filter specific tests
wheels test:integration --filter=UserWorkflowTest
```

#### Watch Mode
```bash
# Watch for changes and rerun tests
wheels test:watch

# Watch specific directory
wheels test:watch --directory=tests/unit

# With custom delay
wheels test:watch --delay=500

# Watch additional paths
wheels test:watch --watchPaths=models,controllers
```

#### Code Coverage
```bash
# Run tests with code coverage
wheels test:coverage

# With HTML reporter (default)
wheels test:coverage --reporter=html

# With JSON reporter
wheels test:coverage --reporter=json

# Set coverage threshold
wheels test:coverage --threshold=80

# Coverage for specific directory
wheels test:coverage --directory=tests/unit

# Specify paths to capture
wheels test:coverage --pathsToCapture=models,controllers
```

### TestBox Integration

```bash
# Run TestBox directly
box testbox run

# With coverage
box testbox run --coverage --coverageReporter=html

# Watch mode
box testbox watch

# Run specific directory
box testbox run --directory=tests/specs/unit

# Run specific bundles
box testbox run --bundles=tests.specs.models.UserTest

# Run with labels
box testbox run --labels=critical

# Exclude labels
box testbox run --excludeLabels=slow
```

## Environment Commands

### Environment Management

#### Legacy Commands (for backward compatibility)
```bash
# Show current environment
wheels get environment

# Set environment
wheels set environment development
wheels set environment testing
wheels set environment production
```

#### New Environment Command (Recommended)

The enhanced `wheels environment` command provides better environment management:

```bash
# Show current environment with detailed info
wheels environment

# Set environment (with automatic reload)
wheels environment set development
wheels environment set testing
wheels environment set production
wheels environment set maintenance

# Set environment without reload
wheels environment set production --reload=false

# List all available environments
wheels environment list

# Quick environment switching
wheels environment development    # Shortcut for set development
wheels environment production     # Shortcut for set production

# Reload application
wheels reload
wheels reload development
wheels reload force=true
```

### Interactive Console (REPL)

The `wheels console` command starts an interactive REPL with full Wheels application context:

```bash
# Start interactive console
wheels console

# Start console in specific environment
wheels console environment=testing

# Execute single command
wheels console execute="model('User').count()"

# Start in tag mode (default is script mode)
wheels console script=false
```

**Console Features:**
- Access to all Wheels models via `model()` function
- Direct database queries via `query()` function
- All Wheels helper functions available
- Persistent variable state between commands
- Command history
- Script and tag mode support

**Example Console Session:**
```cfscript
wheels:script> user = model("User").findByKey(1)
wheels:script> user.name = "Updated Name"
wheels:script> user.save()
wheels:script> users = model("User").findAll(where="active=1", order="createdAt DESC")
wheels:script> pluralize("person")
people
wheels:script> query("SELECT COUNT(*) as total FROM users").total
42
```

### Script Runner

The `wheels runner` command executes script files in the Wheels application context:

```bash
# Run a script file
wheels runner scripts/data-migration.cfm

# Run with specific environment
wheels runner scripts/cleanup.cfm environment=production

# Run with parameters
wheels runner scripts/import.cfm params='{"source":"data.csv","dryRun":true}'

# Run with verbose output
wheels runner scripts/process.cfm --verbose
```

**Script Features:**
- Full access to Wheels application context
- Pass parameters via JSON
- Scripts can access `request.scriptParams`
- Model and query functions available
- Execution time reporting

**Example Script:**
```cfm
<!--- scripts/cleanup-users.cfm --->
<cfscript>
// Access passed parameters
var dryRun = structKeyExists(request.scriptParams, "dryRun") ? request.scriptParams.dryRun : false;

// Use Wheels models
var inactiveUsers = request.model("User").findAll(
    where="lastLoginAt < '#dateAdd('m', -6, now())#'"
);

writeOutput("Found #inactiveUsers.recordCount# inactive users<br>");

if (!dryRun) {
    for (var user in inactiveUsers) {
        request.model("User").deleteByKey(user.id);
        writeOutput("Deleted user: #user.email#<br>");
    }
} else {
    writeOutput("Dry run - no users deleted");
}
</cfscript>
```

### Configuration

```bash
# Show settings
wheels get settings

# Show specific setting
wheels get settings cacheQueries

# Set configuration value
wheels set settings cacheQueries false

# Show routes
wheels routes

# Show route details
wheels routes name=users
```

## Configuration Commands

The Wheels CLI provides comprehensive configuration management commands for working with application settings and environment variables.

### Config Commands

#### Dump Configuration
Export configuration settings for any environment:

```bash
# Dump current environment config
wheels config dump

# Dump specific environment
wheels config dump production

# Export as JSON
wheels config dump --format=json

# Export as .env format
wheels config dump --format=env

# Export as CFML
wheels config dump --format=cfml

# Save to file
wheels config dump --output=config.json

# Show unmasked sensitive values (careful!)
wheels config dump --no-mask
```

#### Check Configuration
Validate configuration for security and best practices:

```bash
# Check current environment
wheels config check

# Check specific environment
wheels config check production

# Show detailed fix suggestions
wheels config check --verbose

# Auto-fix issues where possible
wheels config check --fix
```

#### Compare Configurations
Compare settings between environments:

```bash
# Compare two environments
wheels config diff development production

# Show only differences
wheels config diff development production --changes-only

# Output as JSON
wheels config diff testing production --format=json
```

### Secret Generation

Generate cryptographically secure secrets:

```bash
# Generate hex secret (default)
wheels secret

# Generate with specific type and length
wheels secret --type=hex --length=64
wheels secret --type=base64 --length=48
wheels secret --type=alphanumeric --length=32
wheels secret --type=uuid

# Save directly to .env file
wheels secret --save-to-env=SECRET_KEY
wheels secret --type=base64 --save-to-env=API_SECRET
```

### Enhanced Environment Variable Commands

#### Show Environment Variables
Display environment variables with enhanced formatting:

```bash
# Show all env vars (with masking)
wheels env show

# Show specific variable
wheels env show --key=DB_HOST

# Output as JSON
wheels env show --format=json

# Read from specific file
wheels env show --file=.env.production
```

#### Set Environment Variables
Update .env files programmatically:

```bash
# Set single variable
wheels env set DB_HOST=localhost

# Set multiple variables
wheels env set DB_HOST=localhost DB_PORT=3306 DB_NAME=myapp

# Update specific file
wheels env set --file=.env.production API_URL=https://api.example.com
```

#### Validate Environment Files
Check .env file format and content:

```bash
# Validate default .env
wheels env validate

# Validate specific file
wheels env validate --file=.env.production

# Check for required variables
wheels env validate --required=DB_HOST,DB_USER,DB_PASSWORD

# Show detailed information
wheels env validate --verbose
```

#### Merge Environment Files
Combine multiple .env files with precedence:

```bash
# Merge files (later files override earlier)
wheels env merge .env.defaults .env.local --output=.env

# Merge with dry run to preview
wheels env merge base.env override.env --dry-run

# Merge multiple files
wheels env merge .env .env.local .env.production --output=.env.merged
```

### Environment File Features

The framework now supports enhanced .env file handling:

1. **Environment-specific files**: Automatically loads `.env.{environment}` files
2. **Variable interpolation**: Use `${VAR}` syntax to reference other variables
3. **Type casting**: Boolean and numeric values are automatically converted
4. **Comments**: Lines starting with `#` are treated as comments

Example .env file with new features:
```bash
# Base configuration
APP_NAME=MyWheelsApp
APP_ENV=development

# Database with interpolation
DB_HOST=localhost
DB_PORT=3306
DB_NAME=${APP_NAME}_${APP_ENV}
DB_URL=mysql://${DB_HOST}:${DB_PORT}/${DB_NAME}

# Type casting examples
DEBUG_MODE=true        # Boolean
MAX_CONNECTIONS=100    # Numeric
CACHE_TTL=3600        # Numeric
```

## Development Commands

### Server Management

#### CommandBox Native Server Commands

```bash
# Start server
server start

# Start with specific port
server start port=3000

# Start with specific engine
server start cfengine=lucee5.3.9

# Stop server
server stop

# Restart server
server restart

# Show server status
server status

# Open browser
server open
```

#### Wheels Server Commands (Enhanced Wrappers)

The Wheels CLI provides enhanced server management commands that wrap CommandBox's native functionality with Wheels-specific checks and enhancements.

```bash
# Start Wheels development server
wheels server start

# Start with specific port
wheels server start port=8080

# Start with URL rewriting enabled
wheels server start --rewritesEnable

# Start without opening browser
wheels server start openbrowser=false

# Start with specific host
wheels server start host=0.0.0.0

# Force start even if already running
wheels server start --force

# Stop the server
wheels server stop

# Stop specific named server
wheels server stop name=myapp

# Force stop all servers
wheels server stop --force

# Restart the server (also reloads Wheels app)
wheels server restart

# Force restart
wheels server restart --force

# Show server status with Wheels info
wheels server status

# Show status in JSON format
wheels server status --json

# Show verbose status
wheels server status --verbose

# Tail server logs
wheels server log

# Show last 100 lines of logs
wheels server log lines=100

# Follow logs (default behavior)
wheels server log --follow

# Show debug-level logs
wheels server log --debug

# Open application in browser
wheels server open

# Open specific path
wheels server open /admin

# Open in specific browser
wheels server open --browser=firefox

# Display server help
wheels server
```

**Key Differences from CommandBox Native Commands:**
- Checks if current directory is a Wheels application
- Shows Wheels-specific information (version, paths)
- Automatically reloads Wheels application on restart
- Provides helpful error messages and suggestions
- Integrates with Wheels application context

### Code Formatting

```bash
# Format code
box run-script format

# Check formatting
box run-script format:check

# Watch mode
box run-script format:watch

# Format specific file
box cfformat path/to/file.cfc

# Format directory
box cfformat app/**/*.cfc
```

### Development Workflow

#### Initialize Wheels in Existing Project

The `wheels init` command bootstraps an existing Wheels application to work with the CLI:

```bash
# Initialize current directory
wheels init

# Initialize with custom name
wheels init name=myapp

# Skip server.json creation
wheels init createServerJSON=false

# Force overwrite existing files
wheels init --force
```

This command creates:
- `vendor/wheels/box.json` - Tracks Wheels framework version
- `server.json` - CommandBox server configuration
- `box.json` - Application package configuration

#### Upgrade Framework

The `wheels upgrade` command provides an interactive wizard for upgrading your Wheels framework:

```bash
# Start upgrade wizard
wheels upgrade

# Upgrade to specific version
wheels upgrade --to=3.0.0

# Check for available upgrades
wheels upgrade --check

# Skip confirmation prompts
wheels upgrade --force

# Upgrade without backup
wheels upgrade --backup=false
```

Features:
- Shows available versions from ForgeBox
- Detects breaking changes between versions
- Creates backup before upgrading
- Updates dependencies automatically
- Provides post-upgrade recommendations

#### Benchmark Application

The `wheels benchmark` command performs simple benchmarking of your application endpoints:

```bash
# Benchmark homepage
wheels benchmark /

# Benchmark with custom settings
wheels benchmark /products --requests=1000 --concurrent=10

# Benchmark POST request
wheels benchmark /api/users --method=POST --data='{"name":"test"}'

# Use config file for multiple scenarios
wheels benchmark --config=benchmark.json

# Output formats
wheels benchmark /users --output=json --save=results.json
wheels benchmark /api --output=csv --save=results.csv
```

Options:
- `--requests`: Number of requests to make (default: 100)
- `--concurrent`: Number of concurrent requests (default: 1)
- `--method`: HTTP method (GET, POST, PUT, DELETE)
- `--headers`: Comma-separated headers
- `--timeout`: Request timeout in seconds
- `--output`: Output format (text, json, csv)

#### Profile Requests

The `wheels profile` command helps identify performance bottlenecks:

```bash
# Profile single endpoint
wheels profile /products

# Profile with multiple iterations
wheels profile /api/users --iterations=10

# Interactive profiling mode
wheels profile --interactive

# Save profile results
wheels profile /admin --output=html --save=profile.html

# Profile with custom settings
wheels profile /search --method=POST --data='{"q":"wheels"}'
```

Features:
- Detailed timing breakdown
- Memory usage analysis
- Query performance metrics
- HTML reports with charts
- Interactive mode for comparing endpoints
- Recommendations for optimization

#### Documentation Management

The `wheels docs` command manages documentation:

```bash
# Open Wheels documentation
wheels docs

# Generate API documentation
wheels docs:generate

# Generate with specific format
wheels docs:generate --format=markdown
wheels docs:generate --format=html --template=bootstrap

# Generate for specific components
wheels docs:generate --type=models,controllers

# Serve documentation locally
wheels docs:generate --serve --port=8080
```

Supported formats:
- HTML with syntax highlighting
- Markdown for GitHub/GitLab
- JSON for custom processing

## Asset and Cache Management Commands

### Asset Management

```bash
# Precompile assets for production
wheels assets:precompile
wheels assets:precompile --force              # Force recompilation
wheels assets:precompile --environment=staging # Target specific environment

# Clean old compiled assets
wheels assets:clean
wheels assets:clean --keep=5                  # Keep 5 versions of each asset
wheels assets:clean --dryRun                  # Preview what would be deleted

# Remove all compiled assets
wheels assets:clobber
wheels assets:clobber --force                 # Skip confirmation
```

### Cache Management

```bash
# Clear all caches
wheels cache:clear
wheels cache:clear --force                    # Skip confirmation

# Clear specific cache
wheels cache:clear query                      # Clear query cache
wheels cache:clear page                       # Clear page cache
wheels cache:clear partial                    # Clear partial/fragment cache
wheels cache:clear action                     # Clear action cache
wheels cache:clear sql                        # Clear SQL file cache

# Clear multiple caches
wheels cache:clear all                        # Clear all caches (default)
```

### Log Management

```bash
# Clear log files
wheels log:clear
wheels log:clear --environment=production     # Clear specific environment logs
wheels log:clear --days=30                    # Clear logs older than 30 days
wheels log:clear --force                      # Skip confirmation

# Tail log files
wheels log:tail
wheels log:tail --environment=production      # Tail specific environment log
wheels log:tail --lines=50                    # Show last 50 lines
wheels log:tail --follow                      # Follow log in real-time (default)
wheels log:tail --file=custom.log            # Tail specific log file
```

### Temporary Files Management

```bash
# Clear all temporary files
wheels tmp:clear
wheels tmp:clear --force                      # Skip confirmation

# Clear specific temp file types
wheels tmp:clear cache                        # Clear cache files only
wheels tmp:clear sessions                     # Clear session files only
wheels tmp:clear uploads                      # Clear upload files only

# Clear old temporary files
wheels tmp:clear --days=7                     # Clear files older than 7 days
wheels tmp:clear --type=cache --days=30      # Clear cache files older than 30 days
```

### Asset Precompilation Details

The `wheels assets:precompile` command:
- Minifies JavaScript and CSS files
- Generates cache-busted filenames with MD5 hashes
- Creates a manifest.json for asset mapping
- Optimizes images (copies with cache-busted names)
- Stores compiled assets in `/public/assets/compiled/`

**Example manifest.json:**
```json
{
  "application.js": "application-a1b2c3d4.min.js",
  "styles.css": "styles-e5f6g7h8.min.css",
  "logo.png": "logo-i9j0k1l2.png"
}
```

### Cache Types Explained

- **Query Cache**: Stores database query results
- **Page Cache**: Stores complete rendered pages
- **Partial Cache**: Stores rendered view fragments
- **Action Cache**: Stores controller action results
- **SQL Cache**: Stores parsed SQL files

### Log File Color Coding

The `wheels log:tail` command color-codes log entries:
- **Red**: ERROR level messages
- **Yellow**: WARN/WARNING level messages
- **Cyan**: INFO level messages
- **Grey**: DEBUG level messages

### Package Management

```bash
# Install dependencies
box install

# Install specific package
box install cfwheels

# Install and save as dependency
box install cfwheels --save

# Install development dependency
box install testbox --saveDev

# Update packages
box update

# List installed packages
box list
```

## Plugin Management

### Plugin Commands Overview

Wheels provides comprehensive plugin management through the CLI:

```bash
# Search for plugins on ForgeBox
wheels plugin search
wheels plugin search auth
wheels plugin search --format=json --orderBy=downloads

# Get detailed plugin information
wheels plugin info wheels-auth
wheels plugin info wheels-api-builder

# List installed plugins
wheels plugin list
wheels plugin list --global
wheels plugin list --format=json
wheels plugin list --available    # Show all ForgeBox plugins

# Install plugins
wheels plugin install wheels-auth
wheels plugin install wheels-vue-cli --dev
wheels plugin install https://github.com/user/wheels-plugin
wheels plugin install wheels-api@2.0.0 --global

# Update plugins
wheels plugin update wheels-auth
wheels plugin update wheels-api --version=2.1.0 --force
wheels plugin update:all
wheels plugin update:all --dry-run

# Check for outdated plugins
wheels plugin outdated
wheels plugin outdated --format=json

# Remove plugins
wheels plugin remove wheels-auth
wheels plugin remove wheels-docker --global --force

# Create new plugin
wheels plugin init my-awesome-plugin
wheels plugin init wheels-payment-gateway --author="John Doe" --license=MIT
```

### Plugin Search

Search ForgeBox for available Wheels plugins:

```bash
# Search all plugins
wheels plugin search

# Search with query
wheels plugin search authentication
wheels plugin search "api builder"

# Sort results
wheels plugin search --orderBy=downloads    # Most popular first (default)
wheels plugin search --orderBy=updated      # Recently updated first
wheels plugin search --orderBy=name         # Alphabetical

# JSON output for scripting
wheels plugin search auth --format=json
```

### Plugin Information

Get detailed information about a plugin:

```bash
# Show plugin details
wheels plugin info wheels-auth

# Information includes:
# - Installation status
# - Latest version
# - Description and author
# - Download statistics
# - Dependencies
# - Available versions
# - Repository and homepage URLs
```

### Plugin Installation

Install plugins from ForgeBox or GitHub:

```bash
# Install from ForgeBox
wheels plugin install wheels-auth
wheels plugin install wheels-api-builder

# Install specific version
wheels plugin install wheels-auth@2.0.0

# Install as development dependency
wheels plugin install wheels-test-helpers --dev

# Install globally (available to all projects)
wheels plugin install wheels-docker --global

# Install from GitHub
wheels plugin install https://github.com/username/wheels-custom-plugin
```

### Plugin Updates

Keep plugins up to date:

```bash
# Update single plugin
wheels plugin update wheels-auth
wheels plugin update wheels-api --version=2.1.0

# Force update (reinstall even if up to date)
wheels plugin update wheels-auth --force

# Update all plugins
wheels plugin update:all

# Preview updates without installing
wheels plugin update:all --dry-run

# Force update all
wheels plugin update:all --force
```

### Outdated Plugins

Check which plugins have available updates:

```bash
# List outdated plugins
wheels plugin outdated

# JSON format for automation
wheels plugin outdated --format=json

# Output includes:
# - Current version
# - Latest available version
# - Last update date
# - Plugin type (dev/prod)
```

### Plugin Development

Create new Wheels plugins:

```bash
# Basic plugin initialization
wheels plugin init my-plugin

# With metadata
wheels plugin init payment-gateway \
  --author="Jane Smith" \
  --description="Payment processing for Wheels" \
  --version="0.1.0" \
  --license=MIT

# Generated structure:
# my-plugin/
# ├── box.json          # Package configuration
# ├── ModuleConfig.cfc  # Module configuration
# ├── README.md         # Documentation
# ├── commands/         # CLI commands
# ├── models/           # Service components
# ├── templates/        # File templates
# └── tests/            # Test suite
```

### Plugin Publishing

Publish plugins to ForgeBox:

```bash
# Login to ForgeBox
box login

# From plugin directory
cd my-plugin

# Publish to ForgeBox
box package publish

# Update version and publish
box bump --major
box package publish
```

### Plugin Best Practices

1. **Naming Convention**: Prefix with `wheels-` (e.g., `wheels-auth`)
2. **Type Declaration**: Set type as `commandbox-modules,cfwheels-plugins`
3. **Documentation**: Include comprehensive README.md
4. **Testing**: Include test suite in `/tests/`
5. **Versioning**: Follow semantic versioning (major.minor.patch)

## Maintenance Commands

### Maintenance Mode

Control application availability during deployments or maintenance:

#### Enable Maintenance Mode
```bash
# Basic maintenance mode
wheels maintenance:on

# With custom message
wheels maintenance:on message="We'll be back shortly after upgrading our systems."

# Allow specific IPs to bypass
wheels maintenance:on allowedIPs="192.168.1.100,10.0.0.5"

# With redirect URL
wheels maintenance:on redirectURL="/maintenance.html"

# Skip confirmation
wheels maintenance:on --force

# Combined options
wheels maintenance:on \
  message="Scheduled maintenance in progress" \
  allowedIPs="192.168.1.100" \
  --force
```

Features:
- Creates `.maintenance` file in config directory
- Automatically updates Application.cfc with maintenance check
- Supports IP whitelisting for admin access
- Custom messages and redirect URLs
- Tracks who enabled maintenance and when

#### Disable Maintenance Mode
```bash
# Basic disable
wheels maintenance:off

# Skip confirmation
wheels maintenance:off --force

# Remove maintenance check from Application.cfc
wheels maintenance:off --cleanup
```

Shows:
- Current maintenance configuration
- Duration of maintenance window
- Who enabled maintenance mode

### Cleanup Commands

Remove old files to free disk space and improve performance:

#### Clean Log Files
```bash
# Remove logs older than 7 days (default)
wheels cleanup:logs

# Keep last 30 days of logs
wheels cleanup:logs days=30

# Clean specific directory
wheels cleanup:logs directory="logs/custom"

# Use custom pattern
wheels cleanup:logs pattern="*.log,*.txt"

# Preview without deleting
wheels cleanup:logs --dryRun

# Skip confirmation
wheels cleanup:logs --force

# Clean all logs immediately
wheels cleanup:logs days=0 --force
```

Features:
- Scans recursively for log files
- Shows file age and size statistics
- Removes empty directories after cleanup
- Detailed reporting of freed space

#### Clean Temporary Files
```bash
# Remove temp files older than 1 day (default)
wheels cleanup:tmp

# Keep last 3 days
wheels cleanup:tmp days=3

# Clean specific directories
wheels cleanup:tmp directories="tmp,temp,cache,uploads/temp"

# Custom file patterns
wheels cleanup:tmp patterns="*.tmp,*.cache,~*"

# Exclude patterns
wheels cleanup:tmp excludePatterns=".gitkeep,important.tmp"

# Preview cleanup
wheels cleanup:tmp --dryRun

# Force cleanup
wheels cleanup:tmp --force
```

Features:
- Cleans multiple temp directories
- Flexible pattern matching
- Preserves important files (.gitkeep, .gitignore)
- Groups files by directory in output

#### Clean Session Files
```bash
# Clean file-based sessions
wheels cleanup:sessions

# Clean database sessions
wheels cleanup:sessions storage=database datasource=mydb

# Custom session directory
wheels cleanup:sessions directory="sessions/custom"

# Database with custom table
wheels cleanup:sessions \
  storage=database \
  datasource=mydb \
  table=user_sessions

# Delete all sessions (not just expired)
wheels cleanup:sessions expiredOnly=false --force

# Preview session cleanup
wheels cleanup:sessions --dryRun
```

Features:
- Supports both file and database session storage
- Auto-detects common session directories
- Shows active vs expired session counts
- Configurable expiration detection

### Cleanup Best Practices

1. **Schedule Regular Cleanups**
   ```bash
   # Add to cron/scheduled task
   0 2 * * * cd /path/to/app && wheels cleanup:logs days=7 --force
   0 3 * * * cd /path/to/app && wheels cleanup:tmp days=1 --force
   0 4 * * * cd /path/to/app && wheels cleanup:sessions --force
   ```

2. **Test with Dry Run First**
   ```bash
   wheels cleanup:logs --dryRun
   wheels cleanup:tmp --dryRun
   wheels cleanup:sessions --dryRun
   ```

3. **Monitor Disk Usage**
   ```bash
   # Check before cleanup
   df -h

   # Run cleanup
   wheels cleanup:logs days=30 --force
   wheels cleanup:tmp --force

   # Check after cleanup
   df -h
   ```

4. **Maintenance Mode Workflow**
   ```bash
   # Enable maintenance
   wheels maintenance:on message="Upgrading to v2.0"

   # Perform deployment/updates
   git pull
   wheels dbmigrate latest

   # Clear caches
   wheels cache:clear

   # Disable maintenance
   wheels maintenance:off
   ```

## Analysis and Optimization Commands

### Application Analysis

```bash
# Analyze all aspects (performance, code quality, security)
wheels analyze

# Analyze specific aspect
wheels analyze performance
wheels analyze code
wheels analyze security

# With options
wheels analyze --type=all --report --format=html
wheels analyze --path=app/models --format=json
wheels analyze performance --report --format=console
```

The analyze command provides comprehensive analysis of your application:
- **Performance**: Identifies slow queries, N+1 problems, caching opportunities
- **Code Quality**: Detects code smells, complexity issues, best practice violations
- **Security**: Scans for common vulnerabilities like SQL injection, XSS

### Performance Optimization

```bash
# Show optimization help and available commands
wheels optimize

# Run performance optimization analysis
wheels optimize performance
wheels optimize performance --analysis
wheels optimize performance --cache --apply
```

**Note**: This feature is currently under development. It will provide:
- Cache configuration optimization
- Asset optimization (minification, bundling)
- Database query optimization
- Index recommendations

### Security Scanning

```bash
# Show security help and available commands
wheels security

# Run security scan
wheels security scan
wheels security scan --fix
wheels security scan --path=models --severity=high
wheels security scan --report=html --output=security-report.html
```

**Note**: This feature is currently under development. It will detect:
- SQL Injection vulnerabilities
- Cross-Site Scripting (XSS)
- Hardcoded credentials
- File upload vulnerabilities
- Directory traversal issues

### File Watching

```bash
# Basic file watching with auto-reload
wheels watch

# Watch with specific options
wheels watch --reload --tests
wheels watch --includeDirs=controllers,models --excludeFiles=*.txt,*.log
wheels watch --interval=2 --command="wheels test run"

# Watch and run tests on changes
wheels watch --tests

# Watch and run migrations on schema changes
wheels watch --migrations

# Custom command on file changes
wheels watch --command="box run-script build"
```

Options:
- `--includeDirs`: Directories to watch (default: controllers,models,views,config,migrator/migrations)
- `--excludeFiles`: File patterns to ignore
- `--interval`: Check interval in seconds (default: 1)
- `--reload`: Reload framework on changes (default: true)
- `--tests`: Run tests on changes
- `--migrations`: Run migrations on schema changes
- `--command`: Custom command to run on changes
- `--debounce`: Debounce delay in milliseconds (default: 500)

## Application Utilities

### Route Management

#### Display Routes
```bash
# Show all routes
wheels routes

# Filter routes by name or pattern
wheels routes name=users
wheels routes name=admin

# Output in JSON format
wheels routes format=json
wheels routes name=users format=json
```

#### Match Route
```bash
# Find which route matches a URL
wheels routes:match /users
wheels routes:match /users/123
wheels routes:match /users/123/edit

# Match with specific HTTP method
wheels routes:match /products method=POST
wheels routes:match /api/users method=DELETE
```

The routes:match command shows:
- Matching route name and pattern
- Controller and action that will handle the request
- Extracted parameters (e.g., key, id)
- Other possible matches

### Application Information

#### About Command
```bash
# Display comprehensive application information
wheels about
```

Shows:
- Wheels framework version
- CLI version and location
- Application name and environment
- Database configuration status
- Server environment (CFML engine, Java, OS)
- CommandBox version
- Application statistics (controllers, models, views, tests, migrations)
- Helpful resource links

#### Version Command
```bash
# Show version information
wheels version
```

Displays:
- Wheels CLI version
- Wheels framework version
- CFML engine and version
- CommandBox version

### Code Analysis

#### Code Statistics
```bash
# Display code statistics
wheels stats

# Show detailed statistics with largest files
wheels stats verbose=true
```

Shows statistics for:
- Controllers, Models, Views
- Helpers, Tests, Migrations
- Configuration files
- JavaScript and CSS files
- Lines of code (LOC), comments, blank lines
- Code-to-test ratio
- Average file sizes
- Comment percentage

#### Extract Annotations
```bash
# Extract TODO, FIXME, OPTIMIZE annotations
wheels notes

# Search for specific annotations
wheels notes TODO
wheels notes TODO,FIXME

# Add custom annotations
wheels notes custom=HACK,REVIEW

# Show with file paths and line numbers
wheels notes verbose=true
```

Searches for annotations in:
- Application code (controllers, models, views)
- Configuration files
- Tests
- Migrations

### Health Checks

#### Doctor Command
```bash
# Run health checks
wheels doctor

# Show detailed diagnostic information
wheels doctor verbose=true
```

Checks for:
- Required directories and files
- Application configuration
- Database configuration and migrations
- Write permissions
- Dependencies and modules
- Test suite presence
- Security files (.gitignore)

Provides:
- Critical issues that need immediate attention
- Warnings for recommended improvements
- Passed checks (shown with verbose flag)
- Specific recommendations for fixing issues

### Dependency Management

#### Show Dependency Tree
```bash
# Display dependency tree
wheels deptree

# Limit depth of tree
wheels deptree depth=2

# Show only production dependencies
wheels deptree production=true

# Display as flat list instead of tree
wheels deptree format=list
```

Shows:
- Hierarchical dependency tree
- Installation status for each package
- Sub-dependencies (up to specified depth)
- Production vs development dependencies
- Missing packages highlighted in red

#### Manage Wheels Dependencies
```bash
# List dependencies
wheels deps list

# Install a dependency
wheels deps install PluginName
wheels deps install PluginName version=1.2.0
wheels deps install TestPlugin --dev

# Update a dependency
wheels deps update PluginName

# Remove a dependency
wheels deps remove PluginName

# Generate dependency report
wheels deps report
```

The deps command manages Wheels-specific dependencies and provides detailed reporting including:
- Current dependencies and versions
- Installation status
- Outdated packages
- Full dependency report with export to JSON

## Asset and Cache Management Commands

### Asset Management

#### Precompile Assets
```bash
# Precompile all assets for production
wheels assets:precompile

# Precompile with specific environment
wheels assets:precompile environment=production

# Force precompilation (ignore cache)
wheels assets:precompile --force

# Show verbose output
wheels assets:precompile --verbose
```

The precompile command:
- Minifies JavaScript and CSS files
- Combines files based on configuration
- Generates asset fingerprints for cache busting
- Creates compressed versions (gzip)
- Updates asset manifest

#### Clean Assets
```bash
# Remove old compiled assets (keeps latest 3 versions)
wheels assets:clean

# Keep specific number of versions
wheels assets:clean keep=5

# Preview what will be removed
wheels assets:clean --dryRun

# Force cleanup without confirmation
wheels assets:clean --force
```

#### Remove All Assets
```bash
# Remove all compiled assets
wheels assets:clobber

# Force removal without confirmation
wheels assets:clobber --force
```

### Cache Management

#### Clear Cache
```bash
# Clear all caches
wheels cache:clear

# Clear specific cache type
wheels cache:clear type=template
wheels cache:clear type=query
wheels cache:clear type=object
wheels cache:clear type=page

# Clear cache by name pattern
wheels cache:clear name=user*
wheels cache:clear name=*_cache

# Force clear without confirmation
wheels cache:clear --force

# Show what would be cleared
wheels cache:clear --dryRun
```

Cache types:
- `template`: Compiled view templates
- `query`: Database query results
- `object`: Object caching
- `page`: Full page caching
- `all`: All cache types (default)

### Log Management

#### Tail Logs
```bash
# Tail application logs (follows by default)
wheels log:tail

# Show specific number of lines
wheels log:tail lines=50

# Tail specific log file
wheels log:tail file=error.log
wheels log:tail file=access.log

# Filter log entries
wheels log:tail filter=ERROR
wheels log:tail filter="user authentication"

# Don't follow (just show last lines)
wheels log:tail --noFollow
```

#### Clear Logs
```bash
# Clear all log files
wheels log:clear

# Clear logs older than 7 days
wheels log:clear days=7

# Clear specific log files
wheels log:clear files=error.log,debug.log

# Preview what will be cleared
wheels log:clear --dryRun

# Force clear without confirmation
wheels log:clear --force
```

### Temporary Files

#### Clear Temporary Files
```bash
# Clear all temporary files
wheels tmp:clear

# Clear files older than 1 day
wheels tmp:clear days=1

# Clear specific directories
wheels tmp:clear dirs=uploads/temp,cache/temp

# Preview cleanup
wheels tmp:clear --dryRun

# Force cleanup
wheels tmp:clear --force
```

## Docker Commands

### Docker Integration

#### Initialize Docker Configuration
```bash
# Create Docker configuration files
wheels docker:init

# Initialize with specific CFML engine
wheels docker:init engine=lucee
wheels docker:init engine=adobe2023

# Include development tools
wheels docker:init --withDevTools

# Custom port mapping
wheels docker:init port=8080
```

Creates:
- `Dockerfile` - Application container configuration
- `docker-compose.yml` - Multi-container orchestration
- `.dockerignore` - Files to exclude from build

#### Deploy with Docker
```bash
# Build and deploy containers
wheels docker:deploy

# Deploy to specific environment
wheels docker:deploy environment=production

# Use specific tag
wheels docker:deploy tag=v1.0.0

# Deploy with docker-compose
wheels docker:deploy --compose

# Push to registry
wheels docker:deploy registry=myregistry.com push=true
```

## Deployment Commands

### Deploy Application

#### Basic Deployment
```bash
# Deploy to default target
wheels deploy

# Deploy to specific target
wheels deploy target=production
wheels deploy target=staging

# Deploy specific branch/tag
wheels deploy branch=main
wheels deploy tag=v1.0.0

# Dry run (show what would happen)
wheels deploy --dryRun
```

#### Initialize Deployment
```bash
# Set up deployment configuration
wheels deploy:init

# Initialize for specific provider
wheels deploy:init provider=aws
wheels deploy:init provider=heroku
wheels deploy:init provider=digitalocean

# With custom configuration
wheels deploy:init target=production host=myserver.com
```

#### Deployment Setup
```bash
# Set up deployment target
wheels deploy:setup

# Setup specific target
wheels deploy:setup target=production

# Verify setup
wheels deploy:setup --verify
```

#### Push Deployment
```bash
# Push current code to deployment target
wheels deploy:push

# Push to specific target
wheels deploy:push target=staging

# Force push (overwrites remote)
wheels deploy:push --force

# Include migrations
wheels deploy:push --migrate
```

#### Rollback Deployment
```bash
# Rollback to previous version
wheels deploy:rollback

# Rollback specific number of versions
wheels deploy:rollback steps=2

# Rollback to specific version
wheels deploy:rollback version=v1.2.3

# Preview rollback
wheels deploy:rollback --dryRun
```

#### Deployment Status
```bash
# Check deployment status
wheels deploy:status

# Status for specific target
wheels deploy:status target=production

# Detailed status
wheels deploy:status --verbose

# JSON output
wheels deploy:status format=json
```

#### Deployment Logs
```bash
# View deployment logs
wheels deploy:logs

# Tail logs
wheels deploy:logs --follow

# Specific number of lines
wheels deploy:logs lines=100

# Filter by date
wheels deploy:logs since="2 hours ago"
```

#### Deployment Audit
```bash
# Show deployment history
wheels deploy:audit

# Audit specific target
wheels deploy:audit target=production

# Show last N deployments
wheels deploy:audit limit=10

# Export audit log
wheels deploy:audit format=csv output=audit.csv
```

#### Execute Remote Commands
```bash
# Execute command on deployment target
wheels deploy:exec "wheels dbmigrate latest"

# Execute on specific target
wheels deploy:exec target=staging command="wheels cache:clear"

# Interactive mode
wheels deploy:exec --interactive
```

#### Deployment Hooks
```bash
# List deployment hooks
wheels deploy:hooks

# Add deployment hook
wheels deploy:hooks add name=post-deploy command="wheels cache:clear"

# Remove hook
wheels deploy:hooks remove name=post-deploy

# Test hooks
wheels deploy:hooks test
```

#### Deployment Lock
```bash
# Lock deployments (prevent concurrent deploys)
wheels deploy:lock

# Lock with reason
wheels deploy:lock reason="Database maintenance"

# Unlock deployments
wheels deploy:lock --unlock

# Check lock status
wheels deploy:lock --status
```

#### Deployment Proxy
```bash
# Manage deployment proxy/load balancer
wheels deploy:proxy

# Add server to pool
wheels deploy:proxy add server=192.168.1.10

# Remove server from pool
wheels deploy:proxy remove server=192.168.1.10

# Show proxy status
wheels deploy:proxy status
```

#### Deployment Secrets
```bash
# Manage deployment secrets/environment variables
wheels deploy:secrets

# Set secret
wheels deploy:secrets set API_KEY=abc123

# Remove secret
wheels deploy:secrets remove API_KEY

# List secrets (values hidden)
wheels deploy:secrets list

# Export secrets
wheels deploy:secrets export --output=secrets.env
```

#### Stop Deployment
```bash
# Stop running deployment
wheels deploy:stop

# Stop specific deployment
wheels deploy:stop id=abc123

# Force stop
wheels deploy:stop --force
```

## Security Commands

### Security Scanning

#### Security Overview
```bash
# Show security overview and available commands
wheels security

# Run quick security check
wheels security --check
```

#### Run Security Scan
```bash
# Scan entire application
wheels security:scan

# Scan specific paths
wheels security:scan path=models,controllers

# Scan with specific severity threshold
wheels security:scan severity=high

# Auto-fix issues where possible
wheels security:scan --fix

# Generate report
wheels security:scan report=html output=security-report.html
wheels security:scan report=json output=security.json

# Scan specific vulnerability types
wheels security:scan types=sql,xss,csrf
```

Security scan checks for:
- SQL Injection vulnerabilities
- Cross-Site Scripting (XSS)
- Cross-Site Request Forgery (CSRF)
- Insecure Direct Object References
- Security Misconfiguration
- Sensitive Data Exposure
- XML External Entity (XXE)
- Broken Access Control
- File Upload vulnerabilities
- Hardcoded credentials
- Insecure Cryptography
- Directory Traversal

## Documentation Commands

### Documentation Management

#### Documentation Overview
```bash
# Show documentation commands
wheels docs
```

#### Generate Documentation
```bash
# Generate API documentation
wheels docs:generate

# Generate with specific format
wheels docs:generate format=html
wheels docs:generate format=markdown
wheels docs:generate format=json

# Include source code
wheels docs:generate --includeSource

# Custom output directory
wheels docs:generate output=docs/api

# Generate for specific components
wheels docs:generate components=models,controllers
```

#### Serve Documentation
```bash
# Start documentation server
wheels docs:serve

# Serve on specific port
wheels docs:serve port=4000

# Open in browser automatically
wheels docs:serve --open

# Watch for changes and regenerate
wheels docs:serve --watch
```

Documentation features:
- Auto-generates from code comments
- Supports JavaDoc-style annotations
- Includes method signatures and parameters
- Shows relationships between components
- Generates navigation and search

## Continuous Integration Commands

### CI/CD Integration

#### Initialize CI Configuration
```bash
# Create CI configuration files
wheels ci:init

# Initialize for specific provider
wheels ci:init provider=github     # Creates .github/workflows/ci.yml
wheels ci:init provider=gitlab     # Creates .gitlab-ci.yml
wheels ci:init provider=jenkins    # Creates Jenkinsfile
wheels ci:init provider=circle     # Creates .circleci/config.yml
wheels ci:init provider=travis     # Creates .travis.yml

# Include additional workflows
wheels ci:init --withDeployment
wheels ci:init --withCoverage
wheels ci:init --withDocker
```

CI configuration includes:
- Dependency installation
- Database setup
- Migration running
- Test execution
- Code quality checks
- Build artifacts
- Deployment steps (optional)

## Interactive Console and Runner

### Interactive Console (REPL)
```bash
# Start interactive console with application context
wheels console

# Start in specific environment
wheels console environment=testing

# Preload specific components
wheels console preload=models,services

# With command history
wheels console --history

# Execute command and exit
wheels console --execute="user = model('User').findByKey(1); writeDump(user);"
```

Console features:
- Full application context loaded
- Access to all models, services, and helpers
- Command history and tab completion
- Multi-line command support
- Result pretty-printing

### Script Runner
```bash
# Run arbitrary CFML script in application context
wheels runner myScript.cfm

# Run with arguments
wheels runner dataImport.cfm inputFile=data.csv

# Run code directly
wheels runner --code="users = model('User').findAll(); writeDump(users.recordCount);"

# Run in specific environment
wheels runner script.cfm environment=production
```

## Destroy Commands

### Remove Generated Code

The destroy commands are the inverse of generate commands, removing files that were created:

#### Destroy Model
```bash
# Remove model and associated files
wheels destroy model User

# Force removal without confirmation
wheels destroy model User --force

# Also remove migration
wheels destroy model User --removeMigration
```

Removes:
- Model file
- Model test file
- Optionally: associated migration

#### Destroy Controller
```bash
# Remove controller and views
wheels destroy controller Users

# Force removal
wheels destroy controller Users --force

# Keep views
wheels destroy controller Users --keepViews
```

Removes:
- Controller file
- Controller test file
- View directory and all views (unless --keepViews)

#### Destroy Scaffold
```bash
# Remove entire scaffold
wheels destroy scaffold Product

# Force removal
wheels destroy scaffold Product --force
```

Removes:
- Model and model test
- Controller and controller test
- All views
- Does NOT remove migrations (safety measure)

#### Destroy View
```bash
# Remove specific view
wheels destroy view users show

# Remove multiple views
wheels destroy view users index,show,edit

# Force removal
wheels destroy view users index --force
```

#### Destroy Migration
```bash
# Remove migration file
wheels destroy migration CreateUsersTable

# Force removal
wheels destroy migration CreateUsersTable --force
```

**Warning**: Only removes the migration file, does not rollback database changes

#### Destroy Test
```bash
# Remove test file
wheels destroy test model User
wheels destroy test controller Users

# Force removal
wheels destroy test model User --force
```

#### Destroy Mailer
```bash
# Remove mailer
wheels destroy mailer UserNotifications

# Force removal
wheels destroy mailer UserNotifications --force
```

Removes:
- Mailer file
- Mailer test file
- View templates

#### Destroy Service
```bash
# Remove service
wheels destroy service PaymentProcessor

# Force removal
wheels destroy service PaymentProcessor --force
```

#### Destroy Helper
```bash
# Remove helper
wheels destroy helper StringUtils

# Force removal
wheels destroy helper StringUtils --force
```

#### Destroy Job
```bash
# Remove job
wheels destroy job ProcessOrders

# Force removal
wheels destroy job ProcessOrders --force
```

#### Destroy Plugin
```bash
# Remove plugin
wheels destroy plugin Authentication

# Force removal
wheels destroy plugin Authentication --force

# Also remove from dependencies
wheels destroy plugin Authentication --removeDependency
```

### Destroy Best Practices

1. **Always Review First**: Use `git status` before destroying
2. **Backup Important Code**: Destroy commands are irreversible
3. **Check Dependencies**: Ensure other code doesn't depend on what you're removing
4. **Use Force Sparingly**: Confirmations exist for safety
5. **Migrations**: Manually rollback database changes before destroying migrations

## Additional Generators

### Generate Frontend Components
```bash
# Generate frontend scaffold with JavaScript framework
wheels g frontend component=UserList framework=vue

# Supported frameworks
wheels g frontend component=ProductGrid framework=react
wheels g frontend component=Dashboard framework=alpine
wheels g frontend component=DataTable framework=htmx

# With TypeScript
wheels g frontend component=UserForm framework=vue --typescript

# Include tests
wheels g frontend component=CartWidget framework=react --withTests

# Custom output directory
wheels g frontend component=NavBar framework=alpine output=assets/components
```

### Generate Property
```bash
# Add property to existing model
wheels g property model=User name=email type=string

# With validation
wheels g property model=User name=age type=integer required=true

# With default value
wheels g property model=Product name=inStock type=boolean default=true

# Multiple properties
wheels g property model=User properties=phone:string,address:text
```

### Generate Route
```bash
# Add route to config/routes.cfm
wheels g route name=userProfile pattern="/users/[key]/profile" controller=users action=profile

# RESTful resource route
wheels g route resource=products

# Nested resource
wheels g route resource=users nestedResource=posts

# API namespace
wheels g route namespace=api resource=users
```

## Reload Command
```bash
# Reload application
wheels reload

# Reload with specific environment
wheels reload environment=development
wheels reload environment=production

# Force reload
wheels reload --force

# Reload and clear cache
wheels reload --clearCache
```

## Common Command Sequences

### New Project Setup

```bash
# 1. Create project directory
mkdir myproject && cd myproject

# 2. Initialize Wheels
wheels g app myproject

# 3. Install dependencies
box install

# 4. Setup database (H2 is setup by default)
# For other databases, configure datasource in Admin or .cfconfig.json

# 5. Run migrations
wheels dbmigrate latest

# 6. Start server
server start
```

### Adding New Feature

```bash
# 1. Generate model with migration
wheels g model Article title:string,content:text,authorId:integer

# 2. Run migration
wheels dbmigrate latest

# 3. Generate controller with views
wheels g controller Articles index,show,new,create,edit,update,delete

# 4. Generate tests
wheels g test model Article
wheels g test controller Articles

# 5. Run tests
wheels test app
```

### Testing Workflow

```bash
# 1. Start test watcher
box testbox watch

# 2. Make changes (in another terminal)
# Edit files...

# 3. Run specific test after changes
wheels test app ArticleTest

# 4. Run all tests before commit
box testbox run

# 5. Check code formatting
box run-script format:check
```

### Docker Testing

```bash
# 1. Start all test databases
docker compose up -d

# 2. Run tests against specific engine
docker compose --profile lucee up -d
wheels test app

# 3. Switch to Adobe CF
docker compose --profile adobe2023 up -d
wheels test app

# 4. Access TestUI
open http://localhost:3000
```

## Parameter Syntax Requirements

### CommandBox Parameter Rules

CommandBox has strict parameter requirements that must be followed:

1. **DO NOT mix positional and named parameters**
   ```bash
   # ❌ WRONG - This will error
   wheels g app myapp template=base --force

   # ✅ CORRECT - Use all named parameters
   wheels g app name=myapp template=base force=true

   # ✅ CORRECT - Or all positional (if command supports it)
   wheels g app myapp
   ```

2. **Named parameters use equals sign**
   ```bash
   # ❌ WRONG
   wheels g model name User properties title:string

   # ✅ CORRECT
   wheels g model name=User properties="title:string"
   ```

3. **Boolean flags**
   ```bash
   # Two ways to specify boolean true:
   wheels g scaffold Product --force      # Flag style (means force=true)
   wheels g scaffold Product force=true   # Explicit style

   # For false, must use explicit style:
   wheels g model User migration=false
   ```

4. **Quote complex values**
   ```bash
   # ❌ WRONG - Space breaks parsing
   wheels g controller name=Users actions=index,show,new

   # ✅ CORRECT - Quote values with spaces or special characters
   wheels g controller name=Users actions="index,show,new,create"
   wheels g model name=Article properties="title:string,content:text,userId:integer"
   ```

### Common Parameter Patterns

1. **Generators typically support positional name**
   ```bash
   # These are equivalent:
   wheels g model User
   wheels g model name=User
   ```

2. **Database commands require named parameters**
   ```bash
   # ❌ WRONG
   wheels dbmigrate create CreateUsers

   # ✅ CORRECT
   wheels dbmigrate create name=CreateUsers
   ```

3. **Multiple values use comma separation**
   ```bash
   # Controller actions
   wheels g controller name=Posts actions="index,show,new,create,edit,update,delete"

   # Model properties
   wheels g model name=User properties="name:string,email:string,active:boolean"

   # View names
   wheels g view name=posts views="index,show,edit,new"
   ```

### Best Practices

1. **When in doubt, use all named parameters**
   ```bash
   wheels g app name=myapp template=base datasourceName=mydb setupH2=true
   ```

2. **Check command help for parameter names**
   ```bash
   wheels help g model
   wheels help dbmigrate create
   ```

3. **Use quotes for safety**
   ```bash
   wheels g migration name="AddIndexToUsersEmail"
   wheels g controller name="Admin/Users" actions="index,show"
   ```

## Troubleshooting

### Command Not Found

```bash
# If 'wheels' command not found
box install cfwheels-cli --force
box reload

# Verify installation
which wheels
wheels version
```

### Parameter Errors

```bash
# Error: Missing required parameter
wheels g model
# Fix: Add required name
wheels g model name=User

# Error: Invalid parameter format
wheels g model User properties=name,email
# Fix: Specify types
wheels g model User properties=name:string,email:string
```

### Database Connection Issues

```bash
# Error: Datasource not found
# Fix: Configure datasource
wheels set datasource myapp

# Error: Database doesn't exist
# Fix: Create database
wheels db create

# Error: Migrations table missing
# Fix: Initialize migrations
wheels db migrate version=0
```

### Testing Issues

```bash
# Error: Test not found
# Fix: Use correct path or name
wheels test app tests/specs/models/UserTest.cfc

# Error: TestBox not found
# Fix: Install TestBox
box install testbox --saveDev

# Error: BaseSpec not found
# Fix: Ensure test extends correct path
# component extends="tests.BaseSpec"
```

### CLI Module Issues

```bash
# After modifying CLI code
box reload

# If changes don't take effect
box restart

# Complete reinstall
box uninstall cfwheels-cli
box install cfwheels-cli
```

## Advanced Usage

### Custom Templates

```bash
# Use custom template for generation
wheels g app myapp template=https://github.com/myrepo/template.git

# Local template
wheels g app myapp template=../my-template/
```

### Environment Variables

```bash
# Set environment variables
wheels set environment=production
wheels set datasource=productionDB

# Use in commands
WHEELS_ENV=testing wheels test app
```

### Scripting

```bash
# Create setup script
#!/bin/bash
wheels g app myapp
cd myapp
box install
wheels db create
wheels db migrate
server start
```

### Aliases

```bash
# Add to ~/.bashrc or ~/.zshrc
alias wt='wheels test app'
alias wm='wheels db migrate'
alias wr='wheels reload'
alias wdev='wheels set environment development && wheels reload'
alias wprod='wheels set environment production && wheels reload'
```

## New in Wheels 3.0

### Enhanced Deployment System

```bash
# Initialize deployment configuration
wheels deploy init --provider=aws --region=us-east-1
wheels deploy init --provider=digitalocean --domain=myapp.com
wheels deploy init --provider=heroku --app=myapp

# Setup infrastructure
wheels deploy setup
wheels deploy setup --environment=staging
wheels deploy setup --skip-database

# Deploy application
wheels deploy push
wheels deploy push --branch=develop
wheels deploy push --tag=v2.0.0
wheels deploy push --force  # Force deployment even with uncommitted changes

# Zero-downtime deployment
wheels deploy blue-green
wheels deploy blue-green --swap  # Swap blue/green environments
wheels deploy blue-green --rollback  # Rollback to previous version

# Manage secrets
wheels deploy secrets list
wheels deploy secrets set API_KEY=xxx DATABASE_PASSWORD=yyy
wheels deploy secrets push  # Push local secrets to deployment
wheels deploy secrets pull  # Pull remote secrets to local

# Monitoring
wheels deploy status
wheels deploy logs --follow
wheels deploy logs --lines=100 --since="2h"
wheels deploy metrics  # View performance metrics
wheels deploy health  # Health check

# Rollback
wheels deploy rollback
wheels deploy rollback --steps=2
wheels deploy rollback --to-version=1.5.0
```

### Performance Optimization Commands

```bash
# Analyze performance
wheels optimize analyze
wheels optimize analyze --profile=database
wheels optimize analyze --profile=application
wheels optimize analyze --profile=assets

# Database optimization
wheels optimize database
wheels optimize database --analyze-queries
wheels optimize database --add-indexes
wheels optimize database --vacuum  # PostgreSQL
wheels optimize database --optimize-tables  # MySQL

# Application optimization
wheels optimize cache
wheels optimize cache --precompile
wheels optimize cache --warm  # Warm up caches
wheels optimize cache --analyze  # Cache hit/miss analysis

# Asset optimization
wheels optimize assets
wheels optimize assets --compress
wheels optimize assets --fingerprint
wheels optimize assets --cdn-upload

# Query optimization
wheels optimize queries
wheels optimize queries --slow-log
wheels optimize queries --explain
wheels optimize queries --suggest-indexes
```

### Enhanced Security Features

```bash
# Security audit with auto-fix
wheels security audit --fix
wheels security audit --critical-only
wheels security audit --compliance=pci  # PCI compliance check
wheels security audit --compliance=hipaa  # HIPAA compliance check

# Vulnerability scanning
wheels security vulnerabilities
wheels security vulnerabilities --cve  # Check CVE database
wheels security vulnerabilities --update-db  # Update vulnerability database

# Penetration testing
wheels security pentest
wheels security pentest --target=api
wheels security pentest --target=authentication
wheels security pentest --target=forms

# Security headers
wheels security headers check
wheels security headers fix
wheels security headers strict  # Apply strict security headers

# API security
wheels security api scan
wheels security api rate-limits
wheels security api tokens rotate
```

### Environment Management

```bash
# List all environments
wheels env list
wheels env list --verbose

# Switch environment
wheels env switch production
wheels env switch staging
wheels env switch development

# Create new environment
wheels env create qa
wheels env create qa --copy-from=staging
wheels env create qa --template=minimal

# Environment configuration
wheels env config show
wheels env config set DATABASE_URL=xxx
wheels env config get DATABASE_URL
wheels env config export > .env
wheels env config import < .env.production

# Environment comparison
wheels env diff production staging
wheels env diff --config-only
wheels env diff --database-only

# Sync environments
wheels env sync staging from=production
wheels env sync staging from=production --data
wheels env sync staging from=production --config-only
```

### Enhanced Database Features

```bash
# Database branching (for development)
wheels db branch create feature-xyz
wheels db branch switch feature-xyz
wheels db branch merge feature-xyz
wheels db branch delete feature-xyz

# Database snapshots
wheels db snapshot create before-deploy
wheels db snapshot list
wheels db snapshot restore before-deploy
wheels db snapshot delete old-snapshot

# Database analysis
wheels db analyze
wheels db analyze --tables=users,posts
wheels db analyze --suggest-indexes
wheels db analyze --unused-indexes

# Database maintenance
wheels db vacuum  # PostgreSQL
wheels db reindex
wheels db repair  # MySQL
wheels db optimize

# Advanced migrations
wheels db migrate --dry-run
wheels db migrate --force  # Skip safety checks
wheels db migrate --target=20250121000000
wheels db migrate --redo  # Rollback and re-run last migration
```

### Container and Cloud Support

```bash
# Docker commands
wheels docker build
wheels docker build --tag=myapp:latest
wheels docker build --platform=linux/amd64,linux/arm64

wheels docker run
wheels docker run --port=8080
wheels docker run --env-file=.env

wheels docker compose up
wheels docker compose down
wheels docker compose logs

# Kubernetes support
wheels k8s generate  # Generate K8s manifests
wheels k8s deploy
wheels k8s scale --replicas=3
wheels k8s rollout status
wheels k8s rollout undo

# Cloud-specific commands
wheels cloud aws deploy
wheels cloud aws lambda deploy
wheels cloud azure deploy
wheels cloud gcp deploy
```

### Advanced Testing Features

```bash
# Mutation testing
wheels test mutate
wheels test mutate --threshold=80

# Performance testing
wheels test performance
wheels test performance --concurrent=100
wheels test performance --duration=60s

# Security testing
wheels test security
wheels test security --owasp

# Contract testing
wheels test contracts
wheels test contracts --consumer=frontend
wheels test contracts --provider=api

# Visual regression testing
wheels test visual
wheels test visual --baseline
wheels test visual --compare

# Stress testing
wheels test stress
wheels test stress --users=1000
wheels test stress --ramp-up=60
```

### API Development Tools

```bash
# API documentation generation
wheels api docs generate
wheels api docs serve --port=3000
wheels api docs export --format=openapi
wheels api docs export --format=postman

# API mocking
wheels api mock start
wheels api mock start --port=3001
wheels api mock record  # Record real API responses
wheels api mock playback  # Playback recorded responses

# API versioning
wheels api version create v2
wheels api version list
wheels api version deprecate v1 --sunset="2025-12-31"

# GraphQL support
wheels graphql schema generate
wheels graphql schema validate
wheels graphql playground --port=4000
```

### Monitoring and Observability

```bash
# Application monitoring
wheels monitor start
wheels monitor status
wheels monitor metrics
wheels monitor traces
wheels monitor logs

# Performance profiling
wheels profile start
wheels profile stop
wheels profile report
wheels profile flamegraph

# Error tracking
wheels errors list
wheels errors show ERROR_ID
wheels errors resolve ERROR_ID
wheels errors ignore PATTERN

# Health checks
wheels health check
wheels health check --verbose
wheels health endpoints  # List health check endpoints
```

### Development Workflow Enhancements

```bash
# Code generation with AI assistance
wheels ai generate model --description="User with email and password"
wheels ai generate controller --description="RESTful API for posts"
wheels ai generate test --for=UserService
wheels ai suggest --context=current-file

# Hot reload with specific options
wheels dev watch
wheels dev watch --only=models
wheels dev watch --ignore=tests
wheels dev watch --delay=500  # Milliseconds

# Development proxy
wheels dev proxy --target=http://api.example.com
wheels dev proxy --port=3000 --ssl

# Mock data generation
wheels dev mock users --count=100
wheels dev mock posts --count=500 --with-comments
wheels dev mock orders --realistic  # Realistic data patterns
```

### CLI Plugins and Extensions

```bash
# Install CLI plugins
wheels plugin install wheels-graphql
wheels plugin install wheels-oauth
wheels plugin install wheels-queue

# List installed plugins
wheels plugin list
wheels plugin list --updates-available

# Update plugins
wheels plugin update
wheels plugin update wheels-graphql

# Create custom plugin
wheels plugin create my-plugin
wheels plugin publish my-plugin
```

## BoxLang Support (New in Wheels 3.0)

```bash
# BoxLang-specific commands
wheels boxlang compile
wheels boxlang compile --target=jar
wheels boxlang compile --optimize

wheels boxlang run
wheels boxlang run --jvm-args="-Xmx2g"

wheels boxlang test
wheels boxlang benchmark
```

## Configuration Management (Enhanced in 3.0)

```bash
# Configuration validation
wheels config validate
wheels config validate --strict

# Configuration migration (from 2.x to 3.0)
wheels config migrate
wheels config migrate --backup
wheels config migrate --from=/app/config --to=/config

# Configuration templates
wheels config template list
wheels config template apply production
wheels config template create custom --from=current
```

This comprehensive CLI reference should help AI assistants understand and use all available Wheels commands effectively, including the new features in Wheels 3.0.
