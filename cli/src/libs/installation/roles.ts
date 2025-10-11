/**
 * Roles Installation
 * Handles installing role files from profiles
 */

import { copyFile, joinPath } from '../../utils/files';
import { getProfileFiles } from '../profiles/profiles';
import type { InstallResult } from '../../types';

/**
 * Install role files from profile to project
 */
export async function installRoles(
  baseDir: string,
  projectDir: string,
  profile: string,
  dryRun: boolean = false
): Promise<InstallResult> {
  const files = await getProfileFiles(baseDir, profile, 'roles');
  const installedFiles: string[] = [];

  for (const { relativePath, fullPath } of files) {
    if (relativePath.startsWith('roles/')) {
      const dest = joinPath(projectDir, 'agent-os', relativePath);

      if (!dryRun) {
        await copyFile(fullPath, dest);
      }

      installedFiles.push(dest);
    }
  }

  return {
    count: installedFiles.length,
    files: installedFiles,
  };
}
