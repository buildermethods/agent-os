# Product Mission

## Pitch
QA Agent OS is a distributable, spec-driven context system that helps QA engineers, development teams, and AI coding assistants perform production-quality QA tasks by providing structured, 3-layer context that transforms generic AI capabilities into specialized QA expertise.

## Users

### Primary Customers
- QA Engineers: Individual contributors who perform testing, bug reporting, and requirement analysis as part of their daily work
- Development Teams: Engineering teams that need consistent QA standards and automation across projects
- AI Assistant Users: Anyone using AI coding tools (Claude Code, Cursor, Windsurf) who wants their AI to understand QA best practices

### User Personas

**Sarah, QA Engineer** (28-40)
- Role: Quality Assurance Engineer at a software company
- Context: Works on multiple projects simultaneously, needs to maintain consistent testing standards across all work
- Pain Points: AI coding assistants don't understand company-specific QA standards, repetitive documentation of test cases and bugs, difficulty maintaining context across features
- Goals: Automate repetitive QA documentation, ensure AI assistants follow team conventions, reduce time spent on boilerplate work while maintaining quality

**Mike, Development Team Lead** (32-45)
- Role: Engineering Team Lead responsible for QA process standardization
- Context: Manages a team of 5-10 developers and QA engineers across 3-4 active projects
- Pain Points: Inconsistent QA practices across team members, AI assistants producing different quality outputs for different engineers, difficult to onboard new team members to QA standards
- Goals: Standardize QA processes across the team, enable AI assistants to follow team conventions automatically, reduce onboarding time for new engineers

**Alex, Solo Developer** (25-35)
- Role: Full-stack developer wearing multiple hats including QA
- Context: Works on personal or small business projects without dedicated QA resources
- Goals: Get QA best practices without hiring specialists, leverage AI to perform professional-quality testing, learn proper QA workflows

## The Problem

### AI Assistants Lack QA Context
Current AI coding assistants operate as "confused interns" when it comes to QA work. They don't understand your team's bug reporting standards, test case formats, severity rules, or project-specific conventions. This results in inconsistent outputs that require constant correction and rework, negating the productivity benefits of AI assistance.

**Our Solution:** QA Agent OS provides a 3-layer context system that gives AI assistants the knowledge they need: Standards (how you test), Product (what you're testing and why), and Features (what you're testing next). This transforms generic AI into a specialized QA assistant that follows your team's exact conventions on the first try.

### QA Documentation is Repetitive and Time-Consuming
QA engineers spend significant time on repetitive documentation tasks: writing test cases following specific templates, creating bug reports with consistent structure, analyzing requirements using standard checklists. While AI assistants can help, they require detailed prompting each time to understand the context and format requirements.

**Our Solution:** QA Agent OS captures your QA standards, workflows, and templates once, then makes them available to AI assistants automatically. Commands like `/analise-requirements` and `/generate-testcases` execute multi-step QA workflows that follow your exact standards, eliminating repetitive prompting.

### Context Gets Lost Between Features and Projects
When working on multiple features or projects, maintaining context becomes difficult. QA engineers must remember project-specific details, re-explain requirements to AI assistants, and manually track what's been tested. This context-switching overhead reduces productivity and increases the risk of missing important test scenarios.

**Our Solution:** QA Agent OS creates a persistent "brain" for each project through its Product and Features layers. Product mission documents capture what you're building and why. Feature directories organize requirements, test cases, and artifacts in a structured hierarchy. AI assistants can reference this context automatically, reducing context-switching overhead.

## Differentiators

### Spec-Driven, Not Prompt-Driven
Unlike traditional AI workflows that require detailed prompting for each task, QA Agent OS operates on specifications. You define your standards, product context, and feature requirements once in structured Markdown files. AI assistants then execute complex, multi-step QA workflows automatically by following these features specs. This results in consistent, predictable outputs without repetitive prompting.

### Distributable Profile System
Unlike monolithic QA tools or single-project solutions, QA Agent OS uses a profile-based architecture. Create your standards once in a profile, then install that profile across unlimited projects. Customize profiles for different teams, clients, or project types. This results in true portability and reusability of your QA knowledge.

### AI-Tool Agnostic
Unlike tools locked to specific AI platforms, QA Agent OS compiles context for multiple AI coding assistants. Current support for Claude Code with subagents, commands, and skills. Architecture designed for easy extension to Cursor, Windsurf, and future tools. This results in freedom to use your preferred AI assistant without vendor lock-in.

### 3-Layer Context Architecture
Unlike flat knowledge systems, QA Agent OS organizes context in three distinct layers: Standards (foundational QA rules), Product (project-specific vision), and Features (immediate work details). This hierarchical structure ensures AI assistants have the right level of context for each task. This results in better decision-making and more relevant outputs.

## Key Features

### Core Features
- **Standards Library:** Comprehensive, customizable QA standards covering bug reporting, test case structure, severity rules, requirement analysis checklists, and testing methodologies that define how your team performs QA work
- **Product Context System:** `/plan-product` command creates mission.md documenting product vision, target users, key problems, and strategic goals, giving AI assistants high-level understanding of what you're building and why
- **Feature Management:** Hierarchical directory structure (Product > Feature > Ticket) organizes requirements, test cases, and testing artifacts for each piece of work in a standardized, navigable format
- **Requirement Analysis Workflow:** `/analise-requirements` command performs multi-phase analysis: initializes feature structure, analyzes BRDs/requirements for risks and ambiguities, generates comprehensive test cases following your standards

### Installation & Configuration Features
- **One-Command Base Installation:** Single curl command installs QA Agent OS to ~/qa-agent-os with all profiles, standards, and scripts ready for use across unlimited projects
- **Project Installation:** `/project-install.sh` compiles your chosen profile into project-specific .claude/ and qa-agent-os/ directories, injecting standards and creating AI-ready commands
- **Profile Customization:** Create custom profiles with your team's specific standards, workflows, and conventions using `/create-profile.sh` or manual profile directory creation
- **Configuration Control:** Central config.yml controls AI agent targeting (Claude Code), single vs multi-agent setup, subagent usage, and standards injection method (file references vs skills)

### Advanced Features
- **Test Case Generation:** `/generate-testcases` command creates functional, regression, API, integration, negative, and boundary test cases from analyzed requirements, formatted for Testmo/Jira import
- **Bug Reporting Framework:** Structured bug reporting standards with severity rules, templates, analysis checklists, and evidence formats ensuring consistent, professional bug documentation
- **Multi-Agent Architecture:** Optional subagent system with specialized roles (product-planner, requirement-analyst, testcase-writer, bug-writer) for complex QA workflows when enabled via configuration
- **Integration Commands:** Jira and Testmo integration commands (in development) for automated test case export, bug creation, and ticket management directly from QA Agent OS workflows
