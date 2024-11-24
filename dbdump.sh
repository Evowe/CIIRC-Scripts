#!/bin/bash

# Command: ./dbdump.sh database_name team_name

# Save the params from the CLI input

TEAM_NAME="$2"
DB_NAME="$1"

# Bash Script for extracting a database dump from a PostGres SQL Database

# PostgreSQL database credentials
DB_USER="your_username"
DB_PASS="your_password"
DB_NAME="your_database_name"


# Directory to save the dump file 
DUMP_DIR="/path/to/dump/directory"

# Date format for the dump file
DATE=$(date + "%Y%m%d%H%M")

# Create the dump file name
DUMP_FILE="$DB_NAME_$DATE.sql"

# Postgres database dump command
pg_dump -U "$DB_USER" -d "$DB_NAME" > "$BACKUP_DIR/$DUMP_FILE"

# Check if dump was successful
if [ $? -eq 0 ]; then
    echo "Database dump successful. Backup saved to: $BACKUP_DIR/$DUMP_FILE"
else
    echo "Error: $DUMP_FILE Database dump failed."
fi