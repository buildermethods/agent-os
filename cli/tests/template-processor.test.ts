import { describe, test, expect } from 'bun:test';
import { processTemplate, getCommonReplacements, buildRoleReplacements } from '../src/libs/templates/processor';
import type { Role } from '../src/types';

describe('Template Processor', () => {
  // Conditionals
  test('processes simple if statement with contains operator', async () => {
    const template = `
Before
{{if verification_capabilities contains "web"}}
This should be included
{{endif}}
After
`;

    const replacements = {
      verification_capabilities: 'web, api, database',
    };

    const result = await processTemplate(template, replacements);

    expect(result).toContain('This should be included');
    expect(result).toContain('Before');
    expect(result).toContain('After');
  });

  test('excludes content when contains condition is false', async () => {
    const template = `
Before
{{if verification_capabilities contains "mobile"}}
This should NOT be included
{{endif}}
After
`;

    const replacements = {
      verification_capabilities: 'web, api, database',
    };

    const result = await processTemplate(template, replacements);

    expect(result).not.toContain('This should NOT be included');
    expect(result).toContain('Before');
    expect(result).toContain('After');
  });

  test('processes equals operator', async () => {
    const template = `
{{if model equals "sonnet"}}
Using Sonnet model
{{endif}}
`;

    const replacements = {
      model: 'sonnet',
    };

    const result = await processTemplate(template, replacements);

    expect(result).toContain('Using Sonnet model');
  });

  test('excludes content when equals condition is false', async () => {
    const template = `
{{if model equals "gpt-4"}}
This should NOT be included
{{endif}}
`;

    const replacements = {
      model: 'sonnet',
    };

    const result = await processTemplate(template, replacements);

    expect(result).not.toContain('This should NOT be included');
  });

  test('processes simple variable existence check', async () => {
    const template = `
{{if has_tools}}
Tools are available
{{endif}}
`;

    const replacements = {
      has_tools: 'true',
    };

    const result = await processTemplate(template, replacements);

    expect(result).toContain('Tools are available');
  });

  test('excludes content when variable is false', async () => {
    const template = `
{{if has_tools}}
This should NOT be included
{{endif}}
`;

    const replacements = {
      has_tools: 'false',
    };

    const result = await processTemplate(template, replacements);

    expect(result).not.toContain('This should NOT be included');
  });

  test('excludes content when variable is missing', async () => {
    const template = `
{{if missing_variable}}
This should NOT be included
{{endif}}
`;

    const replacements = {};

    const result = await processTemplate(template, replacements);

    expect(result).not.toContain('This should NOT be included');
  });

  test('processes multiple conditionals', async () => {
    const template = `
{{if has_web contains "yes"}}
Web feature enabled
{{endif}}
{{if has_api contains "yes"}}
API feature enabled
{{endif}}
{{if has_mobile contains "yes"}}
Mobile feature enabled
{{endif}}
`;

    const replacements = {
      has_web: 'yes',
      has_api: 'yes',
      has_mobile: 'no',
    };

    const result = await processTemplate(template, replacements);

    expect(result).toContain('Web feature enabled');
    expect(result).toContain('API feature enabled');
    expect(result).not.toContain('Mobile feature enabled');
  });

  test('combines conditionals with variable replacements', async () => {
    const template = `
Project: {{project_name}}
{{if environment contains "production"}}
Environment: {{environment}}
Status: Live
{{endif}}
`;

    const replacements = {
      project_name: 'My App',
      environment: 'production',
    };

    const result = await processTemplate(template, replacements);

    expect(result).toContain('Project: My App');
    expect(result).toContain('Environment: production');
    expect(result).toContain('Status: Live');
  });

  test('handles multiline content in conditionals', async () => {
    const template = `
{{if show_docs contains "true"}}
# Documentation

This is a long
multiline documentation
section with multiple paragraphs.

And more content.
{{endif}}
`;

    const replacements = {
      show_docs: 'true',
    };

    const result = await processTemplate(template, replacements);

    expect(result).toContain('# Documentation');
    expect(result).toContain('multiline documentation');
    expect(result).toContain('And more content.');
  });

  // Variable Replacement
  test('replaces simple variables', async () => {
    const template = 'Version: {{version}}, Profile: {{profile}}';
    const replacements = {
      version: '2.0.3',
      profile: 'default',
    };

    const result = await processTemplate(template, replacements);

    expect(result).toBe('Version: 2.0.3, Profile: default');
  });

  test('handles missing variables', async () => {
    const template = 'Version: {{version}}, Missing: {{missing}}';
    const replacements = {
      version: '2.0.3',
    };

    const result = await processTemplate(template, replacements);

    expect(result).toContain('Version: 2.0.3');
    expect(result).toContain('{{missing}}'); // Should remain unreplaced
  });

  // Common Replacements
  test('generates common replacements', () => {
    const config = {
      version: '2.0.3',
      profile: 'default',
    };

    const replacements = getCommonReplacements(config);

    expect(replacements.version).toBe('2.0.3');
    expect(replacements.profile).toBe('default');
  });

  // Role Replacements
  test('builds role replacements with all fields', () => {
    const role: Role = {
      id: 'backend-dev',
      description: 'Backend developer',
      your_role: 'You are a backend specialist',
      tools: 'Glob, Grep, Write',
      model: 'sonnet',
      color: 'blue',
      areas_of_responsibility: ['API development', 'Database design'],
      example_areas_outside_of_responsibility: ['Frontend', 'Mobile'],
      standards: ['backend/api', 'backend/models'],
    };

    const replacements = buildRoleReplacements(role);

    expect(replacements.id).toBe('backend-dev');
    expect(replacements.description).toBe('Backend developer');
    expect(replacements.your_role).toBe('You are a backend specialist');
    expect(replacements.tools).toBe('Glob, Grep, Write');
    expect(replacements.model).toBe('sonnet');
    expect(replacements.color).toBe('blue');
    expect(replacements.areas_of_responsibility).toContain('- API development');
    expect(replacements.areas_of_responsibility).toContain('- Database design');
    expect(replacements.implementer_standards).toContain('@agent-os/standards/backend/api.md');
  });

  test('handles missing optional fields', () => {
    const role = {
      id: 'simple-dev',
    } as Role;

    const replacements = buildRoleReplacements(role);

    expect(replacements.id).toBe('simple-dev');
    expect(replacements.description).toBe('');
    expect(replacements.tools).toBe('');
  });

  test('builds verifier with verification_capabilities', () => {
    const verifier = {
      id: 'mobile-verifier',
      description: 'Mobile platform verifier',
      your_role: 'You verify mobile implementations',
      tools: 'Mobile MCP, Figma MCP',
      model: 'sonnet',
      color: 'red',
      areas_of_responsibility: ['Mobile UI', 'Native integrations'],
      example_areas_outside_of_responsibility: ['Backend'],
      standards: ['mobile/*'],
      verification_capabilities: ['mobile', 'figma', 'mobile-automation'],
    };

    const replacements = buildRoleReplacements(verifier as any);

    expect(replacements.id).toBe('mobile-verifier');
    expect(replacements.verification_capabilities).toBe('mobile, figma, mobile-automation');
  });

  test('verification_capabilities works with contains operator', async () => {
    const template = `
{{if verification_capabilities contains "mobile"}}
Mobile verification enabled
{{endif}}
{{if verification_capabilities contains "web"}}
Web verification enabled
{{endif}}
`;

    const verifier = {
      id: 'mobile-verifier',
      verification_capabilities: ['mobile', 'figma', 'mobile-automation'],
    };

    const replacements = buildRoleReplacements(verifier as any);
    const result = await processTemplate(template, replacements);

    expect(result).toContain('Mobile verification enabled');
    expect(result).not.toContain('Web verification enabled');
  });
});
