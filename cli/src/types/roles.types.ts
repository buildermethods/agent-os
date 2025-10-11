/**
 * Role Types
 */

export interface Role {
  id: string;
  description: string;
  your_role: string;
  tools: string;
  model: string;
  color: string;
  areas_of_responsibility: string[];
  example_areas_outside_of_responsibility: string[];
  standards: string[];
  verified_by?: string[];
}

export interface Implementer extends Role {
  // Implementer-specific fields can be added here
}

export interface Verifier extends Role {
  // Verifier-specific fields can be added here
}

export interface RolesFile {
  implementers?: Implementer[];
  verifiers?: Verifier[];
}
