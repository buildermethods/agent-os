/**
 * Template Processing
 * Handles template variable replacement and compilation
 */

import type { Role } from '../../types';
import { joinPath, fileExists } from '../../utils/files';
import { globSync } from 'glob';
import { readFileSync } from 'fs';

/**
 * Process template placeholders in content, including file includes
 */
export async function processTemplate(
  content: string,
  replacements: Record<string, string>,
  baseDir?: string,
  profile?: string
): Promise<string> {
  let processed = content;

  // First, handle conditionals
  processed = processConditionals(processed, replacements);

  // Then, handle file includes if baseDir and profile are provided
  if (baseDir && profile) {
    processed = await processFileIncludes(processed, baseDir, profile);
  }

  // Finally handle simple variable replacements
  for (const [key, value] of Object.entries(replacements)) {
    const pattern = new RegExp(`\\{\\{${key}\\}\\}`, 'g');
    processed = processed.replace(pattern, value);
  }

  return processed;
}

/**
 * Process conditional statements like {{if variable contains "value"}}...{{endif}}
 */
function processConditionals(content: string, replacements: Record<string, string>): string {
  let processed = content;

  // Match {{if condition}}...{{endif}} blocks
  const conditionalPattern = /\{\{if\s+([^}]+)\}\}([\s\S]*?)\{\{endif\}\}/g;

  processed = processed.replace(conditionalPattern, (match, condition, contentBlock) => {
    const trimmedCondition = condition.trim();

    // Evaluate the condition
    if (evaluateCondition(trimmedCondition, replacements)) {
      return contentBlock;
    } else {
      return '';
    }
  });

  return processed;
}

/**
 * Evaluate a conditional expression
 * Supports: "variable contains value", "variable equals value", "variable"
 */
function evaluateCondition(condition: string, replacements: Record<string, string>): boolean {
  // Handle "contains" operator: variable contains "value"
  const containsMatch = condition.match(/^(\w+)\s+contains\s+"([^"]+)"$/);
  if (containsMatch) {
    const [, variable, value] = containsMatch;
    const variableValue = replacements[variable] || '';
    return variableValue.includes(value);
  }

  // Handle "equals" operator: variable equals "value"
  const equalsMatch = condition.match(/^(\w+)\s+equals\s+"([^"]+)"$/);
  if (equalsMatch) {
    const [, variable, value] = equalsMatch;
    const variableValue = replacements[variable] || '';
    return variableValue === value;
  }

  // Handle simple variable existence check: variable
  const simpleMatch = condition.match(/^(\w+)$/);
  if (simpleMatch) {
    const [, variable] = simpleMatch;
    const variableValue = replacements[variable];
    return !!variableValue && variableValue !== 'false' && variableValue !== '0';
  }

  // If no pattern matches, return false
  console.warn(`Unknown conditional expression: ${condition}`);
  return false;
}

/**
 * Process file include patterns like {{workflows/path}} and {{standards/*}}
 * Recursively processes nested includes
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

  let processed = content;

  // Match patterns like {{workflows/...}} and {{standards/*}}
  const includePattern = /\{\{(workflows|standards)\/([^}]+)\}\}/g;
  const matches = [...content.matchAll(includePattern)];

  if (matches.length === 0) {
    return processed;
  }

  for (const match of matches) {
    const [fullMatch, category, path] = match;
    const profilePath = joinPath(baseDir, 'profiles', profile);

    if (path.includes('*')) {
      // Handle glob patterns (e.g., standards/*)
      const globPattern = joinPath(profilePath, category, path.replace('*', '**/*.md'));
      const files = globSync(globPattern);

      let includedContent = '';
      for (const file of files) {
        if (await fileExists(file)) {
          const fileContent = readFileSync(file, 'utf-8');
          includedContent += `\n\n${fileContent}\n`;
        }
      }

      processed = processed.replace(fullMatch, includedContent.trim());
    } else {
      // Handle specific file includes (e.g., workflows/specification/research-spec)
      const filePath = joinPath(profilePath, category, `${path}.md`);

      if (await fileExists(filePath)) {
        const fileContent = readFileSync(filePath, 'utf-8');
        processed = processed.replace(fullMatch, fileContent);
      } else {
        // Leave the placeholder if file doesn't exist
        console.warn(`Template include file not found: ${filePath}`);
      }
    }
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
