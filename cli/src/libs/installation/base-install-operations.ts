/**
 * Base Installation Operations
 * Functions for fresh installation and backups
 */

import * as clack from '@clack/prompts';
import { $ } from 'bun';
import { colors, printSuccess, printError } from '../../utils/colors';
import { ensureDir, moveFile, generateUniqueBackupPath } from '../../utils/files';
import { downloadAllFiles, REPO_URL } from '../../utils/github';
import { createDownloadProgress } from '../ui/feedback';

/**
 * Perform fresh installation
 */
export async function performFreshInstallation(
  baseDir: string,
  exclusions: string[],
  options: { verbose: boolean }
): Promise<void> {
  console.log('');
  clack.log.info(`Repository: ${colors.yellow(REPO_URL)}`);
  clack.log.info(`Target: ${colors.yellow('~/agent-os')}`);
  console.log('');

  await ensureDir(baseDir);
  printSuccess('Created base directory: ~/agent-os');
  console.log('');

  const progress = createDownloadProgress(options.verbose);
  progress.start();

  try {
    const fileCount = await downloadAllFiles(baseDir, exclusions, progress.onProgress);

    if (fileCount === 0) {
      progress.fail();
      printError('No files were downloaded');
      process.exit(1);
    }

    progress.stop();
    printSuccess(`Installed ${fileCount} files to ~/agent-os`);
  } catch (error) {
    progress.fail();
    throw error;
  }

  // Make scripts executable
  await $`chmod +x ${baseDir}/scripts/*.sh`.quiet();

  console.log('');
  printSuccess('Agent OS has been successfully installed!');
  console.log('');
}

/**
 * Display next steps after installation
 */
export function displayNextSteps(): void {
  clack.note(
    `${colors.green("1) Customize your profile's standards in ~/agent-os/profiles/default/standards")}\n\n` +
      `${colors.green('2) Navigate to a project directory')}\n` +
      `   ${colors.yellow('cd path/to/project-directory')}\n\n` +
      `${colors.green('3) Install Agent OS in your project by running:')}\n` +
      `   ${colors.yellow('~/agent-os/cli')}\n` +
      `   ${colors.dim('(then select "Install Agent OS in project")')}\n\n` +
      `${colors.green('Visit the docs: https://buildermethods.com/agent-os')}`,
    'Next steps:'
  );
  console.log('');
}

/**
 * Backup and reinstall
 */
export async function backupAndReinstall(
  baseDir: string,
  exclusions: string[],
  options: { verbose: boolean }
): Promise<void> {
  const spinner = clack.spinner();
  spinner.start('Backing up existing installation');

  const backupDir = await generateUniqueBackupPath(baseDir);
  await moveFile(baseDir, backupDir);

  const backupDirName = backupDir.split('/').pop();
  spinner.stop(`Backed up to ~/${backupDirName}`);
  printSuccess(`Backed up existing installation to ~/${backupDirName}`);

  await performFreshInstallation(baseDir, exclusions, options);
}
