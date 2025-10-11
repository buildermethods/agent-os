/**
 * Base Update Flows
 * High-level flows for base installation updates
 */

import * as clack from '@clack/prompts';
import { colors, printSuccess, printError } from '../../utils/colors';
import { joinPath, fileExists } from '../../utils/files';
import { getLatestVersion } from '../../utils/github';
import { loadConfig } from '../../utils/yaml';
import { promptOverwriteChoice } from '../ui/prompts';
import {
  performFreshInstallation,
  displayNextSteps,
  backupAndReinstall,
} from './base-install-operations';
import { updateProfile, updateScripts, updateConfig } from './base-update-operations';

interface UpdateOptions {
  verbose: boolean;
}

/**
 * Check existing installation and handle update
 */
export async function checkExistingInstallation(
  baseDir: string,
  exclusions: string[],
  options: UpdateOptions
): Promise<void> {
  if (!(await fileExists(baseDir))) {
    await performFreshInstallation(baseDir, exclusions, options);
    displayNextSteps();
    return;
  }

  // Get current version
  const configPath = joinPath(baseDir, 'config.yml');
  let currentVersion: string | null = null;

  if (await fileExists(configPath)) {
    const config = await loadConfig(configPath);
    currentVersion = config?.version || null;
  }

  // Get latest version
  const latestVersion = await getLatestVersion();

  // Prompt for overwrite choice
  const choice = await promptOverwriteChoice(currentVersion, latestVersion);

  switch (choice) {
    case 'all':
      await backupAndReinstall(baseDir, exclusions, options);
      displayNextSteps();
      break;
    case 'profile':
      await updateProfile(baseDir, exclusions);
      break;
    case 'scripts':
      await updateScripts(baseDir, exclusions);
      break;
    case 'config':
      await updateConfig(baseDir);
      break;
  }
}

/**
 * Validate base installation exists
 */
export async function validateBaseExists(baseDir: string): Promise<void> {
  if (!(await fileExists(baseDir))) {
    printError('Agent OS base installation not found at ~/agent-os');
    printError('Please reinstall using: curl -fsSL https://install.agent-os.dev | bash');
    process.exit(1);
  }
}

/**
 * Show help message
 */
export function showHelp(): void {
  console.log('Usage: agent-os base-update [OPTIONS]');
  console.log('');
  console.log('Options:');
  console.log('  -v, --verbose    Show verbose output');
  console.log('  -h, --help       Show this help message');
  process.exit(0);
}

/**
 * Parse command line arguments
 */
export function parseArguments(): UpdateOptions {
  const args = process.argv.slice(2);

  if (args.includes('-h') || args.includes('--help')) {
    showHelp();
  }

  return {
    verbose: args.includes('-v') || args.includes('--verbose'),
  };
}
