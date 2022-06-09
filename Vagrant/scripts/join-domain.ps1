# Purpose: Joins a Windows host to the windomain.local domain which was created with "create-domain.ps1".
# Source: https://github.com/StefanScherer/adfs2

# a variable that is never used :o
$hostsFile = "c:\Windows\System32\drivers\etc\hosts"

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Joining the domain..."

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) First, set DNS to DC to join the domain..."
# new dns server (dc's ip address)
$newDNSServers = "192.168.56.102"
# get network adapters with the ip address containing "192.168.36."
$adapters = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object {$_.IPAddress -match "192.168.56."}
# Don't do this in Azure. If the network adatper description contains "Hyper-V", this won't apply changes.
# Specify the DC as a WINS server to help with connectivity as well
# if the network adapter's description does not contain "hyper-v", set new dns to dc's ip address
$adapters | ForEach-Object {if (!($_.Description).Contains("Hyper-V")) {$_.SetDNSServerSearchOrder($newDNSServers); $_.SetWINSServer($newDNSServers, "")}}

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Now join the domain..."
# get the host name of the machine
$hostname = $(hostname)
# path locating the user
$user = "windomain.local\vagrant"
# password for user
$pass = ConvertTo-SecureString "vagrant" -AsPlainText -Force
# set user and password into a new PSCredential object
$DomainCred = New-Object System.Management.Automation.PSCredential $user, $pass

# Place the computer in the correct OU based on hostname
# Retry up to 3 times. Sleep 15 seconds between tries.
# if the hostname is "wef" or "exchange"---------------------------------- NOT NEEDED -------------------------------------------------------------------------------------------
If (($hostname -eq "wef") -or ($hostname -eq "exchange")) {
  $tries = 0
  While ($tries -lt 3) {
    Try {
      $tries += 1
      Add-Computer -DomainName "windomain.local" -credential $DomainCred -OUPath "ou=Servers,dc=windomain,dc=local" -PassThru -ErrorAction Stop
      Break
    } Catch {
      $tries += 1
      Write-Host $_.Exception.Message
      Start-Sleep 15
    }
  }
  # Attempt to fix Issue #517
  Set-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control' -Name 'WaitToKillServiceTimeout' -Value '500' -Type String -Force -ea SilentlyContinue
  New-ItemProperty -LiteralPath 'HKCU:\Control Panel\Desktop' -Name 'AutoEndTasks' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue
  Set-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\SessionManager\Power' -Name 'HiberbootEnabled' -Value 0 -Type DWord -Force -ea SilentlyContinue
# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# WINDOWS 10 joins the domain
} ElseIf ($hostname -eq "win10") {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Adding Win10 to the domain. Sometimes this step times out. If that happens, just run 'vagrant reload win10 --provision'" #debug
  # adds windows 10 to "windomain.local" and distinguished ou name (found in properties) with credentials
  Add-Computer -DomainName "windomain.local" -credential $DomainCred -OUPath "ou=Workstations,dc=windomain,dc=local"
} Else {
  # if fail, just add windows 10 to the domain without ou
  Add-Computer -DomainName "windomain.local" -credential $DomainCred -PassThru
}

# Stop Windows Update
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Disabling Windows Updates and Windows Module Services"
# disable windows update auto service
Set-Service wuauserv -StartupType Disabled
# stop windows update auto service
Stop-Service wuauserv
# disable trusted installer
Set-Service TrustedInstaller -StartupType Disabled
# stop trusted installer
Stop-Service TrustedInstaller

# Uninstall Windows Defender from WEF----------NOT NEEDED-------------------------------------------------------------------------------
# This command isn't supported on WIN10
If ($hostname -ne "win10" -And (Get-Service -Name WinDefend -ErrorAction SilentlyContinue).status -eq 'Running') {
  # Uninstalling Windows Defender (https://github.com/StefanScherer/packer-windows/issues/201)
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Uninstalling Windows Defender..."
  Try {
    Uninstall-WindowsFeature Windows-Defender -ErrorAction Stop
    Uninstall-WindowsFeature Windows-Defender-Features -ErrorAction Stop
  } Catch {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Windows Defender did not uninstall successfully..."
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) We'll try again during install-red-team.ps1"
  }
}
# --------------------------------------------------------------------------------------------------------------------------------------