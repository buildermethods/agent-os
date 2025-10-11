/**
 * Profile Creation
 * Functions for creating profile structures
 */

import { $ } from 'bun';
import { joinPath, ensureDir } from '../../utils/files';
import { printStatus, printSuccess } from '../../utils/colors';

/**
 * Normalize profile name to valid format
 */
export function normalizeProfileName(name: string): string {
  return name
    .toLowerCase()
    .trim()
    .replace(/\s+/g, '-')
    .replace(/[^a-z0-9-]/g, '');
}

/**
 * Create profile by copying from existing profile
 */
async function copyProfile(
  profilesDir: string,
  profileName: string,
  copyFrom: string
): Promise<void> {
  const profilePath = joinPath(profilesDir, profileName);

  printStatus(`Copying from profile: ${copyFrom}`);
  await $`cp -r ${joinPath(profilesDir, copyFrom)} ${profilePath}`.quiet();

  const configContent = `inherits_from: false

# Profile configuration for ${profileName}
# Copied from: ${copyFrom}
`;
  await Bun.write(joinPath(profilePath, 'profile-config.yml'), configContent);

  printSuccess('Profile copied and configured');
}

/**
 * Create new profile structure with optional inheritance
 */
async function createNewProfile(
  profilesDir: string,
  profileName: string,
  inheritFrom: string | null
): Promise<void> {
  const profilePath = joinPath(profilesDir, profileName);

  await ensureDir(profilePath);

  // Create standard directories
  await ensureDir(joinPath(profilePath, 'standards'));
  await ensureDir(joinPath(profilePath, 'workflows/implementation'));
  await ensureDir(joinPath(profilePath, 'workflows/planning'));
  await ensureDir(joinPath(profilePath, 'workflows/specification'));

  // Create profile-config.yml
  let configContent = '';
  if (inheritFrom) {
    configContent = `inherits_from: ${inheritFrom}

# Uncomment and modify to exclude specific inherited files:
# exclude_inherited_files:
#   - standards/backend/api/*
#   - standards/backend/database/migrations.md
#   - workflows/implementation/specific-workflow.md
`;
  } else {
    configContent = `inherits_from: false

# Profile configuration for ${profileName}
`;
  }

  await Bun.write(joinPath(profilePath, 'profile-config.yml'), configContent);

  printSuccess('Profile structure created');
}

/**
 * Create profile structure (copy or new)
 */
export async function createProfileStructure(
  profilesDir: string,
  profileName: string,
  inheritFrom: string | null,
  copyFrom: string | null
): Promise<void> {
  printStatus('Creating profile structure...');

  if (copyFrom) {
    await copyProfile(profilesDir, profileName, copyFrom);
  } else {
    await createNewProfile(profilesDir, profileName, inheritFrom);
  }
}
