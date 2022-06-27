# Purpose: Sets up the Server and Workstations OUs

# Hardcoding DC hostname in hosts file to sidestep any DNS issues
Add-Content "c:\windows\system32\drivers\etc\hosts" "        192.168.56.102    dc.windomain.local"

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Creating Server and Workstation OUs..."
# Create the Servers OU if it doesn't exist
$servers_ou_created = 0
# if servers ou created variable does not equal to 1
while ($servers_ou_created -ne 1) {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Creating Server OU..."
  try {
    # get the OU using distinguished OU name
    Get-ADOrganizationalUnit -Identity 'OU=Servers,DC=windomain,DC=local' | Out-Null
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Servers OU already exists. Moving On."
    # change servers ou created variable to 1
    $servers_ou_created = 1
  }
  # if there is an ERROR that the OU cannot be found
  catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
    # create the OU with the name and the server
    New-ADOrganizationalUnit -Name "Servers" -Server "dc.windomain.local"
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Created Servers OU."
    # change the servers ou created variable to 1
    $servers_ou_created = 1
  }
  # if there is an ERROR that the AD server cannot be found
  catch [Microsoft.ActiveDirectory.Management.ADServerDownException] {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Unable to reach Active Directory. Sleeping for 5 and trying again..."
    # pause for 5 seconds
    Start-Sleep 5
  }
  # if there is an unknown error
  catch {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Something went wrong attempting to reach AD or create the OU."
  }
}

# same thing as above -----------------------------------------------------------------------------------------------------------------------------
# Create the Workstations OU if it doesn't exist
$workstations_ou_created = 0
while ($workstations_ou_created -ne 1) {
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Creating Workstations OU..."
  try {
    Get-ADOrganizationalUnit -Identity 'OU=Workstations,DC=windomain,DC=local' | Out-Null
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Workstations OU already exists. Moving On."
    $workstations_ou_created = 1
  }
  catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
    New-ADOrganizationalUnit -Name "Workstations" -Server "dc.windomain.local"
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Created Workstations OU."
    $workstations_ou_created = 1
  }
  catch [Microsoft.ActiveDirectory.Management.ADServerDownException] {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Unable to reach Active Directory. Sleeping for 5 and trying again..."
    Start-Sleep 5
  }
  catch {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Something went wrong attempting to reach AD or create the OU."
  }
}
# ------------------------------------------------------------------------------------------------------------------------------------------------