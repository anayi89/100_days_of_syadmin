function installRolesAndFeatures {
    $rolesandfeatures = @("Bitlocker", "DHCP", "DNS", "GPMC", "Print-Services",
                            "Remote-Desktop-Services", "SMTP-Server", "UpdateServices",
                            "Web-MGMT-Service", "Web-Server", "Wireless-Networking")

    foreach ($roleandfeature in $rolesandfeatures){
    Install-WindowsFeature -Name $roleandfeature -IncludeManagementTools
    Get-WindowsFeature -Name $roleandfeature
    }
    $pcname = (Get-WmiObject -Class Win32_ComputerSystem -Property Name).Name
    Restart-Computer -ComputerName $pcname -Force
}
installRolesAndFeatures
