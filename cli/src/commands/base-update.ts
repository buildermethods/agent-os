import * as clack from '@clack/prompts';
import { colors, printError } from '../utils/colors';
import { getHomeDir, joinPath } from '../utils/files';
import {
  checkExistingInstallation,
  validateBaseExists,
  parseArguments,
} from '../libs/installation/base-update-flows';

const BASE_DIR = joinPath(getHomeDir(), 'agent-os');
const EXCLUSIONS = ['old-versions/*', '.git*', '.github/*', 'cli/*'];

export async function runBaseUpdate() {
  console.clear();
  clack.intro(colors.blue('Agent OS Base Update'));

  await validateBaseExists(BASE_DIR);

  const options = parseArguments();

  try {
    await checkExistingInstallation(BASE_DIR, EXCLUSIONS, options);
  } catch (error) {
    printError(`Update failed: ${error}`);
    process.exit(1);
  }

  clack.outro(colors.green('Update complete!'));
}
