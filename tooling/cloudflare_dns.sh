#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/env.sh"

: "${CLOUDFLARE_DOMAIN:=giftpath.app}"
: "${CLOUDFLARE_PAGES_PROJECT:=giftpath}"

zone_json="$(curl -fsS "https://api.cloudflare.com/client/v4/zones?name=${CLOUDFLARE_DOMAIN}&account.id=${CLOUDFLARE_ACCOUNT_ID}" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  -H "Content-Type: application/json")"

zone_id="$(printf '%s' "$zone_json" | /usr/bin/python3 -c 'import json,sys; data=json.load(sys.stdin); result=data.get("result", []); print(result[0]["id"] if result else "")')"

if [[ -z "$zone_id" ]]; then
  echo "Could not find zone ${CLOUDFLARE_DOMAIN} in account ${CLOUDFLARE_ACCOUNT_ID}."
  echo "Make sure the domain is added to Cloudflare and the token has Zone:Read."
  exit 1
fi

create_or_update_cname() {
  local name="$1"
  local content="$2"
  local proxied="$3"
  local existing
  existing="$(curl -fsS "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records?type=CNAME&name=${name}" \
    -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
    -H "Content-Type: application/json")"
  local record_id
  record_id="$(printf '%s' "$existing" | /usr/bin/python3 -c 'import json,sys; data=json.load(sys.stdin); result=data.get("result", []); print(result[0]["id"] if result else "")')"

  local payload
  payload="$(/usr/bin/python3 - <<PY
import json
print(json.dumps({
  "type": "CNAME",
  "name": "$name",
  "content": "$content",
  "proxied": $proxied,
  "ttl": 1
}))
PY
)"

  if [[ -n "$record_id" ]]; then
    curl -fsS -X PUT "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records/${record_id}" \
      -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
      -H "Content-Type: application/json" \
      --data "$payload" >/dev/null
    echo "Updated CNAME ${name} -> ${content}"
  else
    curl -fsS -X POST "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records" \
      -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
      -H "Content-Type: application/json" \
      --data "$payload" >/dev/null
    echo "Created CNAME ${name} -> ${content}"
  fi
}

create_or_update_cname "www.${CLOUDFLARE_DOMAIN}" "${CLOUDFLARE_PAGES_PROJECT}.pages.dev" true

cat <<EOF

DNS helper complete for www.${CLOUDFLARE_DOMAIN}.

For the apex ${CLOUDFLARE_DOMAIN}, add it as a custom domain in Cloudflare Pages.
Cloudflare Pages may create/validate apex records for you, depending on the project setup.
EOF
