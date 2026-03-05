#!/bin/bash
#
# OpenClaw One-Click Installer
# Author: world.je
# License: MIT
# Version: 1.0.0
#
# Usage: ./install.sh [options]
#
# Options:
#   --version VERSION   OpenClaw version (default: latest)
#   --dir DIR          Installation directory (default: ~/openclaw)
#   --no-browser       Don't open browser after install
#   --verbose          Verbose output
#   --help             Show help
#

set -e

# ============================================================
# Configuration
# ============================================================

OPENCLAW_REPO="https://github.com/openclaw/openclaw.git"
OPENCLAW_VERSION="${OPENCLAW_VERSION:-latest}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/openclaw}"
STATE_DIR="${STATE_DIR:-$HOME/.openclaw}"
VERBOSE="${VERBOSE:-false}"
NO_BROWSER="${NO_BROWSER:-false}"
BYPASS_CONFIRM="${BYPASS_CONFIRM:-false}"
RECONFIGURE="${RECONFIGURE:-false}"

# ============================================================
# Colors
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# ============================================================
# Print Functions
# ============================================================

print_banner() {
  echo -e "${CYAN}"
  echo "╔═══════════════════════════════════════════════════════════════╗"
  echo "║                                                               ║"
  echo "║     🚀 OpenClaw One-Click Installer                          ║"
  echo "║                                                               ║"
  echo "║     Powered by world.je                               ║"
  echo "║     https://world.je                                        ║"
  echo "║                                                               ║"
  echo "╚═══════════════════════════════════════════════════════════════╝"
  echo -e "${NC}"
}

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_step() { echo -e "${CYAN}▶ $1${NC}"; }
print_header() { echo -e "${MAGENTA}$1${NC}"; }

# ============================================================
# OS Detection
# ============================================================

detect_os() {
  if [ -d "/data/data/com.termux" ]; then
    echo "termux"
  elif [ "$(uname)" = "Darwin" ]; then
    echo "macos"
  elif [ "$(uname)" = "Linux" ]; then
    if [ -f /etc/debian_version ]; then
      echo "debian"
    elif [ -f /etc/redhat-release ]; then
      echo "redhat"
    else
      echo "linux"
    fi
  else
    echo "unknown"
  fi
}

# ============================================================
# Dependency Checks
# ============================================================

check_node() {
  print_step "Checking Node.js..."
  
  if command -v node &> /dev/null; then
    NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -ge 18 ]; then
      print_success "Node.js $(node -v) found"
      return 0
    else
      print_error "Node.js version too old (need 18+, got $(node -v))"
      print_info "Install Node.js: https://nodejs.org"
      return 1
    fi
  else
    print_error "Node.js not found"
    print_info "Install Node.js: https://nodejs.org"
    return 1
  fi
}

check_git() {
  print_step "Checking Git..."
  
  if command -v git &> /dev/null; then
    print_success "Git $(git --version | cut -d' ' -f3) found"
    return 0
  else
    print_error "Git not found"
    print_info "Install Git first:"
    print_info "  macOS: brew install git"
    print_info "  Debian/Ubuntu: sudo apt install git"
    print_info "  Termux: pkg install git"
    return 1
  fi
}

check_curl() {
  if command -v curl &> /dev/null; then
    return 0
  elif command -v wget &> /dev/null; then
    return 0
  else
    print_warning "Neither curl nor wget found"
    return 1
  fi
}

# ============================================================
# Installation Functions
# ============================================================

install_dependencies_termux() {
  print_step "Installing Termux dependencies..."
  pkg install -y nodejs git python build-essential binutils 2>/dev/null || true
}

install_dependencies_debian() {
  print_step "Installing Debian/Ubuntu dependencies..."
  sudo apt update
  sudo apt install -y build-essential python3
}

install_dependencies_redhat() {
  print_step "Installing CentOS/RHEL dependencies..."
  sudo yum groupinstall -y "Development Tools"
  sudo yum install -y python3
}

install_dependencies_macos() {
  print_step "Checking macOS dependencies..."
  if ! command -v brew &> /dev/null; then
    print_warning "Homebrew not found. Some packages may fail to build."
  fi
}

install_dependencies() {
  local os=$(detect_os)
  
  case $os in
    termux)
      install_dependencies_termux
      ;;
    debian)
      install_dependencies_debian
      ;;
    redhat)
      install_dependencies_redhat
      ;;
    macos)
      install_dependencies_macos
      ;;
  esac
}

clone_openclaw() {
  print_step "Cloning OpenClaw..."
  
  if [ -d "$INSTALL_DIR" ]; then
    print_warning "Directory $INSTALL_DIR already exists"
    if [ "$BYPASS_CONFIRM" = "true" ]; then
      print_info "Removing existing directory..."
      rm -rf "$INSTALL_DIR"
    else
      read -p "Remove and reinstall? [y/N] " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$INSTALL_DIR"
      else
        print_error "Installation cancelled"
        exit 1
      fi
    fi
  fi
  
  git clone "$OPENCLAW_REPO" "$INSTALL_DIR"
  print_success "Cloned to $INSTALL_DIR"
}

install_npm_dependencies() {
  print_step "Installing npm dependencies..."

  cd "$INSTALL_DIR"

  # Install pnpm if not available (required by OpenClaw build)
  if ! command -v pnpm &> /dev/null; then
    print_info "Installing pnpm..."
    npm install -g pnpm
  fi

  # Use pnpm (OpenClaw requires pnpm)
  print_info "Using pnpm..."
  pnpm install

  print_success "Dependencies installed"
}

build_project() {
  print_step "Building OpenClaw..."

  cd "$INSTALL_DIR"

  if [ -f "package.json" ] && grep -q '"build"' package.json; then
    pnpm build
    print_success "Build complete"
  else
    print_info "No build step required"
  fi
}

create_config() {
  print_step "Creating configuration..."

  mkdir -p "$STATE_DIR"

  if [ ! -f "$STATE_DIR/openclaw.json" ] || [ "$RECONFIGURE" = "true" ]; then
    print_warning "Configuration exists, but --reconfigure flag set"
    print_info "Reconfiguring channels..."
  else
    print_info "Configuration already exists"
    print_info "Use --reconfigure to reconfigure channels"
    return 0
  fi
    # Interactive channel configuration
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  📡 Channel Configuration${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Which channels do you want to configure? (You can configure later)"
    echo ""
    echo "  1) Telegram Bot"
    echo "  2) Feishu (Lark)"
    echo "  3) Discord"
    echo "  4) WhatsApp"
    echo "  5) Skip - Configure later"
    echo ""
    read -p "Select option [1-5]: " -n 1 -r
    echo ""

    TELEGRAM_ENABLED="false"
    TELEGRAM_TOKEN=""
    FEISHU_ENABLED="false"
    FEISHU_APP_ID=""
    FEISHU_APP_SECRET=""

    case $REPLY in
      1)
        echo ""
        print_info "Configure Telegram Bot"
        echo "Get your bot token from @BotFather on Telegram"
        echo ""
        read -p "Enter Telegram Bot Token: " TELEGRAM_TOKEN
        if [ -n "$TELEGRAM_TOKEN" ]; then
          TELEGRAM_ENABLED="true"
          print_success "Telegram configured"
        fi
        ;;
      2)
        echo ""
        print_info "Configure Feishu (Lark)"
        echo "Get your App ID and Secret from Feishu Open Platform"
        echo ""
        read -p "Enter Feishu App ID: " FEISHU_APP_ID
        read -p "Enter Feishu App Secret: " FEISHU_APP_SECRET
        if [ -n "$FEISHU_APP_ID" ] && [ -n "$FEISHU_APP_SECRET" ]; then
          FEISHU_ENABLED="true"
          print_success "Feishu configured"
        fi
        ;;
      3)
        echo ""
        print_info "Discord configuration will be done via CLI"
        print_info "Run: openclaw channels login discord"
        ;;
      4)
        echo ""
        print_info "WhatsApp configuration will be done via CLI"
        print_info "Run: openclaw channels login whatsapp"
        ;;
      5)
        print_info "Skipped - Configure later with: openclaw configure"
        ;;
      *)
        print_info "Skipped - Configure later with: openclaw configure"
        ;;
    esac

    # Build channels config
    CHANNELS_CONFIG='"telegram": {"enabled": '"$TELEGRAM_ENABLED"', "token": "'"$TELEGRAM_TOKEN"'", "streaming": "partial"}'

    if [ "$FEISHU_ENABLED" = "true" ]; then
      CHANNELS_CONFIG="$CHANNELS_CONFIG"', "feishu": {"enabled": true, "appId": "'"$FEISHU_APP_ID"'", "appSecret": "'"$FEISHU_APP_SECRET"'"}'
    fi

    cat > "$STATE_DIR/openclaw.json" << EOF
{
  "\$schema": "https://openclaw.ai/schema/openclaw.json",
  "version": "1.0.0",
  "gateway": {
    "port": 18789,
    "host": "127.0.0.1",
    "authToken": ""
  },
  "channels": {
    $CHANNELS_CONFIG
  },
  "models": {
    "default": "openai/gpt-4o-mini",
    "providers": {}
  },
  "skills": {
    "autoUpdate": true,
    "trustedSources": ["anthropic", "openclaw", "community"]
  }
}
EOF
    print_success "Created configuration"
  else
    print_info "Configuration already exists"
  fi
}

run_doctor() {
  print_step "Running diagnostics..."

  cd "$INSTALL_DIR"

  if [ -f "openclaw.mjs" ]; then
    node openclaw.mjs doctor --fix 2>/dev/null || true
  fi

  print_success "Diagnostics complete"
}

start_gateway() {
  print_step "Starting OpenClaw Gateway..."

  cd "$INSTALL_DIR"

  # Check if already running
  if pgrep -f "openclaw.*gateway" > /dev/null 2>&1; then
    print_warning "Gateway already running"
    return 0
  fi

  # Start in background using openclaw.mjs
  if [ -f "openclaw.mjs" ]; then
    nohup node openclaw.mjs gateway > /tmp/openclaw-gateway.log 2>&1 &
    sleep 3

    if pgrep -f "openclaw.*gateway" > /dev/null 2>&1; then
      print_success "Gateway started on port 18789"
    else
      print_warning "Gateway may have failed to start"
      print_info "Check logs: /tmp/openclaw-gateway.log"
    fi
  else
    print_warning "Gateway entry point not found"
  fi
}

open_browser() {
  if [ "$NO_BROWSER" = "true" ]; then
    return 0
  fi
  
  print_step "Opening browser..."
  
  URL="http://localhost:18789"
  
  if command -v xdg-open &> /dev/null; then
    xdg-open "$URL" 2>/dev/null &
  elif command -v open &> /dev/null; then
    open "$URL" 2>/dev/null &
  elif command -v termux-open-url &> /dev/null; then
    termux-open-url "$URL" 2>/dev/null &
  else
    print_info "Open $URL in your browser"
  fi
}

# ============================================================
# Success Message
# ============================================================

print_success_message() {
  echo ""
  echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║                                                               ║${NC}"
  echo -e "${GREEN}║     ✅ OpenClaw Installed Successfully!                       ║${NC}"
  echo -e "${GREEN}║                                                               ║${NC}"
  echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "📍 ${WHITE}Install location:${NC} ${CYAN}$INSTALL_DIR${NC}"
  echo -e "📍 ${WHITE}Config location:${NC}  ${CYAN}$STATE_DIR${NC}"
  echo -e "🌐 ${WHITE}Web UI:${NC}          ${CYAN}http://localhost:18789${NC}"
  echo -e "📚 ${WHITE}Documentation:${NC}    ${CYAN}https://docs.openclaw.ai${NC}"
  echo ""
  echo -e "${WHITE}Commands:${NC}"
  echo -e "  ${CYAN}openclaw status${NC}        Check status"
  echo -e "  ${CYAN}openclaw gateway start${NC} Start gateway"
  echo -e "  ${CYAN}openclaw gateway stop${NC}  Stop gateway"
  echo -e "  ${CYAN}openclaw doctor${NC}        Run diagnostics"
  echo ""
  echo -e "${WHITE}Install skills:${NC}"
  echo -e "  ${CYAN}npx skills add <skill-name>${NC}"
  echo ""
  echo -e "${CYAN}Need help? Visit https://world.je${NC}"
  echo ""
}

# ============================================================
# Help
# ============================================================

show_help() {
  echo ""
  echo "OpenClaw One-Click Installer"
  echo "Powered by world.je"
  echo ""
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "  --version VERSION   OpenClaw version to install (default: latest)"
  echo "  --dir DIR          Installation directory (default: ~/openclaw)"
  echo "  --no-browser       Don't open browser after install"
  echo "  --verbose          Show verbose output"
  echo "  --yes              Skip confirmation prompts"
  echo "  --reconfigure      Reconfigure channels even if config exists"
  echo "  --help             Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0                              # Basic install"
  echo "  $0 --dir ~/my-openclaw          # Custom directory"
  echo "  $0 --version v1.2.0             # Specific version"
  echo "  $0 --no-browser                 # Don't open browser"
  echo ""
  echo "Support: https://world.je"
  echo ""
}

# ============================================================
# Main
# ============================================================

main() {
  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --version)
        OPENCLAW_VERSION="$2"
        shift 2
        ;;
      --dir)
        INSTALL_DIR="$2"
        shift 2
        ;;
      --no-browser)
        NO_BROWSER="true"
        shift
        ;;
      --verbose)
        VERBOSE="true"
        shift
        ;;
      --yes|-y)
        BYPASS_CONFIRM="true"
        shift
        ;;
      --reconfigure)
        RECONFIGURE="true"
        shift
        ;;
      --help|-h)
        show_help
        exit 0
        ;;
      *)
        print_error "Unknown option: $1"
        show_help
        exit 1
        ;;
    esac
  done
  
  # Export for sub-processes
  export OPENCLAW_VERSION
  export INSTALL_DIR
  export NO_BROWSER
  export VERBOSE
  
  # Show banner
  print_banner
  
  # Detect OS
  OS=$(detect_os)
  print_info "Detected OS: $OS"
  
  # Check dependencies
  check_node || exit 1
  check_git || exit 1
  
  # Install system dependencies
  install_dependencies
  
  # Install OpenClaw
  clone_openclaw
  install_npm_dependencies
  build_project
  create_config
  run_doctor
  start_gateway
  open_browser
  
  # Show success
  print_success_message
}

main "$@"
