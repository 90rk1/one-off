#!/bin/bash

set -e

if [ -f .env ]; then
    export $(cat .env | grep -v '#' | xargs)
elif [ -f ../.env ]; then
    export $(cat ../.env | grep -v '#' | xargs)
else
    echo "Error: .env file not found!"
    exit 1
fi

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="libreplan_backup_${TIMESTAMP}"
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_NAME}"

echo "Starting LibrePlan backup sequence..."

mkdir -p "${BACKUP_DIR}"
mkdir -p "${BACKUP_PATH}/data"

echo "Extracting database records..."
docker compose exec -T libreplan-db pg_dump -U "${DB_USER}" "${DB_NAME}" > "${BACKUP_PATH}/database.sql"

echo "Extracting application storage files..."
docker run --rm \
  -v $(docker volume inspect $(basename "$PWD")_libreplan_data --format '{{.Name}}'):/from \
  -v "$(pwd)/${BACKUP_PATH}/data:/to" \
  alpine cp -a /from/. /to/

echo "Compressing archive..."
tar -czf "${BACKUP_PATH}.tar.gz" -C "${BACKUP_DIR}" "${BACKUP_NAME}"
rm -rf "${BACKUP_PATH}"

echo "Success! Backup file created at: ${BACKUP_PATH}.tar.gz"
