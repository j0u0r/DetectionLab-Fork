# this is FALSE lol
# Purpose: Install the GPO that disables Windows Defender and AMSI
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Importing the GPO to set the Taskbar layout..."
# imports GPO with backup name, path, target name and if create the GPO if needed
# this is an imported GPO that has been created beforehand with presumably the same environment configurations
Import-GPO -BackupGpoName 'Taskbar Layout' -Path "c:\vagrant\resources\GPO\taskbar_layout" -TargetName 'Taskbar Layout' -CreateIfNeeded

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Copying layout file to SYSVOL..."
# copies layout file to specified path
Copy-Item "c:\vagrant\resources\GPO\taskbar_layout\DetectionLabLayout.xml" "c:\Windows\SYSVOL\domain\scripts\DetectionLabLayout.xml"

# configuring GPO -------------------------------------------------------------------------------------------------
# specified OU (what if you want to make it a domain instead...)
$OU = "ou=Domain Controllers,dc=windomain,dc=local"
# specify gPLinks variable into null
$gPLinks = $null
# get the specified OU's information (name, distinguished name, gp links, gp options)
$gPLinks = Get-ADOrganizationalUnit -Identity $OU -Properties name, distinguishedName, gPLink, gPOptions
# get gpo with the name 'taskbar layout'
$GPO = Get-GPO -Name 'Taskbar Layout'
# if the linked gpos in the OU does not contain the path of the GPO 'taskbar layout'
If ($gPLinks.LinkedGroupPolicyObjects -notcontains $gpo.path) {
    # create a new gp link targeting the OU with enforced enabled
    New-GPLink -Name 'Taskbar Layout' -Target $OU -Enforced yes
# if the linked gpos in the OU  contains the path of the GPO 'taskbar layout'
} Else {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Taskbar Layout GPO was already linked at $OU. Moving On."
}
# ----------------------------------------------------------------------------------------------------------------

# try again 1 more time to ensure that the GPO is properly configured---------------------------------------------
$OU = "ou=Workstations,dc=windomain,dc=local"
$gPLinks = $null
$gPLinks = Get-ADOrganizationalUnit -Identity $OU -Properties name, distinguishedName, gPLink, gPOptions
$GPO = Get-GPO -Name 'Taskbar Layout'
If ($gPLinks.LinkedGroupPolicyObjects -notcontains $gpo.path) {
    New-GPLink -Name 'Taskbar Layout' -Target $OU -Enforced yes
} Else {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Taskbar Layout GPO was already linked at $OU. Moving On."
}

$OU = "ou=Servers,dc=windomain,dc=local"
$gPLinks = $null
$gPLinks = Get-ADOrganizationalUnit -Identity $OU -Properties name, distinguishedName, gPLink, gPOptions
$GPO = Get-GPO -Name 'Taskbar Layout'
If ($gPLinks.LinkedGroupPolicyObjects -notcontains $gpo.path) {
    New-GPLink -Name 'Taskbar Layout' -Target $OU -Enforced yes
} Else {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Taskbar Layout GPO was already linked at $OU. Moving On."
}
# --------------------------------------------------------------------------------------------------------------

# force refresh GP
gpupdate /force
