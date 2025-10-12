/**
 * Template Processing
 * Handles template variable replacement and compilation using regex patterns
 * Processes in phases to avoid conflicts between different template types
 */

import type { Role } from '../../types';
import { joinPath, fileExists } from '../../utils/files';
import { globSync } from 'glob';

/**
 * Process template placeholders in content, including file includes
 * Processing order:
 * 1. File includes ({{path/to/file}})
 * 2. Conditionals ({{if condition}})
 * 3. Variables ({{variable}})
 */
export async function processTemplate(
  content: string,
  replacements: Record<string, string>,
  baseDir?: string,
  profile?: string
): Promise<string> {
  let processed = content;

  // Phase 1: Handle file includes (must be first, contains /)
  if (baseDir && profile) {
    processed = await processFileIncludes(processed, baseDir, profile);
  }

  // Phase 2: Handle conditionals (contains 'if ')
  processed = processConditionals(processed, replacements);

  // Phase 3: Handle simple variable replacements (everything else)
  processed = processVariables(processed, replacements);

  return processed;
}

/**
 * Process conditional blocks
 * Supports:
 * - {{if variable}} - checks if variable is truthy
 * - {{if variable contains "value"}} - checks if variable contains substring
 * - {{if variable equals "value"}} - checks if variable equals value
 */
function processConditionals(
  content: string,
  replacements: Record<string, string>
): string {
  // Match {{if condition}}content{{endif}} blocks
  const conditionalPattern = /\{\{if\s+([^}]+?)\}\}([\s\S]*?)\{\{endif\}\}/g;

  return content.replace(conditionalPattern, (_match, condition, contentBlock) => {
    const trimmedCondition = condition.trim();

    // Check if condition is true
    if (evaluateCondition(trimmedCondition, replacements)) {
      return contentBlock;
    }
    return '';
  });
}

/**
 * Evaluate a conditional expression
 */
function evaluateCondition(
  condition: string,
  replacements: Record<string, string>
): boolean {
  // Pattern: "variable contains 'value'" or 'variable contains "value"'
  const containsMatch = condition.match(/^(\w+)\s+contains\s+["']([^"']+)["']$/);
  if (containsMatch) {
    const [, variable, value] = containsMatch;
    const variableValue = replacements[variable] || '';
    return typeof variableValue === 'string' && variableValue.includes(value);
  }

  // Pattern: "variable equals 'value'" or 'variable equals "value"'
  const equalsMatch = condition.match(/^(\w+)\s+equals\s+["']([^"']+)["']$/);
  if (equalsMatch) {
    const [, variable, value] = equalsMatch;
    const variableValue = replacements[variable] || '';
    return variableValue === value;
  }

  // Pattern: "variable" (simple truthiness check)
  const simpleMatch = condition.match(/^(\w+)$/);
  if (simpleMatch) {
    const [, variable] = simpleMatch;
    const value = replacements[variable];
    // Treat 'false', '0', empty string, null, and undefined as falsy
    return !!value && value !== 'false' && value !== '0';
  }

  console.warn(`Unknown conditional expression: ${condition}`);
  return false;
}

/**
 * Process simple variable replacements
 * Matches {{variable}} patterns that are NOT file paths or conditionals
 */
function processVariables(
  content: string,
  replacements: Record<string, string>
): string {
  // Match {{word}} but NOT {{word/path}} or {{if word}}
  return content.replace(/\{\{(\w+)\}\}/g, (match, variable) => {
    return replacements[variable] !== undefined ? replacements[variable] : match;
  });
}

/**
 * Process file include patterns like {{workflows/path}} and {{standards/*}}
 * - paths starting with 'standards' are converted to file path references
 * - all other paths have their content expanded inline
 */
async function processFileIncludes(
  content: string,
  baseDir: string,
  profile: string,
  depth: number = 0
): Promise<string> {
  // Prevent infinite recursion
  if (depth > 10) {
    console.warn('Maximum template include depth reached');
    return content;
  }

  // Match patterns like {{workflows/...}} and {{standards/*}}
  // Only match patterns that contain a forward slash (file paths)
  const includePattern = /\{\{([\w\-\/\*]+)\}\}/g;
  const matches = [...content.matchAll(includePattern)];

  if (matches.length === 0) {
    return content;
  }

  // Collect all replacements with their positions
  type Replacement = {
    start: number;
    end: number;
    newContent: string;
  };
  const replacements: Replacement[] = [];

  for (const match of matches) {
    const [fullMatch, pathPattern] = match;
    const matchIndex = match.index!;

    // Skip if this doesn't actually contain a forward slash (not a file path)
    if (!pathPattern.includes('/')) {
      continue;
    }

    const profilePath = joinPath(baseDir, 'profiles', profile);

    // Check if this should be expanded or just referenced
    const shouldReference = pathPattern.startsWith('standards/');

    let newContent: string;

    if (pathPattern.includes('*')) {
      // Handle glob patterns (e.g., standards/* or workflows/*)
      const globPattern = joinPath(profilePath, pathPattern.replace('*', '**/*.md'));
      const files = globSync(globPattern);

      if (shouldReference) {
        // Generate file path references instead of embedding content
        const filePaths = files
          .sort((a, b) => {
            // Sort by directory depth (fewer slashes = more important/general)
            const depthA = (a.match(/\//g) || []).length;
            const depthB = (b.match(/\//g) || []).length;
            if (depthA !== depthB) return depthA - depthB;
            // Then alphabetically
            return a.localeCompare(b);
          })
          .map((file) => {
            // Extract relative path from profile directory
            const relativePath = file.replace(profilePath + '/', '');
            // Convert to agent-os project path with bullet point
            return `- agent-os/${relativePath}`;
          })
          .join('\n');

        newContent = filePaths;
      } else {
        // Expand content from all matching files
        const contents = await Promise.all(
          files.map(async (file) => {
            const fs = await import('fs/promises');
            return fs.readFile(file, 'utf-8');
          })
        );
        newContent = contents.join('\n\n');
      }
    } else {
      // Handle specific file includes (e.g., workflows/specification/research-spec)
      const filePath = joinPath(profilePath, `${pathPattern}.md`);

      if (await fileExists(filePath)) {
        if (shouldReference) {
          // Generate single file path reference with bullet point
          newContent = `- agent-os/${pathPattern}.md`;
        } else {
          // Expand file content inline
          const fs = await import('fs/promises');
          newContent = await fs.readFile(filePath, 'utf-8');
        }
      } else {
        // Leave the placeholder if file doesn't exist
        console.warn(`Template include file not found: ${filePath}`);
        continue;
      }
    }

    replacements.push({
      start: matchIndex,
      end: matchIndex + fullMatch.length,
      newContent,
    });
  }

  // Apply replacements in reverse order (from end to start)
  // This ensures that earlier replacements don't affect the positions of later ones
  let processed = content;
  for (let i = replacements.length - 1; i >= 0; i--) {
    const { start, end, newContent } = replacements[i];
    processed = processed.substring(0, start) + newContent + processed.substring(end);
  }

  // Recursively process any nested includes
  return await processFileIncludes(processed, baseDir, profile, depth + 1);
}

/**
 * Common template replacements for all files
 */
export function getCommonReplacements(config: {
  version: string;
  profile: string;
}): Record<string, string> {
  return {
    version: config.version,
    profile: config.profile,
  };
}

/**
 * Build role-specific template replacements
 */
export function buildRoleReplacements(role: Role): Record<string, string> {
  // Type guard to check if role is a Verifier
  const isVerifier = (r: Role): r is import('../../types').Verifier => {
    return 'verification_capabilities' in r;
  };

  return {
    id: role.id,
    description: role.description || '',
    your_role: role.your_role || '',
    tools: role.tools || '',
    model: role.model || '',
    color: role.color || '',
    areas_of_responsibility: role.areas_of_responsibility?.map((s) => `- ${s}`).join('\n') || '',
    example_areas_outside_of_responsibility:
      role.example_areas_outside_of_responsibility?.map((s) => `- ${s}`).join('\n') || '',
    implementer_standards:
      role.standards?.map((s: string) => `@agent-os/standards/${s}.md`).join('\n') || '',
    verifier_standards:
      role.standards?.map((s: string) => `@agent-os/standards/${s}.md`).join('\n') || '',
    verification_capabilities:
      isVerifier(role) && role.verification_capabilities
        ? role.verification_capabilities.join(', ')
        : '',
  };
}
