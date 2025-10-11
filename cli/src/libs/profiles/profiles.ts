/**
 * Profile Management
 * Handles profile file discovery and loading
 */

import { joinPath, fileExists } from '../../utils/files';
import { readdir } from 'fs/promises';
import { join } from 'path';
import type { ProfileFile } from '../../types';

/**
 * Get all files from a profile directory
 */
export async function getProfileFiles(
  baseDir: string,
  profile: string,
  subdir: string
): Promise<ProfileFile[]> {
  const searchDir = joinPath(baseDir, 'profiles', profile, subdir);

  if (!(await fileExists(searchDir))) {
    return [];
  }

  const files: ProfileFile[] = [];
  const entries = await readdir(searchDir, { withFileTypes: true, recursive: true });

  for (const entry of entries) {
    if (entry.isFile() && (entry.name.endsWith('.md') || entry.name.endsWith('.yml'))) {
      // Use parentPath or construct from search dir
      const fullPath = (entry as any).parentPath
        ? join((entry as any).parentPath, entry.name)
        : join(searchDir, entry.name);
      const relativePath = fullPath.replace(joinPath(baseDir, 'profiles', profile) + '/', '');
      files.push({ relativePath, fullPath });
    }
  }

  return files;
}

/**
 * Check if profile exists
 */
export async function profileExists(baseDir: string, profile: string): Promise<boolean> {
  const profileDir = joinPath(baseDir, 'profiles', profile);
  return await fileExists(profileDir);
}

/**
 * List all available profiles
 */
export async function listProfiles(baseDir: string): Promise<string[]> {
  const profilesDir = joinPath(baseDir, 'profiles');

  if (!(await fileExists(profilesDir))) {
    return [];
  }

  const entries = await readdir(profilesDir, { withFileTypes: true });
  return entries.filter((entry) => entry.isDirectory()).map((entry) => entry.name);
}
