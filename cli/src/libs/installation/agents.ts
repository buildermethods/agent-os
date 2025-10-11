/**
 * Agents Installation
 * Handles installing and generating agent files for Claude Code
 */

import { writeFile, joinPath, fileExists } from '../../utils/files';
import { getProfileFiles } from '../profiles/profiles';
import {
  processTemplate,
  getCommonReplacements,
  buildRoleReplacements,
} from '../templates/processor';
import type { InstallResult, RolesFile } from '../../types';
import { basename } from 'path';
import { load } from 'js-yaml';

/**
 * Install static agent files
 */
export async function installStaticAgents(
  baseDir: string,
  projectDir: string,
  profile: string,
  config: { version: string; profile: string },
  dryRun: boolean = false
): Promise<InstallResult> {
  const files = await getProfileFiles(baseDir, profile, 'agents');
  const installedFiles: string[] = [];
  const replacements = getCommonReplacements(config);

  for (const { relativePath, fullPath } of files) {
    if (
      relativePath.startsWith('agents/') &&
      relativePath.endsWith('.md') &&
      !relativePath.includes('/templates/')
    ) {
      const agentName = basename(relativePath, '.md');
      const dest = joinPath(projectDir, '.claude/agents/agent-os', `${agentName}.md`);

      if (!dryRun) {
        const content = await Bun.file(fullPath).text();
        const processed = processTemplate(content, replacements);
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
 * Generate and install implementer agents from roles
 */
export async function generateImplementerAgents(
  baseDir: string,
  projectDir: string,
  profile: string,
  config: { version: string; profile: string },
  dryRun: boolean = false
): Promise<InstallResult> {
  const implementersPath = joinPath(baseDir, 'profiles', profile, 'roles/implementers.yml');
  const templatePath = joinPath(baseDir, 'profiles', profile, 'agents/templates/implementer.md');

  if (!(await fileExists(implementersPath)) || !(await fileExists(templatePath))) {
    return { count: 0, files: [] };
  }

  const implementersContent = await Bun.file(implementersPath).text();
  const rolesData = load(implementersContent) as RolesFile;

  if (!rolesData.implementers || !Array.isArray(rolesData.implementers)) {
    return { count: 0, files: [] };
  }

  const template = await Bun.file(templatePath).text();
  const commonReplacements = getCommonReplacements(config);
  const installedFiles: string[] = [];

  for (const role of rolesData.implementers) {
    const dest = joinPath(projectDir, '.claude/agents/agent-os', `${role.id}.md`);

    if (!dryRun) {
      const roleReplacements = buildRoleReplacements(role);
      const allReplacements = { ...commonReplacements, ...roleReplacements };
      const processed = processTemplate(template, allReplacements);
      await writeFile(dest, processed);
    }

    installedFiles.push(dest);
  }

  return {
    count: installedFiles.length,
    files: installedFiles,
  };
}

/**
 * Generate and install verifier agents from roles
 */
export async function generateVerifierAgents(
  baseDir: string,
  projectDir: string,
  profile: string,
  config: { version: string; profile: string },
  dryRun: boolean = false
): Promise<InstallResult> {
  const verifiersPath = joinPath(baseDir, 'profiles', profile, 'roles/verifiers.yml');
  const templatePath = joinPath(baseDir, 'profiles', profile, 'agents/templates/verifier.md');

  if (!(await fileExists(verifiersPath)) || !(await fileExists(templatePath))) {
    return { count: 0, files: [] };
  }

  const verifiersContent = await Bun.file(verifiersPath).text();
  const rolesData = load(verifiersContent) as RolesFile;

  if (!rolesData.verifiers || !Array.isArray(rolesData.verifiers)) {
    return { count: 0, files: [] };
  }

  const template = await Bun.file(templatePath).text();
  const commonReplacements = getCommonReplacements(config);
  const installedFiles: string[] = [];

  for (const role of rolesData.verifiers) {
    const dest = joinPath(projectDir, '.claude/agents/agent-os', `${role.id}.md`);

    if (!dryRun) {
      const roleReplacements = buildRoleReplacements(role);
      const allReplacements = { ...commonReplacements, ...roleReplacements };
      const processed = processTemplate(template, allReplacements);
      await writeFile(dest, processed);
    }

    installedFiles.push(dest);
  }

  return {
    count: installedFiles.length,
    files: installedFiles,
  };
}

/**
 * Install all Claude Code agents (static + generated)
 */
export async function installAllClaudeCodeAgents(
  baseDir: string,
  projectDir: string,
  profile: string,
  config: { version: string; profile: string },
  dryRun: boolean = false
): Promise<InstallResult> {
  const staticResult = await installStaticAgents(baseDir, projectDir, profile, config, dryRun);
  const implementerResult = await generateImplementerAgents(
    baseDir,
    projectDir,
    profile,
    config,
    dryRun
  );
  const verifierResult = await generateVerifierAgents(baseDir, projectDir, profile, config, dryRun);

  return {
    count: staticResult.count + implementerResult.count + verifierResult.count,
    files: [...staticResult.files, ...implementerResult.files, ...verifierResult.files],
  };
}
