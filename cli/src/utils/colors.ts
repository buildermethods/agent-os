import pc from 'picocolors';

/**
 * Agent OS Brand Colors
 * Extracted from https://buildermethods.com/agent-os
 *
 * The site uses a modern color palette with:
 * - Primary: Red (used for main branding, logo, buttons)
 * - Secondary: Cyan/Blue (used for accents and highlights)
 * - Tertiary: Purple/Violet (used for tertiary elements and variety)
 */
export const colors = {
  // Primary brand color - red
  red: pc.red, // Primary brand color (logo, branding)

  // Secondary brand color
  blue: pc.cyan, // Secondary brand color
  cyan: pc.cyan, // Alias for blue

  // Status colors
  green: pc.green, // Success messages
  yellow: pc.yellow, // Warning messages

  // Accent colors
  purple: pc.magenta, // Tertiary brand color

  // Text colors
  gray: pc.gray,
  dim: pc.dim,
  bold: pc.bold,
};

export function printSection(text: string) {
  console.log('');
  console.log(colors.red(`=== ${text} ===`));
  console.log('');
}

export function printStatus(text: string) {
  console.log(colors.red(text));
}

export function printSuccess(text: string) {
  console.log(colors.green(`✓ ${text}`));
}

export function printWarning(text: string) {
  console.log(colors.yellow(`⚠️  ${text}`));
}

export function printError(text: string) {
  console.log(colors.red(`✗ ${text}`));
}

export function printVerbose(text: string, verbose: boolean) {
  if (verbose) {
    console.log(colors.gray(`[VERBOSE] ${text}`));
  }
}
