/**
 * Role File Operations
 * Handles saving role configurations to files
 */

import { dump } from 'js-yaml';
import { joinPath, ensureDir } from '../../utils/files';
import { printSuccess } from '../../utils/colors';
import type { RoleConfiguration } from './types';

/**
 * Build YAML content from role configuration
 */
function buildConfigYaml(config: RoleConfiguration): string {
  const yamlObject: Record<string, any> = {
    type: config.type,
    description: config.description,
    your_role: config.yourRole,
    tools: config.tools,
    model: config.model,
    color: config.color,
  };

  if (config.areasOfResponsibility.length > 0) {
    yamlObject.areas_of_responsibility = config.areasOfResponsibility;
  }

  if (config.exampleAreasOutsideOfResponsibility.length > 0) {
    yamlObject.example_areas_outside_of_responsibility = config.exampleAreasOutsideOfResponsibility;
  }

  if (config.standards.length > 0) {
    yamlObject.standards = config.standards;
  }

  if (config.verifiedBy && config.verifiedBy.length > 0) {
    yamlObject.verified_by = config.verifiedBy;
  }

  return dump(yamlObject, { lineWidth: -1, noRefs: true });
}

/**
 * Save role configuration to file
 */
export async function saveRoleConfiguration(
  profilePath: string,
  config: RoleConfiguration
): Promise<void> {
  const rolePath = joinPath(profilePath, 'roles', config.id);
  await ensureDir(rolePath);

  const configContent = buildConfigYaml(config);
  await Bun.write(joinPath(rolePath, 'config.yml'), configContent);

  printSuccess(`Role configuration saved to: ${rolePath}/config.yml`);
}
