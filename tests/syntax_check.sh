#!/bin/bash

# Test script for syntax checking
# Uses bash -n to check for syntax errors

EXIT_CODE=0

echo "Checking shell scripts syntax..."

# Check src/setup.sh
if [ -f "src/setup.sh" ]; then
    if bash -n src/setup.sh; then
        echo "PASS: src/setup.sh syntax is valid."
    else
        echo "FAIL: src/setup.sh has syntax errors."
        EXIT_CODE=1
    fi
else
    echo "FAIL: src/setup.sh not found."
    EXIT_CODE=1
fi

# Check config files integrity (basic check if they exist)
echo "Checking configuration files..."
CONFIG_FILES=(
    "configs/dhcp/dhcpd.conf"
    "configs/dhcp/isc-dhcp-server"
    "configs/dns/named.conf.options"
    "configs/dns/named.conf.local"
)

for file in "${CONFIG_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "PASS: $file exists."
    else
        echo "FAIL: $file not found."
        EXIT_CODE=1
    fi
done

exit $EXIT_CODE
