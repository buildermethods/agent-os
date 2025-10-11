/**
 * Base Update Operations
 * Functions for updating different parts of the base installation
 */

import * as clack from '@clack/prompts';
import { $ } from 'bun';
import { printSuccess } from '../../utils/colors';
import { joinPath, removeDir, fileExists } from '../../utils/files';
import { getAllRepoFiles, downloadFile } from '../../utils/github';

/**
 * Update the default profile
 */
export async function updateProfile(baseDir: string, exclusions: string[]): Promise<void> {
  const spinner = clack.spinner();
  spinner.start('Updating default profile');

  const profileDir = joinPath(baseDir, 'profiles/default');
  await removeDir(profileDir);

  const files = await getAllRepoFiles(exclusions);
  const profileFiles = files.filter((f) => f.startsWith('profiles/default/'));

  let count = 0;
  for (const file of profileFiles) {
    const destFile = joinPath(baseDir, file);
    const success = await downloadFile(file, destFile);
    if (success) count++;
  }

  spinner.stop('Profile updated');
  printSuccess(`Default profile has been updated! (${count} files)`);
  console.log('');
}

/**
 * Update scripts directory
 */
export async function updateScripts(baseDir: string, exclusions: string[]): Promise<void> {
  const spinner = clack.spinner();
  spinner.start('Updating scripts');

  const scriptsDir = joinPath(baseDir, 'scripts');
  await removeDir(scriptsDir);

  const files = await getAllRepoFiles(exclusions);
  const scriptFiles = files.filter((f) => f.startsWith('scripts/'));

  let count = 0;
  for (const file of scriptFiles) {
    const destFile = joinPath(baseDir, file);
    const success = await downloadFile(file, destFile);
    if (success) count++;
  }

  await $`chmod +x ${scriptsDir}/*.sh`.quiet();

  spinner.stop('Scripts updated');
  printSuccess(`Scripts have been updated! (${count} files)`);
  console.log('');
}

/**
 * Update config.yml
 */
export async function updateConfig(baseDir: string): Promise<void> {
  const spinner = clack.spinner();
  spinner.start('Updating config.yml');

  const configFile = joinPath(baseDir, 'config.yml');
  if (await fileExists(configFile)) {
    await $`cp ${configFile} ${configFile}.backup`.quiet();
    clack.log.info('Backed up existing config to config.yml.backup');
  }

  await downloadFile('config.yml', configFile);

  spinner.stop('Config updated');
  printSuccess('Config has been updated!');
  console.log('');
}
