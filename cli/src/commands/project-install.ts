import * as clack from '@clack/prompts';
import { colors, printError } from '../utils/colors';
import { getHomeDir, joinPath } from '../utils/files';
import { UserCancelledError } from '../utils/errors';
import {
  performInstallation,
  handleReinstallation,
  isAgentOsInstalled,
  validateBaseInstallation,
} from '../libs/installation/project-install-flows';

const BASE_DIR = joinPath(getHomeDir(), 'agent-os');
const PROJECT_DIR = process.cwd();

export async function runProjectInstall() {
  console.clear();
  clack.intro(colors.blue('Agent OS Project Installation'));

  await validateBaseInstallation(BASE_DIR);

  try {
    if (await isAgentOsInstalled(PROJECT_DIR)) {
      clack.log.warn('Agent OS is already installed in this project');

      const shouldUpdate = await clack.confirm({
        message: 'Would you like to update instead?',
      });

      if (clack.isCancel(shouldUpdate)) {
        throw new UserCancelledError();
      }

      if (shouldUpdate) {
        const { runProjectUpdate } = await import('./project-update');
        await runProjectUpdate();
        return;
      }

      const shouldReinstall = await clack.confirm({
        message: 'Would you like to reinstall (delete and install fresh)?',
      });

      if (clack.isCancel(shouldReinstall)) {
        throw new UserCancelledError();
      }

      if (shouldReinstall) {
        await handleReinstallation(BASE_DIR, PROJECT_DIR, { verbose: false, reInstall: true });
        return;
      }

      return;
    }

    await performInstallation(BASE_DIR, PROJECT_DIR, { verbose: false });
  } catch (error) {
    if (error instanceof UserCancelledError) {
      return;
    }
    printError(`Installation failed: ${error}`);
    throw error;
  }
}
