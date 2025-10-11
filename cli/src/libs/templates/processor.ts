/**
 * Template Processing
 * Handles template variable replacement and compilation
 */

import type { Role } from '../../types';

/**
 * Process template placeholders in content
 */
export function processTemplate(content: string, replacements: Record<string, string>): string {
  let processed = content;

  for (const [key, value] of Object.entries(replacements)) {
    const pattern = new RegExp(`\\{\\{${key}\\}\\}`, 'g');
    processed = processed.replace(pattern, value);
  }

  return processed;
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
  };
}
