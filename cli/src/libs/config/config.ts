/**
 * Configuration Management
 * Handles loading, merging, and writing configuration files
 */

import { loadConfig as loadYamlConfig, writeProjectConfig } from '../../utils/yaml';
import { joinPath } from '../../utils/files';
import type { BaseConfig, EffectiveConfig, ConfigOptions, ValidationResult } from '../../types';

/**
 * Load base configuration from BASE_DIR/config.yml
 */
export async function loadBaseConfig(baseDir: string): Promise<BaseConfig | null> {
  const configPath = joinPath(baseDir, 'config.yml');
  return await loadYamlConfig(configPath);
}

/**
 * Load project configuration from project/agent-os/config.yml
 */
export async function loadProjectConfig(projectDir: string): Promise<BaseConfig | null> {
  const configPath = joinPath(projectDir, 'agent-os/config.yml');
  return await loadYamlConfig(configPath);
}

/**
 * Merge base config with command-line options
 * Converts snake_case from YAML to camelCase
 */
export function mergeConfig(baseConfig: BaseConfig, options: ConfigOptions): EffectiveConfig {
  return {
    version: baseConfig.version,
    profile: options.profile ?? baseConfig.profile,
    multiAgentMode: options.multiAgentMode ?? baseConfig.multi_agent_mode,
    multiAgentTool: options.multiAgentTool ?? baseConfig.multi_agent_tool,
    singleAgentMode: options.singleAgentMode ?? baseConfig.single_agent_mode,
    singleAgentTool: options.singleAgentTool ?? baseConfig.single_agent_tool,
  };
}

/**
 * Validate configuration
 */
export function validateConfig(config: EffectiveConfig, baseDir: string): ValidationResult {
  // At least one mode must be enabled
  if (!config.multiAgentMode && !config.singleAgentMode) {
    return {
      valid: false,
      error: 'At least one mode (single-agent or multi-agent) must be enabled',
    };
  }

  // Note: Profile existence check is handled at the caller level
  // since we need async file system access

  return { valid: true };
}

/**
 * Save project configuration
 * writeProjectConfig handles conversion to snake_case for YAML
 */
export async function saveProjectConfig(
  projectDir: string,
  config: EffectiveConfig
): Promise<void> {
  const configPath = joinPath(projectDir, 'agent-os/config.yml');
  await writeProjectConfig(configPath, {
    version: config.version,
    profile: config.profile,
    multiAgentMode: config.multiAgentMode,
    multiAgentTool: config.multiAgentTool,
    singleAgentMode: config.singleAgentMode,
    singleAgentTool: config.singleAgentTool,
  });
}
