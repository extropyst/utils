#!/usr/bin/env bash
set -euo pipefail
BASE_DOMAIN="workplace.comunidadcientifica.cl"
PROJECT_NAME="erp"
echo "==== Post-deploy: ayuda rápida ===="
echo "Sitio principal: https://${BASE_DOMAIN}"
echo
echo "Estado de contenedores:"
echo "  docker compose --project-name ${PROJECT_NAME} ps"
echo "  docker compose --project-name traefik ps"
echo "  docker compose --project-name mariadb ps"
echo
echo "Logs:"
echo "  sudo tail -n 200 /var/log/setup-frappe.log"
echo "  docker compose --project-name ${PROJECT_NAME} logs -f backend"
echo "  docker compose --project-name ${PROJECT_NAME} logs -f create-site"
echo
echo "Bench útil:"
echo "  docker compose --project-name ${PROJECT_NAME} exec backend bench --site ${BASE_DOMAIN} list-apps"
echo "  docker compose --project-name ${PROJECT_NAME} exec backend bench --site ${BASE_DOMAIN} console"
echo
echo "Traefik (API local vía túnel SSH al 127.0.0.1:8080):"
echo "  curl -sSI http://127.0.0.1:8080/api/rawdata | head -n 1"
echo "  curl http://127.0.0.1:8080/api/rawdata"
echo
echo "Validación rápida (ignora certificado mientras LE está rate-limited):"
echo "  curl -kI https://${BASE_DOMAIN}/login | head -n 1"
echo
echo "Certificados (ACME Staging vs Prod):"
echo "  Mantén ACME_STAGING=\"true\" en pruebas y cámbialo a \"false\" en producción cuando el dominio ya responda en 80/443."
echo "  Variable en: /root/.frappe-env (requiere reiniciar Traefik tras cambiarla)."
echo
echo "Si la validación de Traefik falló durante el arranque, puede revisar un preview enmascarado de /tmp/traefik-config.yaml (si existe) con:"
echo "sudo /usr/local/bin/traefik-config-preview"
