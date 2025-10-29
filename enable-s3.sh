#!/usr/bin/env bash
set -euo pipefail
if [ -f /root/.frappe-env ]; then source /root/.frappe-env; fi
PROJECT_NAME="${PROJECT_NAME:-erp}"
BASE_DOMAIN="${BASE_DOMAIN:-workplace.comunidadcientifica.cl}"
S3_BUCKET="s3://TU-BUCKET"
S3_REGION="${S3_REGION:-ewr1}"
S3_ENDPOINT="${AWS_ENDPOINT_URL:-}"
S3_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-}"
S3_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-}"
docker compose --project-name ${PROJECT_NAME} exec -T backend bash -lc "bench get-app --branch ${FILES_S3_APP_BRANCH:-main} ${FILES_S3_APP_REPO:-https://github.com/leam-tech/frappe_s3_attachment} || true && bench --site ${BASE_DOMAIN} install-app frappe_s3_attachment || true && bench --site ${BASE_DOMAIN} set-config enable_s3_file_storage true --value-type bool && bench --site ${BASE_DOMAIN} set-config use_s3 true --value-type bool && bench --site ${BASE_DOMAIN} set-config s3_bucket '${S3_BUCKET}' && bench --site ${BASE_DOMAIN} set-config s3_access_key_id '${S3_ACCESS_KEY_ID}' && bench --site ${BASE_DOMAIN} set-config s3_secret_access_key '${S3_SECRET_ACCESS_KEY}' && bench --site ${BASE_DOMAIN} set-config s3_region_name '${S3_REGION}' && [ -n '${S3_ENDPOINT}' ] && bench --site ${BASE_DOMAIN} set-config s3_endpoint_url '${S3_ENDPOINT}' || true && bench --site ${BASE_DOMAIN} set-config s3_signature_version 's3v4' && bench --site ${BASE_DOMAIN} set-config s3_use_path_style 'true'"
