/**
 * Profile Prompts
 * Interactive prompts for profile configuration
 */

import * as clack from '@clack/prompts';
import { UserCancelledError } from '../../utils/errors';
import { normalizeProfileName } from './profile-creation';

/**
 * Prompt for profile name
 */
export async function promptProfileName(): Promise<string> {
  const profileInput = await clack.text({
    message: 'Enter a name for the new profile:',
    placeholder: 'e.g., rails, python, react, wordpress',
    validate: (value) => {
      if (!value) return 'Profile name is required';
      const normalized = normalizeProfileName(value);
      if (!normalized) return 'Profile name contains invalid characters';
      return undefined;
    },
  });

  if (clack.isCancel(profileInput)) {
    clack.cancel('Operation cancelled');
    throw new UserCancelledError();
  }

  return normalizeProfileName(profileInput as string);
}

/**
 * Prompt for profile inheritance
 */
export async function promptInheritance(
  availableProfiles: string[]
): Promise<string | null> {
  const inheritChoice = await clack.select({
    message: 'Should this profile inherit from an existing profile?',
    options: [
      { value: 'none', label: "Don't inherit" },
      ...availableProfiles.map((p) => ({ value: p, label: p })),
    ],
  });

  if (clack.isCancel(inheritChoice)) {
    clack.cancel('Operation cancelled');
    throw new UserCancelledError();
  }

  return inheritChoice === 'none' ? null : (inheritChoice as string);
}

/**
 * Prompt for copying from existing profile
 */
export async function promptCopy(availableProfiles: string[]): Promise<string | null> {
  const copyChoice = await clack.select({
    message: 'Copy contents from an existing profile?',
    options: [
      { value: 'none', label: "Don't copy, create empty structure" },
      ...availableProfiles.map((p) => ({ value: p, label: p })),
    ],
  });

  if (clack.isCancel(copyChoice)) {
    clack.cancel('Operation cancelled');
    throw new UserCancelledError();
  }

  return copyChoice === 'none' ? null : (copyChoice as string);
}
