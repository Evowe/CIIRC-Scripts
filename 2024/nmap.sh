#!/bin/bash

target_ips{
        "<team1_IP>"
        "<team2_IP>"
        "<team3_IP>"
        # Add more IPs for each team
}

for ip in "${target_ips[@]}"; do

        sudo nmap -A -sU -T5 "ip"
        sudo nmap -A -Sn -T5 "ip"
        echo "nmap scanned $ip"
        echo "================================="
done