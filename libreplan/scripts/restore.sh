#!/bin/bash

set -e

if [ -f .env ]; then
    export $(cat .env | grep -v '#' | xargs)
else
    echo "Error: .env file not found!"
    exit 1
fi

if [ -z "$1" ]; then
    echo "Usage: $0 <path_to_backup_file.tar.gz>"
    exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "${BACKUP_FILE}" ]; then
    echo "Error: Backup file '${BACKUP_FILE}' does not exist."
    exit 1
fi

EXTRACT_DIR=$(tar -tf "${BACKUP_FILE}" | head -n 1 | cut -f1 -d"/")

echo "Starting LibrePlan restore sequence..."

echo "Stopping application container..."
docker compose stop libreplan

echo "Extracting backup archive..."
rm -rf "./tmp_restore" && mkdir -p "./tmp_restore"
tar -xzf "${BACKUP_FILE}" -C "./tmp_restore"

echo "Restoring application files..."
docker run --rm \
  -v "./tmp_restore/${EXTRACT_DIR}/data:/from" \
  -v $(docker volume inspect $(basename "$PWD")_libreplan_data --format '{{.Name}}'):/to \
  alpine sh -c "rm -rf /to/* && cp -a /from/. /to/"

echo "Restoring database records..."
# Clear existing public schema to avoid duplicate key or table conflicts
docker compose exec -T libreplan-db psql -U "${DB_USER}" -d "${DB_NAME}" -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
# Import SQL file
docker compose exec -T libreplan-db psql -U "${DB_USER}" -d "${DB_NAME}" < "./tmp_restore/${EXTRACT_DIR}/database.sql"

rm -rf "./tmp_restore"

echo "Restarting application stack..."
docker compose up -d

echo "Success! LibrePlan stack successfully restored and restarted."
