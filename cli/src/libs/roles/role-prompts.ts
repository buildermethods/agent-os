/**
 * Role UI Prompts
 * Interactive prompts for gathering role configuration from user
 */

import * as clack from '@clack/prompts';
import { UserCancelledError } from '../../utils/errors';
import type { RoleType } from './types';

/**
 * Interactive role type selection
 */
export async function selectRoleType(): Promise<RoleType> {
  const choice = await clack.select({
    message: 'What type of role do you wish to create? (Ctrl+C to cancel)',
    options: [
      {
        value: 'implementer' as RoleType,
        label: 'Implementer',
        hint: 'Specialized agents that write code for specific areas',
      },
      {
        value: 'verifier' as RoleType,
        label: 'Verifier',
        hint: 'Review and validate the work of implementers',
      },
    ],
  });

  if (clack.isCancel(choice)) {
    clack.cancel('Operation cancelled');
    throw new UserCancelledError();
  }

  return choice;
}

/**
 * Get role ID from user
 */
export async function getRoleId(): Promise<string> {
  const roleId = await clack.text({
    message: 'Enter an ID for this role:',
    placeholder: 'backend-developer',
    validate: (value) => {
      if (!value) return 'Role ID is required';
      const normalized = value
        .toLowerCase()
        .replace(/[\s_]/g, '-')
        .replace(/[^a-z0-9-]/g, '');
      if (!normalized) return 'Invalid role ID';
      return;
    },
  });

  if (clack.isCancel(roleId)) {
    clack.cancel('Operation cancelled');
    throw new UserCancelledError();
  }

  // Normalize the ID
  const normalized = roleId
    .toLowerCase()
    .replace(/[\s_]/g, '-')
    .replace(/[^a-z0-9-]/g, '');
  return normalized;
}

/**
 * Get role description
 */
export async function getRoleDescription(): Promise<string> {
  const description = await clack.text({
    message: 'Enter a description for this role:',
    placeholder: 'Specializes in backend API development and database design',
    validate: (value) => {
      if (!value) return 'Description is required';
    },
  });

  if (clack.isCancel(description)) {
    clack.cancel('Operation cancelled');
    throw new UserCancelledError();
  }

  return description;
}

/**
 * Get role text (what the agent's role is)
 */
export async function getRoleText(): Promise<string> {
  const roleText = await clack.text({
    message: 'Enter text that informs the agent what their role is:',
    placeholder: 'You are a backend specialist focused on API design and database optimization',
    validate: (value) => {
      if (!value) return 'Role text is required';
    },
  });

  if (clack.isCancel(roleText)) {
    clack.cancel('Operation cancelled');
    throw new UserCancelledError();
  }

  return roleText;
}

/**
 * Get areas of responsibility
 */
export async function getAreasOfResponsibility(): Promise<string[]> {
  const areasInput = await clack.text({
    message: 'Define areas of responsibility (comma-separated):',
    placeholder: 'API endpoint development, Database schema design, Authentication systems',
  });

  if (clack.isCancel(areasInput)) {
    clack.cancel('Operation cancelled');
    throw new UserCancelledError();
  }

  if (!areasInput) return [];

  return areasInput
    .split(',')
    .map((s) => s.trim())
    .filter((s) => s.length > 0);
}

/**
 * Get areas outside of responsibility
 */
export async function getOutOfScopeAreas(): Promise<string[]> {
  const areasInput = await clack.text({
    message: 'Define areas outside of responsibility (comma-separated):',
    placeholder: 'Frontend UI components, Mobile app development, DevOps infrastructure',
  });

  if (clack.isCancel(areasInput)) {
    clack.cancel('Operation cancelled');
    throw new UserCancelledError();
  }

  if (!areasInput) return [];

  return areasInput
    .split(',')
    .map((s) => s.trim())
    .filter((s) => s.length > 0);
}
