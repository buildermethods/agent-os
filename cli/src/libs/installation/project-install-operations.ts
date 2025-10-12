/**
 * Project Installation Operations
 * Shared installation logic for project install/update
 */

import * as clack from '@clack/prompts';
import { colors, printSuccess } from '../../utils/colors';
import { joinPath, ensureDir, removeDir, fileExists } from '../../utils/files';
import {
  loadBaseConfig,
  mergeConfig,
  validateConfig,
  saveProjectConfig,
} from '../config/config';
import { profileExists } from '../profiles/profiles';
import { installStandards } from './standards';
import { installRoles } from './roles';
import { installCustomFiles } from './custom';
import { installSingleAgentCommands, installClaudeCodeCommands } from './commands';
import { installAllClaudeCodeAgents } from './agents';
import { confirmReinstall } from '../ui/prompts';
import { ProgressSpinner, displayConfiguration } from '../ui/feedback';
import type { ConfigOptions } from '../../types';

interface InstallationOptions extends ConfigOptions {
  verbose: boolean;
  dryRun?: boolean;
}

/**
 * Load and validate configuration
 */
async function loadAndValidateConfig(
  baseDir: string,
  options: InstallationOptions
): Promise<any> {
  const baseConfig = await loadBaseConfig(baseDir);
  if (!baseConfig) {
    throw new Error('Base installation config not found');
  }

  const config = mergeConfig(baseConfig, options);

  const validation = validateConfig(config, baseDir);
  if (!validation.valid) {
    throw new Error(validation.error);
  }

  if (!(await profileExists(baseDir, config.profile))) {
    throw new Error(`Profile not found: ${config.profile}`);
  }

  return config;
}

/**
 * Install all project files
 */
export async function performProjectInstallation(
  baseDir: string,
  projectDir: string,
  options: InstallationOptions
): Promise<void> {
  const config = await loadAndValidateConfig(baseDir, options);

  if (options.dryRun) {
    clack.log.warn('DRY RUN - No files will be actually created');
    console.log('');
  }

  displayConfiguration({
    profile: config.profile,
    multiAgentMode: config.multiAgentMode,
    multiAgentTool: config.multiAgentMode ? config.multiAgentTool : undefined,
    singleAgentMode: config.singleAgentMode,
    singleAgentTool: config.singleAgentMode ? config.singleAgentTool : undefined,
  });

  // Create agent-os folder
  await ensureDir(joinPath(projectDir, 'agent-os'));
  if (!options.dryRun) {
    await saveProjectConfig(projectDir, config);
    printSuccess('Created agent-os folder and configuration');
  }
  console.log('');

  // Install standards
  const spinner = new ProgressSpinner();
  spinner.start('Installing standards');
  const standardsResult = await installStandards(
    baseDir,
    projectDir,
    config.profile,
    options.dryRun
  );
  spinner.stop(`Installed ${standardsResult.count} standards`);
  console.log('');

  // Install custom files
  spinner.start('Installing custom files');
  const customResult = await installCustomFiles(
    baseDir,
    projectDir,
    config.profile,
    options.dryRun
  );
  if (customResult.count > 0) {
    spinner.stop(`Installed ${customResult.count} custom files`);
    console.log('');
  } else {
    spinner.stop('No custom files to install');
    console.log('');
  }

  // Install single-agent mode files
  if (config.singleAgentMode) {
    spinner.start('Installing roles');
    const rolesResult = await installRoles(baseDir, projectDir, config.profile, options.dryRun);
    spinner.stop(`Installed ${rolesResult.count} role files`);
    console.log('');

    spinner.start('Installing single-agent commands');
    const commandsResult = await installSingleAgentCommands(
      baseDir,
      projectDir,
      config.profile,
      {
        version: config.version,
        profile: config.profile,
        multiAgentMode: config.multiAgentMode,
      },
      options.dryRun
    );
    spinner.stop(`Installed ${commandsResult.count} single-agent commands`);
    console.log('');
  }

  // Install multi-agent mode files (Claude Code)
  if (config.multiAgentMode && config.multiAgentTool === 'claude-code') {
    spinner.start('Installing Claude Code commands');
    const commandsResult = await installClaudeCodeCommands(
      baseDir,
      projectDir,
      config.profile,
      { version: config.version, profile: config.profile },
      options.dryRun
    );
    spinner.stop(`Installed ${commandsResult.count} commands`);

    spinner.start('Installing Claude Code agents');
    const agentsResult = await installAllClaudeCodeAgents(
      baseDir,
      projectDir,
      config.profile,
      { version: config.version, profile: config.profile },
      options.dryRun
    );
    spinner.stop(`Installed ${agentsResult.count} agents`);
    console.log('');
  }

  if (!options.dryRun) {
    printSuccess('Agent OS has been successfully installed in your project!');
    console.log('');
    clack.note(
      `${colors.green('Visit the docs for guides on how to use Agent OS:')}\n` +
        `${colors.yellow('https://buildermethods.com/agent-os')}`,
      'Next steps'
    );
    console.log('');
  }
}

/**
 * Handle reinstallation by removing old files first
 */
export async function handleProjectReinstallation(
  baseDir: string,
  projectDir: string,
  options: InstallationOptions
): Promise<void> {
  const hasClaudeAgents = await fileExists(joinPath(projectDir, '.claude/agents/agent-os'));
  const hasClaudeCommands = await fileExists(joinPath(projectDir, '.claude/commands/agent-os'));

  await confirmReinstall({ hasClaudeAgents, hasClaudeCommands });

  if (!options.dryRun) {
    const spinner = new ProgressSpinner();
    spinner.start('Removing existing installation');

    await removeDir(joinPath(projectDir, 'agent-os'));
    await removeDir(joinPath(projectDir, '.claude/agents/agent-os'));
    await removeDir(joinPath(projectDir, '.claude/commands/agent-os'));

    spinner.stop('Existing installation removed');
    console.log('');
  }

  await performProjectInstallation(baseDir, projectDir, options);
}
