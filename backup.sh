#!/usr/bin/env bash
set -euo pipefail
source /root/.frappe-env
PROJECT_NAME="${PROJECT_NAME}"
SITE="${BASE_DOMAIN}"
LOCAL_DIR="${BACKUP_LOCAL_DIR}"
mkdir -p "$LOCAL_DIR" "$LOCAL_DIR/latest"
docker compose --project-name "${PROJECT_NAME}" exec -T backend bash -lc "bench --site ${BASE_DOMAIN} backup --with-files >/dev/null 2>&1"
CID=$(docker compose --project-name "${PROJECT_NAME}" ps -q backend)
SRC_DIR="/home/frappe/frappe-bench/sites/${BASE_DOMAIN}/private/backups"
TMP_DIR="${LOCAL_DIR}/latest"
mkdir -p "$TMP_DIR"
docker cp "$CID:$SRC_DIR/." "$TMP_DIR/" || true
if [ "${BACKUP_DEST}" = "s3" ]; then
  export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
  export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
  export AWS_DEFAULT_REGION="${S3_REGION}"
  [ -n "${AWS_S3_FORCE_PATH_STYLE}" ] && export AWS_S3_FORCE_PATH_STYLE="${AWS_S3_FORCE_PATH_STYLE}"
  if [ -n "${AWS_ENDPOINT_URL}" ]; then
    aws --endpoint-url "${AWS_ENDPOINT_URL}" s3 sync "$TMP_DIR/" "${S3_BUCKET%/}/${S3_PREFIX}/${BASE_DOMAIN}/" --region "${S3_REGION}"
  else
    aws s3 sync "$TMP_DIR/" "${S3_BUCKET%/}/${S3_PREFIX}/${BASE_DOMAIN}/" --region "${S3_REGION}"
  fi
fi
stamp=$(date +%F_%H-%M)
mkdir -p "${LOCAL_DIR}/history/$stamp"
mv "$TMP_DIR"/* "${LOCAL_DIR}/history/$stamp/" 2>/dev/null || true
RET_DAYS=${BACKUP_RETENTION_DAYS:-7}
find "${LOCAL_DIR}/history" -maxdepth 1 -type d -mtime +"$RET_DAYS" -exec rm -rf {} +
