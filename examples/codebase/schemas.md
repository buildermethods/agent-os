# Schema Reference

Generated: 2025-01-21
Last Updated: 2025-01-21

## Database Schema

### users
- id: integer (primary key, auto-increment)
- email: string (unique, not null)
- username: string (unique, not null)
- password_hash: string (not null)
- first_name: string
- last_name: string
- role: enum('user', 'admin', 'moderator') (default: 'user')
- email_verified: boolean (default: false)
- created_at: timestamp (default: now)
- updated_at: timestamp (default: now, on update)

### products
- id: integer (primary key, auto-increment)
- name: string (not null)
- description: text
- price: decimal(10,2) (not null)
- stock_quantity: integer (default: 0)
- category_id: integer (foreign key -> categories.id)
- image_url: string
- active: boolean (default: true)
- created_at: timestamp (default: now)
- updated_at: timestamp (default: now, on update)

### orders
- id: integer (primary key, auto-increment)
- user_id: integer (foreign key -> users.id)
- order_number: string (unique)
- status: enum('pending', 'processing', 'shipped', 'delivered', 'cancelled')
- total_amount: decimal(10,2)
- shipping_address: json
- billing_address: json
- created_at: timestamp (default: now)
- updated_at: timestamp (default: now, on update)

### order_items
- id: integer (primary key, auto-increment)
- order_id: integer (foreign key -> orders.id)
- product_id: integer (foreign key -> products.id)
- quantity: integer (not null)
- price: decimal(10,2) (not null)
- created_at: timestamp (default: now)

### categories
- id: integer (primary key, auto-increment)
- name: string (unique, not null)
- slug: string (unique, not null)
- parent_id: integer (foreign key -> categories.id, nullable)
- created_at: timestamp (default: now)

### sessions
- id: string (primary key)
- user_id: integer (foreign key -> users.id)
- token: string (unique, not null)
- expires_at: timestamp (not null)
- created_at: timestamp (default: now)

## API Endpoints

### Authentication
POST   /api/auth/register     - Register new user
POST   /api/auth/login        - User login
POST   /api/auth/logout       - User logout
POST   /api/auth/refresh      - Refresh access token
GET    /api/auth/me           - Get current user
POST   /api/auth/verify-email - Verify email address
POST   /api/auth/forgot       - Request password reset
POST   /api/auth/reset        - Reset password

### Users
GET    /api/users             - List users (admin only)
GET    /api/users/:id         - Get user by ID
PUT    /api/users/:id         - Update user
DELETE /api/users/:id         - Delete user (admin only)
GET    /api/users/:id/orders  - Get user's orders

### Products
GET    /api/products          - List products (with pagination)
GET    /api/products/:id      - Get product by ID
POST   /api/products          - Create product (admin only)
PUT    /api/products/:id      - Update product (admin only)
DELETE /api/products/:id      - Delete product (admin only)
GET    /api/products/search   - Search products

### Categories
GET    /api/categories        - List all categories
GET    /api/categories/:id    - Get category by ID
POST   /api/categories        - Create category (admin only)
PUT    /api/categories/:id    - Update category (admin only)
DELETE /api/categories/:id    - Delete category (admin only)

### Orders
GET    /api/orders            - List orders (user's own or all for admin)
GET    /api/orders/:id        - Get order by ID
POST   /api/orders            - Create new order
PUT    /api/orders/:id        - Update order status (admin only)
DELETE /api/orders/:id        - Cancel order

### Cart
GET    /api/cart              - Get current cart
POST   /api/cart/items        - Add item to cart
PUT    /api/cart/items/:id    - Update cart item quantity
DELETE /api/cart/items/:id    - Remove item from cart
DELETE /api/cart              - Clear cart

## Request/Response Formats

### Standard Success Response
```json
{
  "success": true,
  "data": { ... },
  "message": "Operation successful"
}
```

### Standard Error Response
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": { ... }
  }
}
```

### Paginated Response
```json
{
  "success": true,
  "data": {
    "items": [ ... ],
    "pagination": {
      "page": 1,
      "perPage": 20,
      "total": 100,
      "totalPages": 5
    }
  }
}
```

## Environment Variables

DATABASE_URL=postgresql://user:pass@localhost:5432/dbname
REDIS_URL=redis://localhost:6379
JWT_SECRET=your-secret-key
JWT_EXPIRY=15m
REFRESH_TOKEN_EXPIRY=7d
API_BASE_URL=https://api.example.com
FRONTEND_URL=https://example.com
SMTP_HOST=smtp.example.com
SMTP_PORT=587
SMTP_USER=noreply@example.com
SMTP_PASS=password
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_REGION=us-east-1
S3_BUCKET=your-bucket-name