#!/bin/bash

# Command: passwd_extract.sh OS_NAME TARGET_IP USERNAME PASSWORD

#Set the ENV variables
OS_NAME=$1
TARGET_IP=$2
USERNAME=$3
PASSWORD=$4

# Can change this to be passed via arguments
$WORD_LIST_FILE="rockyou.txt.gz"

#Pre-requisites

# Check if ntdsxtract is installed
if ! command -v ntdsxtract &> /dev/null
then
    echo "Error: ntdsxtract is not installed. Please install it from https://github.com/csababarta/ntdsxtract"
    exit 1
fi

# Script to decode the hash stored in the shadow password file

if [ OS_NAME = "linux" ]
then
    #Run the script for Linux 
    echo "Linux password extraction running"
    source "./linux_shadow_copy.sh"
else
    #Run the script for Windows
    echo "Windows password extraction running"
    source "./windows_shadow_copy.sh"