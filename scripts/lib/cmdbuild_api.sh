#!/usr/bin/env bash
set -euo pipefail

cmdbuild_api_url() {
  local base_url="$1"
  local path="$2"
  printf '%s%s' "${base_url%/}" "$path"
}

cmdbuild_post_json() {
  local url="$1"
  local json_file="$2"
  local token="${CMDBUILD_TOKEN:-}"

  if [[ -z "$token" ]]; then
    echo "CMDBUILD_TOKEN is not set" >&2
    return 1
  fi

  curl -sS \
    -X POST "$url" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${token}" \
    --data @"$json_file"
}

cmdbuild_put_json() {
  local url="$1"
  local json_file="$2"
  local token="${CMDBUILD_TOKEN:-}"

  if [[ -z "$token" ]]; then
    echo "CMDBUILD_TOKEN is not set" >&2
    return 1
  fi

  curl -sS \
    -X PUT "$url" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${token}" \
    --data @"$json_file"
}
