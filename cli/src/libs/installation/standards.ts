/**
 * Standards Installation
 * Handles installing standards files from profiles
 */

import { copyFile, joinPath } from '../../utils/files';
import { getProfileFiles } from '../profiles/profiles';
import type { InstallResult } from '../../types';

/**
 * Install standards files from profile to project
 */
export async function installStandards(
  baseDir: string,
  projectDir: string,
  profile: string,
  dryRun: boolean = false
): Promise<InstallResult> {
  const files = await getProfileFiles(baseDir, profile, 'standards');
  const installedFiles: string[] = [];

  for (const { relativePath, fullPath } of files) {
    if (relativePath.startsWith('standards/')) {
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
