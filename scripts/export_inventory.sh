#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${OUTPUT_DIR:-$ROOT_DIR/out}"

mkdir -p "$OUTPUT_DIR"

log() {
  printf '[%s] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*" >&2
}

log "Exporting inventory files to $OUTPUT_DIR"

# Start from a clean staging directory so no old host files remain.
find "$OUTPUT_DIR" -maxdepth 1 -type f -name '*.json' -delete

ansible-playbook \
  "$ROOT_DIR/ansible/playbooks/cmdbuild_inventory.yml" \
  -i "$ROOT_DIR/ansible/inventory.ini" \
  --extra-vars "cmdbuild_export_dir=$OUTPUT_DIR"

count="$(find "$OUTPUT_DIR" -maxdepth 1 -type f -name '*.json' | wc -l | tr -d ' ')"
log "Inventory export complete. JSON files written: $count"
