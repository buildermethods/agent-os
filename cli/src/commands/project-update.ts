import * as clack from '@clack/prompts';
import { colors, printError } from '../utils/colors';
import { getHomeDir, joinPath } from '../utils/files';
import { UserCancelledError } from '../utils/errors';
import { performUpdate, validateUpdatePreconditions } from '../libs/installation/project-update-flows';

const BASE_DIR = joinPath(getHomeDir(), 'agent-os');
const PROJECT_DIR = process.cwd();

export async function runProjectUpdate() {
  console.clear();
  clack.intro(colors.blue('Agent OS Project Update'));

  await validateUpdatePreconditions(BASE_DIR, PROJECT_DIR);

  try {
    await performUpdate(BASE_DIR, PROJECT_DIR, { verbose: false });
  } catch (error) {
    if (error instanceof UserCancelledError) {
      return;
    }
    printError(`Update failed: ${error}`);
    throw error;
  }
}
