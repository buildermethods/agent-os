# Tech Stack

## Context

WordPress-specific tech stack for Agent OS projects, overridable in project-specific `.agent-os/product/tech-stack.md`.

### Core Platform
- **CMS Platform**: WordPress 6.0+
- **Language**: PHP 8.1+
- **Server**: Apache 2.4+ or Nginx 1.18+
- **Database**: MySQL 8.0+ or MariaDB 10.6+
- **Cache**: Redis 7.0+ for object caching
- **PHP Extensions**: OPcache, Imagick, GD, cURL, XML, JSON

### Development Environment
- **Local Development**: Local by Flywheel or WP Local Docker
- **Version Control**: Git with WordPress VIP Go standards
- **Code Quality**: PHP_CodeSniffer with WordPress coding standards
- **Static Analysis**: PHPStan with WordPress ruleset
- **Testing**: PHPUnit with WP_Mock for unit tests

### Frontend Technologies
- **CSS Framework**: TailwindCSS 4.0+ with WordPress integration
- **JavaScript Framework**: React 18+ with WordPress blocks
- **Build Tool**: Vite with WordPress plugin configuration
- **Package Manager**: npm or yarn
- **Node Version**: 18 LTS or 20 LTS
- **TypeScript**: 5.0+ for React block development

### WordPress Specific
- **Theme Development**: Block-based themes with theme.json
- **Plugin Development**: Custom plugins with OOP architecture
- **Block Development**: Custom Gutenberg blocks with React
- **REST API**: WordPress REST API for frontend integration
- **Custom Post Types**: Custom post types and taxonomies
- **ACF**: Advanced Custom Fields Pro for flexible content

### Performance Optimization
- **Caching**: WP Rocket or LiteSpeed Cache
- **CDN**: Cloudflare or KeyCDN
- **Image Optimization**: ShortPixel or Smush
- **Asset Optimization**: Autoptimize for CSS/JS
- **Database Optimization**: WP-Optimize or similar
- **Object Cache**: Redis for database query caching

### Security
- **Security Plugin**: Wordfence Security or iThemes Security
- **SSL**: Let's Encrypt SSL certificates
- **File Permissions**: Proper WordPress file permissions
- **User Management**: Two-factor authentication with Google Authenticator
- **Backup**: UpdraftPlus or BlogVault for automated backups
- **Malware Scanning**: Sucuri Security or Wordfence Malware Scan

### Hosting & Deployment
- **Managed Hosting**: WordPress VIP, Kinsta, or WP Engine
- **Self-Hosted**: DigitalOcean, Linode, or AWS EC2
- **Containerization**: Docker with WordPress official images
- **CI/CD**: GitHub Actions or GitLab CI
- **Deployment**: Deployer or WP-CLI scripts
- **Staging**: WP Staging or All-in-One WP Migration

### Development Tools
- **IDE**: PhpStorm with WordPress plugin
- **Code Editor**: VS Code with WordPress development extensions
- **Debugging**: Query Monitor, Debug Bar, and Xdebug
- **Version Control**: Git with pre-commit hooks
- **Documentation**: JSDoc for JavaScript, PHPDoc for PHP

### Testing
- **Unit Testing**: PHPUnit with WP_Mock
- **Integration Testing**: WP Browser with Codeception
- **End-to-End Testing**: Cypress or Playwright
- **Performance Testing**: Lighthouse CI and WebPageTest
- **Code Coverage**: PHPUnit with coverage reports

### Monitoring & Analytics
- **Analytics**: Google Analytics 4 with enhanced measurement
- **Error Tracking**: Sentry or Bugsnag for error monitoring
- **Performance Monitoring**: New Relic or Datadog
- **Uptime Monitoring**: UptimeRobot or Pingdom
- **Log Management**: Papertrail or Loggly

### API Integration
- **REST API**: WordPress REST API for custom endpoints
- **GraphQL**: WPGraphQL for GraphQL API
- **Third-party APIs**: WooCommerce, Zapier, or custom integrations
- **Webhooks**: Custom webhook handlers for external services

### E-commerce (if applicable)
- **E-commerce Platform**: WooCommerce 8.0+
- **Payment Gateways**: Stripe, PayPal, Square
- **Shipping**: WooCommerce Shipping or custom solutions
- **Inventory**: WooCommerce inventory management
- **Tax Calculation**: WooCommerce Tax or Avalara

### Mobile & Progressive Web Apps
- **PWA Support**: WP PWA or PWA for WordPress plugin
- **Mobile Apps**: React Native with WordPress REST API
- **Push Notifications**: OneSignal or Push Notifications
- **Offline Support**: Service Workers with WordPress caching

### Accessibility
- **Accessibility**: WCAG 2.1 AA compliance
- **Screen Readers**: ARIA labels and landmarks
- **Keyboard Navigation**: Full keyboard accessibility
- **Color Contrast**: Proper contrast ratios for readability
- **Testing**: axe DevTools or WAVE for accessibility testing

### SEO
- **SEO Plugin**: Yoast SEO or Rank Math
- **XML Sitemaps**: Automatic sitemap generation
- **Schema Markup**: JSON-LD structured data
- **Performance**: Core Web Vitals optimization
- **Content**: Content optimization and readability analysis

### Content Management
- **Content Strategy**: Content modeling and architecture
- **Media Management**: WordPress media library optimization
- **Content Delivery**: CDN and caching strategies
- **Multilingual**: WPML or Polylang for multilingual sites
- **Content Versioning**: Revisions and version control

### Compliance
- **GDPR**: Cookie consent and privacy compliance
- **CCPA**: California Consumer Privacy Act compliance
- **Accessibility**: WCAG and ADA compliance
- **Performance**: Core Web Vitals optimization
- **Security**: SOC 2 compliance for enterprise clients
