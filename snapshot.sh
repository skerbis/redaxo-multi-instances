#!/bin/bash
# Usage:
#   snapshot make instanzname
#   snapshot recover instanzname
#
# Sichert und stellt eine REDAXO-Instanz (Datenbank-Volume + App-Verzeichnis) wieder her.
# Snapshots liegen in backups/<instanzname>/

set -e

show_help() {
  echo "Usage: $0 make <instanzname>"
  echo "       $0 recover <instanzname>"
  exit 1
}

if [ "$#" -lt 2 ]; then
  show_help
fi

MODE="$1"
INSTANZ="$2"

if [ -z "$INSTANZ" ]; then
  show_help
fi

DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$DIR/backups/$INSTANZ"
COMPOSE_FILE="$DIR/instances/$INSTANZ/docker-compose.yml"
VOLUME_NAME="${INSTANZ}_mariadb_data"
APP_DIR="$DIR/instances/$INSTANZ/app"

if [ ! -f "$COMPOSE_FILE" ]; then
  echo "docker-compose.yml für Instanz '$INSTANZ' nicht gefunden! ($COMPOSE_FILE)"
  exit 1
fi

mkdir -p "$BACKUP_DIR"

if [ "$MODE" = "make" ]; then
  echo "[INFO] Backup für Instanz $INSTANZ wird erstellt..."
  docker compose -f "$COMPOSE_FILE" down
  docker run --rm -v "${VOLUME_NAME}:/volume" -v "$BACKUP_DIR:/backup" alpine sh -c "tar czf /backup/mariadb_data.tar.gz -C /volume ."
  tar czf "$BACKUP_DIR/app.tar.gz" -C "$APP_DIR" .
  echo "[OK] Backup gespeichert in $BACKUP_DIR"
  docker compose -f "$COMPOSE_FILE" up -d
elif [ "$MODE" = "recover" ]; then
  echo "[INFO] Wiederherstellung für Instanz $INSTANZ..."
  if [ ! -f "$BACKUP_DIR/mariadb_data.tar.gz" ] || [ ! -f "$BACKUP_DIR/app.tar.gz" ]; then
    echo "Kein Backup gefunden für $INSTANZ!"
    exit 1
  fi
  docker compose -f "$COMPOSE_FILE" down
  docker volume rm "$VOLUME_NAME" || true
  docker volume create "$VOLUME_NAME"
  docker run --rm -v "${VOLUME_NAME}:/volume" -v "$BACKUP_DIR:/backup" alpine sh -c "cd /volume && tar xzf /backup/mariadb_data.tar.gz"
  rm -rf "$APP_DIR"/*
  tar xzf "$BACKUP_DIR/app.tar.gz" -C "$APP_DIR"
  echo "[OK] Wiederherstellung abgeschlossen."
  docker compose -f "$COMPOSE_FILE" up -d
else
  show_help
fi
