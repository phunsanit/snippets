<#
PowerShell: set dns server ip4 and ip6 to google dns all Adapters
#by pitt phunsanit
https://pitt.plusmagi.com
phunsanit@gmail.com
#>

$ErrorActionPreference = "SilentlyContinue"  # Suppress errors for adapters without IPv6

# Define Google DNS server addresses
$PreferredIPv4 = "8.8.8.8"
$AlternateIPv4 = "8.8.4.4"
$PreferredIPv6 = "2001:db8:853:0::1"
$AlternateIPv6 = "2001:db8:853:0::2"

# Get all network adapters
$Adapters = Get-NetAdapter

# Loop through each adapter and configure DNS
foreach ($Adapter in $Adapters) {
  # Set IPv4 DNS servers
  Set-DnsClientServerAddress -InterfaceIndex $Adapter.NetInterfaceIndex -ServerAddresses ($PreferredIPv4, $AlternateIPv4)

  # Try setting IPv6 DNS servers (ignore errors if not supported)
  try {
    Set-DnsClientServerAddress -InterfaceIndex $Adapter.NetInterfaceIndex -ServerAddresses ($PreferredIPv6, $AlternateIPv6) -AddressFamily IPv6
  } catch {
    Write-Warning "Failed to set IPv6 DNS servers for adapter: $Adapter.Name"
  }
}

Write-Host "DNS server addresses set to Google DNS for all adapters (if supported)."

# Verify DNS server settings
Get-DnsClientServerAddress

# Flush DNS cache (recommended after changing servers)
ipconfig /flushdns
Write-Host "DNS cache flushed."