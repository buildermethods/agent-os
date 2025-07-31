# Product Analysis for GitHub Copilot

## Purpose
Analyze an existing codebase to understand its current state, then establish Agent OS documentation and workflows. This sets up systematic development practices for ongoing work.

## When to Use
- Working with an existing codebase for the first time
- Need to understand current product state and progress
- Setting up Agent OS workflows in an established project
- Onboarding to a project without clear documentation

## What This Creates
- `@.agent-os/product/mission-lite.md` - Inferred product purpose and goals
- `@.agent-os/product/tech-stack.md` - Documented technology choices
- `@.agent-os/product/roadmap.md` - Current state and suggested next steps
- `@.agent-os/product/decisions.md` - Documented architectural decisions
- Analysis summary of current implementation

## Step-by-Step Process

### 1. Codebase Structure Analysis

Examine the project to understand:

#### Project Organization
- Directory structure and organization patterns
- File naming conventions
- Module/component structure
- Configuration file locations

#### Technology Stack
- Programming language and version
- Frameworks and libraries (check package.json, requirements.txt, etc.)
- Database systems and ORMs
- Build tools and deployment configuration
- Testing frameworks

#### Implementation Status
- Completed features and functionality
- Work in progress indicators
- Authentication/authorization implementation
- API endpoints and data models
- Database schema and migrations

### 2. Feature Inventory

Document what exists:

#### Completed Features
- User-facing functionality
- Admin/management features
- Integration capabilities
- Performance optimizations

#### Technical Infrastructure
- Authentication system
- Database design
- API architecture
- Testing coverage
- Deployment pipeline

#### Incomplete or Missing Elements
- TODO comments and planned features
- Broken or incomplete functionality
- Missing tests or documentation
- Technical debt areas

### 3. Generate Product Documentation

Create Agent OS product files based on analysis:

#### A. Mission Document (`mission-lite.md`)
Based on codebase analysis, create:
- Inferred product purpose and value proposition
- Target user types (from UI/UX patterns)
- Core feature set (from implemented functionality)
- Success metrics (business logic indicators)

#### B. Tech Stack Document (`tech-stack.md`)
Document discovered technologies:
- Language and framework choices with versions
- Database and data storage decisions
- Third-party services and integrations
- Development and deployment tools
- Rationale for technology choices (where apparent)

#### C. Current Roadmap (`roadmap.md`)
Based on current state:
- **Phase 1 (Completed)**: List implemented features
- **Phase 2 (In Progress)**: Identify work in progress
- **Phase 3 (Planned)**: Suggest logical next features
- **Future Considerations**: Areas for improvement

#### D. Decisions Log (`decisions.md`)
Document architectural decisions found:
- Database design choices
- Framework selection rationale
- Authentication approach
- API design patterns
- Testing strategy

### 4. Gap Analysis

Identify areas needing attention:

#### Technical Gaps
- Missing tests or low coverage
- Security vulnerabilities
- Performance bottlenecks
- Code quality issues
- Documentation gaps

#### Feature Gaps
- Incomplete user workflows
- Missing admin functionality
- Integration opportunities
- User experience improvements

#### Infrastructure Gaps
- Deployment automation
- Monitoring and logging
- Backup and recovery
- Development environment setup

### 5. Recommendations Summary

Provide actionable next steps:

#### Immediate Priorities
- Critical bugs or security issues
- Incomplete core features
- Essential testing or documentation

#### Short-term Enhancements
- User experience improvements
- Feature completions
- Technical debt reduction

#### Long-term Opportunities
- New feature development
- Architecture improvements
- Scaling considerations

## Analysis Template

Use this structure for analysis documentation:

```markdown
# Product Analysis Summary

## Current State
- **Product Stage**: [MVP/Beta/Production/etc.]
- **Core Functionality**: [What works well]
- **User Base**: [If known/inferred]

## Technology Assessment
- **Stack Maturity**: [Modern/Legacy/Mixed]
- **Code Quality**: [High/Medium/Low with specifics]
- **Test Coverage**: [Percentage and quality]
- **Documentation**: [Complete/Partial/Missing]

## Feature Completeness
### Completed ✅
- [Feature 1 with brief description]
- [Feature 2 with brief description]

### In Progress 🔄
- [Feature 1 with status]
- [Feature 2 with status]

### Planned 📋
- [Suggested feature 1]
- [Suggested feature 2]

## Recommended Next Steps
1. **Priority 1**: [Most important action]
2. **Priority 2**: [Second most important]
3. **Priority 3**: [Third priority]
```

## Quality Checklist

Before completing analysis:
- [ ] All major directories and files examined
- [ ] Technology stack fully documented
- [ ] Feature inventory is comprehensive
- [ ] Product documents created
- [ ] Clear next steps identified
- [ ] Gaps and opportunities noted

## Common Patterns to Look For

### Code Organization
- MVC or similar architectural patterns
- Component-based structure
- Service/utility organization
- Configuration management

### Data Patterns
- Database schema design
- API endpoint structure
- Data validation approaches
- Relationship modeling

### User Experience
- Authentication flows
- Navigation patterns
- Form handling
- Error management

## Next Steps After Analysis

1. **Review findings** with team/stakeholders
2. **Prioritize gaps** based on business impact
3. **Create specifications** for next features using `@.github/instructions/create-spec.instruction.md`
4. **Begin implementation** using `@.github/instructions/execute-tasks.instruction.md`

## Integration with Agent OS

Product analysis establishes the foundation for:
- **Informed specifications**: Based on existing patterns
- **Consistent development**: Following established conventions
- **Strategic planning**: Building on current progress
- **Quality maintenance**: Addressing technical debt

This analysis becomes the baseline for all future Agent OS workflows and ensures new development aligns with existing codebase patterns and business goals.
