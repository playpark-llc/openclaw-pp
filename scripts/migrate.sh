#!/usr/bin/env bash
#
# migrate.sh - Migrate existing OpenClaw data to Docker-based setup
#
# Copies credentials, identity, memory, agents, and other runtime data
# from the existing ~/.openclaw directory to the new data/ directory.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DATA_DIR="${PROJECT_DIR}/data"

# Source: existing OpenClaw directory (resolve symlink if present)
OPENCLAW_HOME="${HOME}/.openclaw"
if [[ -L "${OPENCLAW_HOME}" ]]; then
  OPENCLAW_SOURCE="$(readlink "${OPENCLAW_HOME}")"
else
  OPENCLAW_SOURCE="${OPENCLAW_HOME}"
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

log_info()    { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

if [[ ! -d "${OPENCLAW_SOURCE}" ]]; then
  log_error "Source directory not found: ${OPENCLAW_SOURCE}"
  exit 1
fi

log_info "Migrating from: ${OPENCLAW_SOURCE}"
log_info "Migrating to:   ${DATA_DIR}"
echo ""

# Directories to migrate
DIRS_TO_COPY=(
  credentials
  identity
  memory
  agents
  media
  browser
  canvas
  devices
  logs
)

for dir in "${DIRS_TO_COPY[@]}"; do
  src="${OPENCLAW_SOURCE}/${dir}"
  dst="${DATA_DIR}/${dir}"

  if [[ -d "${src}" ]]; then
    mkdir -p "${dst}"
    cp -rp "${src}/." "${dst}/"
    log_info "Copied: ${dir}/"
  else
    mkdir -p "${dst}"
    log_warn "Not found (created empty): ${dir}/"
  fi
done

# Copy .env if it exists
if [[ -f "${OPENCLAW_SOURCE}/.env" ]]; then
  cp "${OPENCLAW_SOURCE}/.env" "${PROJECT_DIR}/.env"
  log_info "Copied: .env"
else
  log_warn ".env not found in source. Copy .env.example to .env and configure manually."
fi

echo ""
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}  SECURITY REMINDER${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""
echo "1. Generate a new gateway token:"
echo "     openssl rand -hex 32"
echo ""
echo "2. Update .env with the new token:"
echo "     OPENCLAW_GATEWAY_TOKEN=<new-token>"
echo ""
echo "3. Consider rotating Slack tokens if the old"
echo "   installation was compromised."
echo ""
log_info "Migration complete. Run 'docker compose up -d' to start."
