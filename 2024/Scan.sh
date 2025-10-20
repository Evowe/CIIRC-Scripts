#!/bin/bash
# Function to install nmap if not installed
# Should be on a master machine but just in case
install_nmap() {
echo "Installing nmap..."
if [[ $(uname) == "Linux" ]]; then
sudo apt-get update
sudo apt-get install nmap -y
else
echo "Operating system not supported."
exit 1
fi
}
# Check if nmap is installed
if ! command -v nmap &> /dev/null; then
install_nmap
fi
# IP address to scan
#will need to change to competition IP
IP_ADDRESS="127.0.0.1"
# Run nmap scan
echo "Scanning $IP_ADDRESS for open ports 22 and 1234..."
nmap_output=$(nmap -p 22,1234 $IP_ADDRESS)
# Check if ports are open
if [[ $nmap_output == *"22/tcp open"* ]]; then
echo "Port 22 is open on $IP_ADDRESS"
else
echo "Port 22 is closed on $IP_ADDRESS"
fi
if [[ $nmap_output == *"1234/tcp open"* ]]; then
echo "Port 1234 is open on $IP_ADDRESS"
else
echo "Port 1234 is closed on $IP_ADDRESS"
fi