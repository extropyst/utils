#!/usr/bin/env bash
set -euo pipefail
DEVICE=""; MOUNTPOINT="/mnt/frappe-files"; FORCE_FORMAT="false"
usage(){ echo "Uso: $0 --device /dev/vdb [--mount /mnt/frappe-files] [--force-format]"; exit 1; }
while [ $# -gt 0 ]; do case "$1" in --device) DEVICE="$2"; shift 2;; --mount) MOUNTPOINT="$2"; shift 2;; --force-format) FORCE_FORMAT="true"; shift 1;; -h|--help) usage;; *) echo "Parámetro desconocido: $1"; usage;; esac; done
[ -b "$DEVICE" ] || { echo "Dispositivo no válido: $DEVICE"; exit 1; }
mkdir -p "$MOUNTPOINT"
FS=$(lsblk -no FSTYPE "$DEVICE" | head -n1 || true)
if [ -z "$FS" ] || [ "$FORCE_FORMAT" = "true" ]; then mkfs.ext4 -F -m 0 "$DEVICE"; fi
UUID=$(blkid -s UUID -o value "$DEVICE")
if ! grep -q "UUID=$UUID" /etc/fstab; then echo "UUID=$UUID $MOUNTPOINT ext4 defaults,nofail,noatime 0 2" >> /etc/fstab; fi
mount -a; mkdir -p "$MOUNTPOINT/public" "$MOUNTPOINT/private" "$MOUNTPOINT/backups"; chown -R 1000:1000 "$MOUNTPOINT"
