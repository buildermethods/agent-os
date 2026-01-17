## Tech stack

Define your technical stack below. This serves as a reference for all team members and helps maintain consistency across the project.

### Framework & Runtime
- **Application Framework:** WordPress
- **Language/Runtime:** PHP
- **Package Manager:** Composer (PHP dependencies), npm/Bun (JavaScript build tools)
- **Dependency Injection:** DI52 (dependency injection container with providers pattern)

### Frontend
- **JavaScript Framework:** Vanilla JavaScript (preferred), jQuery (for WordPress/legacy code compatibility)
- **CSS Framework:** SCSS (compiled to CSS), BEM methodology (preferred), Tailwind CSS (on some sites)
- **UI Components:** Kadence Blocks, Kadence Blocks Pro, Kadence Conversions, WordPress blocks
- **Theme Structure:** Kadence parent theme with child themes for customizations

### Database & Storage
- **Database:** MariaDB
- **ORM/Query Builder:** WordPress Query API, WPDB
- **Caching:** Redis (via Object Cache Pro, hosted on Liquid Web servers)
- **Page Caching:** Solid Performance
- **Image Storage:** AWS S3 (via S3 Uploads plugin)

### Testing & Quality
- **Test Framework:** PHPUnit (PHP), JavaScript testing framework TBD
- **Linting/Formatting:** WordPress Coding Standards (mostly followed), specific tools TBD
- **Code Quality:** WordPress Coding Standards compliance

### Build Tools
- **CSS/JS Compilation:** Gulp (preferred), Webpack (legacy projects)
- **Build Process:** Compile and minimize CSS and JS files using npm/Bun
- **SCSS Processing:** SCSS compilation with nesting and variables support

### Deployment & Infrastructure
- **Hosting:** Liquid Web servers
- **CDN/DNS:** CloudFlare (domains, caching, firewall features)
- **CI/CD:** Ansible + Jenkins (primary), GitHub Actions (some sites)
- **Local Development:** Lando with Docker Desktop or Orbstack
- **Environments:** dev, staging, production
- **Version Control:** GitHub (main branch for production, feature branches for dev/staging)

### WordPress Plugins & Tools
- **Commerce:** WooCommerce (primary), Easy Digital Downloads (legacy), WooCommerce Subscriptions, WooCommerce Bundles
- **Payment Processing:** Braintree PayPal, Avalara Avatax
- **Core Plugins:** Advanced Custom Fields Pro, Safe SVG, Solid Security, Solid Performance, Object Cache Pro, Gravity Forms, Yoast SEO, S3 Uploads
- **Kadence Suite:** Kadence Blocks, Kadence Blocks Pro, Kadence Conversions

### Third-Party Services
- **Authentication:** WordPress native authentication
- **Email:** Mailgun (transactional), Active Campaign (marketing communications)
- **Monitoring:** Sentry (planned/in discussion)

### Architecture Patterns
- **Site Separation:** Marketing sites (custombrand.com) and commerce sites (my.custombrand.com) separated for performance and separation of concerns
- **Code Organization:** DI52 container with providers pattern for all plugins
- **Shared Libraries:** Common code shared across StellarWP brands
