#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '[%s] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*" >&2
}

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    log "Missing required command: $cmd"
    exit 1
  fi
}

require_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    log "Missing required file: $file"
    exit 1
  fi
}

load_env_file() {
  local env_file="$1"
  require_file "$env_file"

  # shellcheck disable=SC1090
  set -a
  source "$env_file"
  set +a
}
