import * as clack from '@clack/prompts';
import { colors } from '../utils/colors';
import { getHomeDir, joinPath } from '../utils/files';
import { UserCancelledError } from '../utils/errors';
import { createProfile } from '../libs/profiles/profile-creation-flows';

const BASE_DIR = joinPath(getHomeDir(), 'agent-os');
const PROFILES_DIR = joinPath(BASE_DIR, 'profiles');

export async function runCreateProfile() {
  console.clear();
  clack.intro(colors.blue('Create Agent OS Profile'));

  try {
    await createProfile(BASE_DIR, PROFILES_DIR);
  } catch (error) {
    if (error instanceof UserCancelledError) {
      return;
    }
    throw error;
  }
}
