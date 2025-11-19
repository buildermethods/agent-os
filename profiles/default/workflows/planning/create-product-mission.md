Create `qa-agent-os/product/mission.md` with comprehensive product definition following this structure for its' content:

#### Mission Structure:
```markdown
# Product Mission

## Pitch
[PRODUCT_NAME] is a [PRODUCT_TYPE] that helps [TARGET_USERS] [SOLVE_PROBLEM]
by providing [KEY_VALUE_PROPOSITION].

## Users

### Primary Customers
- [CUSTOMER_SEGMENT_1]: [DESCRIPTION]
- [CUSTOMER_SEGMENT_2]: [DESCRIPTION]

### User Personas
**[USER_TYPE]** ([AGE_RANGE])
- **Role:** [JOB_TITLE/CONTEXT]
- **Context:** [BUSINESS/PERSONAL_CONTEXT]
- **Pain Points:** [SPECIFIC_PROBLEMS]
- **Goals:** [DESIRED_OUTCOMES]

## The Problem

### [PROBLEM_TITLE]
[PROBLEM_DESCRIPTION]. [QUANTIFIABLE_IMPACT].

**Our Solution:** [SOLUTION_APPROACH]

## Differentiators

### [DIFFERENTIATOR_TITLE]
Unlike [COMPETITOR/ALTERNATIVE], we provide [SPECIFIC_ADVANTAGE].
This results in [MEASURABLE_BENEFIT].

## Key Features

### Core Features
- **[FEATURE_NAME]:** [USER_BENEFIT_DESCRIPTION]

### Collaboration Features
- **[FEATURE_NAME]:** [USER_BENEFIT_DESCRIPTION]

### Advanced Features
- **[FEATURE_NAME]:** [USER_BENEFIT_DESCRIPTION]

## Product Areas & Team Ownership

| Team / Squad | Domain | Responsibilities | Notes |
|--------------|--------|------------------|-------|
| Cows | Investments flows (example) | [WHAT THEY OWN] | [Escalation notes / SME] |
| Chicks | Cards & Onboarding (example) | [WHAT THEY OWN] | [Escalation notes / SME] |
| [TEAM_NAME] | [PRODUCT_AREA] | [KEY RESPONSIBILITIES] | [DEPENDENCIES / RUNBOOKS] |

## Epic & Ticket Alignment
- **Primary Epics:** [List active/ upcoming epics or initiatives that live under this mission]
- **Example Tickets:** [Ticket IDs or themes that will likely run through this mission]
- **Cross-Team Dependencies:** [Any shared components, APIs, or workflows to track]
```

#### Directory Creation

Before creating the mission.md file, ensure the directory exists:

```bash
# Create the qa-agent-os/product directory if it doesn't exist
mkdir -p qa-agent-os/product
```

#### Important Constraints

- **Focus on user benefits** in feature descriptions, not technical details
- **Keep it concise** and easy for users to scan and get the more important concepts quickly
