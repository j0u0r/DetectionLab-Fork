# Purpose: Re-arms the expiration timer on expiring Windows eval images and fixes activation issues

# Check to see if there are days left on the timer or if it's just expired
$regex = cscript c:\windows\system32\slmgr.vbs /dlv | select-string -Pattern "\((\d+) day\(s\)|grace time expired|0xC004D302|0xC004FC07"
If ($regex.Matches.Value -eq "grace time expired" -or $regex.Matches.Value -eq "0xC004D302") {
  # If it shows expired, it's likely it wasn't properly activated
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) It appears Windows was not properly activated. Attempting to resolve..."
  Try {
    # The TrustedInstaller service MUST be running for activation to succeed
    # change TrustedInstaller to Automatic start
    Set-Service TrustedInstaller -StartupType Automatic
    # start TrustedUnstaller
    Start-Service TrustedInstaller
    # suspends the script for 10 seconds
    Start-Sleep 10
    # Attempt to activate windows online
    cscript c:\windows\system32\slmgr.vbs /ato
  } Catch { # if there is an ERROR
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Something went wrong trying to reactivate Windows..."
  }
} 
# if there is an ERROR code
Elseif ($regex.Matches.Value -eq "0xC004FC07") {
  Try {
    # resets windows trial timer
    cscript c:\windows\system32\slmgr.vbs /rearm
  } Catch { # if there is an error
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Something went wrong trying to re-arm the image..."
  }
}

# If activation was successful, the regex should match 90 or 180 (Win10 or Win2016) (days)
$regex = cscript c:\windows\system32\slmgr.vbs /dlv | select-string -Pattern "\((\d+) day\(s\)"

Try {
  # get number of days left
  $days_left = $regex.Matches.Groups[1].Value
} Catch { # if there is an ERROR
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Unable to successfully parse the output from slmgr, not rearming"
  # set days_left variable to 90
  $days_left = 90
}
  
# the days remaining is less than 30 days
If ($days_left -as [int] -lt 30) {
  write-host "$('[{0:HH:mm}]' -f (Get-Date)) $days_left days remaining before expiration"
  write-host "$('[{0:HH:mm}]' -f (Get-Date)) Less than 30 days remaining before Windows expiration. Attempting to rearm..."
  # retry resetting the windows trial
  Try {
    # The TrustedInstaller service MUST be running for activation to succeed
    Set-Service TrustedInstaller -StartupType Automatic
    Start-Service TrustedInstaller
    Start-Sleep 10
    # Attempt to activate
    cscript c:\windows\system32\slmgr.vbs /ato
  } Catch { # ERROR
    Try { # try again
      cscript c:\windows\system32\slmgr.vbs /rearm
    } Catch { # give up if another error
      Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Something went wrong trying to re-arm the image..."
    }
  }
} 
Else { # not expiring soon
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) $days_left days left until expiration, no need to rearm."
}
