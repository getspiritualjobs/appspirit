#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -f "${repo_root}/.env.local" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "${repo_root}/.env.local"
  set +a
fi

required=(
  CLOUDFLARE_ACCOUNT_ID
  CLOUDFLARE_API_TOKEN
)

for name in "${required[@]}"; do
  if [[ -z "${!name:-}" ]]; then
    echo "Missing ${name}. Add it to .env.local or export it in your shell."
    exit 1
  fi
done
