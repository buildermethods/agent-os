/**
 * UI Prompts
 * Common interactive prompts for installation workflows
 */

import * as clack from '@clack/prompts';
import { colors } from '../../utils/colors';
import type { OverwriteChoice } from '../../types';

/**
 * Prompt user for overwrite choice when existing installation is detected
 */
export async function promptOverwriteChoice(
  currentVersion: string | null,
  latestVersion: string | null
): Promise<OverwriteChoice> {
  console.log('');
  clack.log.warn('Existing Installation Detected');
  console.log('');

  clack.log.info('You already have a base installation of Agent OS');

  if (currentVersion) {
    clack.log.info(`Your installed version: ${colors.yellow(currentVersion)}`);
  } else {
    clack.log.info('Your installed version: (unknown)');
  }

  if (latestVersion) {
    clack.log.info(`Latest available version: ${colors.yellow(latestVersion)}`);
  } else {
    clack.log.info('Latest available version: (unable to determine)');
  }

  console.log('');

  const choice = await clack.select({
    message: 'What would you like to do?',
    options: [
      { value: 'all', label: 'Overwrite everything' },
      { value: 'profile', label: 'Overwrite only the default profile, including your standards' },
      { value: 'scripts', label: 'Overwrite only the scripts' },
      { value: 'config', label: 'Overwrite only the base config.yml' },
      { value: 'cancel', label: 'Cancel installation' },
    ],
  });

  if (clack.isCancel(choice) || choice === 'cancel') {
    clack.cancel('Installation cancelled');
    process.exit(0);
  }

  console.log('');
  clack.log.info(
    'If you choose to update and overwrite, your previous base installation will be saved in a timestamped backup directory (~/agent-os.backup.{hash}).'
  );
  console.log('');

  return choice as OverwriteChoice;
}

/**
 * Confirm re-installation (destructive action)
 */
export async function confirmReinstall(details: {
  hasClaudeAgents: boolean;
  hasClaudeCommands: boolean;
}): Promise<boolean> {
  clack.log.warn('This will DELETE your current agent-os/ folder and reinstall from scratch.');
  console.log('');

  if (details.hasClaudeAgents || details.hasClaudeCommands) {
    clack.log.warn('This will also DELETE:');
    if (details.hasClaudeAgents) console.log('  - .claude/agents/agent-os/');
    if (details.hasClaudeCommands) console.log('  - .claude/commands/agent-os/');
    console.log('');
  }

  const shouldContinue = await clack.confirm({
    message: 'Are you sure you want to proceed?',
  });

  if (clack.isCancel(shouldContinue) || !shouldContinue) {
    clack.cancel('Re-installation cancelled');
    process.exit(0);
  }

  return true;
}
