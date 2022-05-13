# Source: https://github.com/StefanScherer/adfs2
param ([String] $ip, [String] $dns, [String] $gateway)
# print info
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Running fix-second-network.ps1..."
# if network adapter contains Red Hat VirtIO (virtual ethernet card)
if ( (Get-NetAdapter | Select-Object -First 1 | Select-Object -ExpandProperty InterfaceDescription).Contains('Red Hat VirtIO')) {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Setting Network Configuration for LibVirt interface"
  # get first 3 octets from ip address
  $subnet = $ip -replace "\.\d+$", ""
  # getting ipv4 address
  $name = (Get-NetIPAddress -AddressFamily IPv4 `
     | Where-Object -FilterScript { ($_.IPAddress).StartsWith("$subnet") } ` # finds ip addr with first 3 octets of ip addr
     ).InterfaceAlias # gets the name for the internet adapter/interface
  # if name variable is not empty
  if ($name) {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Set IP address to $ip of interface $name"
    # exectues network shell to assign static ip, subnet and gateway for specific internet adapter/interface
    & netsh.exe int ip set address "$name" static $ip 255.255.255.0 "$gateway"
    # if dns variable is not empty
    if ($dns) {
      Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Set DNS server address to $dns of interface $name"
      # set 1st preferred dns server for specific internet adapter/interface
      & netsh.exe interface ipv4 add dnsserver "$name" address=$dns index=1
    }
  # if name variable is empty (ERROR)
  } else {
    Write-Error "Could not find a interface with subnet $subnet.xx"
  }
  # exit with success code
  exit 0
# if network adapter does not contain Red Hat VirtIO (ERROR)
} Else {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) No VirtIO adapters, moving on..."
}

# if there is no vmware tools
if (! (Test-Path 'C:\Program Files\VMware\VMware Tools') ) {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) VMware Tools not found, no need to continue. Exiting."
  # exit with success code
  exit 0
}

Write-Host "$('[{0:HH:mm}]' -f (Get-Date))"
Write-Host "Setting IP address and DNS information for the Ethernet1 interface"
Write-Host "If this step times out, it's because vagrant is connecting to the VM on the wrong interface"
Write-Host "See https://github.com/clong/DetectionLab/issues/114 for more information"
# get first 3 octets from ip address
$subnet = $ip -replace "\.\d+$", ""
# getting ipv4 address
$name = (Get-NetIPAddress -AddressFamily IPv4 `
   | Where-Object -FilterScript { ($_.IPAddress).StartsWith($subnet) } ` # finds ip addr with first 3 octets of ip addr
   ).InterfaceAlias # gets the name for internet adapter/interface
  #  if there is no name for the internet adapter/interface
   if (!$name) {
  # retry getting the name for the internet adapter/interface
  $name = (Get-NetIPAddress -AddressFamily IPv4 `
     | Where-Object -FilterScript { ($_.IPAddress).StartsWith("169.254.") } `
     ).InterfaceAlias
}
# if there is a name for the internet adapter/interface
if ($name) {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Set IP address to $ip of interface $name"
  # executes network shell to assign static ip and gateway to specific internet adapter/interface
  & netsh.exe int ip set address "$name" static $ip 255.255.255.0 "$subnet.1"
  # if there is something in dns variable
  if ($dns) {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Set DNS server address to $dns of interface $name"
    # executes network shell to assign dns to specific internet adapter/interface
    & netsh.exe interface ipv4 add dnsserver "$name" address=$dns index=1
  }
# if there is no name for the internet adapter/interface (ERROR)
} else {
  Write-Error "$('[{0:HH:mm}]' -f (Get-Date)) Could not find a interface with subnet $subnet.xx"
}
