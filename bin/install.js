#!/usr/bin/env node
/**
 * OpenClaw One-Click Installer
 * @author world.je
 * @license MIT
 */

const { execSync, spawn } = require('child_process');
const fs = require('fs');
const path = require('path');
const os = require('os');

// Colors
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
  white: '\x1b[37m',
};

const log = {
  success: (msg) => console.log(`${colors.green}✅ ${msg}${colors.reset}`),
  error: (msg) => console.log(`${colors.red}❌ ${msg}${colors.reset}`),
  warning: (msg) => console.log(`${colors.yellow}⚠️  ${msg}${colors.reset}`),
  info: (msg) => console.log(`${colors.blue}ℹ️  ${msg}${colors.reset}`),
  step: (msg) => console.log(`${colors.cyan}▶ ${msg}${colors.reset}`),
};

// Banner
function showBanner() {
  console.log('');
  console.log(`${colors.cyan}╔═══════════════════════════════════════════════════════════╗${colors.reset}`);
  console.log(`${colors.cyan}║                                                           ║${colors.reset}`);
  console.log(`${colors.cyan}║     🚀 OpenClaw One-Click Installer                      ║${colors.reset}`);
  console.log(`${colors.cyan}║                                                           ║${colors.reset}`);
  console.log(`${colors.cyan}║     Powered by world.je                                   ║${colors.reset}`);
  console.log(`${colors.cyan}║     https://world.je                                      ║${colors.reset}`);
  console.log(`${colors.cyan}║                                                           ║${colors.reset}`);
  console.log(`${colors.cyan}╚═══════════════════════════════════════════════════════════╝${colors.reset}`);
  console.log('');
}

// Detect OS
function detectOS() {
  const platform = os.platform();
  const isTermux = fs.existsSync('/data/data/com.termux');
  
  if (isTermux) return 'termux';
  if (platform === 'darwin') return 'macos';
  if (platform === 'linux') return 'linux';
  if (platform === 'win32') return 'windows';
  return 'unknown';
}

// Check command exists
function commandExists(cmd) {
  try {
    execSync(process.platform === 'win32' ? `where ${cmd}` : `which ${cmd}`, { stdio: 'ignore' });
    return true;
  } catch {
    return false;
  }
}

// Check Node.js version
function checkNode() {
  log.step('Checking Node.js...');
  
  const version = process.version.replace('v', '');
  const major = parseInt(version.split('.')[0]);
  
  if (major >= 18) {
    log.success(`Node.js ${process.version} found`);
    return true;
  } else {
    log.error(`Node.js version too old (need 18+, got ${process.version})`);
    return false;
  }
}

// Check Git
function checkGit() {
  log.step('Checking Git...');
  
  if (commandExists('git')) {
    log.success('Git found');
    return true;
  } else {
    log.error('Git not found. Install Git first.');
    return false;
  }
}

// Run shell script installer
function runInstaller() {
  const osType = detectOS();
  log.info(`Detected OS: ${osType}`);
  
  const scriptDir = path.join(__dirname, '..', 'scripts');
  let scriptPath;
  
  if (osType === 'windows') {
    // On Windows, run PowerShell script
    scriptPath = path.join(scriptDir, 'install.ps1');
    log.step('Running PowerShell installer...');
    
    const ps = spawn('powershell.exe', ['-ExecutionPolicy', 'Bypass', '-File', scriptPath], {
      stdio: 'inherit',
      shell: true
    });
    
    ps.on('close', (code) => {
      if (code === 0) {
        showSuccess();
      } else {
        log.error(`Installation failed with code ${code}`);
      }
    });
  } else {
    // On Unix-like systems, run Bash script
    scriptPath = path.join(scriptDir, 'install.sh');
    log.step('Running Bash installer...');
    
    const bash = spawn('bash', [scriptPath], {
      stdio: 'inherit',
      env: { ...process.env }
    });
    
    bash.on('close', (code) => {
      if (code === 0) {
        showSuccess();
      } else {
        log.error(`Installation failed with code ${code}`);
      }
    });
  }
}

// Show success message
function showSuccess() {
  console.log('');
  console.log(`${colors.green}╔═══════════════════════════════════════════════════════════╗${colors.reset}`);
  console.log(`${colors.green}║                                                           ║${colors.reset}`);
  console.log(`${colors.green}║     ✅ OpenClaw Installed Successfully!                   ║${colors.reset}`);
  console.log(`${colors.green}║                                                           ║${colors.reset}`);
  console.log(`${colors.green}╚═══════════════════════════════════════════════════════════╝${colors.reset}`);
  console.log('');
  console.log(`${colors.cyan}🌐 Web UI: http://localhost:5203${colors.reset}`);
  console.log(`${colors.cyan}📚 Docs: https://docs.openclaw.ai${colors.reset}`);
  console.log(`${colors.cyan}📞 Support: https://world.je${colors.reset}`);
  console.log('');
  console.log('Commands:');
  console.log(`  ${colors.cyan}openclaw status${colors.reset}       - Check status`);
  console.log(`  ${colors.cyan}openclaw gateway start${colors.reset} - Start gateway`);
  console.log(`  ${colors.cyan}openclaw doctor${colors.reset}       - Run diagnostics`);
  console.log('');
}

// Parse arguments
function parseArgs() {
  const args = process.argv.slice(2);
  const options = {
    version: 'latest',
    dir: null,
    noBrowser: false,
    verbose: false,
    uninstall: false,
    help: false,
  };
  
  for (let i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--version':
        options.version = args[++i];
        break;
      case '--dir':
        options.dir = args[++i];
        break;
      case '--no-browser':
        options.noBrowser = true;
        break;
      case '--verbose':
        options.verbose = true;
        break;
      case '--uninstall':
        options.uninstall = true;
        break;
      case '--help':
      case '-h':
        options.help = true;
        break;
    }
  }
  
  return options;
}

// Show help
function showHelp() {
  console.log(`
Usage: npx @worldje/openclaw-installer [options]

Options:
  --version VERSION   OpenClaw version to install (default: latest)
  --dir DIR           Installation directory (default: ~/openclaw)
  --no-browser        Don't open browser after installation
  --verbose           Show verbose output
  --uninstall         Uninstall OpenClaw
  --help, -h          Show this help message

Examples:
  npx @worldje/openclaw-installer
  npx @worldje/openclaw-installer --version 1.2.0
  npx @worldje/openclaw-installer --dir ~/my-openclaw

Support: https://world.je
`);
}

// Main
function main() {
  const options = parseArgs();
  
  if (options.help) {
    showHelp();
    process.exit(0);
  }
  
  showBanner();
  
  if (!checkNode()) process.exit(1);
  if (!checkGit()) process.exit(1);
  
  runInstaller();
}

main();
