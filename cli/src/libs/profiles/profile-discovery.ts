/**
 * Profile Discovery
 * Functions for finding and listing profiles
 */

import { $ } from 'bun';
import * as clack from '@clack/prompts';
import { joinPath, fileExists } from '../../utils/files';
import { UserCancelledError } from '../../utils/errors';

/**
 * Get list of available profiles
 */
export async function getAvailableProfiles(profilesDir: string): Promise<string[]> {
  const profiles: string[] = [];

  try {
    const dirList = await $`ls -d ${profilesDir}/*`.text();
    const dirs = dirList.trim().split('\n').filter(Boolean);

    for (const dir of dirs) {
      const name = dir.split('/').pop();
      if (name) profiles.push(name);
    }
  } catch (error) {
    // Directory might be empty or not exist
  }

  return profiles;
}

/**
 * Prompt user to select a profile
 */
export async function selectProfile(profiles: string[]): Promise<string> {
  const options = profiles.map((p) => ({
    value: p,
    label: p,
  }));

  const profile = await clack.select({
    message: 'Select the profile for this role:',
    options,
  });

  if (clack.isCancel(profile)) {
    throw new UserCancelledError();
  }

  return profile as string;
}

/**
 * Get available standards for a profile
 */
export async function getAvailableStandards(profilePath: string): Promise<string[]> {
  const standards: string[] = [];
  const standardsDir = joinPath(profilePath, 'standards');

  if (!(await fileExists(standardsDir))) {
    return standards;
  }

  try {
    const result = await $`find ${standardsDir} -name "*.md"`.text();
    const files = result.trim().split('\n').filter(Boolean);

    for (const file of files) {
      const relativePath = file.replace(`${standardsDir}/`, '');
      standards.push(relativePath);
    }
  } catch (error) {
    // No standards found
  }

  return standards;
}

/**
 * Get available verifiers for a profile
 */
export async function getAvailableVerifiers(profilePath: string): Promise<string[]> {
  const verifiers: string[] = [];
  const rolesDir = joinPath(profilePath, 'roles');

  if (!(await fileExists(rolesDir))) {
    return verifiers;
  }

  try {
    const dirList = await $`ls -d ${rolesDir}/*`.text();
    const dirs = dirList.trim().split('\n').filter(Boolean);

    for (const dir of dirs) {
      const roleId = dir.split('/').pop();
      if (!roleId) continue;

      const configPath = joinPath(dir, 'config.yml');
      if (await fileExists(configPath)) {
        const content = await Bun.file(configPath).text();
        if (content.includes('type: verifier')) {
          verifiers.push(roleId);
        }
      }
    }
  } catch (error) {
    // No roles found
  }

  return verifiers;
}
