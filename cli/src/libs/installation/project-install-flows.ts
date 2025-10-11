/**
 * Project Installation Flows
 * High-level flows for project installation scenarios
 */

import * as clack from '@clack/prompts';
import { colors, printSuccess, printError } from '../../utils/colors';
import { joinPath, fileExists, ensureDir, removeDir } from '../../utils/files';
import {
  loadBaseConfig,
  mergeConfig,
  validateConfig,
  saveProjectConfig,
} from '../config/config';
import { profileExists } from '../profiles/profiles';
import { installStandards } from './standards';
import { installRoles } from './roles';
import { singleAgentInstallers, multiAgentInstallers } from './commands';
import { installAllClaudeCodeAgents } from './agents';
import { confirmReinstall } from '../ui/prompts';
import { ProgressSpinner, displayConfiguration } from '../ui/feedback';
import type { ConfigOptions } from '../../types';

interface InstallOptions extends ConfigOptions {
  verbose: boolean;
  reInstall?: boolean;
}

/**
 * Perform fresh project installation
 */
export async function performInstallation(
  baseDir: string,
  projectDir: string,
  options: InstallOptions
): Promise<void> {
  // Load and merge configuration
  const baseConfig = await loadBaseConfig(baseDir);
  if (!baseConfig) {
    throw new Error('Base installation config not found');
  }

  const config = mergeConfig(baseConfig, options);

  // Validate configuration
  const validation = validateConfig(config, baseDir);
  if (!validation.valid) {
    throw new Error(validation.error);
  }

  // Check if profile exists
  if (!(await profileExists(baseDir, config.profile))) {
    throw new Error(`Profile not found: ${config.profile}`);
  }

  // Display configuration
  displayConfiguration({
    profile: config.profile,
    multiAgentMode: config.multiAgentMode,
    multiAgentTool: config.multiAgentMode ? config.multiAgentTool : undefined,
    singleAgentMode: config.singleAgentMode,
    singleAgentTool: config.singleAgentMode ? config.singleAgentTool : undefined,
  });

  // Create agent-os folder
  await ensureDir(joinPath(projectDir, 'agent-os'));
  await saveProjectConfig(projectDir, config);
  printSuccess('Created agent-os folder and configuration');
  console.log('');

  // Install standards
  const spinner = new ProgressSpinner();
  spinner.start('Installing standards');
  const standardsResult = await installStandards(baseDir, projectDir, config.profile, false);
  spinner.stop(`Installed ${standardsResult.count} standards`);
  console.log('');

  // Install single-agent mode files
  if (config.singleAgentMode) {
    spinner.start('Installing roles');
    const rolesResult = await installRoles(baseDir, projectDir, config.profile, false);
    spinner.stop(`Installed ${rolesResult.count} role files`);
    console.log('');

    // Install single-agent commands using the appropriate installer
    const installer = singleAgentInstallers[config.singleAgentTool];
    const toolName = config.singleAgentTool === 'cursor' ? 'Cursor rules' : 'single-agent commands';

    spinner.start(`Installing ${toolName}`);
    const commandsResult = await installer(
      baseDir,
      projectDir,
      config.profile,
      { version: config.version, profile: config.profile },
      false
    );
    spinner.stop(`Installed ${commandsResult.count} ${toolName}`);
    console.log('');
  }

  // Install multi-agent mode files
  if (config.multiAgentMode) {
    const installer = multiAgentInstallers[config.multiAgentTool];
    const toolName = config.multiAgentTool === 'claude-code' ? 'Claude Code' : config.multiAgentTool;

    spinner.start(`Installing ${toolName} commands`);
    const commandsResult = await installer(
      baseDir,
      projectDir,
      config.profile,
      { version: config.version, profile: config.profile },
      false
    );
    spinner.stop(`Installed ${commandsResult.count} commands`);

    // Install agents for Claude Code
    if (config.multiAgentTool === 'claude-code') {
      spinner.start('Installing Claude Code agents');
      const agentsResult = await installAllClaudeCodeAgents(
        baseDir,
        projectDir,
        config.profile,
        { version: config.version, profile: config.profile },
        false
      );
      spinner.stop(`Installed ${agentsResult.count} agents`);
    }
    console.log('');
  }

  printSuccess('Agent OS has been successfully installed in your project!');
  console.log('');
  clack.note(
    `${colors.green('Visit the docs for guides on how to use Agent OS:')}\n` +
      `${colors.yellow('https://buildermethods.com/agent-os')}`,
    'Next steps'
  );
  console.log('');
}

/**
 * Handle reinstallation by removing existing files first
 */
export async function handleReinstallation(
  baseDir: string,
  projectDir: string,
  options: InstallOptions
): Promise<void> {
  const hasClaudeAgents = await fileExists(joinPath(projectDir, '.claude/agents/agent-os'));
  const hasClaudeCommands = await fileExists(joinPath(projectDir, '.claude/commands/agent-os'));

  await confirmReinstall({ hasClaudeAgents, hasClaudeCommands });

  const spinner = new ProgressSpinner();
  spinner.start('Removing existing installation');

  await removeDir(joinPath(projectDir, 'agent-os'));
  await removeDir(joinPath(projectDir, '.claude/agents/agent-os'));
  await removeDir(joinPath(projectDir, '.claude/commands/agent-os'));
  await removeDir(joinPath(projectDir, '.cursor/rules/agent-os'));

  spinner.stop('Existing installation removed');
  console.log('');

  await performInstallation(baseDir, projectDir, options);
}

/**
 * Check if Agent OS is installed in directory
 */
export async function isAgentOsInstalled(projectDir: string): Promise<boolean> {
  return await fileExists(joinPath(projectDir, 'agent-os/config.yml'));
}

/**
 * Validate base installation exists
 */
export async function validateBaseInstallation(baseDir: string): Promise<void> {
  if (!(await fileExists(baseDir))) {
    printError('Agent OS base installation not found at ~/agent-os');
    printError('Please run base-install first.');
    process.exit(1);
  }
}
