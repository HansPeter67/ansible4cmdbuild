#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${OUTPUT_DIR:-$ROOT_DIR/out}"

mkdir -p "$OUTPUT_DIR"

log() {
  printf '[%s] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*" >&2
}

shopt -s nullglob
inventory_files=("$OUTPUT_DIR"/*.json)
shopt -u nullglob

if (( ${#inventory_files[@]} == 0 )); then
  log "No JSON files found in $OUTPUT_DIR"
  exit 0
fi

log "Found ${#inventory_files[@]} inventory file(s) in $OUTPUT_DIR"

for file in "${inventory_files[@]}"; do
  log "Syncing $file"
  "$ROOT_DIR/scripts/sync_to_cmdbuild.sh" "$file"
done

log "All inventory files processed"
