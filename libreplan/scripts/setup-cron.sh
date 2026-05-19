#!/bin/bash
set -e

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "${SCRIPTS_DIR}")"
BACKUP_SCRIPT="${SCRIPTS_DIR}/backup.sh"

if [ ! -f "$BACKUP_SCRIPT" ]; then
    echo "Error: backup.sh not found in ${SCRIPTS_DIR}"
    exit 1
fi

chmod +x "$BACKUP_SCRIPT"

# Define daily job (02:00 AM)
CRON_JOB="0 2 * * * cd ${PROJECT_DIR} && ./scripts/backup.sh > /dev/null 2>&1"
# Fetch existing crontab, filtering out old variations of this specific project path to prevent duplicates
CURRENT_CRON=$(crontab -l 2>/dev/null | grep -v "${PROJECT_DIR}/scripts/backup.sh" || true)

echo -e "${CURRENT_CRON}\n${CRON_JOB}" | crontab -

echo "Success! Daily backup job scheduled at 02:00 AM."
echo "View active jobs with: crontab -l"
