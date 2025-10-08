# Content Mapping Pattern

## Problem Statement

When building features that reference external content (images, data files, documents, media, datasets), the specification process often fails to capture these artifacts. This leads to:

1. **Missing References**: Implementation doesn't know what content exists or where it's located
2. **Incorrect Paths**: Developers guess file paths, leading to broken references
3. **Lost Context**: Content descriptions and usage instructions are not documented
4. **Manual Workarounds**: Creating ad-hoc content files after spec creation

## Solution: Content Mapping Sub-Spec

Similar to `database-schema.md` and `api-spec.md`, we introduce `content-mapping.md` as a conditional sub-spec that:

- Documents all external content referenced by the feature
- Provides exact file paths and names
- Describes content purpose and usage
- Prevents incorrect references during implementation
- Loads automatically during task execution

## When to Use Content Mapping

Create a content-mapping.md when the feature requires:

### Static Content
- **Images**: logos, icons, illustrations, photos, diagrams
- **Media**: videos, audio files, animations
- **Documents**: PDFs, markdown files, text content
- **Data Files**: JSON, CSV, XML, YAML configuration

### Dynamic Content
- **Datasets**: seed data, sample data, test fixtures
- **Templates**: email templates, document templates
- **Content Structures**: page layouts, component content
- **Copy/Text**: marketing copy, UI text, help documentation

### External Resources
- **Third-party Assets**: fonts, libraries, frameworks
- **API Data**: external API responses to integrate
- **Content Sources**: CMS content, database dumps

## Content Mapping Structure

### File Location
```
.agent-os/specs/YYYY-MM-DD-spec-name/
├── spec.md
├── spec-lite.md
└── sub-specs/
    ├── technical-spec.md
    ├── content-mapping.md      # ← New conditional sub-spec
    ├── database-schema.md      (conditional)
    └── api-spec.md             (conditional)
```

### Template Structure

```markdown
# Content Mapping

This document maps all external content referenced by the spec detailed in @.agent-os/specs/YYYY-MM-DD-spec-name/spec.md

## Overview

[Brief description of what content is needed and why]

## Content Categories

### [CATEGORY_NAME]

#### Purpose
[What this content is used for in the feature]

#### Content Items

**[ITEM_NAME]**
- **Path**: `[EXACT_FILE_PATH]`
- **Type**: [FILE_TYPE]
- **Description**: [WHAT_IT_CONTAINS]
- **Usage**: [HOW_TO_USE_IN_IMPLEMENTATION]
- **Dimensions/Size**: [IF_APPLICABLE]
- **Reference Name**: `[EXACT_NAME_TO_USE_IN_CODE]`

## Implementation Guidelines

### File Path References
[Instructions on how to reference these files in code]

### Content Processing
[Any transformations, optimizations, or processing needed]

### Validation Rules
[How to verify content is correctly integrated]

## Content Checklist

- [ ] All content files exist at specified paths
- [ ] File formats match specifications
- [ ] Content is optimized for production
- [ ] References use exact names from this mapping
```

## Example: Website Content Mapping

```markdown
# Content Mapping

This document maps all external content referenced by the spec detailed in @.agent-os/specs/2025-03-15-product-landing-page/spec.md

## Overview

This landing page requires hero images, product screenshots, team photos, and marketing copy to be integrated from existing assets.

## Content Categories

### Hero Section

#### Purpose
Display main hero image with overlay text for landing page above-the-fold content.

#### Content Items

**Hero Background Image**
- **Path**: `public/images/hero/main-background.jpg`
- **Type**: JPEG image
- **Description**: Full-width hero background showing product in use
- **Usage**: Background image for hero section
- **Dimensions**: 1920x1080px (16:9 aspect ratio)
- **Reference Name**: `heroBackground`

**Hero Logo**
- **Path**: `public/images/logos/company-logo-white.svg`
- **Type**: SVG vector
- **Description**: Company logo in white for dark hero background
- **Usage**: Display in top-left of hero section
- **Dimensions**: SVG (scalable)
- **Reference Name**: `companyLogoWhite`

### Product Screenshots

#### Purpose
Showcase product features in the features section with annotated screenshots.

#### Content Items

**Dashboard Screenshot**
- **Path**: `public/images/features/dashboard-screenshot.png`
- **Type**: PNG image
- **Description**: Main dashboard view showing analytics
- **Usage**: Feature card #1 image
- **Dimensions**: 800x600px
- **Reference Name**: `dashboardFeatureImage`

**Settings Screenshot**
- **Path**: `public/images/features/settings-screenshot.png`
- **Type**: PNG image
- **Description**: Settings panel with configuration options
- **Usage**: Feature card #2 image
- **Dimensions**: 800x600px
- **Reference Name**: `settingsFeatureImage`

### Team Section

#### Purpose
Display team member photos and bios in About section.

#### Content Items

**Team Photos**
- **Path**: `public/images/team/[member-name].jpg`
- **Type**: JPEG images (multiple)
- **Description**: Professional headshots of team members
- **Usage**: Team member cards
- **Dimensions**: 400x400px (1:1 square)
- **Reference Names**:
  - `teamJohnDoe` (john-doe.jpg)
  - `teamJaneSmith` (jane-smith.jpg)
  - `teamBobJohnson` (bob-johnson.jpg)

### Marketing Copy

#### Purpose
Pre-written marketing text for various sections.

#### Content Items

**Copy Document**
- **Path**: `content/marketing/landing-page-copy.md`
- **Type**: Markdown document
- **Description**: All marketing copy organized by section
- **Usage**: Import and display in respective sections
- **Reference Name**: `landingPageCopy`

**Structure**:
```yaml
hero:
  headline: "Transform Your Workflow"
  subheadline: "Streamline operations with AI-powered automation"
features:
  - title: "Real-time Analytics"
    description: "Get instant insights into your data"
  - title: "Smart Automation"
    description: "Automate repetitive tasks effortlessly"
```

## Implementation Guidelines

### File Path References

All paths are relative to project root. Use the following import pattern:

```typescript
// Images
import heroBackground from '@/public/images/hero/main-background.jpg'
import companyLogoWhite from '@/public/images/logos/company-logo-white.svg'

// Content
import landingPageCopy from '@/content/marketing/landing-page-copy.md'
```

### Content Processing

1. **Image Optimization**: All images should be processed through Next.js Image component for optimization
2. **Responsive Images**: Use srcset for different screen sizes
3. **Lazy Loading**: Apply lazy loading to below-fold images
4. **Alt Text**: Derive from content descriptions in this mapping

### Validation Rules

1. Verify all file paths exist before deployment
2. Check image dimensions match specifications
3. Validate copy structure matches expected YAML schema
4. Ensure all reference names are used consistently in code

## Content Checklist

- [x] All content files exist at specified paths
- [x] File formats match specifications (JPEG, PNG, SVG, MD)
- [x] Images are optimized (compressed, correct dimensions)
- [ ] Content is integrated using exact reference names
- [ ] All images have appropriate alt text
```

## Integration with Agent OS Workflow

### 1. During Spec Creation (`/create-spec`)

**New Step 10.5: Content Mapping Detection (Conditional)**

```
ACTION: Detect if external content is referenced
CHECK: User description mentions:
  - Images, photos, graphics, icons
  - Data files, JSON, CSV, datasets
  - Documents, PDFs, markdown files
  - Media, videos, audio
  - Templates, content structures

IF content_referenced OR user_provides_content_files:
  ASK: "This feature references external content. Please provide:
        1. List of content files/directories
        2. Purpose of each content item
        3. Where content is currently located"

  WAIT: For user response

  ACTION: Use file-creator subagent
  CREATE: sub-specs/content-mapping.md
  TEMPLATE: Use content-mapping template
  POPULATE: With user-provided content information

  NOTE: Reference content-mapping.md in spec.md
ELSE:
  SKIP: Content mapping step
```

### 2. During Task Execution (`/execute-tasks`)

**Update Step 7.3: Batched Context Retrieval**

Add content-mapping to conditional context loading:

```
ACTION: Check if .agent-os/specs/[SPEC]/sub-specs/content-mapping.md exists

IF content-mapping.md exists:
  MANDATORY: Include in batched context request

  FROM content-mapping.md:
  - All content item paths and reference names
  - Content usage guidelines
  - Implementation instructions
  - Validation rules

  REASON: Prevents incorrect file paths and names
```

**New Step 7.3.6: Verify Content References (MANDATORY if content-mapping exists)**

```
IF content-mapping.md exists:

  ACTION: Create content reference sheet

  EXTRACT AND NOTE:
  1. File paths (exact, relative to project root)
  2. Reference names to use in code
  3. File types and dimensions
  4. Import patterns from implementation guidelines

  VALIDATION GATE:
  - ✓ Do NOT guess file paths or names
  - ✓ Do NOT write code until paths verified
  - ✓ Use exact reference names from mapping
  - ✓ Follow import patterns from guidelines
  - HALT if critical content missing or paths ambiguous
```

### 3. During Debugging (`/debug`)

**Update Step 3: Issue Information Gathering**

Add content-mapping to context gathering:

```
IF scope == "task" OR scope == "spec":
  CHECK: .agent-os/specs/[SPEC]/sub-specs/content-mapping.md

  IF exists:
    READ: Content mapping
    NOTE: Content references for debugging context

    IF issue_involves_missing_files OR broken_references:
      VERIFY: Actual file paths match content-mapping
      CHECK: Reference names used correctly in code
```

### 4. Context Fetcher Subagent Update

Add content-mapping to batched retrieval capabilities:

```
FROM .agent-os/specs/[SPEC]/sub-specs/content-mapping.md (if exists):
- Content item paths and reference names
- Implementation guidelines
- Validation rules

RETURN as structured 'Content References' section for easy lookup
```

## Benefits

### 1. Prevents Implementation Errors
- No guessing file paths or content locations
- Exact reference names documented upfront
- Clear import patterns provided

### 2. Improves Spec Completeness
- All external dependencies documented
- Content requirements clear before implementation
- Prevents "missing assets" during development

### 3. Enables Validation
- Checklist for content integration
- Verification steps defined
- Quality gates before deployment

### 4. Streamlines Workflow
- Auto-loads during task execution
- Part of standard context retrieval
- No manual content hunting

### 5. Knowledge Transfer
- New developers understand content structure
- Content purpose documented
- Usage patterns clear

## Use Case Examples

### Example 1: E-commerce Product Pages
```yaml
Content Categories:
  - Product images (hero, gallery, thumbnails)
  - Product data (JSON with specs, pricing)
  - Related products dataset
  - Marketing copy (descriptions, features)
  - Brand assets (logos, badges, certifications)
```

### Example 2: Documentation Site
```yaml
Content Categories:
  - Markdown documentation files
  - Code examples (snippets, demos)
  - Diagrams and flowcharts
  - Tutorial videos
  - API reference data
```

### Example 3: Portfolio Website
```yaml
Content Categories:
  - Project screenshots
  - Case study PDFs
  - Client logos
  - Testimonial data
  - Contact information
```

### Example 4: Data Visualization Dashboard
```yaml
Content Categories:
  - Sample datasets (CSV, JSON)
  - Chart configuration files
  - Color scheme definitions
  - Icon set
  - Data transformation rules
```

## Migration for Existing Projects

### If Content Mapping Doesn't Exist

1. **Identify Content Needs**
   - Review spec for content references
   - List all external files needed
   - Document current locations

2. **Create Content Mapping Manually**
   ```bash
   # Create file
   touch .agent-os/specs/[SPEC]/sub-specs/content-mapping.md

   # Use template from this document
   # Fill in content items
   ```

3. **Update Spec Reference**
   - Add reference in spec.md: "Content requirements documented in @sub-specs/content-mapping.md"

4. **Verify Implementation**
   - Check code uses paths from content-mapping
   - Update any hardcoded paths to match mapping
   - Validate all content exists

### Future Enhancement Ideas

1. **Content Validation Tool**: Script to verify all content-mapping paths exist
2. **Content Generator**: Auto-create placeholder content for development
3. **Content Inventory**: Track content across all specs
4. **Content Versioning**: Document content updates and changes
5. **Content Optimization**: Auto-optimize images, compress files

## Summary

The content-mapping pattern provides:

- ✅ Structured external content documentation
- ✅ Exact file paths and reference names
- ✅ Implementation guidelines
- ✅ Auto-loading during task execution
- ✅ Prevention of broken references
- ✅ Clear validation criteria
- ✅ Improved spec completeness

By treating external content as a first-class concern in specifications, we prevent common implementation errors and ensure all required assets are documented before development begins.
