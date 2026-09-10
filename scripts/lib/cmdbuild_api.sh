#!/usr/bin/env bash
set -euo pipefail

cmdbuild_api_url() {
  local base_url="$1"
  local path="$2"
  printf '%s%s' "${base_url%/}" "$path"
}

cmdbuild_login() {
  local base_url="$1"
  local scope="$2"
  local username="$3"
  local password="$4"

  local response session_id
  response="$({
    curl -sS -X POST \
      "$(cmdbuild_api_url "$base_url" "/services/rest/v3/sessions?scope=${scope}&returnId=true")" \
      -H 'Content-Type: application/json' \
      -d "$(jq -nc --arg username "$username" --arg password "$password" '{username:$username,password:$password}')"
  } )"

  session_id="$(printf '%s' "$response" | jq -r '.data._id // empty')"

  if [[ -z "$session_id" ]]; then
    echo "Failed to obtain CMDBuild session ID" >&2
    echo "$response" >&2
    return 1
  fi

  printf '%s' "$session_id"
}

cmdbuild_post_json() {
  local url="$1"
  local json_file="$2"
  local session_id="${CMDBUILD_SESSION_ID:-}"

  if [[ -z "$session_id" ]]; then
    echo "CMDBUILD_SESSION_ID is not set" >&2
    return 1
  fi

  curl -sS \
    -X POST "$url" \
    -H "Content-Type: application/json" \
    -H "Cmdbuild-authorization: ${session_id}" \
    --data @"$json_file"
}

cmdbuild_put_json() {
  local url="$1"
  local json_file="$2"
  local session_id="${CMDBUILD_SESSION_ID:-}"

  if [[ -z "$session_id" ]]; then
    echo "CMDBUILD_SESSION_ID is not set" >&2
    return 1
  fi

  curl -sS \
    -X PUT "$url" \
    -H "Content-Type: application/json" \
    -H "Cmdbuild-authorization: ${session_id}" \
    --data @"$json_file"
}
