# Purpose: Sets timezone to UTC, sets hostname, creates/joins domain.
# Source: https://github.com/StefanScherer/adfs2

# store profile path in ProfilePath variable
$ProfilePath = "C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1"
# get computer name from HKEY
$box = Get-ItemProperty -Path HKLM:SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName -Name "ComputerName"
# turn computer name to lowercase string
$box = $box.ComputerName.ToString().ToLower()

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Setting timezone to UTC..."
# runs timezone utility and change timezone to UTC
c:\windows\system32\tzutil.exe /s "UTC"

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Checking if Windows evaluation is expiring soon or expired..."
# runs fix-windows-expiration.ps1 from vagrant to extend windows trial
. c:\vagrant\scripts\fix-windows-expiration.ps1

# if there is no directory matching ProfilePath
If (!(Test-Path $ProfilePath)) {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Disabling the Invoke-WebRequest download progress bar globally for speed improvements." 
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) See https://github.com/PowerShell/PowerShell/issues/2138 for more info"
  # make a new file in the variable ProfilePath's path then outputs null
  New-Item -Path $ProfilePath | Out-Null
  # if there is no result for getting the file contents and matching "SilentlyContinue" in every variable 
  If (!(Get-Content $Profilepath| % { $_ -match "SilentlyContinue" } )) {
    # add SilentlyContinue to ProgressPreference, which disables errors and continue
    Add-Content -Path $ProfilePath -Value "$ProgressPreference = 'SilentlyContinue'"
  }
}

# Ping DetectionLab server for usage statistics (honestly not needed)
Try {
  # get response from detectionlab website then ouputs null
  curl -userAgent "DetectionLab-$box" "https://ping.detectionlab.network/$box" -UseBasicParsing | out-null
} Catch { # ERROR
  Write-Host "Unable to connect to ping.detectionlab.network"
}

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Disabling IPv6 on all network adatpers..."
# get tcpip6/ipv6 info from network adapter, then disable them for each binding
Get-NetAdapterBinding -ComponentID ms_tcpip6 | ForEach-Object {Disable-NetAdapterBinding -Name $_.Name -ComponentID ms_tcpip6}
# displays ipv6 components, which by right is already disabled (for logging on host machine. i assume)
Get-NetAdapterBinding -ComponentID ms_tcpip6 
# https://support.microsoft.com/en-gb/help/929852/guidance-for-configuring-ipv6-in-windows-for-advanced-users
# disable ipv6 via HKEY
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v DisabledComponents /t REG_DWORD /d 255 /f

# ----------------------------------------------------------------------------------------------------------------------------
# if the computer name found via the $env variable matches 'vagrant' (not supposed to be)
if ($env:COMPUTERNAME -imatch 'vagrant') {

  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Hostname is still the original one, skip provisioning for reboot..."

  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing bginfo..."
  # runs install-bginfo.ps1 script in vagrant to install bginfo AND set wallpaper
  . c:\vagrant\scripts\install-bginfo.ps1
  # once done, script ends here
# ---------------------------------------------------------------------------------------------------------------------------
# else if that particular vm (using Windows Management Instrumentation) is part of a domain equals false (boolean) (CORRECT PATH)
} elseif ((gwmi win32_computersystem).partofdomain -eq $false) {

  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Current domain is set to 'workgroup'. Time to join the domain!"

  # if there is no path to bginfo.exe
  if (!(Test-Path 'c:\Program Files\sysinternals\bginfo.exe')) {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing bginfo..."
    # runs install-bginfo.ps1 in vagrant to install bginfo AND set wallpaper
    . c:\vagrant\scripts\install-bginfo.ps1
    # Set desktop background to be "fitted" instead of "tiled"
    Set-ItemProperty 'HKCU:\Control Panel\Desktop' -Name TileWallpaper -Value '0'
    Set-ItemProperty 'HKCU:\Control Panel\Desktop' -Name WallpaperStyle -Value '6'
    # Set Task Manager prefs (direct stderr to stdout) (not too sure why)
    reg import "c:\vagrant\resources\windows\TaskManager.reg" 2>&1 | out-null
  }

  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) My hostname is $env:COMPUTERNAME"
  # if computer name from the env variable matches 'dc' (case insensitive)
  if ($env:COMPUTERNAME -imatch 'dc') {
    # runs create-domain.ps1 script from vagrant
    . c:\vagrant\scripts\create-domain.ps1 192.168.56.102
  } else { # if computer name isnt 'dc'
    # runs join-domain.ps1 script from vagrant
    . c:\vagrant\scripts\join-domain.ps1
  }
# ---------------------------------------------------------------------------------------------------------------------------
# else; meaning that the vm has a domain
} else {
  Write-Host -fore green "$('[{0:HH:mm}]' -f (Get-Date)) I am domain joined!"
  # installs bginfo if there is no path
  if (!(Test-Path 'c:\Program Files\sysinternals\bginfo.exe')) {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing bginfo..."
    . c:\vagrant\scripts\install-bginfo.ps1
  }

  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Setting the registry for auto-login..."
  # sets autoadminlogon as 1 as a string (?)
  Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -Value 1 -Type String
  # sets default username for auto login
  Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value "vagrant"
  # sets default password for auto login
  Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -Value "vagrant"
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Provisioning after joining domain..."
}
