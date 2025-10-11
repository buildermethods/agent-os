/**
 * Role Types
 * Type definitions for role configuration
 */

export type RoleType = 'implementer' | 'verifier';

export interface RoleConfiguration {
  type: RoleType;
  id: string;
  description: string;
  yourRole: string;
  tools: string;
  model: string;
  color: string;
  areasOfResponsibility: string[];
  exampleAreasOutsideOfResponsibility: string[];
  standards: string[];
  verifiedBy?: string[];
}
