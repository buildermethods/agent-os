/**
 * Installation Types
 */

export interface InstallResult {
  count: number;
  files: string[];
}

export interface InstallOptions {
  verbose: boolean;
  dryRun?: boolean;
  reInstall?: boolean;
}

export interface ProfileFile {
  relativePath: string;
  fullPath: string;
}

export interface DownloadProgress {
  current: number;
  total: number;
  file: string;
}

export type OverwriteChoice = 'all' | 'profile' | 'scripts' | 'config' | 'cancel';
