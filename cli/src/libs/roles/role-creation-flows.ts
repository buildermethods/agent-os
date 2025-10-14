/**
 * Role Creation Flows
 * High-level flows for creating roles
 */

import * as clack from '@clack/prompts';
import { printSuccess, printError, printStatus } from '../../utils/colors';
import { joinPath, fileExists } from '../../utils/files';
import {
  selectRoleType,
  getRoleId,
  getRoleDescription,
  getRoleText,
  configureTools,
  selectModel,
  selectColor,
  getAreasOfResponsibility,
  getOutOfScopeAreas,
  selectStandards,
  selectVerifiers,
  type RoleConfiguration,
} from './role-builder';
import {
  getAvailableProfiles,
  selectProfile,
  getAvailableStandards,
  getAvailableVerifiers,
} from '../profiles/profile-discovery';
import { saveRoleConfiguration } from './role-file-operations';

/**
 * Validate base installation exists
 */
export async function validateInstallation(baseDir: string, profilesDir: string): Promise<void> {
  if (!(await fileExists(baseDir))) {
    printError(`Agent OS base installation not found at ${baseDir}`);
    printError('Please run base-install first.');
    process.exit(1);
  }

  if (!(await fileExists(profilesDir))) {
    printError(`Profiles directory not found at ${profilesDir}`);
    process.exit(1);
  }
}

/**
 * Get profile selection from user
 */
export async function getProfileSelection(
  profilesDir: string
): Promise<{ name: string; path: string }> {
  const profiles = await getAvailableProfiles(profilesDir);

  if (profiles.length === 0) {
    printError('No profiles found. Please create a profile first using create-profile.');
    process.exit(1);
  }

  const profileName = await selectProfile(profiles);
  const profilePath = joinPath(profilesDir, profileName);

  printSuccess(`Using profile: ${profileName}`);
  console.log('');

  return { name: profileName, path: profilePath };
}

/**
 * Check if role already exists
 */
export async function checkRoleExists(profilePath: string, roleId: string): Promise<void> {
  const rolePath = joinPath(profilePath, 'roles', roleId);
  if (await fileExists(rolePath)) {
    const profileName = profilePath.split('/').pop();
    printError(`Role '${roleId}' already exists in profile '${profileName}'`);
    process.exit(1);
  }
}

/**
 * Gather all role configuration from user
 */
export async function gatherRoleConfiguration(
  profilePath: string,
  roleType: 'implementer' | 'verifier'
): Promise<RoleConfiguration> {
  const roleId = await getRoleId();
  await checkRoleExists(profilePath, roleId);

  const description = await getRoleDescription();
  const yourRole = await getRoleText();
  const tools = await configureTools();
  const model = await selectModel();
  const color = await selectColor();
  const areasOfResponsibility = await getAreasOfResponsibility();
  const exampleAreasOutsideOfResponsibility = await getOutOfScopeAreas();

  // Get standards
  const availableStandards = await getAvailableStandards(profilePath);
  const standards = await selectStandards(availableStandards);

  // Get verifiers if implementer
  let verifiedBy: string[] = [];
  if (roleType === 'implementer') {
    const availableVerifiers = await getAvailableVerifiers(profilePath);
    verifiedBy = await selectVerifiers(availableVerifiers);
  }

  return {
    type: roleType,
    id: roleId,
    description,
    yourRole,
    tools,
    model,
    color,
    areasOfResponsibility,
    exampleAreasOutsideOfResponsibility,
    standards,
    verifiedBy,
  };
}

/**
 * Display success message after role creation
 */
export function displaySuccessMessage(
  profilesDir: string,
  profileName: string,
  roleType: string,
  roleId: string
): void {
  const rolePath = joinPath(profilesDir, profileName, 'roles', roleId);

  console.log('');
  printSuccess(`Role '${roleId}' has been successfully created!`);
  console.log('');
  printStatus(`Profile: ${profileName}`);
  printStatus(`Type: ${roleType}`);
  printStatus(`Location: ${rolePath}`);
  console.log('');

  clack.note(
    `1. Customize the role by editing: ${rolePath}/config.yml\n` +
      `2. Install Agent OS in a project using this profile:\n` +
      `   agent-os project-install --profile ${profileName}\n\n` +
      `Visit the docs: https://buildermethods.com/agent-os/roles`,
    'Next steps:'
  );

  console.log('');
}

/**
 * Complete role creation flow
 */
export async function createRole(baseDir: string, profilesDir: string): Promise<void> {
  await validateInstallation(baseDir, profilesDir);

  const { name: profileName, path: profilePath } = await getProfileSelection(profilesDir);

  const roleType = await selectRoleType();
  const config = await gatherRoleConfiguration(profilePath, roleType);

  await saveRoleConfiguration(profilePath, config);

  displaySuccessMessage(profilesDir, profileName, roleType, config.id);
}
