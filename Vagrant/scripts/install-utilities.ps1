# Purpose: Installs chocolatey package manager, then installs custom utilities from Choco.

# if there is no existing test path C:\ProgramData\chocolatey
If (-not (Test-Path "C:\ProgramData\chocolatey")) {
  # set security protocol type to tls12
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing Chocolatey"
  # download chocolatey install contents from the website, runs the install as a string
  Invoke-Expression ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
} else {
  # chocolatey is already installed
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Chocolatey is already installed."
}

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing utilities..."

# downloads custom windows 7 start menu in windows 10----- NOT NEEDED -------------------------------------------
If ($(hostname) -eq "win10") {
  # Because the Windows10 start menu sucks
  choco install -y --limit-output --no-progress classic-shell -installArgs ADDLOCAL=ClassicStartMenu
  & "C:\Program Files\Classic Shell\ClassicStartMenu.exe" "-xml" "c:\vagrant\resources\windows\MenuSettings.xml"
  regedit /s c:\vagrant\resources\windows\MenuStyle_Default_Win7.reg
}
# ---------------------------------------------------------------------------------------------------------------

# downloads processhacker (better task manager)------------- NOT VERY USEFUL ------------------------------------
choco install -y --limit-output --no-progress NotepadPlusPlus WinRar processhacker
# ---------------------------------------------------------------------------------------------------------------

# downloads google chrome----------------------------- QUITE USEFUL ---------------------------------------------
# This repo often causes failures due to incorrect checksums, so we ignore them for Chrome
choco install -y --limit-output --no-progress --ignore-checksums GoogleChrome 
# ---------------------------------------------------------------------------------------------------------------

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Utilties installation complete!"
