#!/bin/bash
set -e

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

mkdir -p "$BACKUP_DIR"

echo "[$(date)] Starting backup..."

# PostgreSQL Backup
echo "Backing up PostgreSQL..."
docker exec postgres pg_dumpall -U admin > "$BACKUP_DIR/postgres_$TIMESTAMP.sql" 2>/dev/null || \
  echo "Warning: PostgreSQL backup failed (container may not be running)"

# Compress backup
if [ -f "$BACKUP_DIR/postgres_$TIMESTAMP.sql" ]; then
  gzip "$BACKUP_DIR/postgres_$TIMESTAMP.sql"
  echo "PostgreSQL backup saved: postgres_$TIMESTAMP.sql.gz"
fi

# Redis Backup
echo "Backing up Redis..."
docker exec redis redis-cli BGSAVE > /dev/null 2>&1 || echo "Warning: Redis backup failed"
sleep 2
docker cp redis:/data/dump.rdb "$BACKUP_DIR/redis_$TIMESTAMP.rdb" 2>/dev/null || echo "Warning: Redis RDB copy failed"

# Cleanup old backups
echo "Cleaning up backups older than $RETENTION_DAYS days..."
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete 2>/dev/null
find "$BACKUP_DIR" -name "*.rdb" -mtime +$RETENTION_DAYS -delete 2>/dev/null

echo "[$(date)] Backup complete! Files in $BACKUP_DIR:"
ls -lh "$BACKUP_DIR/" 2>/dev/null || echo "No backups found"
