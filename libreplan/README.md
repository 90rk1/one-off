# Libreplan

This project provides a local deployment environment for LibrePlan using Docker Compose.

Enough for testing and not enough for production use.
---

## Project Structure

```text
libreplan/
├── .env
├── docker-compose.yml
├── README.md
└── scripts/
    ├── backup.sh
    ├── restore.sh
    └── setup-cron.sh
```

---

## 1. Prerequisites

* docker
* docker compose

---
#### 1.1 Fix bug
mkdir patches
curl -sSLo patches/stax2-api-4.2.1.jar https://maven.org 
## 2. Starting the Application Stack

```bash
docker compose up -d
```

In web browser:

http://localhost:8080

---

## 3. Script Permissions

```bash
chmod +x scripts/backup.sh scripts/restore.sh scripts/setup-cron.sh
```

---

## 4. Backup and Restore Operations

Always run the scripts from the root directory.

### Manual Backup
Run backup script to export db and libreplan files:

```bash
./scripts/backup.sh
```

*  Creates a backup like `./backups/libreplan_backup_20260519_142000.tar.gz`.

### Manual Restore
Warning: This action completely overwrites your current database and uploaded application file data.

```bash
./scripts/restore.sh ./backups/libreplan_backup_20260519_142000.tar.gz
```

---

## 5. Automated Daily Backups

Add backup script to cron.

```bash
./scripts/setup-cron.sh
```

* Execute daily at 02:00 AM.
* View active cron jobs by running: `crontab -l`.

