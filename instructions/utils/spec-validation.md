---
description: General specification validation utilities for any project type
globs:
alwaysApply: false
version: 1.0
encoding: UTF-8
---

# Specification Validation Utilities

## Overview

Generic validation utilities to ensure implementation compliance with project specifications across any domain.

## Pre-Implementation Validation

<approach_validation>
  <specification_checklist>
    Before implementing any feature:
    
    ✓ Relevant specifications identified and read
    ✓ Implementation approach documented
    ✓ Expected inputs/outputs defined
    ✓ Success criteria from specs established
    ✓ Edge cases from specs identified
    ✓ Integration points verified against specs
  </specification_checklist>
  
  <validation_questions>
    ASK before coding:
    1. Does this approach align with architectural specifications?
    2. Are all specification requirements addressed?
    3. Do expected outputs match spec definitions?
    4. Are interfaces and contracts correctly implemented?
    5. Will this handle edge cases mentioned in specs?
  </validation_questions>
</approach_validation>

## Post-Implementation Validation

<output_validation>
  <generic_compliance_checks>
    After implementation, verify:
    
    ✓ Functionality matches specification descriptions
    ✓ Output format follows specified structure
    ✓ Error handling covers specified scenarios
    ✓ Integration points work as documented
    ✓ Performance meets specified criteria
    ✓ Security requirements from specs are met
  </generic_compliance_checks>
  
  <anomaly_detection>
    RED FLAGS for any project type:
    - Behavior contradicts documented requirements
    - Missing functionality described in specifications
    - Error messages don't match spec requirements
    - Integration failures with specified systems
    - Performance significantly below spec expectations
  </anomaly_detection>
</output_validation>

## Validation Process

<validation_steps>
  1. **Reference Check**: Confirm all spec sections consulted
  2. **Requirement Coverage**: Verify every spec requirement addressed  
  3. **Behavior Validation**: Test implementation against spec examples
  4. **Integration Testing**: Validate against interface specifications
  5. **Edge Case Testing**: Test scenarios defined in specifications
  6. **Acceptance Criteria**: Confirm all spec acceptance criteria met
</validation_steps>

## Documentation Requirements

<compliance_documentation>
  For each task, document:
  - Specifications consulted (files and sections)
  - Requirements extracted from specs
  - How implementation addresses each requirement
  - Validation results against spec criteria
  - Any deviations and their justifications
</compliance_documentation>