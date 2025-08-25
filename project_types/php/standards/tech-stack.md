# Tech Stack

## Context

PHP-specific tech stack for Agent OS projects, overridable in project-specific `.agent-os/product/tech-stack.md`.

### Core Platform
- **Language**: PHP 8.2+
- **Web Server**: Apache 2.4+ or Nginx 1.20+
- **Database**: MySQL 8.0+ or PostgreSQL 15+
- **Cache**: Redis 7.0+ for session and object caching
- **PHP Extensions**: OPcache, Imagick, GD, cURL, XML, JSON, OpenSSL

### Frameworks
- **Primary Framework**: Laravel 10+ or Symfony 6+
- **Alternative Frameworks**: Slim, CakePHP, or custom MVC
- **Microservices**: Lumen for lightweight microservices
- **API Framework**: Laravel API Resources or custom REST API

### Development Environment
- **Local Development**: Laravel Sail, Docker, or Valet
- **Version Control**: Git with branching strategy
- **Code Quality**: PHP_CodeSniffer with PSR-12 standards
- **Static Analysis**: PHPStan with level 8 strictness
- **Testing**: PHPUnit with Mockery for unit tests
- **Integration Testing**: Pest or PHPUnit with browser testing

### Frontend Technologies
- **CSS Framework**: TailwindCSS 4.0+ or Bootstrap 5
- **JavaScript Framework**: Vue 3+ or React 18+
- **Build Tool**: Vite or Laravel Mix
- **Package Manager**: npm or yarn
- **Node Version**: 18 LTS or 20 LTS
- **TypeScript**: 5.0+ for type-safe JavaScript

### Database & ORM
- **Primary Database**: MySQL 8.0+ or PostgreSQL 15+
- **ORM**: Eloquent (Laravel) or Doctrine ORM
- **Database Migrations**: Laravel Migrations or Doctrine Migrations
- **Seeding**: Database seeding with Faker for test data
- **Database Tools**: Laravel Telescope, phpMyAdmin, or pgAdmin

### Authentication & Security
- **Authentication**: Laravel Sanctum or Passport
- **Authorization**: Laravel Gates and Policies
- **Security**: Laravel Security features, CSRF protection
- **Authentication Packages**: Socialite for OAuth
- **Security Headers**: Laravel Security Headers middleware
- **Rate Limiting**: Laravel Rate Limiting

### API Development
- **REST API**: Laravel API Resources or custom REST API
- **GraphQL**: Laravel GraphQL or custom GraphQL implementation
- **API Documentation**: Swagger/OpenAPI or custom documentation
- **API Testing**: Postman, Insomnia, or Pest API tests
- **API Versioning**: Versioned API endpoints

### Performance Optimization
- **Caching**: Redis, Memcached, or file-based caching
- **CDN**: Cloudflare or AWS CloudFront
- **Asset Optimization**: Laravel Mix, Vite, or Webpack
- **Database Optimization**: Query optimization, indexing
- **Caching Strategies**: HTTP caching, browser caching
- **Load Balancing**: Nginx load balancing or cloud load balancers

### Deployment & DevOps
- **Containerization**: Docker with Docker Compose
- **CI/CD**: GitHub Actions, GitLab CI, or Jenkins
- **Deployment**: Laravel Forge, Deployer, or custom scripts
- **Server Management**: Ansible for server configuration
- **Monitoring**: New Relic, Datadog, or custom monitoring
- **Logging**: Laravel Telescope, Sentry, or custom logging

### Testing
- **Unit Testing**: PHPUnit with Mockery
- **Feature Testing**: Laravel Dusk or Pest
- **Integration Testing**: API integration tests
- **End-to-End Testing**: Cypress or Playwright
- **Performance Testing**: Laravel Benchmark, PHPUnit performance
- **Code Coverage**: PHPUnit with coverage reports

### Development Tools
- **IDE**: PhpStorm, VS Code with PHP extensions
- **Code Quality**: PHPStan, PHP_CodeSniffer, PHPMD
- **Debugging**: Xdebug, Laravel Telescope, Blackfire
- **Profiling**: XHProf, Tideways, or New Relic
- **Version Control**: Git with pre-commit hooks

### Package Management
- **Composer**: PHP package management
- **NPM/Yarn**: Frontend package management
- **Package Repositories**: Packagist, private repositories
- **Dependency Management**: Composer autoloading, PSR-4
- **Security Scanning**: Composer audit for security vulnerabilities

### Queue & Background Jobs
- **Queue System**: Laravel Queue with Redis or Beanstalkd
- **Job Processing**: Horizon for queue monitoring
- **Background Jobs**: Laravel Queues, Symfony Messenger
- **Scheduling**: Task scheduling with cron or Laravel Scheduler
- **Monitoring**: Queue monitoring and job tracking

### File Storage & Media
- **Local Storage**: Local filesystem for development
- **Cloud Storage**: AWS S3, Google Cloud Storage, or DigitalOcean Spaces
- **File Upload**: Laravel Filesystem with validation
- **Image Processing**: Intervention Image or GD/Imagick
- **Media Management**: Custom media management system

### Email & Communication
- **Email**: Laravel Mail with SMTP, SendGrid, or Mailgun
- **Notifications**: Laravel Notifications with channels
- **SMS**: Twilio or custom SMS integration
- **Push Notifications**: Firebase Cloud Messaging or custom
- **WebSockets**: Laravel WebSockets or custom WebSocket implementation

### Search & Analytics
- **Search**: Algolia, Elasticsearch, or MySQL Full-Text Search
- **Analytics**: Google Analytics, Mixpanel, or custom analytics
- **Logging**: Monolog, custom logging system
- **Monitoring**: Application performance monitoring
- **Error Tracking**: Sentry, Bugsnag, or custom error tracking

### Microservices & Architecture
- **Microservices**: Laravel Lumen, Symfony Microservices
- **Service Communication**: REST API, gRPC, or message queues
- **API Gateway**: Custom API gateway or Kong
- **Service Discovery**: Consul or custom service discovery
- **Load Balancing**: Nginx, HAProxy, or cloud load balancers

### Security & Compliance
- **Authentication**: JWT, OAuth 2.0, custom authentication
- **Authorization**: RBAC, ABAC, custom authorization
- **Data Encryption**: OpenSSL, Laravel Encryption
- **Compliance**: GDPR, CCPA, SOC 2 compliance
- **Security Testing**: OWASP ZAP, Burp Suite, custom security tests

### Performance & Scalability
- **Caching**: Redis, Memcached, CDN caching
- **Database**: Read replicas, database sharding
- **Load Balancing**: Horizontal scaling, load balancers
- **Container Orchestration**: Kubernetes, Docker Swarm
- **Serverless**: AWS Lambda, Google Cloud Functions

### Monitoring & Observability
- **Application Monitoring**: New Relic, Datadog, custom monitoring
- **Infrastructure Monitoring**: Prometheus, Grafana, custom monitoring
- **Logging**: ELK Stack, Splunk, custom logging
- **Tracing**: Jaeger, Zipkin, distributed tracing
- **Alerting**: Custom alerting systems, PagerDuty

### Development Workflow
- **Git Workflow**: Git Flow, GitHub Flow, or custom workflow
- **Code Review**: Pull requests, code review process
- **Continuous Integration**: Automated testing, deployment
- **Continuous Deployment**: Automated deployment pipeline
- **Quality Gates**: Code quality checks, security scans

### Documentation
- **API Documentation**: Swagger/OpenAPI, custom documentation
- **Code Documentation**: PHPDoc, custom documentation
- **Architecture Documentation**: C4 models, custom documentation
- **User Documentation**: Markdown, custom documentation
- **Deployment Documentation**: Deployment guides, custom documentation
