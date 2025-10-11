import { writeFile, ensureDir } from './files';
import { join, dirname } from 'path';

export const REPO_URL = 'https://github.com/buildermethods/agent-os';

export interface GitHubFile {
  path: string;
  type: 'blob' | 'tree';
}

/**
 * Download a file from GitHub repository
 */
export async function downloadFile(relativePath: string, destPath: string): Promise<boolean> {
  const fileUrl = `${REPO_URL}/raw/main/${relativePath}`;

  try {
    const response = await fetch(fileUrl);
    if (!response.ok) return false;

    const content = await response.text();
    await ensureDir(dirname(destPath));
    await writeFile(destPath, content);

    return true;
  } catch (error) {
    console.error(`Failed to download ${relativePath}:`, error);
    return false;
  }
}

/**
 * Get all files from GitHub repository using the tree API
 */
export async function getAllRepoFiles(exclusions: string[] = []): Promise<string[]> {
  const repoPath = REPO_URL.replace('https://github.com/', '');
  const treeUrl = `https://api.github.com/repos/${repoPath}/git/trees/main?recursive=true`;

  try {
    const response = await fetch(treeUrl);
    if (!response.ok) {
      throw new Error(`GitHub API returned ${response.status}`);
    }

    const data = await response.json();

    if (!data.tree || !Array.isArray(data.tree)) {
      throw new Error('Invalid GitHub API response');
    }

    const files: string[] = [];

    for (const item of data.tree) {
      if (item.type === 'blob' && !shouldExclude(item.path, exclusions)) {
        files.push(item.path);
      }
    }

    return files;
  } catch (error) {
    console.error('Failed to fetch repository files:', error);
    return [];
  }
}

/**
 * Check if a file should be excluded
 */
function shouldExclude(filePath: string, exclusions: string[]): boolean {
  for (const pattern of exclusions) {
    // Exact match
    if (filePath === pattern) return true;

    // Wildcard pattern
    if (pattern.includes('*')) {
      const prefix = pattern.replace('*', '');
      if (filePath.startsWith(prefix)) return true;
    }
  }

  return false;
}

/**
 * Download all repository files
 */
export async function downloadAllFiles(
  destBase: string,
  exclusions: string[] = [],
  onProgress?: (current: number, total: number, file: string) => void
): Promise<number> {
  const files = await getAllRepoFiles(exclusions);

  if (files.length === 0) {
    return 0;
  }

  let downloadedCount = 0;

  for (const file of files) {
    const destFile = join(destBase, file);
    const success = await downloadFile(file, destFile);

    if (success) {
      downloadedCount++;
      onProgress?.(downloadedCount, files.length, file);
    }
  }

  return downloadedCount;
}

/**
 * Get latest version from config.yml
 */
export async function getLatestVersion(): Promise<string | null> {
  const configUrl = `${REPO_URL}/raw/main/config.yml`;

  try {
    const response = await fetch(configUrl);
    if (!response.ok) return null;

    const content = await response.text();
    const versionMatch = content.match(/^version:\s*(.+)$/m);

    return versionMatch ? versionMatch[1].trim() : null;
  } catch {
    return null;
  }
}
