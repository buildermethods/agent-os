# BRD Analysis Standard

When analyzing Business Requirement Documents (BRD) or Product Requirement Documents (PRD), follow this structure to ensure comprehensive QA coverage.

## 1. Feature Overview
- **Summary**: One-sentence description of the feature.
- **Goal**: What user problem does this solve?

## 2. Risk Analysis
Identify risks in the following categories:
- **Functional Risk**: Complexity of logic, edge cases.
- **Integration Risk**: Dependencies on other systems/APIs.
- **Performance Risk**: Load, latency, data volume concerns.
- **Security Risk**: Auth, data privacy, injection vulnerabilities.

## 3. Clarification Questions
List questions for the Product Owner/Developer.
- **Format**: `[ID] Question? (Context/Reason)`
- *Example*: `[Q1] What happens if the user loses internet connection during the transaction? (Edge case)`

## 4. QA Breakdown
Decompose the feature into testable areas.
- **Area 1**: [Name]
  - *Scenario*: [Description]
  - *Scenario*: [Description]
