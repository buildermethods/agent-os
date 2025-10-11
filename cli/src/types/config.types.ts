/**
 * Configuration Types
 */

export interface BaseConfig {
  version: string;
  base_install?: boolean;
  profile: string;
  multi_agent_mode: boolean;
  multi_agent_tool: string;
  single_agent_mode: boolean;
  single_agent_tool: string;
  last_compiled?: string;
}

export interface EffectiveConfig {
  version: string;
  profile: string;
  multiAgentMode: boolean;
  multiAgentTool: string;
  singleAgentMode: boolean;
  singleAgentTool: string;
}

export interface ConfigOptions {
  profile?: string;
  multiAgentMode?: boolean;
  multiAgentTool?: string;
  singleAgentMode?: boolean;
  singleAgentTool?: string;
}

export interface ValidationResult {
  valid: boolean;
  error?: string;
}
