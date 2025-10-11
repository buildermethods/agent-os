/**
 * Commands Installation
 * Handles installing command files (single-agent and multi-agent)
 */

import { writeFile, joinPath } from '../../utils/files';
import { getProfileFiles } from '../profiles/profiles';
import { processTemplate, getCommonReplacements } from '../templates/processor';
import type { InstallResult } from '../../types';
import { basename } from 'path';

/**
 * Install single-agent commands
 */
export async function installSingleAgentCommands(
  baseDir: string,
  projectDir: string,
  profile: string,
  config: { version: string; profile: string; multiAgentMode: boolean },
  dryRun: boolean = false
): Promise<InstallResult> {
  const files = await getProfileFiles(baseDir, profile, 'commands');
  const installedFiles: string[] = [];
  const replacements = getCommonReplacements(config);

  for (const { relativePath, fullPath } of files) {
    if (relativePath.includes('/single-agent/')) {
      let dest: string;

      // If both modes enabled, keep folder structure
      if (config.multiAgentMode) {
        dest = joinPath(projectDir, 'agent-os', relativePath);
      } else {
        // Strip single-agent subfolder
        const destFile = relativePath.replace('/single-agent', '');
        dest = joinPath(projectDir, 'agent-os', destFile);
      }

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
 * Install Claude Code multi-agent commands
 */
export async function installClaudeCodeCommands(
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
