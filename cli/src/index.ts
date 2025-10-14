#!/usr/bin/env bun
import * as clack from '@clack/prompts';
import { colors } from './utils/colors';

const LOGO = `
   █████╗  ██████╗ ███████╗███╗   ██╗████████╗     ██████╗ ███████╗
  ██╔══██╗██╔════╝ ██╔════╝████╗  ██║╚══██╔══╝    ██╔═══██╗██╔════╝
  ███████║██║  ███╗█████╗  ██╔██╗ ██║   ██║       ██║   ██║███████╗
  ██╔══██║██║   ██║██╔══╝  ██║╚██╗██║   ██║       ██║   ██║╚════██║
  ██║  ██║╚██████╔╝███████╗██║ ╚████║   ██║       ╚██████╔╝███████║
  ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝   ╚═╝        ╚═════╝ ╚══════╝
`;

async function showMainMenu() {
  console.clear();

  // Display logo
  console.log(colors.red(LOGO));
  console.log(colors.dim('  Agent Framework by Builder Methods - Created by Brian Casel\n'));

  clack.intro(colors.red('Agent OS CLI'));
  console.log(colors.dim('  Press Ctrl+C at any time to cancel and return to menu\n'));

  const command = await clack.select({
    message: 'What would you like to do?',
    options: [
      { value: 'project-install', label: 'Install Agent OS in project', hint: 'Current directory' },
      {
        value: 'project-update',
        label: 'Update Agent OS in project',
        hint: 'Update existing installation',
      },
      { value: 'create-profile', label: 'Create new profile', hint: 'Create custom profile' },
      { value: 'create-role', label: 'Create new role', hint: 'Add implementer or verifier' },
      { value: 'base-update', label: 'Update base installation', hint: 'Update Agent OS base' },
      { value: 'exit', label: 'Exit', hint: '' },
    ],
  });

  if (clack.isCancel(command)) {
    return 'exit';
  }

  return command as string;
}

async function main() {
  let shouldContinue = true;

  while (shouldContinue) {
    try {
      const command = await showMainMenu();

      switch (command) {
        case 'project-install':
          const { runProjectInstall } = await import('./commands/project-install');
          await runProjectInstall();
          break;

        case 'project-update':
          const { runProjectUpdate } = await import('./commands/project-update');
          await runProjectUpdate();
          break;

        case 'create-profile':
          const { runCreateProfile } = await import('./commands/create-profile');
          await runCreateProfile();
          break;

        case 'create-role':
          const { runCreateRole } = await import('./commands/create-role');
          await runCreateRole();
          break;

        case 'base-update':
          const { runBaseUpdate } = await import('./commands/base-update');
          await runBaseUpdate();
          break;

        case 'exit':
          clack.outro(colors.green('Goodbye!'));
          shouldContinue = false;
          break;
      }

      if (shouldContinue && command !== 'exit') {
        console.log('');
        clack.outro(colors.green('Done!'));
        console.log('');

        // Prompt to continue
        const continueChoice = await clack.confirm({
          message: 'Return to main menu?',
          initialValue: true,
        });

        if (clack.isCancel(continueChoice) || !continueChoice) {
          clack.outro(colors.green('Goodbye!'));
          shouldContinue = false;
        }
      }
    } catch (error) {
      clack.log.error(`Error: ${error}`);
      const retry = await clack.confirm({
        message: 'Would you like to return to the main menu?',
        initialValue: true,
      });

      if (clack.isCancel(retry) || !retry) {
        shouldContinue = false;
      }
    }
  }
}

main();
