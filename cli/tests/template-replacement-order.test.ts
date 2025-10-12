import { describe, test, expect, beforeEach, afterEach } from 'bun:test';
import { processTemplate } from '../src/libs/templates/processor';
import { joinPath } from '../src/utils/files';
import { mkdirSync, writeFileSync, rmSync, existsSync } from 'fs';

describe('Template Processor - Replacement Order', () => {
  const testDir = '/tmp/agent-os-test-replacement-order';
  const profileDir = joinPath(testDir, 'profiles', 'default');
  const workflowsDir = joinPath(profileDir, 'workflows');
  const standardsDir = joinPath(profileDir, 'standards');

  // Setup test files before each test
  beforeEach(() => {
    // Clean up if exists from previous test
    if (existsSync(testDir)) {
      rmSync(testDir, { recursive: true, force: true });
    }

    // Create directory structure
    mkdirSync(workflowsDir, { recursive: true });
    mkdirSync(joinPath(standardsDir, 'code-quality'), { recursive: true });

    // Create workflow file with bash command containing special characters
    writeFileSync(
      joinPath(workflowsDir, 'test-workflow.md'),
      `# Test Workflow

This is a workflow that contains a bash command:

\`\`\`bash
ls -la [spec-path]/planning/visuals/ 2>/dev/null | grep -E '\\.(png|jpg|jpeg|gif|svg|pdf)$' || echo "No visual files found"
\`\`\`

More content after the bash command.
`
    );

    // Create some standards files
    writeFileSync(
      joinPath(standardsDir, 'code-quality', 'typescript-patterns.md'),
      '# TypeScript Patterns\n\nUse strict typing.'
    );
    writeFileSync(
      joinPath(standardsDir, 'code-quality', 'documentation.md'),
      '# Documentation\n\nDocument all public APIs.'
    );
  });

  afterEach(() => {
    // Clean up test directory
    if (existsSync(testDir)) {
      rmSync(testDir, { recursive: true, force: true });
    }
  });

  test('should not break bash commands when inserting standards list', async () => {
    // This template simulates the structure of spec-researcher.md
    const template = `Some content before

{{workflows/test-workflow}}

## User Standards & Preferences Compliance

IMPORTANT: Ensure standards compliance:

{{standards/*}}

Content after standards.`;

    const result = await processTemplate(template, {}, testDir, 'default');

    // The bash command should remain intact on a single line
    expect(result).toContain(
      `ls -la [spec-path]/planning/visuals/ 2>/dev/null | grep -E '\\.(png|jpg|jpeg|gif|svg|pdf)$' || echo "No visual files found"`
    );

    // The standards list should appear in the correct location
    expect(result).toContain('- agent-os/standards/code-quality/documentation.md');
    expect(result).toContain('- agent-os/standards/code-quality/typescript-patterns.md');

    // Standards should NOT appear inside the bash command
    const bashCommandStart = result.indexOf('ls -la [spec-path]');
    const bashCommandEnd = result.indexOf('No visual files found"', bashCommandStart);
    const bashCommandSection = result.substring(bashCommandStart, bashCommandEnd + 25);

    expect(bashCommandSection).not.toContain('agent-os/standards');
    expect(bashCommandSection).not.toContain('User Standards');
  });

  test('should handle multiple template replacements in correct order', async () => {
    // Create a second workflow file
    writeFileSync(
      joinPath(workflowsDir, 'another-workflow.md'),
      '# Another Workflow\n\nThis is workflow 2.'
    );

    const template = `Start

First workflow: {{workflows/test-workflow}}

Middle section

Second workflow: {{workflows/another-workflow}}

Standards: {{standards/*}}

End`;

    const result = await processTemplate(template, {}, testDir, 'default');

    // Check that both workflows are included
    expect(result).toContain('# Test Workflow');
    expect(result).toContain('# Another Workflow');

    // Check that the bash command is still intact
    expect(result).toContain(
      `ls -la [spec-path]/planning/visuals/ 2>/dev/null | grep -E '\\.(png|jpg|jpeg|gif|svg|pdf)$' || echo "No visual files found"`
    );

    // Check that standards appear in the right place
    expect(result).toContain('- agent-os/standards/code-quality/documentation.md');

    // Verify the order is preserved
    const firstWorkflowIndex = result.indexOf('# Test Workflow');
    const middleIndex = result.indexOf('Middle section');
    const secondWorkflowIndex = result.indexOf('# Another Workflow');
    const standardsIndex = result.indexOf('- agent-os/standards/code-quality');

    expect(firstWorkflowIndex).toBeLessThan(middleIndex);
    expect(middleIndex).toBeLessThan(secondWorkflowIndex);
    expect(secondWorkflowIndex).toBeLessThan(standardsIndex);
  });

  test('should not insert standards into grep patterns with special characters', async () => {
    const template = `{{workflows/test-workflow}}

Standards: {{standards/*}}`;

    const result = await processTemplate(template, {}, testDir, 'default');

    // The entire bash command should be on consecutive lines within the code block
    const lines = result.split('\n');
    let inCodeBlock = false;
    let bashCommandLines: string[] = [];

    for (const line of lines) {
      if (line.trim().startsWith('```bash')) {
        inCodeBlock = true;
        continue;
      }
      if (line.trim().startsWith('```') && inCodeBlock) {
        inCodeBlock = false;
        break;
      }
      if (inCodeBlock && line.trim().startsWith('ls -la')) {
        bashCommandLines.push(line.trim());
      }
    }

    // The bash command should be a single line
    expect(bashCommandLines.length).toBe(1);
    expect(bashCommandLines[0]).toContain('grep -E');
    expect(bashCommandLines[0]).toContain('|| echo');

    // Make sure the dollar sign at the end of the regex is preserved
    expect(bashCommandLines[0]).toContain('pdf)$');
  });

  test('should handle adjacent template patterns without interference', async () => {
    // Test case where two patterns are very close together
    const template = `{{workflows/test-workflow}}
{{standards/*}}`;

    const result = await processTemplate(template, {}, testDir, 'default');

    // Both should be included
    expect(result).toContain('# Test Workflow');
    expect(result).toContain('- agent-os/standards/code-quality');

    // Bash command should still be intact
    expect(result).toContain('grep -E');
    expect(result).toContain('|| echo "No visual files found"');

    // Standards should not be in the middle of the bash command
    const grepIndex = result.indexOf('grep -E');
    const echoIndex = result.indexOf('|| echo', grepIndex);
    const substringBetween = result.substring(grepIndex, echoIndex);

    expect(substringBetween).not.toContain('agent-os/standards');
  });

  test('should preserve regex special characters in content', async () => {
    // Create a workflow with lots of regex special characters
    writeFileSync(
      joinPath(workflowsDir, 'regex-heavy.md'),
      `# Regex Heavy Workflow

Pattern 1: \`/\\.test\\.(ts|js)$/\`
Pattern 2: \`^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\\.[a-zA-Z0-9_-]+)*$\`
Pattern 3: \`\\$\\{variable\\}\`
Dollar signs: $1 $2 $3
`
    );

    const template = `{{workflows/regex-heavy}}

{{standards/*}}`;

    const result = await processTemplate(template, {}, testDir, 'default');

    // All special characters should be preserved exactly
    expect(result).toContain('/\\.test\\.(ts|js)$/');
    expect(result).toContain('^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\\.[a-zA-Z0-9_-]+)*$');
    expect(result).toContain('\\$\\{variable\\}');
    expect(result).toContain('Dollar signs: $1 $2 $3');

    // Standards should still be inserted correctly
    expect(result).toContain('- agent-os/standards/code-quality');
  });
});
