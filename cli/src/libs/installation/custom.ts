/**
 * Custom Files Installation
 * Handles copying custom files from profile's custom folder to project root
 */

import { copyFile, joinPath, fileExists } from '../../utils/files';
import { getProfileFiles } from '../profiles/profiles';
import type { InstallResult } from '../../types';

/**
 * Install custom files from profile to project root
 * Copies everything from profiles/{profile}/custom/ to the project root
 */
export async function installCustomFiles(
  baseDir: string,
  projectDir: string,
  profile: string,
  dryRun: boolean = false
): Promise<InstallResult> {
  const files = await getProfileFiles(baseDir, profile, 'custom');
  const installedFiles: string[] = [];

  for (const { relativePath, fullPath } of files) {
    if (relativePath.startsWith('custom/')) {
      // Remove 'custom/' prefix to get the destination path
      const destRelativePath = relativePath.substring('custom/'.length);
      const dest = joinPath(projectDir, destRelativePath);

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
