/**
 * Project Update Flows
 * High-level flows for updating project installations
 */

import * as clack from '@clack/prompts';
import { colors, printSuccess, printError } from '../../utils/colors';
import { joinPath, fileExists, removeDir } from '../../utils/files';
import {
  loadBaseConfig,
  loadProjectConfig,
  mergeConfig,
  validateConfig,
  saveProjectConfig,
} from '../config/config';
import { profileExists } from '../profiles/profiles';
import { installStandards } from './standards';
import { installRoles } from './roles';
import { installCustomFiles } from './custom';
import { singleAgentInstallers, multiAgentInstallers } from './commands';
import { installAllClaudeCodeAgents } from './agents';
import { ProgressSpinner, displayConfiguration } from '../ui/feedback';
import type { ConfigOptions, MultiAgentTool, SingleAgentTool } from '../../types';

interface UpdateOptions extends ConfigOptions {
  verbose: boolean;
}

/**
 * Perform project update
 */
export async function performUpdate(
  baseDir: string,
  projectDir: string,
  options: UpdateOptions
): Promise<void> {
  // Load existing project config
  const projectConfig = await loadProjectConfig(projectDir);
  if (!projectConfig) {
    throw new Error('Project config not found. Has Agent OS been installed?');
  }

  // Load base config
  const baseConfig = await loadBaseConfig(baseDir);
  if (!baseConfig) {
    throw new Error('Base installation config not found');
  }

  // Merge configs (project config takes precedence, but we update version from base)
  const mergedConfig = mergeConfig(baseConfig, {
    ...options,
    profile: projectConfig.profile,
    multiAgentMode: projectConfig.multi_agent_mode,
    multiAgentTool: projectConfig.multi_agent_tool as MultiAgentTool,
    singleAgentMode: projectConfig.single_agent_mode,
    singleAgentTool: projectConfig.single_agent_tool as SingleAgentTool
  });

  // Validate configuration
  const validation = validateConfig(mergedConfig, baseDir);
  if (!validation.valid) {
    throw new Error(validation.error);
  }

  // Check if profile exists
  if (!(await profileExists(baseDir, mergedConfig.profile))) {
    throw new Error(`Profile not found: ${mergedConfig.profile}`);
  }

  // Display configuration
  console.log('');
  clack.log.info(`Updating to version: ${colors.yellow(mergedConfig.version)}`);
  displayConfiguration({
    profile: mergedConfig.profile,
    multiAgentMode: mergedConfig.multiAgentMode,
    multiAgentTool: mergedConfig.multiAgentMode ? mergedConfig.multiAgentTool : undefined,
    singleAgentMode: mergedConfig.singleAgentMode,
    singleAgentTool: mergedConfig.singleAgentMode ? mergedConfig.singleAgentTool : undefined,
  });

  const spinner = new ProgressSpinner();

  // Remove old installations
  spinner.start('Removing old files');
  await removeDir(joinPath(projectDir, 'agent-os/roles'));
  await removeDir(joinPath(projectDir, 'agent-os/standards'));
  await removeDir(joinPath(projectDir, 'agent-os/commands'));
  await removeDir(joinPath(projectDir, '.claude/agents/agent-os'));
  await removeDir(joinPath(projectDir, '.claude/commands/agent-os'));
  await removeDir(joinPath(projectDir, '.cursor/rules/agent-os'));
  spinner.stop('Removed old files');
  console.log('');

  // Save updated config
  await saveProjectConfig(projectDir, mergedConfig);
  printSuccess('Updated configuration');
  console.log('');

  // Install standards
  spinner.start('Installing standards');
  const standardsResult = await installStandards(baseDir, projectDir, mergedConfig.profile, false);
  spinner.stop(`Installed ${standardsResult.count} standards`);
  console.log('');

  // Install custom files
  spinner.start('Installing custom files');
  const customResult = await installCustomFiles(baseDir, projectDir, mergedConfig.profile, false);
  if (customResult.count > 0) {
    spinner.stop(`Installed ${customResult.count} custom files`);
    console.log('');
  } else {
    spinner.stop('No custom files to install');
    console.log('');
  }

  // Install single-agent mode files
  if (mergedConfig.singleAgentMode) {
    spinner.start('Installing roles');
    const rolesResult = await installRoles(baseDir, projectDir, mergedConfig.profile, false);
    spinner.stop(`Installed ${rolesResult.count} role files`);
    console.log('');

    // Install single-agent commands using the appropriate installer
    const installer = singleAgentInstallers[mergedConfig.singleAgentTool];
    const toolName =
      mergedConfig.singleAgentTool === 'cursor' ? 'Cursor rules' : 'single-agent commands';

    spinner.start(`Installing ${toolName}`);
    const commandsResult = await installer(
      baseDir,
      projectDir,
      mergedConfig.profile,
      { version: mergedConfig.version, profile: mergedConfig.profile },
      false
    );
    spinner.stop(`Installed ${commandsResult.count} ${toolName}`);
    console.log('');
  }

  // Install multi-agent mode files
  if (mergedConfig.multiAgentMode) {
    const installer = multiAgentInstallers[mergedConfig.multiAgentTool];
    const toolName =
      mergedConfig.multiAgentTool === 'claude-code' ? 'Claude Code' : mergedConfig.multiAgentTool;

    spinner.start(`Installing ${toolName} commands`);
    const commandsResult = await installer(
      baseDir,
      projectDir,
      mergedConfig.profile,
      { version: mergedConfig.version, profile: mergedConfig.profile },
      false
    );
    spinner.stop(`Installed ${commandsResult.count} commands`);

    // Install agents for Claude Code
    if (mergedConfig.multiAgentTool === 'claude-code') {
      spinner.start('Installing Claude Code agents');
      const agentsResult = await installAllClaudeCodeAgents(
        baseDir,
        projectDir,
        mergedConfig.profile,
        { version: mergedConfig.version, profile: mergedConfig.profile },
        false
      );
      spinner.stop(`Installed ${agentsResult.count} agents`);
    }
    console.log('');
  }

  printSuccess('Agent OS has been successfully updated!');
  console.log('');
  clack.note(
    `${colors.green('Updated to version:')} ${colors.yellow(mergedConfig.version)}\n\n` +
      `${colors.green('Visit the docs:')}\n` +
      `${colors.yellow('https://buildermethods.com/agent-os')}`,
    'Update complete'
  );
  console.log('');
}

/**
 * Validate installation state before update
 */
export async function validateUpdatePreconditions(baseDir: string, projectDir: string): Promise<void> {
  if (!(await fileExists(baseDir))) {
    printError(`Agent OS base installation not found at ${baseDir}`);
    printError('Please run base-install first.');
    process.exit(1);
  }

  if (!(await fileExists(joinPath(projectDir, 'agent-os/config.yml')))) {
    printError('Agent OS is not installed in this project');
    printError('Please run project-install first.');
    process.exit(1);
  }
}
