#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage: $0 <IP_Address1> [IP_Address2] ..."
  exit 1
fi

# Collect all IP addresses provided as arguments
TARGET_IPS=("$@")

for TARGET_IP in "${TARGET_IPS[@]}"; do
        echo "Pinging address: $TARGET_IP"

        ping -c 4 "$TARGET_IP" > /dev/null 2>&1

        # Check to see if ping worked

        if [ "$?" -eq 0 ]; then
                echo "Success: $TARGET_IP"
        else
                echo "Failure: Unable to reach $TARGET_IP"
        fi

        echo "-----------------------------"
done