/**
 * Configuration Types
 */

/**
 * Supported single-agent tools
 */
export const SINGLE_AGENT_TOOLS = ['generic', 'cursor'] as const;
export type SingleAgentTool = (typeof SINGLE_AGENT_TOOLS)[number];

/**
 * Supported multi-agent tools
 */
export const MULTI_AGENT_TOOLS = ['claude-code'] as const;
export type MultiAgentTool = (typeof MULTI_AGENT_TOOLS)[number];

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
  multiAgentTool: MultiAgentTool;
  singleAgentMode: boolean;
  singleAgentTool: SingleAgentTool;
}

export interface ConfigOptions {
  profile?: string;
  multiAgentMode?: boolean;
  multiAgentTool?: MultiAgentTool;
  singleAgentMode?: boolean;
  singleAgentTool?: SingleAgentTool;
}

export interface ValidationResult {
  valid: boolean;
  error?: string;
}
