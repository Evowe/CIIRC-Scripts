#!/bin/bash
<<COMMENT

=============================================================================

 Central Texas Cyber Range (CTCR)

=============================================================================

 Maker:       Ethan Vowels

 Maintainer:  Ethan Vowels

 Project:     CIIRC

 Filename:    sshKeys.sh

Git: Abanisenioluwa_oroj1

 Description:

    This script creates ssh keys for the redteam created account on the HR machine. 

 Extension Principle:

    None

 License:

    MIT

 Additional Information:

    - Date Created: 7/24/2024

    - Last Updated: 7/24/2024

    - Contact: ethan_vowels1@baylor.edu

    - Repository: Gitlab CIIRC Hack

=============================================================================

COMMENT

# Ensure this script is run with IP addresses as arguments
if [ $# -lt 1 ]; then
  echo "Usage: $0 <IP_Address1> [IP_Address2] ..."
  exit 1
fi

# Collect all IPs
TARGET_IPS=("$@")
USERNAME="redteam"
PASSWORD="InTheMainframe"
PUBLIC_KEY_PATH="/home/cybears/Scripts/rsa.pub"
PUBLIC_KEY=$(cat "$PUBLIC_KEY_PATH")

copy_key() {
  local target_machine=$1
  echo "Copying key to $USERNAME@$target_machine"
  sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$USERNAME@$target_machine" "mkdir -p ~/.ssh && echo '$PUBLIC_KEY' >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"
  echo "Key copied to $target_machine"
}

for TARGET_IP in "${TARGET_IPS[@]}"; do
  echo "Processing : $TARGET_IP"
  copy_key "$TARGET_IP"
done
