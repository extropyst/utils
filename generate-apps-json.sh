#!/usr/bin/env bash
set -euo pipefail

# Genera apps.json dinámico leyendo variables de entorno o flags
# Variables esperadas (con defaults razonables):
#  FRAPPE_BRANCH=version-15
#  ERPNEXT_BRANCH=version-15
#  HRMS_BRANCH=version-15
#  CRM_BRANCH=main
#  GAMEPLAN_BRANCH=main
#  DRIVE_BRANCH=main
#  EDUCATION_BRANCH=version-15
#  APP_INCLUDE_HRMS=true|false
#  APP_INCLUDE_CRM=true|false
#  APP_INCLUDE_GAMEPLAN=true|false
#  APP_INCLUDE_DRIVE=true|false
#  APP_INCLUDE_EDUCATION=true|false

FRAPPE_BRANCH=${FRAPPE_BRANCH:-version-15}
ERPNEXT_BRANCH=${ERPNEXT_BRANCH:-version-15}
HRMS_BRANCH=${HRMS_BRANCH:-version-15}
CRM_BRANCH=${CRM_BRANCH:-main}
GAMEPLAN_BRANCH=${GAMEPLAN_BRANCH:-main}
DRIVE_BRANCH=${DRIVE_BRANCH:-main}
EDUCATION_BRANCH=${EDUCATION_BRANCH:-version-15}

APP_INCLUDE_HRMS=${APP_INCLUDE_HRMS:-true}
APP_INCLUDE_CRM=${APP_INCLUDE_CRM:-false}
APP_INCLUDE_GAMEPLAN=${APP_INCLUDE_GAMEPLAN:-true}
APP_INCLUDE_DRIVE=${APP_INCLUDE_DRIVE:-false}
APP_INCLUDE_EDUCATION=${APP_INCLUDE_EDUCATION:-true}

if ! command -v jq >/dev/null 2>&1; then
  echo "jq no está instalado" >&2
  exit 1
fi

APPS=$(jq -n '[]')
APPS=$(echo "$APPS" | jq --arg url "https://github.com/frappe/erpnext" --arg br "$ERPNEXT_BRANCH" '. + [{url:$url,branch:$br}]')

if [ "$APP_INCLUDE_HRMS" = "true" ]; then
  APPS=$(echo "$APPS" | jq --arg url "https://github.com/frappe/hrms" --arg br "$HRMS_BRANCH" '. + [{url:$url,branch:$br}]')
fi
if [ "$APP_INCLUDE_CRM" = "true" ]; then
  APPS=$(echo "$APPS" | jq --arg url "https://github.com/frappe/crm" --arg br "$CRM_BRANCH" '. + [{url:$url,branch:$br}]')
fi
if [ "$APP_INCLUDE_GAMEPLAN" = "true" ]; then
  APPS=$(echo "$APPS" | jq --arg url "https://github.com/frappe/gameplan" --arg br "$GAMEPLAN_BRANCH" '. + [{url:$url,branch:$br}]')
fi
if [ "$APP_INCLUDE_DRIVE" = "true" ]; then
  APPS=$(echo "$APPS" | jq --arg url "https://github.com/frappe/drive" --arg br "$DRIVE_BRANCH" '. + [{url:$url,branch:$br}]')
fi
if [ "$APP_INCLUDE_EDUCATION" = "true" ]; then
  APPS=$(echo "$APPS" | jq --arg url "https://github.com/frappe/education" --arg br "$EDUCATION_BRANCH" '. + [{url:$url,branch:$br}]')
fi

OUTPUT=${1:-apps.json}
echo "$APPS" > "$OUTPUT"
if base64 -w 0 "$OUTPUT" > apps.json.b64 2>/dev/null; then
  :
else
  base64 "$OUTPUT" | tr -d '\n' > apps.json.b64
fi

echo "Generado $OUTPUT y apps.json.b64"
