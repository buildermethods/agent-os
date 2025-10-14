import { $ } from 'bun';
import { mkdir, access } from 'fs/promises';
import { dirname, join } from 'path';
import { constants } from 'fs';

/**
 * Check if a file or directory exists
 */
export async function fileExists(path: string): Promise<boolean> {
  try {
    // Use fs.access to check existence (works for both files and directories)
    await access(path, constants.F_OK);
    return true;
  } catch {
    return false;
  }
}

/**
 * Read file contents as string
 */
export async function readFile(path: string): Promise<string | null> {
  try {
    const file = Bun.file(path);
    return await file.text();
  } catch {
    return null;
  }
}

/**
 * Write content to file
 */
export async function writeFile(path: string, content: string): Promise<void> {
  await ensureDir(dirname(path));
  await Bun.write(path, content);
}

/**
 * Copy file from source to destination
 */
export async function copyFile(source: string, dest: string): Promise<void> {
  const content = await readFile(source);
  if (content === null) {
    throw new Error(`Source file not found: ${source}`);
  }
  await writeFile(dest, content);
}

/**
 * Ensure directory exists, create if it doesn't
 */
export async function ensureDir(path: string): Promise<void> {
  try {
    await mkdir(path, { recursive: true });
  } catch (error: any) {
    // Ignore error if directory already exists
    if (error.code !== 'EEXIST') {
      throw error;
    }
  }
}

/**
 * Get home directory path
 */
export function getHomeDir(): string {
  return process.env.HOME || process.env.USERPROFILE || '~';
}

/**
 * Get Agent OS installation directory
 * Checks AGENT_OS_HOME environment variable first, falls back to ~/agent-os
 */
export function getAgentOsHome(): string {
  if (process.env.AGENT_OS_HOME) {
    // Expand ~ if present
    if (process.env.AGENT_OS_HOME.startsWith('~/')) {
      return joinPath(getHomeDir(), process.env.AGENT_OS_HOME.slice(2));
    }
    return process.env.AGENT_OS_HOME;
  }
  return joinPath(getHomeDir(), 'agent-os');
}

/**
 * Join paths
 */
export function joinPath(...paths: string[]): string {
  return join(...paths);
}

/**
 * Check if path is a directory
 */
export async function isDirectory(path: string): Promise<boolean> {
  try {
    const file = Bun.file(path);
    const stat = await file.stat();
    return stat && typeof stat === 'object' && 'isDirectory' in stat
      ? (stat as any).isDirectory
      : false;
  } catch {
    return false;
  }
}

/**
 * Remove directory recursively
 */
export async function removeDir(path: string): Promise<void> {
  await $`rm -rf ${path}`;
}

/**
 * Move/rename file or directory
 */
export async function moveFile(source: string, dest: string): Promise<void> {
  await $`mv ${source} ${dest}`;
}

/**
 * Generate a unique backup directory name with hash
 * @param basePath - The base path (e.g., "~/agent-os")
 * @returns A unique backup path with format: {basePath}.backup.{hash}
 */
export async function generateUniqueBackupPath(basePath: string): Promise<string> {
  // Generate a short hash from timestamp and random value
  const timestamp = Date.now().toString(36);
  const random = Math.random().toString(36).substring(2, 7);
  const hash = `${timestamp}${random}`;

  return `${basePath}.backup.${hash}`;
}
