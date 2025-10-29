#!/usr/bin/env bash
set -euo pipefail
HOST=${1:-localhost}
USER=${2:-admin}
PASS=${3:-password}

# Check basic auth against Traefik (requires curl)
RESPONSE=$(curl -sS -o /dev/null -w "%{http_code}" -u "$USER:$PASS" "https://$HOST/"
)
if [[ "$RESPONSE" == "401" ]]; then
  echo "Unauthorized (401) — credentials rejected"
  exit 1
fi
if [[ "$RESPONSE" =~ ^2 ]]; then
  echo "Auth success (HTTP $RESPONSE)"
  exit 0
fi

echo "Unexpected response: $RESPONSE"
exit 2
