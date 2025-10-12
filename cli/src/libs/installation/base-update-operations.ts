/**
 * Base Update Operations
 * Functions for updating different parts of the base installation
 */

import * as clack from '@clack/prompts';
import { $ } from 'bun';
import { dirname } from 'path';
import { printSuccess } from '../../utils/colors';
import { joinPath, removeDir, fileExists, ensureDir } from '../../utils/files';
import { getAllRepoFiles, downloadFile } from '../../utils/github';

/**
 * Update the default profile
 */
export async function updateProfile(baseDir: string, exclusions: string[]): Promise<void> {
  const spinner = clack.spinner();
  spinner.start('Updating default profile');

  const profileDir = joinPath(baseDir, 'profiles/default');
  const commandsDir = joinPath(profileDir, 'commands');
  const backupDir = joinPath(baseDir, '.profile-update-backup');

  // Get list of files that exist in the repo
  const files = await getAllRepoFiles(exclusions);
  const profileFiles = files.filter((f) => f.startsWith('profiles/default/'));
  const repoCommandFiles = new Set(
    profileFiles
      .filter((f) => f.startsWith('profiles/default/commands/'))
      .map((f) => f.replace('profiles/default/', ''))
  );

  // Backup custom commands (those not in the repo)
  const customCommands: Array<{ relativePath: string; fullPath: string }> = [];

  if (await fileExists(commandsDir)) {
    const findResult = await $`find ${commandsDir} -type f -name "*.md"`.quiet();
    if (findResult.exitCode === 0) {
      const commandFiles = findResult.stdout
        .toString()
        .trim()
        .split('\n')
        .filter((f) => f);

      for (const file of commandFiles) {
        const relativePath = file.replace(profileDir + '/', '');
        if (!repoCommandFiles.has(relativePath)) {
          customCommands.push({ relativePath, fullPath: file });
        }
      }

      if (customCommands.length > 0) {
        await ensureDir(backupDir);
        for (const cmd of customCommands) {
          const backupPath = joinPath(backupDir, cmd.relativePath);
          await ensureDir(dirname(backupPath));
          await $`cp ${cmd.fullPath} ${backupPath}`.quiet();
        }
        clack.log.info(`Backed up ${customCommands.length} custom command(s)`);
      }
    }
  }

  // Remove and reinstall profile
  await removeDir(profileDir);

  let count = 0;
  for (const file of profileFiles) {
    const destFile = joinPath(baseDir, file);
    const success = await downloadFile(file, destFile);
    if (success) count++;
  }

  // Restore custom commands
  if (customCommands.length > 0) {
    for (const cmd of customCommands) {
      const restorePath = joinPath(profileDir, cmd.relativePath);
      const backupPath = joinPath(backupDir, cmd.relativePath);
      await ensureDir(dirname(restorePath));
      await $`cp ${backupPath} ${restorePath}`.quiet();
    }
    await removeDir(backupDir);
    clack.log.success(`Restored ${customCommands.length} custom command(s)`);
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
