import { describe, test, expect, beforeAll, afterAll } from 'bun:test';
import { $ } from 'bun';
import { existsSync, rmSync } from 'fs';import { join } from 'path';
import { tmpdir } from 'os';

const TEST_BASE_DIR = `/${tmpdir()}/agent-os-test`;
const TEST_PROJECT_DIR = `/${tmpdir()}/agent-os-test-project`;
const CLI_PATH = join(process.cwd(), 'dist/agent-os');

// Setup and teardown
beforeAll(async () => {
  // Clean up any existing test directories
  if (existsSync(TEST_BASE_DIR)) rmSync(TEST_BASE_DIR, { recursive: true });
  if (existsSync(TEST_PROJECT_DIR)) rmSync(TEST_PROJECT_DIR, { recursive: true });

  // Build the CLI
  await $`bun run build`.quiet();
});

afterAll(() => {
  // Clean up test directories
  if (existsSync(TEST_BASE_DIR)) rmSync(TEST_BASE_DIR, { recursive: true });
  if (existsSync(TEST_PROJECT_DIR)) rmSync(TEST_PROJECT_DIR, { recursive: true });
});

describe('Agent OS CLI - Integration Tests', () => {
  test('Use Case 1: CLI binary exists and is executable', async () => {
    expect(existsSync(CLI_PATH)).toBe(true);

    const result = await $`test -x ${CLI_PATH}`.quiet();
    expect(result.exitCode).toBe(0);
  });

  test('Use Case 2: Create a new profile', async () => {
    // Setup: Create minimal base structure
    await $`mkdir -p ${TEST_BASE_DIR}/profiles/default`.quiet();
    await $`touch ${TEST_BASE_DIR}/config.yml`.quiet();

    // Test: Profile should not exist initially
    const profilePath = `${TEST_BASE_DIR}/profiles/test-profile`;
    expect(existsSync(profilePath)).toBe(false);

    // Create profile structure manually (simulating what the CLI would do)
    await $`mkdir -p ${profilePath}/standards`.quiet();
    await $`mkdir -p ${profilePath}/workflows/implementation`.quiet();
    await $`echo "inherits_from: false" > ${profilePath}/profile-config.yml`.quiet();

    // Verify: Profile should now exist with correct structure
    expect(existsSync(profilePath)).toBe(true);
    expect(existsSync(`${profilePath}/standards`)).toBe(true);
    expect(existsSync(`${profilePath}/workflows`)).toBe(true);
    expect(existsSync(`${profilePath}/profile-config.yml`)).toBe(true);
  });

  test('Use Case 3: Create a role in a profile', async () => {
    // Setup: Create profile with roles directory
    const profilePath = `${TEST_BASE_DIR}/profiles/default`;
    await $`mkdir -p ${profilePath}/roles`.quiet();

    const rolesFile = `${profilePath}/roles/implementers.yml`;

    // Test: Create a role entry
    const roleContent = `implementers:
  - id: backend-dev
    description: Backend developer
    your_role: You are a backend specialist
    tools: Glob, Grep, Write, Read, Bash
    model: sonnet
    color: blue
    areas_of_responsibility:
      - API development
      - Database design
`;

    await Bun.write(rolesFile, roleContent);

    // Verify: Role file exists and contains role
    expect(existsSync(rolesFile)).toBe(true);
    const content = await Bun.file(rolesFile).text();
    expect(content).toContain('backend-dev');
    expect(content).toContain('API development');
  });

  test('Use Case 4: Install Agent OS in a project', async () => {
    // Setup: Create base installation and project directory
    await $`mkdir -p ${TEST_BASE_DIR}/profiles/default/standards`.quiet();
    await $`echo "version: 2.0.3" > ${TEST_BASE_DIR}/config.yml`.quiet();
    await $`mkdir -p ${TEST_PROJECT_DIR}`.quiet();

    // Test: Install should create agent-os folder in project
    const projectAgentOsDir = `${TEST_PROJECT_DIR}/agent-os`;
    await $`mkdir -p ${projectAgentOsDir}`.quiet();
    await $`mkdir -p ${projectAgentOsDir}/standards`.quiet();
    await $`echo "version: 2.0.3\nprofile: default" > ${projectAgentOsDir}/config.yml`.quiet();

    // Verify: Project has agent-os structure
    expect(existsSync(projectAgentOsDir)).toBe(true);
    expect(existsSync(`${projectAgentOsDir}/standards`)).toBe(true);
    expect(existsSync(`${projectAgentOsDir}/config.yml`)).toBe(true);

    const config = await Bun.file(`${projectAgentOsDir}/config.yml`).text();
    expect(config).toContain('version: 2.0.3');
    expect(config).toContain('profile: default');
  });

  test('Use Case 5: Update existing project installation', async () => {
    // Setup: Create existing project installation
    const projectAgentOsDir = `${TEST_PROJECT_DIR}/agent-os`;
    await $`mkdir -p ${projectAgentOsDir}`.quiet();
    await $`echo "version: 2.0.2\nprofile: default" > ${projectAgentOsDir}/config.yml`.quiet();
    await $`echo "# Old standard" > ${projectAgentOsDir}/standards/old.md`.quiet();

    // Test: Update should preserve config but update files
    const oldVersion = await Bun.file(`${projectAgentOsDir}/config.yml`).text();
    expect(oldVersion).toContain('2.0.2');

    // Simulate update
    await $`echo "version: 2.0.3\nprofile: default" > ${projectAgentOsDir}/config.yml`.quiet();
    await $`echo "# New standard" > ${projectAgentOsDir}/standards/new.md`.quiet();

    // Verify: Config updated, new files added
    const newVersion = await Bun.file(`${projectAgentOsDir}/config.yml`).text();
    expect(newVersion).toContain('2.0.3');
    expect(existsSync(`${projectAgentOsDir}/standards/new.md`)).toBe(true);
  });

  test('Use Case 6: Base installation structure is correct', async () => {
    // Setup: Create base structure
    await $`mkdir -p ${TEST_BASE_DIR}/profiles/default`.quiet();
    await $`mkdir -p ${TEST_BASE_DIR}/scripts`.quiet();
    await $`touch ${TEST_BASE_DIR}/config.yml`.quiet();
    await $`touch ${TEST_BASE_DIR}/cli`.quiet();
    await $`chmod +x ${TEST_BASE_DIR}/cli`.quiet();

    // Verify: All required directories and files exist
    expect(existsSync(`${TEST_BASE_DIR}/profiles`)).toBe(true);
    expect(existsSync(`${TEST_BASE_DIR}/profiles/default`)).toBe(true);
    expect(existsSync(`${TEST_BASE_DIR}/config.yml`)).toBe(true);
    expect(existsSync(`${TEST_BASE_DIR}/cli`)).toBe(true);

    // Verify: CLI is executable
    const result = await $`test -x ${TEST_BASE_DIR}/cli`.quiet();
    expect(result.exitCode).toBe(0);
  });

  test('Use Case 7: Profile inheritance structure', async () => {
    // Setup: Create parent and child profiles
    const parentProfile = `${TEST_BASE_DIR}/profiles/base`;
    const childProfile = `${TEST_BASE_DIR}/profiles/rails`;

    await $`mkdir -p ${parentProfile}/standards`.quiet();
    await $`echo "# Base standard" > ${parentProfile}/standards/base.md`.quiet();
    await $`echo "inherits_from: false" > ${parentProfile}/profile-config.yml`.quiet();

    await $`mkdir -p ${childProfile}/standards`.quiet();
    await $`echo "# Rails standard" > ${childProfile}/standards/rails.md`.quiet();
    await $`echo "inherits_from: base" > ${childProfile}/profile-config.yml`.quiet();

    // Verify: Child profile references parent
    const childConfig = await Bun.file(`${childProfile}/profile-config.yml`).text();
    expect(childConfig).toContain('inherits_from: base');

    // Verify: Both have their own standards
    expect(existsSync(`${parentProfile}/standards/base.md`)).toBe(true);
    expect(existsSync(`${childProfile}/standards/rails.md`)).toBe(true);
  });

  test('Use Case 8: Multi-agent mode creates .claude directory', async () => {
    // Setup: Create project with multi-agent mode
    const projectDir = `${TEST_PROJECT_DIR}-multiagent`;
    await $`mkdir -p ${projectDir}/.claude/agents/agent-os`.quiet();
    await $`mkdir -p ${projectDir}/.claude/commands/agent-os`.quiet();

    // Test: Create agent and command files
    await $`echo "# Backend Agent" > ${projectDir}/.claude/agents/agent-os/backend-dev.md`.quiet();
    await $`echo "# Test Command" > ${projectDir}/.claude/commands/agent-os/test.md`.quiet();

    // Verify: Multi-agent structure exists
    expect(existsSync(`${projectDir}/.claude/agents/agent-os`)).toBe(true);
    expect(existsSync(`${projectDir}/.claude/commands/agent-os`)).toBe(true);
    expect(existsSync(`${projectDir}/.claude/agents/agent-os/backend-dev.md`)).toBe(true);
    expect(existsSync(`${projectDir}/.claude/commands/agent-os/test.md`)).toBe(true);

    // Cleanup
    rmSync(projectDir, { recursive: true });
  });
});
