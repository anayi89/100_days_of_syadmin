function staticIpAddress {
    $wmi = Get-WmiObject win32_networkadapterconfiguration -filter "ipenabled = 'true'"

    $ipAddress = Read-Host -Prompt 'Enter an IP address'
    $subnetMask = Read-Host -Prompt 'Enter the subnet mask'
    $defaultGateway = Read-Host -Prompt 'Enter the router IP address'
    $dnsServer = Read-Host -Prompt 'Enter the DNS server'

    $wmi.EnableStatic($ipAddress, $subnetMask)
    $wmi.SetGateways($defaultGateway, 1)
    $wmi.SetDNSServerSearchOrder($dnsServer)
}

staticIpAddress
