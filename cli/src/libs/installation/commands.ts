/**
 * Commands Installation
 * Handles installing command files (single-agent and multi-agent)
 */

import { writeFile, joinPath } from '../../utils/files';
import { getProfileFiles } from '../profiles/profiles';
import { processTemplate, getCommonReplacements } from '../templates/processor';
import type { InstallResult } from '../../types';
import type { SingleAgentTool, MultiAgentTool } from '../../types/config.types';
import { basename } from 'path';

/**
 * Installer function signature
 */
type InstallerFunction = (
  baseDir: string,
  projectDir: string,
  profile: string,
  config: { version: string; profile: string },
  dryRun?: boolean
) => Promise<InstallResult>;

/**
 * Install generic single-agent commands (to agent-os/commands/)
 */
async function installGenericSingleAgentCommands(
  baseDir: string,
  projectDir: string,
  profile: string,
  config: { version: string; profile: string },
  dryRun: boolean = false
): Promise<InstallResult> {
  const files = await getProfileFiles(baseDir, profile, 'commands');
  const installedFiles: string[] = [];
  const replacements = getCommonReplacements(config);

  for (const { relativePath, fullPath } of files) {
    if (relativePath.includes('/single-agent/')) {
      // Strip single-agent subfolder
      const destFile = relativePath.replace('/single-agent', '');
      const dest = joinPath(projectDir, 'agent-os', destFile);

      if (!dryRun) {
        const content = await Bun.file(fullPath).text();
        const processed = await processTemplate(content, replacements, baseDir, profile);
        await writeFile(dest, processed);
      }

      installedFiles.push(dest);
    }
  }

  return {
    count: installedFiles.length,
    files: installedFiles,
  };
}

/**
 * Install Cursor rules (to .cursor/rules/agent-os/)
 */
async function installCursorRules(
  baseDir: string,
  projectDir: string,
  profile: string,
  config: { version: string; profile: string },
  dryRun: boolean = false
): Promise<InstallResult> {
  const files = await getProfileFiles(baseDir, profile, 'commands');
  const installedFiles: string[] = [];
  const replacements = getCommonReplacements(config);

  for (const { relativePath, fullPath } of files) {
    if (relativePath.includes('/single-agent/')) {
      // Extract command name and preserve directory structure
      // e.g., "commands/new-spec/single-agent/1-new-spec.md" -> "new-spec/1-new-spec"
      const pathParts = relativePath.split('/');
      const commandFolder = pathParts[pathParts.indexOf('commands') + 1];
      const fileName = basename(relativePath, '.md');

      const dest = joinPath(projectDir, '.cursor/rules/agent-os', commandFolder, `${fileName}.mdc`);

      if (!dryRun) {
        const content = await Bun.file(fullPath).text();
        const processed = await processTemplate(content, replacements, baseDir, profile);
        await writeFile(dest, processed);
      }

      installedFiles.push(dest);
    }
  }

  return {
    count: installedFiles.length,
    files: installedFiles,
  };
}

/**
 * Install Claude Code multi-agent commands (to .claude/commands/agent-os/)
 */
async function installClaudeCodeCommands(
  baseDir: string,
  projectDir: string,
  profile: string,
  config: { version: string; profile: string },
  dryRun: boolean = false
): Promise<InstallResult> {
  const files = await getProfileFiles(baseDir, profile, 'commands');
  const installedFiles: string[] = [];
  const replacements = getCommonReplacements(config);

  for (const { relativePath, fullPath } of files) {
    if (relativePath.includes('/multi-agent/')) {
      const commandName = basename(relativePath, '.md').split('/').pop() || '';
      const dest = joinPath(projectDir, '.claude/commands/agent-os', `${commandName}.md`);

      if (!dryRun) {
        const content = await Bun.file(fullPath).text();
        const processed = await processTemplate(content, replacements, baseDir, profile);
        await writeFile(dest, processed);
      }

      installedFiles.push(dest);
    }
  }

  return {
    count: installedFiles.length,
    files: installedFiles,
  };
}

/**
 * Single-agent command installers mapped by tool
 */
export const singleAgentInstallers = {
  generic: installGenericSingleAgentCommands,
  cursor: installCursorRules,
} satisfies Record<SingleAgentTool, InstallerFunction>;

/**
 * Multi-agent command installers mapped by tool
 */
export const multiAgentInstallers = {
  'claude-code': installClaudeCodeCommands,
} satisfies Record<MultiAgentTool, InstallerFunction>;
