# OpenClaw One-Click Installer for Windows
# Author: world.je
# Version: 1.0.0

param (
    [string]$Version = "latest",
    [string]$InstallDir = "$env:USERPROFILE\openclaw",
    [switch]$NoBrowser = $false,
    [switch]$Verbose = $false,
    [switch]$Yes = $false,
    [switch]$Help = $false
)

$ErrorActionPreference = "Stop"

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    
    $colors = @{
        Red = "Red"
        Green = "Green"
        Yellow = "Yellow"
        Blue = "Blue"
        Cyan = "Cyan"
        Magenta = "Magenta"
        White = "White"
    }
    
    Write-Host $Message -ForegroundColor $colors[$Color]
}

function Show-Banner {
    Write-ColorOutput @"
    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║     OpenClaw One-Click Installer                          ║
    ║                                                               ║
    ║     Powered by world.je                               ║
    ║     https://world.je                                        ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝
    "@ Cyan
}

function Test-Command {
    param([string]$Command)
    
    try {
        $null = Get-Command $Command -ErrorAction SilentlyContinue
        return $true
    }
    catch {
        return $false
    }
}

function Check-Node {
    Write-ColorOutput "Checking Node.js..." "Cyan"
    
    if (Test-Command "node") {
        $nodeVersion = node -v
        Write-ColorOutput "Node.js $nodeVersion found" "Green"
        return $true
    }
    else {
        Write-ColorOutput "Node.js not found" "Red"
        Write-ColorOutput "Install Node.js: https://nodejs.org" "Yellow"
        return $false
    }
}

function Check-Git {
    Write-ColorOutput "Checking Git..." "Cyan"
    
    if (Test-Command "git") {
        $gitVersion = git --version
        Write-ColorOutput "Git found" "Green"
        return $true
    }
    else {
        Write-ColorOutput "Git not found" "Red"
        return $false
    }
}

function Install-OpenClaw {
    Write-ColorOutput "Cloning OpenClaw..." "Cyan"
    
    if (Test-Path $InstallDir) {
        Write-ColorOutput "Directory $InstallDir already exists" "Yellow"
        
        if (-not $Yes) {
            $response = Read-Host "Remove and reinstall? [y/N]"
            if ($response -eq "y" -or $response -eq "Y") {
                Remove-Item -Recurse -Force $InstallDir
            }
            else {
                Write-ColorOutput "Installation cancelled" "Red"
                exit 1
            }
        }
        else {
            Remove-Item -Recurse -Force $InstallDir
        }
    }
    
    git clone https://github.com/openclaw/openclaw.git $InstallDir
2>&1 | Out-null
    
    Write-ColorOutput "Cloned to $InstallDir" "Green"
}

function Install-Dependencies {
    Write-ColorOutput "Installing npm dependencies..." "Cyan"
    
    Push-Location $InstallDir
    
    if (Test-Command "pnpm") {
        pnpm install
    }
    elseif (Test-Command "npm") {
        npm install
    }
    else {
        Write-ColorOutput "No package manager found" "Red"
        Pop-Location
        exit 1
    }
    
    Pop-Location
    Write-ColorOutput "Dependencies installed" "Green"
}

function Build-Project {
    Write-ColorOutput "Building OpenClaw..." "Cyan"
    
    Push-Location $InstallDir
    
    if (Test-Path "package.json") {
        $hasBuild = Get-Content package.json | Select-String '"build"'
        if ($hasBuild) {
            if (Test-Command "pnpm") {
                pnpm build
            }
            else {
                npm run build
            }
        }
    }
    
    Pop-Location
    Write-ColorOutput "Build complete" "Green"
}

function Create-Config {
    Write-ColorOutput "Creating configuration..." "Cyan"
    
    $stateDir = "$env:USERPROFILE\.openclaw"
    
    if (-not (Test-Path $stateDir)) {
        New-Item -ItemType Directory -Path $stateDir | Out-Null
    }
    
    $configFile = "$stateDir\openclaw.json"
    
    if (-not (Test-Path $configFile)) {
        $config = @"
{
  "`$schema": "https://openclaw.ai/schema/openclaw.json",
  "version": "1.0.0",
  "gateway": {
    "port": 5203,
    "host": "127.0.0.1"
  },
  "channels": {},
  "models": {
    "default": "openai/gpt-4o-mini"
  }
}
"@
        $config | Out-File -FilePath $configFile -Encoding utf8
        Write-ColorOutput "Created default configuration" "Green"
    }
    else {
        Write-ColorOutput "Configuration already exists" "Yellow"
    }
}

function Start-Gateway {
    Write-ColorOutput "Starting OpenClaw Gateway..." "Cyan"
    
    Push-Location $InstallDir
    
    $startScript = Join-Path $InstallDir "dist\gateway\index.js"
    
    if (Test-Path $startScript) {
        Start-Process -FilePath "node" -ArgumentList $startScript -NoNewWindow
        Start-Sleep -Seconds 3
        
        Write-ColorOutput "Gateway started on port 5203" "Green"
    }
}

function Open-Browser {
    if (-not $NoBrowser) {
        Write-ColorOutput "Opening browser..." "Cyan"
        Start-Process "http://localhost:5203"
    }
}

function Show-Success {
    Write-ColorOutput @"

    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║       OpenClaw Installed Successfully!                           ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝
    "@ Green
    
    Write-ColorOutput "Install location: $InstallDir" "Cyan"
    Write-ColorOutput "Config location:  $env:USERPROFILE\.openclaw" "Cyan"
    Write-ColorOutput "Web UI:          http://localhost:5203" "Cyan"
    Write-ColorOutput "Documentation:    https://docs.openclaw.ai" "Cyan"
    
    Write-ColorOutput @"

Commands:
  openclaw status        Check status
  openclaw gateway start Start gateway
  openclaw gateway stop  Stop gateway
  openclaw doctor        Run diagnostics

Need help? Visit https://world.je
"@ Cyan
}

function Show-Help {
    Write-Host @"

OpenClaw One-Click Installer
Powered by world.je

Usage: .\install.ps1 [options]

Options:
  --version VERSION   OpenClaw version to install
  --dir DIR          Installation directory (default: ~/openclaw)
  --no-browser       Don't open browser after install
  --verbose          Show verbose output
  --yes              Skip confirmation prompts
  --help             Show this help

Examples:
  .\install.ps1
  .\install.ps1 --dir C:\openclaw
  .\install.ps1 --no-browser

Support: https://world.je
"@
}

# Main
if ($Help) {
    Show-Help
    exit 0
}

Show-Banner

if (-not (Check-Node)) { exit 1 }
if (-not (Check-Git)) { exit 1 }

Install-OpenClaw
Install-Dependencies
Build-Project
Create-Config
Start-Gateway
Open-Browser
Show-Success
