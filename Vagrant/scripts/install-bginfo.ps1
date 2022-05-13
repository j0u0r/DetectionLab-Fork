# Installs BGInfo on the host for easy identification
# Source: https://github.com/StefanScherer/adfs2
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing BGInfo..."

# if the path c:\Program Files\sysinternals is not found
if (!(Test-Path 'c:\Program Files\sysinternals')) {
  # force adds new directory c:\Program Files\sysinternals, ignoring all errors
  New-Item -Path 'c:\Program Files\sysinternals' -type directory -Force -ErrorAction SilentlyContinue
}

# if the path c:\Program Files\sysinternals\bginfo.exe is not found
if (!(Test-Path 'c:\Program Files\sysinternals\bginfo.exe')) {
  # SysInternals requires TLS 1.2 (default in powershell is 1.0 for web requests)
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  # use a new object WebClient from system.Net to download bginfo.exe from website to respective path
  (New-Object Net.WebClient).DownloadFile('http://live.sysinternals.com/bginfo.exe', 'c:\Program Files\sysinternals\bginfo.exe')
}

# copies detectionlab background picture to respective path (NOT NEEDED)
Copy-Item "c:\vagrant\resources\windows\background.bmp" 'c:\Program Files\sysinternals\background.bmp'

# Microsoft Visual Basic Scripting Edition
# suspends script for 15 seconds (???), then runs powershell script from VBScript, which runs bginfo.exe, accepts t&c and runs bginfo.bgi silently
# THIS ISNT RUN YET
$vbsScript = @'
WScript.Sleep 15000
Dim objShell
Set objShell = WScript.CreateObject( "WScript.Shell" )
objShell.Run("""c:\Program Files\sysinternals\bginfo.exe"" /accepteula ""c:\Program Files\sysinternals\bginfo.bgi"" /silent /timer:0")
'@

# save the script to respective path
$vbsScript | Out-File 'c:\Program Files\sysinternals\bginfo.vbs'

# copies bginfo configuration from vagrant to respective file
Copy-Item "C:\vagrant\scripts\bginfo.bgi" 'c:\Program Files\sysinternals\bginfo.bgi'

# sets VBScript to run with Windows Script Host to HKEY that runs each time a user logs on with name bginfo and value to respective path
Set-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run -Name bginfo -Value 'wscript "c:\Program Files\sysinternals\bginfo.vbs"'
