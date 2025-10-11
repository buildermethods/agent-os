/**
 * Role Configuration Prompts
 * Prompts for selecting tools, models, colors, standards, and verifiers
 */

import * as clack from '@clack/prompts';
import { colors } from '../../utils/colors';
import { UserCancelledError } from '../../utils/errors';

/**
 * Configure tools for the role
 */
export async function configureTools(): Promise<string> {
  const standardTools = 'Glob, Grep, Write, Read, Bash, WebFetch';

  const addMore = await clack.confirm({
    message: 'Add tools beyond the standard set?',
    initialValue: false,
  });

  if (clack.isCancel(addMore)) {
    clack.cancel('Operation cancelled');
    throw new UserCancelledError();
  }

  let tools = standardTools;

  if (addMore) {
    const addPlaywright = await clack.confirm({
      message: 'Add Playwright tool for browser interaction?',
    });

    if (clack.isCancel(addPlaywright)) {
      clack.cancel('Operation cancelled');
      throw new UserCancelledError();
    }

    if (addPlaywright) {
      tools += ', Playwright';
      clack.log.info('Note: Requires Playwright MCP to be installed');
    }

    const additionalTools = await clack.text({
      message: 'Add any additional tools? (comma-separated)',
      placeholder: 'WebSearch, MultiEdit',
    });

    if (clack.isCancel(additionalTools)) {
      clack.cancel('Operation cancelled');
      throw new UserCancelledError();
    }

    if (additionalTools) {
      tools += `, ${additionalTools}`;
    }
  }

  return tools;
}

/**
 * Select model for the role
 */
export async function selectModel(): Promise<string> {
  const model = await clack.select({
    message: 'Select the model for this agent:',
    options: [
      { value: 'sonnet', label: 'Sonnet' },
      { value: 'opus', label: 'Opus' },
      { value: 'inherit', label: 'Inherit from Claude Code settings' },
    ],
  });

  if (clack.isCancel(model)) {
    clack.cancel('Operation cancelled');
    throw new UserCancelledError();
  }

  return model;
}

/**
 * Select color for the role
 */
export async function selectColor(): Promise<string> {
  const color = await clack.select({
    message: 'Select a color for this agent:',
    options: [
      { value: 'red', label: colors.red('Red') },
      { value: 'blue', label: colors.blue('Blue') },
      { value: 'green', label: colors.green('Green') },
      { value: 'purple', label: colors.purple('Purple') },
      { value: 'pink', label: 'Pink' },
      { value: 'orange', label: 'Orange' },
      { value: 'cyan', label: 'Cyan' },
      { value: 'yellow', label: colors.yellow('Yellow') },
    ],
  });

  if (clack.isCancel(color)) {
    clack.cancel('Operation cancelled');
    throw new UserCancelledError();
  }

  return color;
}

/**
 * Select standards from available options
 */
export async function selectStandards(availableStandards: string[]): Promise<string[]> {
  if (availableStandards.length === 0) {
    clack.log.warn('No standards found for this profile');
    return [];
  }

  const skipStandards = await clack.confirm({
    message: 'Define standards for this role?',
    initialValue: true,
  });

  if (clack.isCancel(skipStandards) || !skipStandards) {
    return [];
  }

  const options = availableStandards.map((std) => ({
    value: std,
    label: std,
  }));

  // Add "select all" option
  options.unshift({ value: '__all__', label: 'Select all standards' });

  const selected = await clack.multiselect({
    message: 'Select standards to include:',
    options,
    required: false,
  });

  if (clack.isCancel(selected)) {
    clack.cancel('Operation cancelled');
    throw new UserCancelledError();
  }

  if (selected.includes('__all__')) {
    return availableStandards;
  }

  return selected as string[];
}

/**
 * Select verifiers for an implementer role
 */
export async function selectVerifiers(availableVerifiers: string[]): Promise<string[]> {
  if (availableVerifiers.length === 0) {
    return [];
  }

  const addVerifiers = await clack.confirm({
    message: "Select verifiers to check this implementer's work?",
    initialValue: false,
  });

  if (clack.isCancel(addVerifiers) || !addVerifiers) {
    return [];
  }

  const options = availableVerifiers.map((v) => ({
    value: v,
    label: v,
  }));

  const selected = await clack.multiselect({
    message: 'Select verifiers:',
    options,
    required: false,
  });

  if (clack.isCancel(selected)) {
    clack.cancel('Operation cancelled');
    throw new UserCancelledError();
  }

  return selected as string[];
}
