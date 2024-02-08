#!/bin/bash

# Check if hosts file given as first arg
if [ $# -eq 0 ]; then
    echo "Usage: $0 -h <hosts_file> [-o <output_file>]"
    exit 1
fi

while getopts "h:o:" opt; do
    case $opt in
        h) hosts_file="$OPTARG" ;;
        o) output_file="$OPTARG" ;;
        \?) echo "Invalid option: -$OPTARG"; exit 1 ;;
        :) echo "Option -$OPTARG requires an argument."; exit 1 ;;
    esac
done

# Check if hosts file provided
[ -z "$hosts_file" ] && { echo "Error: Hosts file not provided. Use -h <hosts_file>."; exit 1; }

# Check if file exists
[ ! -f "$hosts_file" ] && { echo "Error: File '$hosts_file' not found."; exit 1; }

# Set output file/use default 
output_file="${output_file:-snmpwalk_results.txt}"

# Function to run snmpwalk
run_snmpwalk() {
    host=$1; oid=$2; title=$3
    echo -e "\n[-] $title\n-----------------------------\n$(snmpwalk -c public -v2c "$host" "$oid")"
}

# OIDs and their corresponding titles
declare -A oids=(
    ["1.3.6.1.4.1.77.1.2.25"]="Windows Users"
    ["1.3.6.1.2.1.25.4.2.1.2"]="Running Windows Processes"
    ["1.3.6.1.2.1.6.13.1.3"]="Open TCP Ports"
    ["1.3.6.1.2.1.25.6.3.1.2"]="Installed Software"
    ["1.3.6.1.2.1.25.2.3.1.4"]="Storage Units"
)

# Iterate through each host in file
cat "$hosts_file" | while read -r host; do
    echo -e "[+] Testing $host\n-----------------------------"
    for oid in "${!oids[@]}"; do
        run_snmpwalk "$host" "$oid" "${oids[$oid]}"
    done
done > "$output_file"

echo "Results have been saved to $output_file"