/**
 * Profile Creation Flows
 * High-level flows for creating profiles
 */

import * as clack from '@clack/prompts';
import { printSuccess, printError, printStatus } from '../../utils/colors';
import { joinPath, fileExists } from '../../utils/files';
import { getAvailableProfiles } from './profile-discovery';
import { createProfileStructure } from './profile-creation';
import { promptProfileName, promptInheritance, promptCopy } from './profile-prompts';

/**
 * Validate base installation exists
 */
export async function validateInstallation(baseDir: string, profilesDir: string): Promise<void> {
  if (!(await fileExists(baseDir))) {
    printError('Agent OS not installed. Please run base-install first.');
    process.exit(1);
  }

  if (!(await fileExists(profilesDir))) {
    printError(`Profiles directory not found at ${profilesDir}`);
    process.exit(1);
  }
}

/**
 * Check if profile already exists
 */
export async function checkProfileExists(profilesDir: string, profileName: string): Promise<void> {
  if (await fileExists(joinPath(profilesDir, profileName))) {
    printError(`Profile '${profileName}' already exists`);
    process.exit(1);
  }
}

/**
 * Select inheritance or copy option
 */
export async function selectInheritanceOrCopy(
  availableProfiles: string[]
): Promise<{ inheritFrom: string | null; copyFrom: string | null }> {
  if (availableProfiles.length === 0) {
    return { inheritFrom: null, copyFrom: null };
  }

  const inheritFrom = await promptInheritance(availableProfiles);

  if (inheritFrom) {
    printSuccess(`Profile will inherit from: ${inheritFrom}`);
    return { inheritFrom, copyFrom: null };
  }

  const copyFrom = await promptCopy(availableProfiles);

  if (copyFrom) {
    printSuccess(`Will copy contents from: ${copyFrom}`);
  }

  return { inheritFrom: null, copyFrom };
}

/**
 * Display success message after profile creation
 */
export function displaySuccessMessage(
  profilesDir: string,
  profileName: string,
  inheritFrom: string | null,
  copyFrom: string | null
): void {
  console.log('');
  printSuccess(`Profile '${profileName}' has been successfully created!`);
  console.log('');
  printStatus(`Location: ${joinPath(profilesDir, profileName)}`);

  if (inheritFrom) {
    console.log('');
    printStatus(`This profile inherits from: ${inheritFrom}`);
  } else if (copyFrom) {
    console.log('');
    printStatus(`This profile was copied from: ${copyFrom}`);
  }

  console.log('');
  clack.note(
    `1. Customize standards, workflows, and configurations in your profile\n` +
      `2. Use 'agent-os create-role' to add agent roles to this profile\n` +
      `3. Install Agent OS in a project using this profile with:\n` +
      `   agent-os project-install --profile ${profileName}\n\n` +
      `Visit the docs: https://buildermethods.com/agent-os/profiles`,
    'Next steps:'
  );

  console.log('');
}

/**
 * Complete profile creation flow
 */
export async function createProfile(baseDir: string, profilesDir: string): Promise<void> {
  await validateInstallation(baseDir, profilesDir);

  const profileName = await promptProfileName();
  await checkProfileExists(profilesDir, profileName);

  printSuccess(`Profile name set to: ${profileName}`);

  const availableProfiles = await getAvailableProfiles(profilesDir);
  const { inheritFrom, copyFrom } = await selectInheritanceOrCopy(availableProfiles);

  await createProfileStructure(profilesDir, profileName, inheritFrom, copyFrom);

  displaySuccessMessage(profilesDir, profileName, inheritFrom, copyFrom);
}
