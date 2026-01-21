#!/bin/bash

echo "--- Available Network Services ---"
networksetup -listallnetworkservices
echo "----------------------------------"

# Ask for Network name
echo "Enter network name (Press Enter to use 'Wi-Fi'):"
read INPUT_NAME

if [ -z "$INPUT_NAME" ]; then
    SERVICE_NAME="Wi-Fi"
    echo "Using default: 'Wi-Fi'"
else
    SERVICE_NAME="$INPUT_NAME"
fi

# DNS Addresses (IPv4 + IPv6)
# Cloudflare v4: 1.1.1.1, 1.0.0.1
# Google v4:     8.8.8.8, 8.8.4.4
# Cloudflare v6: 2606:4700:4700::1111, 2606:4700:4700::1001
# Google v6:     2001:4860:4860::8888, 2001:4860:4860::8844

echo "Setting IPv4 & IPv6 DNS for '$SERVICE_NAME'..."

# This command is a bit long because it includes all DNS servers
sudo networksetup -setdnsservers "$SERVICE_NAME" \
1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4 \
2606:4700:4700::1111 2606:4700:4700::1001 \
2001:4860:4860::8888 2001:4860:4860::8844

# Check results
echo "--- Current DNS Settings ---"
networksetup -getdnsservers "$SERVICE_NAME"

echo "Done! Full IPv4 & IPv6 coverage."
