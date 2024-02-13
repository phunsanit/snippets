<#
PowerShell: set dns server ip4 and ip6 to google dns all Adapter
#by pitt phunsanit
https://pitt.plusmagi.com
phunsanit@gmail.com
#>

# Disable automatic DNS retrieval (important for static configuration)
Get-NetAdapter | ForEach-Object {
    Set-NetAdapterProperty -Name $_.Name -IPv4Address -DNSAddressMode Static
    Set-NetAdapterProperty -Name $_.Name -IPv6Address -DNSAddressMode Static
}

# Set IPv4 and IPv6 DNS servers
$DnsServersIPv4 = @("8.8.8.8", "8.8.4.4")
$DnsServersIPv6 = @("2001:4860:4860::8888", "2001:4860:4860::8844")

Get-NetAdapter | ForEach-Object {
    # Set IPv4
    Set-DnsClientServerAddress -InterfaceIndex $_.InterfaceIndex -ServerAddresses $DnsServersIPv4 -Family IPv4
    Write-Host "Set IPv4 DNS servers for: $($_.Name) - $($DnsServersIPv4)"

    # Set IPv6 (skip if adapter doesn't support IPv6)
    if ($_.SupportsMulticast) {
        Set-DnsClientServerAddress -InterfaceIndex $_.InterfaceIndex -ServerAddresses $DnsServersIPv6 -Family IPv6
        Write-Host "Set IPv6 DNS servers for: $($_.Name) - $($DnsServersIPv6)"
    }
}

# Verify DNS server settings
Get-DnsClientServerAddress

# Flush DNS cache (recommended after changing servers)
ipconfig /flushdns
Write-Host "DNS cache flushed."