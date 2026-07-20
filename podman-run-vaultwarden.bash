#!/usr/bin/env bash
set -euo pipefail

# Vaultwarden mit Podman betreiben
# Verwendung: ./vaultwarden.sh {start|stop|restart|status|logs|update}

CONTAINER_NAME="vaultwarden"
IMAGE="docker.io/vaultwarden/server:latest"
DATA_DIR="${HOME}/vaultwarden/data"
HTTP_PORT=8080
ADMIN_TOKEN="changeme-admin-token"

start() {
    mkdir -p "${DATA_DIR}"
    echo "Starte Vaultwarden..."
    podman run -d \
        --name "${CONTAINER_NAME}" \
        --restart unless-stopped \
        -p "${HTTP_PORT}:80" \
        -v "${DATA_DIR}:/data:Z" \
        -e SIGNUPS_ALLOWED=true \
        -e WEBSOCKET_ENABLED=true \
        -e ADMIN_TOKEN="${ADMIN_TOKEN}" \
        "${IMAGE}"
    echo "Vaultwarden läuft auf http://localhost:${HTTP_PORT}"
    echo "Admin-Panel:  http://localhost:${HTTP_PORT}/admin (Token: ${ADMIN_TOKEN})"
}

stop() {
    echo "Stoppe Vaultwarden..."
    podman stop "${CONTAINER_NAME}" || true
    podman rm "${CONTAINER_NAME}" || true
}

status() {
    podman ps -a --filter "name=${CONTAINER_NAME}"
}

logs() {
    podman logs -f "${CONTAINER_NAME}"
}

update() {
    echo "Aktualisiere Image..."
    podman pull "${IMAGE}"
    stop
    start
}

case "${1:-}" in
    start)   start ;;
    stop)    stop ;;
    restart) stop; start ;;
    status)  status ;;
    logs)    logs ;;
    update)  update ;;
    *)
        echo "Verwendung: $0 {start|stop|restart|status|logs|update}"
        exit 1
        ;;
esac
