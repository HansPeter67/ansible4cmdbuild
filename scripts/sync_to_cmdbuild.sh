#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
source "$ROOT_DIR/scripts/lib/cmdbuild_api.sh"

require_cmd jq
require_cmd curl

ENV_FILE="${CMDBUILD_ENV_FILE:-$ROOT_DIR/config/cmdbuild.env}"
load_env_file "$ENV_FILE"

INVENTORY_FILE="${1:-}"
if [[ -z "$INVENTORY_FILE" ]]; then
  log "Usage: $0 <inventory-json-file>"
  exit 1
fi

require_file "$INVENTORY_FILE"

BASE_URL="${CMDBUILD_BASE_URL:?CMDBUILD_BASE_URL is not set}"
API_PATH="${CMDBUILD_API_PATH:-/api}"
CLASS_NAME="${CMDBUILD_CLASS_NAME:-Server}"
UNIQUE_KEY="${CMDBUILD_UNIQUE_KEY:-hostname}"
DRY_RUN="${CMDBUILD_DRY_RUN:-false}"

log "Using class: $CLASS_NAME"
log "Using unique key: $UNIQUE_KEY"

TMP_PAYLOAD="$(mktemp)"
trap 'rm -f "$TMP_PAYLOAD"' EXIT

jq -n \
  --arg class "$CLASS_NAME" \
  --arg unique_key "$UNIQUE_KEY" \
  --argfile inv "$INVENTORY_FILE" \
  '{
    class: $class,
    unique_key: $unique_key,
    data: $inv
  }' > "$TMP_PAYLOAD"

URL="$(cmdbuild_api_url "$BASE_URL" "$API_PATH/assets/sync")"

if [[ "$DRY_RUN" == "true" ]]; then
  log "Dry run enabled. Payload:"
  cat "$TMP_PAYLOAD"
  exit 0
fi

log "Syncing to CMDBuild at $URL"
cmdbuild_post_json "$URL" "$TMP_PAYLOAD"
