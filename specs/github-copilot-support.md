# GitHub Copilot Support for Agent OS

## Overview

Add GitHub Copilot support to Agent OS by creating a setup script that configures Copilot-specific instruction files within individual repositories/projects, similar to the existing Cursor and Claude Code support.

## Technical Specifications

### File Structure
The setup will create the following structure in the target repository:

```
.github/
├── copilot-instructions.md          # Main Copilot configuration
└── instructions/                    # Agent OS instruction files
    ├── create-spec.instruction.md
    ├── execute-tasks.instruction.md
    ├── plan-product.instruction.md
    └── analyze-product.instruction.md
```

### Setup Script Requirements

**File**: `setup-github-copilot.sh`

**Location**: `/workspaces/agent-os/setup-github-copilot.sh`

**Functionality**:
- Check for Agent OS base installation
- Create `.github/instructions/` directory structure
- Download and configure Copilot-specific instruction files
- Setup main `.github/copilot-instructions.md` configuration file
- Provide clear feedback and next steps

### GitHub Copilot Configuration

**Main Configuration**: `.github/copilot-instructions.md`
- Contains project-specific Agent OS workflow instructions
- References instruction files in `.github/instructions/`
- Provides context about the Agent OS methodology
- Includes coding standards and best practices

**Instruction Files**: `.github/instructions/*.instruction.md`
- Adapted versions of base Agent OS commands for Copilot
- Optimized for Copilot's interaction model
- Include clear task breakdowns and technical specifications
- Follow GitHub's `.instruction.md` naming convention

## Task Breakdown

### Task 1: Create Setup Script Structure
**Estimated Time**: 30 minutes

Create `setup-github-copilot.sh` with:
- Shebang and error handling (`set -e`)
- Welcome message and branding
- Agent OS base installation check
- Directory creation logic

### Task 2: Implement Download Logic
**Estimated Time**: 45 minutes

Add functionality to:
- Download instruction files from GitHub repository
- Handle existing file conflicts (skip with warning)
- Provide progress feedback during downloads
- Error handling for network issues

### Task 3: Create Copilot Configuration File
**Estimated Time**: 60 minutes

Develop `.github/copilot-instructions.md` template that:
- Explains Agent OS methodology to Copilot
- References instruction files properly
- Includes project context and coding standards
- Provides clear workflow guidance

### Task 4: Adapt Instruction Files for Copilot
**Estimated Time**: 90 minutes

Create Copilot-optimized versions with `.instruction.md` extension:
- `plan-product.instruction.md` - Product planning workflow
- `create-spec.instruction.md` - Feature specification creation
- `execute-tasks.instruction.md` - Task execution guidance
- `analyze-product.instruction.md` - Product analysis workflow

Each file should:
- Use Copilot-friendly language and structure
- Include clear step-by-step instructions
- Reference Agent OS standards appropriately
- Provide examples and templates

### Task 5: Add Repository Detection
**Estimated Time**: 30 minutes

Implement logic to:
- Detect if running inside a Git repository
- Verify `.github/` directory exists or can be created
- Provide appropriate error messages for invalid contexts

### Task 6: Testing and Documentation
**Estimated Time**: 45 minutes

- Test script in various repository contexts
- Verify file downloads and permissions
- Create usage documentation
- Test integration with existing Agent OS workflows

## Implementation Details

### Script Requirements
- Bash compatibility (Ubuntu 24.04.2 LTS)
- Use `curl` for file downloads
- Handle missing dependencies gracefully
- Provide clear success/failure feedback

### File Download Strategy
- Base URL: `https://raw.githubusercontent.com/buildermethods/agent-os/main`
- Download paths:
  - `/github-copilot/copilot-instructions.md` → `.github/copilot-instructions.md`
  - `/github-copilot/instructions/*.instruction.md` → `.github/instructions/*.instruction.md`

### Error Handling
- Network connectivity issues
- Permission problems
- Missing Git repository
- Existing file conflicts

## Success Criteria

1. **Setup Script Functionality**
   - Successfully creates directory structure
   - Downloads all required files
   - Handles errors gracefully
   - Provides clear user feedback

2. **Copilot Integration**
   - Instructions are properly formatted for Copilot
   - References to Agent OS workflows work correctly
   - Coding standards are clearly communicated
   - Follows GitHub's `.instruction.md` naming convention

3. **User Experience**
   - Simple one-command setup
   - Clear next steps provided
   - Consistent with existing setup scripts

4. **Compatibility**
   - Works in any Git repository
   - Doesn't conflict with existing GitHub configurations
   - Compatible with Agent OS base installation

## Future Considerations

- Integration with GitHub Actions workflows
- Support for team-specific configurations
- Automatic updates for instruction files
- Integration with GitHub Copilot Chat features

## Dependencies

- Agent OS base installation
- Git repository context
- Network connectivity for downloads
- Write permissions in target directory

## Files to Create

1. `setup-github-copilot.sh` - Main setup script
2. `github-copilot/copilot-instructions.md` - Copilot configuration template
3. `github-copilot/instructions/plan-product.instruction.md` - Product planning for Copilot
4. `github-copilot/instructions/create-spec.instruction.md` - Spec creation for Copilot
5. `github-copilot/instructions/execute-tasks.instruction.md` - Task execution for Copilot
6. `github-copilot/instructions/analyze-product.instruction.md` - Product analysis for Copilot

## Integration Points

- Must reference existing Agent OS standards in `~/.agent-os/standards/`
- Should maintain consistency with Cursor and Claude Code setups
- Needs to work with existing Agent OS base workflows
- Follow GitHub Copilot's instruction file conventions

## Notes

- Corrected file extensions to use `.instruction.md` as per GitHub's documentation
- Main configuration file remains `.github/copilot-instructions.md`
- Individual instruction files use `.instruction.md` extension for proper Copilot recognition
