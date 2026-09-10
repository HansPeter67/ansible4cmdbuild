#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${OUTPUT_DIR:-$ROOT_DIR/out}"
TIMESTAMP="$(date -u +%Y%m%d%H%M%S)"
OUTPUT_FILE="$OUTPUT_DIR/inventory-$TIMESTAMP.json"

mkdir -p "$OUTPUT_DIR"

log() {
  printf '[%s] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*" >&2
}

log "Exporting inventory to $OUTPUT_FILE"

ansible-playbook \
  "$ROOT_DIR/ansible/playbooks/cmdbuild_inventory.yml" \
  -i "$ROOT_DIR/ansible/inventory.ini" \
  --extra-vars "cmdbuild_export_dir=$OUTPUT_DIR"

latest_file="$(ls -1t "$OUTPUT_DIR"/inventory-*.json | head -n 1)"
log "Latest inventory export: $latest_file"
