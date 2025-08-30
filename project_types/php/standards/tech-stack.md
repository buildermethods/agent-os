# Tech Stack

## Context

PHP-specific tech stack for Agent OS projects, overridable in project-specific `.agent-os/product/tech-stack.md`.

### Core Platform
- **Language**: PHP 8.4+
- **Web Server**: Apache 2.4+ or Nginx 1.20+
- **Database**: MySQL 8.0+ or PostgreSQL 15+
- **Cache**: Redis 7.0+ for session and object caching
- **PHP Extensions**: OPcache, Imagick, GD, cURL, XML, JSON, OpenSSL

### Frameworks
- **Primary Framework**: Symfony 6+ or custom MVC
- **Alternative Frameworks**: Slim, CakePHP, or custom MVC
- **Microservices**: Symfony Microservices for lightweight microservices
- **API Framework**: API Resources or custom REST API

### Development Environment
- **Local Development**: Docker or Valet
- **Version Control**: Git with branching strategy
- **Code Quality**: PHP_CodeSniffer with PSR-12 standards
- **Static Analysis**: PHPStan with level 8 strictness
- **Testing**: PHPUnit with Mockery for unit tests
- **Integration Testing**: Pest or PHPUnit with browser testing

### Frontend Technologies
- **CSS Framework**: TailwindCSS 4.0+ or Bootstrap 5
- **JavaScript Framework**: Vue 3+ or React 18+
- **Build Tool**: Vite or Webpack
- **Package Manager**: npm or yarn
- **Node Version**: 18 LTS or 20 LTS
- **TypeScript**: 5.0+ for type-safe JavaScript

### Database & ORM
- **Primary Database**: MySQL 8.0+ or PostgreSQL 15+
- **ORM**: Doctrine ORM or custom ORM
- **Database Migrations**: Doctrine Migrations or custom migrations
- **Seeding**: Database seeding with Faker for test data
- **Database Tools**: phpMyAdmin, pgAdmin, or custom database tools

### Authentication & Security
- **Authentication**: JWT, OAuth 2.0, or custom authentication
- **Authorization**: RBAC, ABAC, or custom authorization
- **Security**: CSRF protection, security middleware
- **Authentication Packages**: OAuth libraries for authentication
- **Security Headers**: Security headers middleware
- **Rate Limiting**: Rate limiting middleware

### API Development
- **REST API**: API Resources or custom REST API
- **GraphQL**: GraphQL libraries or custom GraphQL implementation
- **API Documentation**: Swagger/OpenAPI or custom documentation
- **API Testing**: Postman, Insomnia, or Pest API tests
- **API Versioning**: Versioned API endpoints

### Performance Optimization
- **Caching**: Redis, Memcached, or file-based caching
- **CDN**: Cloudflare or AWS CloudFront
- **Asset Optimization**: Vite or Webpack
- **Database Optimization**: Query optimization, indexing
- **Caching Strategies**: HTTP caching, browser caching
- **Load Balancing**: Nginx load balancing or cloud load balancers

### Deployment & DevOps
- **Containerization**: Docker with Docker Compose
- **CI/CD**: GitHub Actions, GitLab CI, or Jenkins
- **Deployment**: Deployer or custom scripts
- **Server Management**: Ansible for server configuration
- **Monitoring**: New Relic, Datadog, or custom monitoring
- **Logging**: Sentry or custom logging

### Testing
- **Unit Testing**: PHPUnit with Mockery
- **Feature Testing**: Pest or custom feature testing
- **Integration Testing**: API integration tests
- **End-to-End Testing**: Cypress or Playwright
- **Performance Testing**: PHPUnit performance or custom performance testing
- **Code Coverage**: PHPUnit with coverage reports

### Development Tools
- **IDE**: PhpStorm, VS Code with PHP extensions
- **Code Quality**: PHPStan, PHP_CodeSniffer, PHPMD
- **Debugging**: Xdebug, Blackfire, or custom debugging tools
- **Profiling**: XHProf, Tideways, or New Relic
- **Version Control**: Git with pre-commit hooks

### Package Management
- **Composer**: PHP package management
- **NPM/Yarn**: Frontend package management
- **Package Repositories**: Packagist, private repositories
- **Dependency Management**: Composer autoloading, PSR-4
- **Security Scanning**: Composer audit for security vulnerabilities

### Queue & Background Jobs
- **Queue System**: Queue systems with Redis or Beanstalkd
- **Job Processing**: Queue monitoring tools
- **Background Jobs**: Symfony Messenger or custom background jobs
- **Scheduling**: Task scheduling with cron or custom scheduler
- **Monitoring**: Queue monitoring and job tracking

### File Storage & Media
- **Local Storage**: Local filesystem for development
- **Cloud Storage**: AWS S3, Google Cloud Storage, or DigitalOcean Spaces
- **File Upload**: Filesystem with validation
- **Image Processing**: Intervention Image or GD/Imagick
- **Media Management**: Custom media management system

### Email & Communication
- **Email**: Mail with SMTP, SendGrid, or Mailgun
- **Notifications**: Notifications with channels
- **SMS**: Twilio or custom SMS integration
- **Push Notifications**: Firebase Cloud Messaging or custom
- **WebSockets**: WebSocket libraries or custom WebSocket implementation

### Search & Analytics
- **Search**: Algolia, Elasticsearch, or MySQL Full-Text Search
- **Analytics**: Google Analytics, Mixpanel, or custom analytics
- **Logging**: Monolog, custom logging system
- **Monitoring**: Application performance monitoring
- **Error Tracking**: Sentry, Bugsnag, or custom error tracking

### Microservices & Architecture
- **Microservices**: Symfony Microservices or custom microservices
- **Service Communication**: REST API, gRPC, or message queues
- **API Gateway**: Custom API gateway or Kong
- **Service Discovery**: Consul or custom service discovery
- **Load Balancing**: Nginx, HAProxy, or cloud load balancers

### Security & Compliance
- **Authentication**: JWT, OAuth 2.0, custom authentication
- **Authorization**: RBAC, ABAC, custom authorization
- **Data Encryption**: OpenSSL or custom encryption
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
