---
description: Wheels Framework Database Migration Patterns
version: 2.0
encoding: UTF-8
---

# Wheels Database Migration Patterns

Comprehensive migration patterns and best practices for Wheels framework database migrations, including complex scenarios and advanced techniques.

## Critical Information

**ALWAYS use the CLI to generate migrations. NEVER create migration files manually.**

- **Location**: `app/migrator/migrations/`
- **Naming**: Timestamp-based (e.g., `20231215103045_create_users.cfc`)
- **Generation**: Use `wheels g migration MigrationName`
- **Execution**: Migrations run in transactions by default

## Table of Contents
- [CLI Commands](#cli-commands-for-migrations)
- [Basic Migration Patterns](#basic-migration-patterns)
- [Complex Migration Scenarios](#complex-migration-scenarios)
- [Data Migration Patterns](#data-migration-patterns)
- [Index and Constraint Management](#index-and-constraint-management)
- [Multi-Database Support](#multi-database-support)
- [Performance Optimization](#performance-optimization)
- [Migration Best Practices](#migration-best-practices)
- [Rollback Strategies](#rollback-strategies)
- [Troubleshooting](#troubleshooting)

## CLI Commands for Migrations

### Generating Migrations

```bash
# Create a new table
wheels g migration CreateUsers
wheels g migration CreatePosts
wheels g migration CreateComments

# Add columns to existing table
wheels g migration AddEmailVerifiedToUsers
wheels g migration AddPublishedAtToPosts
wheels g migration AddSlugToCategories

# Remove columns from table
wheels g migration RemoveDeprecatedPasswordFromUsers
wheels g migration RemoveStatusFromPosts

# Add indexes
wheels g migration AddIndexToUsersEmail
wheels g migration AddCompoundIndexToPosts
wheels g migration AddFullTextIndexToArticles

# Modify columns
wheels g migration ChangeUserEmailLength
wheels g migration RenamePostsTitleToHeadline
wheels g migration ChangeOrderTotalPrecision

# Data migrations
wheels g migration NormalizeUserEmails
wheels g migration MigratePostCategories
wheels g migration BackfillUserSlugs

# Complex structural changes
wheels g migration SplitUserNameIntoFirstAndLast
wheels g migration ConsolidateAddressTables
wheels g migration CreateAuditTriggers
```

### Running Migrations

```bash
# Run all pending migrations
wheels dbmigrate latest

# Run migrations up to specific version
wheels dbmigrate latest version=20231215103045

# Rollback last migration
wheels dbmigrate down

# Rollback multiple migrations
wheels dbmigrate down steps=3

# Check migration status
wheels dbmigrate info

# Create a new database with all migrations
wheels db setup

# Reset database (drop, create, migrate, seed)
wheels db reset --force
```

## Basic Migration Patterns

### Create Table with All Column Types

```cfml
component extends="wheels.migrator.Migration" hint="Create comprehensive example table" {

	function up() {
		transaction {
			try {
				t = createTable(name='products', force=false, id=true, primaryKey='id');
				
				// String types
				t.string(columnNames='name', limit=255, null=false);
				t.string(columnNames='sku', limit=50, null=false);
				t.text(columnNames='description', null=true);
				
				// Numeric types
				t.integer(columnNames='quantity', default=0, null=false);
				t.bigInteger(columnNames='views', default=0, null=false);
				t.decimal(columnNames='price', precision=10, scale=2, null=false);
				t.float(columnNames='weight', null=true);
				
				// Boolean
				t.boolean(columnNames='active', default=true, null=false);
				t.boolean(columnNames='featured', default=false, null=false);
				
				// Date/Time
				t.date(columnNames='releaseDate', null=true);
				t.time(columnNames='dailyDealTime', null=true);
				t.datetime(columnNames='lastOrderedAt', null=true);
				t.timestamp(columnNames='lastViewedAt', null=true);
				
				// Binary
				t.binary(columnNames='thumbnail', null=true);
				
				// JSON (for databases that support it)
				t.json(columnNames='metadata', null=true);
				
				// UUID
				t.uuid(columnNames='externalId', null=true);
				
				// Enum (MySQL specific)
				if (getDatabaseType() == "MySQL") {
					t.enum(columnNames='status', values='draft,published,archived', default='draft');
				} else {
					t.string(columnNames='status', limit=20, default='draft');
				}
				
				// Automatic timestamps
				t.timestamps(); // Creates createdAt and updatedAt
				
				// Create the table
				t.create();
				
				// Add indexes after table creation
				addIndex(table='products', columnNames='sku', unique=true, name='idx_products_sku');
				addIndex(table='products', columnNames='active,featured', name='idx_products_visibility');
				addIndex(table='products', columnNames='price,quantity', name='idx_products_inventory');
				
				// Add full-text index for MySQL
				if (getDatabaseType() == "MySQL") {
					execute("ALTER TABLE products ADD FULLTEXT(name, description)");
				}
				
			} catch (any e) {
				local.exception = e;
			}

			if (StructKeyExists(local, "exception")) {
				transaction action="rollback";
				throw(errorCode="1", detail=local.exception.detail, message=local.exception.message, type="any");
			} else {
				transaction action="commit";
			}
		}
	}

	function down() {
		transaction {
			try {
				dropTable('products');
			} catch (any e) {
				local.exception = e;
			}

			if (StructKeyExists(local, "exception")) {
				transaction action="rollback";
				throw(errorCode="1", detail=local.exception.detail, message=local.exception.message, type="any");
			} else {
				transaction action="commit";
			}
		}
	}
}
```

### Add Columns with Constraints

```cfml
component extends="wheels.migrator.Migration" hint="Add columns with various constraints" {

	function up() {
		transaction {
			try {
				// Add single column
				addColumn(
					table='users',
					columnName='phoneNumber',
					columnType='string',
					limit=20,
					null=true
				);
				
				// Add column with default value
				addColumn(
					table='users',
					columnName='credits',
					columnType='integer',
					default=100,
					null=false
				);
				
				// Add column with check constraint
				addColumn(
					table='users',
					columnName='age',
					columnType='integer',
					null=true
				);
				
				// Add check constraint (database-specific)
				if (getDatabaseType() == "PostgreSQL") {
					execute("ALTER TABLE users ADD CONSTRAINT check_age CHECK (age >= 0 AND age <= 150)");
				}
				
				// Add computed column (SQL Server specific)
				if (getDatabaseType() == "SQLServer") {
					execute("ALTER TABLE users ADD fullName AS (firstName + ' ' + lastName)");
				}
				
			} catch (any e) {
				local.exception = e;
			}

			if (StructKeyExists(local, "exception")) {
				transaction action="rollback";
				throw(errorCode="1", detail=local.exception.detail, message=local.exception.message, type="any");
			} else {
				transaction action="commit";
			}
		}
	}

	function down() {
		transaction {
			try {
				// Remove constraints first
				if (getDatabaseType() == "PostgreSQL") {
					execute("ALTER TABLE users DROP CONSTRAINT IF EXISTS check_age");
				}
				
				// Remove columns
				removeColumn(table='users', columnName='phoneNumber');
				removeColumn(table='users', columnName='credits');
				removeColumn(table='users', columnName='age');
				
				if (getDatabaseType() == "SQLServer") {
					removeColumn(table='users', columnName='fullName');
				}
				
			} catch (any e) {
				local.exception = e;
			}

			if (StructKeyExists(local, "exception")) {
				transaction action="rollback";
				throw(errorCode="1", detail=local.exception.detail, message=local.exception.message, type="any");
			} else {
				transaction action="commit";
			}
		}
	}
}
```

## Complex Migration Scenarios

### Split Single Column into Multiple

```cfml
component extends="wheels.migrator.Migration" hint="Split fullName into firstName and lastName" {

	function up() {
		transaction {
			try {
				// Add new columns
				addColumn(table='users', columnName='firstName', columnType='string', limit=50, null=true);
				addColumn(table='users', columnName='lastName', columnType='string', limit=50, null=true);
				
				// Migrate existing data
				local.users = queryExecute("SELECT id, fullName FROM users WHERE fullName IS NOT NULL");
				
				for (local.user in local.users) {
					local.nameParts = ListToArray(local.user.fullName, " ");
					local.firstName = local.nameParts[1] ?: "";
					local.lastName = ArrayLen(local.nameParts) > 1 ? 
						ArrayToList(ArraySlice(local.nameParts, 2), " ") : "";
					
					updateRecords(
						table='users',
						where="id=#local.user.id#",
						firstName=local.firstName,
						lastName=local.lastName
					);
				}
				
				// Make columns required after data migration
				changeColumn(table='users', columnName='firstName', null=false);
				changeColumn(table='users', columnName='lastName', null=false);
				
				// Remove old column
				removeColumn(table='users', columnName='fullName');
				
			} catch (any e) {
				local.exception = e;
			}

			if (StructKeyExists(local, "exception")) {
				transaction action="rollback";
				throw(errorCode="1", detail=local.exception.detail, message=local.exception.message, type="any");
			} else {
				transaction action="commit";
			}
		}
	}

	function down() {
		transaction {
			try {
				// Recreate original column
				addColumn(table='users', columnName='fullName', columnType='string', limit=100, null=true);
				
				// Merge data back
				local.users = queryExecute("SELECT id, firstName, lastName FROM users");
				
				for (local.user in local.users) {
					local.fullName = Trim(local.user.firstName & " " & local.user.lastName);
					updateRecords(
						table='users',
						where="id=#local.user.id#",
						fullName=local.fullName
					);
				}
				
				// Make column required
				changeColumn(table='users', columnName='fullName', null=false);
				
				// Remove split columns
				removeColumn(table='users', columnName='firstName');
				removeColumn(table='users', columnName='lastName');
				
			} catch (any e) {
				local.exception = e;
			}

			if (StructKeyExists(local, "exception")) {
				transaction action="rollback";
				throw(errorCode="1", detail=local.exception.detail, message=local.exception.message, type="any");
			} else {
				transaction action="commit";
			}
		}
	}
}
```

### Consolidate Multiple Tables

```cfml
component extends="wheels.migrator.Migration" hint="Consolidate shipping and billing addresses into single table" {

	function up() {
		transaction {
			try {
				// Create new unified addresses table
				t = createTable(name='addresses', force=false, id=true, primaryKey='id');
				t.integer(columnNames='userId', null=false);
				t.string(columnNames='type', limit=20, null=false); // 'shipping' or 'billing'
				t.string(columnNames='street1', limit=255, null=false);
				t.string(columnNames='street2', limit=255, null=true);
				t.string(columnNames='city', limit=100, null=false);
				t.string(columnNames='state', limit=50, null=false);
				t.string(columnNames='postalCode', limit=20, null=false);
				t.string(columnNames='country', limit=2, null=false);
				t.boolean(columnNames='isDefault', default=false, null=false);
				t.timestamps();
				t.create();
				
				// Add indexes
				addIndex(table='addresses', columnNames='userId,type');
				addIndex(table='addresses', columnNames='userId,isDefault');
				
				// Migrate shipping addresses
				local.shippingAddresses = queryExecute("SELECT * FROM shipping_addresses");
				for (local.addr in local.shippingAddresses) {
					execute("
						INSERT INTO addresses (userId, type, street1, street2, city, state, postalCode, country, isDefault, createdAt, updatedAt)
						VALUES (
							#local.addr.userId#,
							'shipping',
							'#local.addr.street1#',
							#local.addr.street2 != "" ? "'#local.addr.street2#'" : "NULL"#,
							'#local.addr.city#',
							'#local.addr.state#',
							'#local.addr.postalCode#',
							'#local.addr.country#',
							#local.addr.isDefault#,
							'#local.addr.createdAt#',
							'#local.addr.updatedAt#'
						)
					");
				}
				
				// Migrate billing addresses
				local.billingAddresses = queryExecute("SELECT * FROM billing_addresses");
				for (local.addr in local.billingAddresses) {
					execute("
						INSERT INTO addresses (userId, type, street1, street2, city, state, postalCode, country, isDefault, createdAt, updatedAt)
						VALUES (
							#local.addr.userId#,
							'billing',
							'#local.addr.address1#',
							#local.addr.address2 != "" ? "'#local.addr.address2#'" : "NULL"#,
							'#local.addr.city#',
							'#local.addr.state#',
							'#local.addr.zip#',
							'#local.addr.countryCode#',
							#local.addr.isPrimary#,
							'#local.addr.createdAt#',
							'#local.addr.updatedAt#'
						)
					");
				}
				
				// Drop old tables
				dropTable('shipping_addresses');
				dropTable('billing_addresses');
				
			} catch (any e) {
				local.exception = e;
			}

			if (StructKeyExists(local, "exception")) {
				transaction action="rollback";
				throw(errorCode="1", detail=local.exception.detail, message=local.exception.message, type="any");
			} else {
				transaction action="commit";
			}
		}
	}

	function down() {
		transaction {
			try {
				// Recreate original tables
				// ... (inverse operations)
				
			} catch (any e) {
				local.exception = e;
			}

			if (StructKeyExists(local, "exception")) {
				transaction action="rollback";
				throw(errorCode="1", detail=local.exception.detail, message=local.exception.message, type="any");
			} else {
				transaction action="commit";
			}
		}
	}
}
```

### Create Polymorphic Association Table

```cfml
component extends="wheels.migrator.Migration" hint="Create polymorphic comments table" {

	function up() {
		transaction {
			try {
				t = createTable(name='comments', force=false, id=true, primaryKey='id');
				t.integer(columnNames='userId', null=false);
				t.string(columnNames='commentableType', limit=50, null=false); // 'Post', 'Article', 'Product'
				t.integer(columnNames='commentableId', null=false);
				t.text(columnNames='body', null=false);
				t.integer(columnNames='parentId', null=true); // For nested comments
				t.integer(columnNames='likesCount', default=0, null=false);
				t.boolean(columnNames='approved', default=false, null=false);
				t.timestamps();
				t.create();
				
				// Add indexes for polymorphic queries
				addIndex(table='comments', columnNames='commentableType,commentableId', name='idx_commentable');
				addIndex(table='comments', columnNames='userId');
				addIndex(table='comments', columnNames='parentId');
				addIndex(table='comments', columnNames='approved,createdAt');
				
			} catch (any e) {
				local.exception = e;
			}

			if (StructKeyExists(local, "exception")) {
				transaction action="rollback";
				throw(errorCode="1", detail=local.exception.detail, message=local.exception.message, type="any");
			} else {
				transaction action="commit";
			}
		}
	}

	function down() {
		transaction {
			try {
				dropTable('comments');
			} catch (any e) {
				local.exception = e;
			}

			if (StructKeyExists(local, "exception")) {
				transaction action="rollback";
				throw(errorCode="1", detail=local.exception.detail, message=local.exception.message, type="any");
			} else {
				transaction action="commit";
			}
		}
	}
}
```

## Data Migration Patterns

### Normalize Denormalized Data

```cfml
component extends="wheels.migrator.Migration" hint="Normalize category data from posts table" {

	function up() {
		transaction {
			try {
				// Create categories table
				t = createTable(name='categories', force=false, id=true, primaryKey='id');
				t.string(columnNames='name', limit=100, null=false);
				t.string(columnNames='slug', limit=100, null=false);
				t.text(columnNames='description', null=true);
				t.timestamps();
				t.create();
				
				addIndex(table='categories', columnNames='slug', unique=true);
				
				// Extract unique categories from posts
				local.categories = queryExecute("
					SELECT DISTINCT categoryName 
					FROM posts 
					WHERE categoryName IS NOT NULL 
					ORDER BY categoryName
				");
				
				// Create category records
				for (local.cat in local.categories) {
					local.slug = LCase(ReReplace(local.cat.categoryName, "[^a-zA-Z0-9]", "-", "all"));
					execute("
						INSERT INTO categories (name, slug, createdAt, updatedAt)
						VALUES (
							'#local.cat.categoryName#',
							'#local.slug#',
							NOW(),
							NOW()
						)
					");
				}
				
				// Add categoryId column to posts
				addColumn(table='posts', columnName='categoryId', columnType='integer', null=true);
				
				// Update posts with category IDs
				execute("
					UPDATE posts p
					SET categoryId = (
						SELECT id FROM categories c 
						WHERE c.name = p.categoryName
					)
					WHERE categoryName IS NOT NULL
				");
				
				// Add foreign key index
				addIndex(table='posts', columnNames='categoryId');
				
				// Remove old column after verification period
				// removeColumn(table='posts', columnName='categoryName');
				
			} catch (any e) {
				local.exception = e;
			}

			if (StructKeyExists(local, "exception")) {
				transaction action="rollback";
				throw(errorCode="1", detail=local.exception.detail, message=local.exception.message, type="any");
			} else {
				transaction action="commit";
			}
		}
	}

	function down() {
		transaction {
			try {
				// Restore denormalized data
				execute("
					UPDATE posts p
					SET categoryName = (
						SELECT name FROM categories c 
						WHERE c.id = p.categoryId
					)
					WHERE categoryId IS NOT NULL
				");
				
				// Remove categoryId column
				removeColumn(table='posts', columnName='categoryId');
				
				// Drop categories table
				dropTable('categories');
				
			} catch (any e) {
				local.exception = e;
			}

			if (StructKeyExists(local, "exception")) {
				transaction action="rollback";
				throw(errorCode="1", detail=local.exception.detail, message=local.exception.message, type="any");
			} else {
				transaction action="commit";
			}
		}
	}
}
```

### Backfill Calculated Fields

```cfml
component extends="wheels.migrator.Migration" hint="Backfill slug fields for existing records" {

	function up() {
		transaction {
			try {
				// Add slug column if it doesn't exist
				addColumn(table='posts', columnName='slug', columnType='string', limit=255, null=true);
				
				// Backfill slugs for existing posts
				local.posts = queryExecute("SELECT id, title FROM posts WHERE slug IS NULL");
				
				for (local.post in local.posts) {
					local.baseSlug = createSlug(local.post.title);
					local.slug = local.baseSlug;
					local.counter = 1;
					
					// Ensure unique slug
					while (queryExecute("SELECT COUNT(*) as count FROM posts WHERE slug = :slug AND id != :id", 
						{slug: local.slug, id: local.post.id}).count > 0) {
						local.slug = local.baseSlug & "-" & local.counter;
						local.counter++;
					}
					
					updateRecords(
						table='posts',
						where="id=#local.post.id#",
						slug=local.slug
					);
				}
				
				// Make slug required and unique
				changeColumn(table='posts', columnName='slug', null=false);
				addIndex(table='posts', columnNames='slug', unique=true);
				
			} catch (any e) {
				local.exception = e;
			}

			if (StructKeyExists(local, "exception")) {
				transaction action="rollback";
				throw(errorCode="1", detail=local.exception.detail, message=local.exception.message, type="any");
			} else {
				transaction action="commit";
			}
		}
	}

	function down() {
		transaction {
			try {
				// Remove unique constraint
				removeIndex(table='posts', columnNames='slug');
				
				// Remove slug column
				removeColumn(table='posts', columnName='slug');
				
			} catch (any e) {
				local.exception = e;
			}

			if (StructKeyExists(local, "exception")) {
				transaction action="rollback";
				throw(errorCode="1", detail=local.exception.detail, message=local.exception.message, type="any");
			} else {
				transaction action="commit";
			}
		}
	}
	
	private string function createSlug(required string text) {
		local.slug = LCase(arguments.text);
		local.slug = ReReplace(local.slug, "[^a-z0-9\s-]", "", "all");
		local.slug = ReReplace(local.slug, "[\s-]+", "-", "all");
		local.slug = ReReplace(local.slug, "^-+|-+$", "", "all");
		return Left(local.slug, 255);
	}
}
```

## Index and Constraint Management

### Complex Index Strategies

```cfml
component extends="wheels.migrator.Migration" hint="Add optimized indexes for performance" {

	function up() {
		transaction {
			try {
				// Single column index
				addIndex(table='users', columnNames='email', unique=true, name='idx_users_email');
				
				// Composite index for queries
				addIndex(table='posts', columnNames='userId,status,publishedAt', name='idx_posts_user_status_date');
				
				// Partial index (PostgreSQL)
				if (getDatabaseType() == "PostgreSQL") {
					execute("CREATE INDEX idx_active_users ON users(email) WHERE active = true");
					execute("CREATE INDEX idx_recent_posts ON posts(createdAt) WHERE createdAt > CURRENT_DATE - INTERVAL '30 days'");
				}
				
				// Full-text index (MySQL)
				if (getDatabaseType() == "MySQL") {
					execute("ALTER TABLE posts ADD FULLTEXT idx_posts_search (title, body)");
					execute("ALTER TABLE products ADD FULLTEXT idx_products_search (name, description)");
				}
				
				// Spatial index (MySQL/PostgreSQL)
				if (getDatabaseType() == "MySQL") {
					execute("ALTER TABLE locations ADD SPATIAL INDEX idx_locations_coords (coordinates)");
				} else if (getDatabaseType() == "PostgreSQL") {
					execute("CREATE INDEX idx_locations_coords ON locations USING GIST(coordinates)");
				}
				
				// Covering index (includes additional columns)
				if (getDatabaseType() == "PostgreSQL") {
					execute("CREATE INDEX idx_orders_user_covering ON orders(userId) INCLUDE (status, total, createdAt)");
				}
				
				// Expression index
				if (getDatabaseType() == "PostgreSQL") {
					execute("CREATE INDEX idx_users_lower_email ON users(LOWER(email))");
				} else if (getDatabaseType() == "MySQL") {
					execute("CREATE INDEX idx_users_lower_email ON users((LOWER(email)))");
				}
				
			} catch (any e) {
				local.exception = e;
			}

			if (StructKeyExists(local, "exception")) {
				transaction action="rollback";
				throw(errorCode="1", detail=local.exception.detail, message=local.exception.message, type="any");
			} else {
				transaction action="commit";
			}
		}
	}

	function down() {
		transaction {
			try {
				// Remove indexes in reverse order
				removeIndex(table='users', name='idx_users_email');
				removeIndex(table='posts', name='idx_posts_user_status_date');
				
				if (getDatabaseType() == "PostgreSQL") {
					execute("DROP INDEX IF EXISTS idx_active_users");
					execute("DROP INDEX IF EXISTS idx_recent_posts");
					execute("DROP INDEX IF EXISTS idx_locations_coords");
					execute("DROP INDEX IF EXISTS idx_orders_user_covering");
					execute("DROP INDEX IF EXISTS idx_users_lower_email");
				} else if (getDatabaseType() == "MySQL") {
					execute("ALTER TABLE posts DROP INDEX idx_posts_search");
					execute("ALTER TABLE products DROP INDEX idx_products_search");
					execute("ALTER TABLE locations DROP INDEX idx_locations_coords");
					execute("DROP INDEX idx_users_lower_email ON users");
				}
				
			} catch (any e) {
				local.exception = e;
			}

			if (StructKeyExists(local, "exception")) {
				transaction action="rollback";
				throw(errorCode="1", detail=local.exception.detail, message=local.exception.message, type="any");
			} else {
				transaction action="commit";
			}
		}
	}
}
```

### Foreign Key Constraints

```cfml
component extends="wheels.migrator.Migration" hint="Add foreign key constraints for referential integrity" {

	function up() {
		transaction {
			try {
				// Add foreign key with CASCADE DELETE
				addForeignKey(
					table='posts',
					referenceTable='users',
					column='userId',
					referenceColumn='id',
					onDelete='CASCADE',
					onUpdate='CASCADE'
				);
				
				// Add foreign key with RESTRICT
				addForeignKey(
					table='order_items',
					referenceTable='orders',
					column='orderId',
					referenceColumn='id',
					onDelete='RESTRICT',
					onUpdate='CASCADE'
				);
				
				// Add foreign key with SET NULL
				addForeignKey(
					table='comments',
					referenceTable='users',
					column='userId',
					referenceColumn='id',
					onDelete='SET NULL',
					onUpdate='CASCADE'
				);
				
				// Composite foreign key
				if (getDatabaseType() != "H2") {
					execute("
						ALTER TABLE order_details
						ADD CONSTRAINT fk_order_product
						FOREIGN KEY (orderId, productId)
						REFERENCES order_products(orderId, productId)
						ON DELETE CASCADE
						ON UPDATE CASCADE
					");
				}
				
			} catch (any e) {
				local.exception = e;
			}

			if (StructKeyExists(local, "exception")) {
				transaction action="rollback";
				throw(errorCode="1", detail=local.exception.detail, message=local.exception.message, type="any");
			} else {
				transaction action="commit";
			}
		}
	}

	function down() {
		transaction {
			try {
				removeForeignKey(table='posts', column='userId');
				removeForeignKey(table='order_items', column='orderId');
				removeForeignKey(table='comments', column='userId');
				
				if (getDatabaseType() != "H2") {
					execute("ALTER TABLE order_details DROP FOREIGN KEY fk_order_product");
				}
				
			} catch (any e) {
				local.exception = e;
			}

			if (StructKeyExists(local, "exception")) {
				transaction action="rollback";
				throw(errorCode="1", detail=local.exception.detail, message=local.exception.message, type="any");
			} else {
				transaction action="commit";
			}
		}
	}
}
```

## Multi-Database Support

### Database-Specific Features

```cfml
component extends="wheels.migrator.Migration" hint="Use database-specific features" {

	function up() {
		transaction {
			try {
				local.dbType = getDatabaseType();
				
				switch(local.dbType) {
					case "PostgreSQL":
						// PostgreSQL specific features
						
						// JSONB column
						execute("ALTER TABLE users ADD COLUMN preferences JSONB DEFAULT '{}'::jsonb");
						
						// Array column
						execute("ALTER TABLE posts ADD COLUMN tags TEXT[]");
						
						// UUID column with auto-generation
						execute("
							CREATE EXTENSION IF NOT EXISTS 'uuid-ossp';
							ALTER TABLE products ADD COLUMN uuid UUID DEFAULT uuid_generate_v4();
						");
						
						// Materialized view
						execute("
							CREATE MATERIALIZED VIEW post_statistics AS
							SELECT 
								userId,
								COUNT(*) as post_count,
								AVG(viewCount) as avg_views,
								MAX(createdAt) as last_post_date
							FROM posts
							GROUP BY userId;
							
							CREATE INDEX ON post_statistics(userId);
						");
						
						break;
						
					case "MySQL":
						// MySQL specific features
						
						// JSON column
						execute("ALTER TABLE users ADD COLUMN preferences JSON");
						
						// Generated column
						execute("
							ALTER TABLE users 
							ADD COLUMN full_name VARCHAR(255) 
							GENERATED ALWAYS AS (CONCAT(firstName, ' ', lastName)) STORED
						");
						
						// Partition table
						execute("
							ALTER TABLE logs 
							PARTITION BY RANGE (YEAR(createdAt)) (
								PARTITION p2023 VALUES LESS THAN (2024),
								PARTITION p2024 VALUES LESS THAN (2025),
								PARTITION p2025 VALUES LESS THAN (2026),
								PARTITION p_future VALUES LESS THAN MAXVALUE
							)
						");
						
						break;
						
					case "SQLServer":
						// SQL Server specific features
						
						// Computed column
						execute("
							ALTER TABLE users 
							ADD fullName AS (firstName + ' ' + lastName) PERSISTED
						");
						
						// Temporal table (system-versioned)
						execute("
							ALTER TABLE products
							ADD 
								SysStartTime datetime2 GENERATED ALWAYS AS ROW START NOT NULL DEFAULT GETUTCDATE(),
								SysEndTime datetime2 GENERATED ALWAYS AS ROW END NOT NULL DEFAULT CONVERT(datetime2, '9999-12-31 23:59:59.9999999'),
								PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime);
							
							ALTER TABLE products
							SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.ProductsHistory));
						");
						
						break;
						
					default:
						// Generic fallback
						addColumn(table='users', columnName='preferences', columnType='text', null=true);
				}
				
			} catch (any e) {
				local.exception = e;
			}

			if (StructKeyExists(local, "exception")) {
				transaction action="rollback";
				throw(errorCode="1", detail=local.exception.detail, message=local.exception.message, type="any");
			} else {
				transaction action="commit";
			}
		}
	}

	function down() {
		transaction {
			try {
				local.dbType = getDatabaseType();
				
				switch(local.dbType) {
					case "PostgreSQL":
						execute("DROP MATERIALIZED VIEW IF EXISTS post_statistics");
						execute("ALTER TABLE products DROP COLUMN IF EXISTS uuid");
						execute("ALTER TABLE posts DROP COLUMN IF EXISTS tags");
						execute("ALTER TABLE users DROP COLUMN IF EXISTS preferences");
						break;
						
					case "MySQL":
						execute("ALTER TABLE users DROP COLUMN IF EXISTS full_name");
						execute("ALTER TABLE users DROP COLUMN IF EXISTS preferences");
						execute("ALTER TABLE logs REMOVE PARTITIONING");
						break;
						
					case "SQLServer":
						execute("ALTER TABLE products SET (SYSTEM_VERSIONING = OFF)");
						execute("ALTER TABLE products DROP PERIOD FOR SYSTEM_TIME");
						execute("ALTER TABLE products DROP COLUMN SysStartTime, SysEndTime");
						execute("ALTER TABLE users DROP COLUMN fullName");
						break;
						
					default:
						removeColumn(table='users', columnName='preferences');
				}
				
			} catch (any e) {
				local.exception = e;
			}

			if (StructKeyExists(local, "exception")) {
				transaction action="rollback";
				throw(errorCode="1", detail=local.exception.detail, message=local.exception.message, type="any");
			} else {
				transaction action="commit";
			}
		}
	}
	
	private string function getDatabaseType() {
		// Helper to determine database type
		local.datasource = get("dataSourceName");
		local.dbinfo = new Query(datasource=local.datasource, sql="SELECT 1").execute().getPrefix();
		
		if (FindNoCase("postgresql", local.dbinfo.database_productname)) {
			return "PostgreSQL";
		} else if (FindNoCase("mysql", local.dbinfo.database_productname)) {
			return "MySQL";
		} else if (FindNoCase("microsoft", local.dbinfo.database_productname)) {
			return "SQLServer";
		} else if (FindNoCase("h2", local.dbinfo.database_productname)) {
			return "H2";
		}
		
		return "Unknown";
	}
}
```

## Performance Optimization

### Large Data Migration with Batching

```cfml
component extends="wheels.migrator.Migration" hint="Migrate large dataset with batching" {

	function up() {
		transaction {
			try {
				// Add new column
				addColumn(table='users', columnName='searchVector', columnType='text', null=true);
				
				// Get total count for progress tracking
				local.totalCount = queryExecute("SELECT COUNT(*) as count FROM users").count;
				local.batchSize = 1000;
				local.offset = 0;
				local.processed = 0;
				
				writeOutput("Migrating #local.totalCount# users in batches of #local.batchSize#...<br>");
				
				while (local.offset < local.totalCount) {
					// Process batch
					local.batch = queryExecute("
						SELECT id, firstName, lastName, email, bio 
						FROM users 
						ORDER BY id 
						LIMIT #local.batchSize# 
						OFFSET #local.offset#
					");
					
					for (local.user in local.batch) {
						// Build search vector
						local.searchVector = LCase(
							local.user.firstName & " " & 
							local.user.lastName & " " & 
							local.user.email & " " & 
							(local.user.bio ?: "")
						);
						
						// Update record
						execute("
							UPDATE users 
							SET searchVector = '#Replace(local.searchVector, "'", "''", "all")#'
							WHERE id = #local.user.id#
						");
						
						local.processed++;
					}
					
					local.offset += local.batchSize;
					
					// Progress indicator
					local.percentComplete = Round((local.processed / local.totalCount) * 100);
					writeOutput("Processed #local.processed# of #local.totalCount# (#local.percentComplete#%)<br>");
					
					// Give database a breather
					sleep(100);
				}
				
				// Add index after data migration
				addIndex(table='users', columnNames='searchVector');
				
			} catch (any e) {
				local.exception = e;
			}

			if (StructKeyExists(local, "exception")) {
				transaction action="rollback";
				throw(errorCode="1", detail=local.exception.detail, message=local.exception.message, type="any");
			} else {
				transaction action="commit";
			}
		}
	}

	function down() {
		transaction {
			try {
				removeIndex(table='users', columnNames='searchVector');
				removeColumn(table='users', columnName='searchVector');
			} catch (any e) {
				local.exception = e;
			}

			if (StructKeyExists(local, "exception")) {
				transaction action="rollback";
				throw(errorCode="1", detail=local.exception.detail, message=local.exception.message, type="any");
			} else {
				transaction action="commit";
			}
		}
	}
}
```

## Migration Best Practices

### 1. Always Use Transactions
```cfml
// Wrap all operations in a transaction
transaction {
	try {
		// Migration operations
	} catch (any e) {
		transaction action="rollback";
		throw;
	}
}
```

### 2. Make Migrations Reversible
```cfml
// Always implement both up() and down() methods
function down() {
	// Reverse all operations from up()
}
```

### 3. Test Migrations Locally First
```bash
# Test migration
wheels dbmigrate latest

# Test rollback
wheels dbmigrate down

# Test re-running
wheels dbmigrate latest
```

### 4. Handle Data Carefully
```cfml
// Backup data before destructive operations
execute("CREATE TABLE users_backup AS SELECT * FROM users");

// Verify data after migration
local.count = queryExecute("SELECT COUNT(*) as count FROM users WHERE newColumn IS NULL").count;
if (local.count > 0) {
	throw(message="Data migration incomplete: #local.count# records not migrated");
}
```

### 5. Use Database-Agnostic Code When Possible
```cfml
// Use Wheels migration methods instead of raw SQL
addColumn() // Good
execute("ALTER TABLE...") // Use only when necessary
```

### 6. Document Complex Migrations
```cfml
component extends="wheels.migrator.Migration" 
	hint="IMPORTANT: This migration consolidates user data and may take 10+ minutes on production" {
	// ...
}
```

## Rollback Strategies

### Safe Rollback Pattern
```cfml
function down() {
	transaction {
		try {
			// Check if rollback is safe
			local.hasData = queryExecute("SELECT COUNT(*) as count FROM new_table").count > 0;
			if (local.hasData) {
				throw(message="Cannot rollback: new_table contains data. Manual intervention required.");
			}
			
			// Proceed with rollback
			dropTable('new_table');
			
		} catch (any e) {
			local.exception = e;
		}

		if (StructKeyExists(local, "exception")) {
			transaction action="rollback";
			throw(errorCode="1", detail=local.exception.detail, message=local.exception.message, type="any");
		} else {
			transaction action="commit";
		}
	}
}
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Migration Fails Midway
```cfml
// Use savepoints for partial rollback
transaction {
	try {
		// Part 1
		transaction action="savepoint" savepoint="part1";
		// ... operations ...
		
		// Part 2 - might fail
		transaction action="savepoint" savepoint="part2";
		// ... risky operations ...
		
	} catch (any e) {
		// Rollback only failed part
		transaction action="rollback" savepoint="part2";
		// Handle error...
	}
}
```

#### 2. Duplicate Migration Numbers
```bash
# Check for duplicates
ls app/migrator/migrations/ | grep "^[0-9]" | cut -d_ -f1 | sort | uniq -d

# Rename duplicate
mv app/migrator/migrations/20231215103045_duplicate.cfc app/migrator/migrations/20231215103046_duplicate.cfc
```

#### 3. Lock Timeout on Large Tables
```cfml
// Add timeout and lock hints
if (getDatabaseType() == "MySQL") {
	execute("SET SESSION innodb_lock_wait_timeout = 120");
	execute("ALTER TABLE large_table ADD COLUMN new_col INT, ALGORITHM=INPLACE, LOCK=NONE");
}
```

#### 4. Memory Issues with Large Datasets
```cfml
// Use streaming queries
local.query = new Query(
	datasource=get("dataSourceName"),
	sql="SELECT * FROM large_table",
	fetchSize=100 // Process 100 rows at a time
);
```

## Summary

Key principles for successful migrations:
1. **Always use CLI** to generate migrations
2. **Test thoroughly** in development first
3. **Make migrations reversible** with proper down() methods
4. **Handle data carefully** with validation and backups
5. **Use transactions** for atomicity
6. **Consider performance** for large datasets
7. **Document complex changes** for team members
8. **Plan for rollbacks** in production scenarios