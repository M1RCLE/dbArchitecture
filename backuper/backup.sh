#!/bin/bash

echo "started backup process"

backup_file="$PWD/backuper/backups/$(date +'%Y%m%d%H%M%S').sql"

echo "$backup_file"

DB_HOST=localhost
POSTGRES_USER=postgres
POSTGRES_DB=postgres
BACKUPS_COUNT=3

export PGPASSWORD='postgres'
pg_dump --host=localhost --username=postgres --dbname=postgres -f "$backup_file"
unset PGPASSWORD

while [[ $(ls -1 backups | wc -l) -gt ${BACKUPS_COUNT} ]]; do
  oldest=$(ls -1 backups | head -n 1)
  rm backups/"$oldest"
done

echo "finished backup process"
