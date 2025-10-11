/**
 * UI Feedback
 * Progress indicators, spinners, and user feedback
 */

import * as clack from '@clack/prompts';

/**
 * Create and manage a progress spinner
 */
export class ProgressSpinner {
  private spinner = clack.spinner();
  private isRunning = false;

  start(message: string) {
    this.spinner.start(message);
    this.isRunning = true;
  }

  update(message: string) {
    if (this.isRunning) {
      this.spinner.message(message);
    }
  }

  stop(message: string) {
    if (this.isRunning) {
      this.spinner.stop(message);
      this.isRunning = false;
    }
  }

  fail(message: string) {
    if (this.isRunning) {
      this.spinner.stop(message);
      this.isRunning = false;
    }
  }
}

/**
 * Show download progress
 */
export function createDownloadProgress(verbose: boolean = false) {
  const spinner = new ProgressSpinner();

  return {
    onProgress: (current: number, total: number, file: string) => {
      if (verbose) {
        spinner.update(`Downloaded ${current}/${total}: ${file}`);
      } else {
        spinner.update(`Installing Agent OS files (${current}/${total})`);
      }
    },
    start: (message: string = 'Installing Agent OS files') => {
      spinner.start(message);
    },
    stop: (message: string = 'Installation complete') => {
      spinner.stop(message);
    },
    fail: (message: string = 'Installation failed') => {
      spinner.fail(message);
    },
  };
}

/**
 * Display configuration summary
 */
export function displayConfiguration(config: {
  profile: string;
  multiAgentMode: boolean;
  multiAgentTool?: string;
  singleAgentMode: boolean;
  singleAgentTool?: string;
}) {
  const { colors } = require('../../utils/colors');

  console.log('');
  clack.log.info(`Profile: ${colors.yellow(config.profile)}`);
  clack.log.info(`Multi-agent mode: ${colors.yellow(config.multiAgentMode.toString())}`);
  if (config.multiAgentMode && config.multiAgentTool) {
    clack.log.info(`Multi-agent tool: ${colors.yellow(config.multiAgentTool)}`);
  }
  clack.log.info(`Single-agent mode: ${colors.yellow(config.singleAgentMode.toString())}`);
  if (config.singleAgentMode && config.singleAgentTool) {
    clack.log.info(`Single-agent tool: ${colors.yellow(config.singleAgentTool)}`);
  }
  console.log('');
}
