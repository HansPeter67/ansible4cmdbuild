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

sync_failed=0
for file in "${inventory_files[@]}"; do
  log "Syncing $file"
  if ! "$ROOT_DIR/scripts/sync_to_cmdbuild.sh" "$file"; then
    log "Sync failed for $file"
    sync_failed=1
    break
  fi
done

if [[ "$sync_failed" -eq 0 ]]; then
  log "All inventory files processed successfully"
  log "Cleaning up staged JSON files"
  rm -f "$OUTPUT_DIR"/*.json
else
  log "Keeping files in $OUTPUT_DIR because one or more syncs failed"
fi

exit "$sync_failed"
