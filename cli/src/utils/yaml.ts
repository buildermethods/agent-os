import { load, dump } from 'js-yaml';
import { readFile, writeFile as writeFileToFs } from './files';
import type { BaseConfig, EffectiveConfig, Role, RolesFile } from '../types';

/**
 * Parse YAML file and return typed object
 */
export async function parseYamlFile<T = any>(filePath: string): Promise<T | null> {
  try {
    const content = await readFile(filePath);
    if (!content) return null;
    return load(content) as T;
  } catch (error) {
    console.error(`Failed to parse YAML file: ${filePath}`, error);
    return null;
  }
}

/**
 * Get a value from YAML config with default fallback
 */
export async function getYamlValue<T = string>(
  filePath: string,
  key: string,
  defaultValue: T
): Promise<T> {
  const data = await parseYamlFile<Record<string, any>>(filePath);
  if (!data || !(key in data)) return defaultValue;
  return data[key] as T;
}

/**
 * Get array from YAML config
 */
export async function getYamlArray(filePath: string, key: string): Promise<string[]> {
  const data = await parseYamlFile<Record<string, any>>(filePath);
  if (!data || !(key in data)) return [];
  const value = data[key];
  if (Array.isArray(value)) return value;
  return [];
}

/**
 * Parse role data from implementers.yml or verifiers.yml
 */
export async function parseRoleYaml(
  yamlFile: string,
  roleType: 'implementers' | 'verifiers',
  roleId: string,
  field?: string
): Promise<Role | any | null> {
  const data = await parseYamlFile<RolesFile>(yamlFile);
  if (!data || !data[roleType]) return null;

  const role = data[roleType]?.find((r) => r.id === roleId);
  if (!role) return null;

  if (field) {
    return (role as any)[field] || null;
  }

  return role;
}

/**
 * Get standards configuration for a role
 */
export async function getRoleStandards(
  yamlFile: string,
  roleType: 'implementers' | 'verifiers',
  roleId: string
): Promise<string[]> {
  const role = await parseRoleYaml(yamlFile, roleType, roleId);
  if (!role || !role.standards) return [];
  return role.standards;
}

/**
 * Load config from config.yml
 */
export async function loadConfig(configPath: string): Promise<BaseConfig | null> {
  return await parseYamlFile<BaseConfig>(configPath);
}

/**
 * Write YAML object to file
 */
export async function writeYamlFile<T = any>(filePath: string, data: T): Promise<void> {
  const yamlContent = dump(data);
  await writeFileToFs(filePath, yamlContent);
}

/**
 * Write project config to YAML file
 */
export async function writeProjectConfig(
  filePath: string,
  config: EffectiveConfig
): Promise<void> {
  const configData = {
    version: config.version,
    last_compiled: new Date().toISOString().replace('T', ' ').substring(0, 19),
    profile: config.profile,
    multi_agent_mode: config.multiAgentMode,
    multi_agent_tool: config.multiAgentTool,
    single_agent_mode: config.singleAgentMode,
    single_agent_tool: config.singleAgentTool,
  };

  await writeYamlFile(filePath, configData);
}
