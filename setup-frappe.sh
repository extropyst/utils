#!/usr/bin/env bash
set -euo pipefail
LOGFILE=/var/log/setup-frappe.log
exec 3>&1 1>>${LOGFILE} 2>&1

echo "Starting setup-frappe.sh"
# Minimal stub: in real script this would install Docker, pull compose, create .frappe-env, etc.

if [[ -f /root/.frappe-env ]]; then
  echo "Found /root/.frappe-env"
else
  echo "No /root/.frappe-env found; using defaults from environment variables"
fi

echo "(setup-frappe.sh) Completed successfully"
