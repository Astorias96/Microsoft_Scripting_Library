#### This Powershell script forgets all Wi-Fi networks on the target computer (except networks stored in the $ssid variable)
### Written on 27-10-2023 by Lemon Tree - Last edited on 02-11-2023 by Lemon Tree
## Latest release comment - Initial release


## Variables
# User-defined variables - Basic settings
$console_text_introduction = "Forget Wi-Fi network(s) utility"                                                                                                                                                                              # Defines the console introduction message (for administrators)
$current_date = "date -f yyyy-MM-dd-HH:mm:ss"                                                                                                                                                                                               # Defines the date format to be used for the console output (for administrators)
#$log_filepath = "C:\Temp\NET_Forget_WiFi_Networks_Utility.log"                                                                                                                                                                             # Debugging - Defines the path to the logfile. Uncomment this line and both "Start/Stop-Transcript" lines to activate logging (lines 11, 33 and 87)

# System variables - Do not change
$ssid = "Your-SSID"                                                                                                                                                                                                                         # Replace with your desired SSID - This $ssid profile will not be forgotten after this script has ran

# Exit codes
$error_configure_wifi_failed = "2"                                                                                                                                                                                                          # The script ran into an error - The Wi-Fi could not be configured with the provided parameters.
$success = "0"                                                                                                                                                                                                                              # The script execution was successful.


## Starting operations
# Check if the script is running as an administrator
$isAdmin = ([System.Security.Principal.WindowsIdentity]::GetCurrent()).Groups -match "S-1-5-32-544"

# If not running as administrator, restart with Run as Administrator
if (-not $isAdmin) {
    Start-Process -FilePath "powershell" -ArgumentList " -NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}


## Debugging - Start transcript recording - Uncomment to activate logging
#Start-Transcript -Path $log_filepath -Append


# Sending date & time to console
Write-Host "$console_text_introduction" -ForegroundColor Cyan
Write-Host "The script has started, the timestamp is:"
Invoke-Expression $current_date
Write-Host ""


## Forget any other Wifi network
# Get all the wireless network profiles
$networkProfiles = netsh wlan show profiles | Select-String "Profile\s+:\s+(\S+)" | ForEach-Object { $_.Matches.Groups[1].Value }

# Loop through the network profiles
foreach ($profile in $networkProfiles) {
    if ($profile -ne $ssid) {
        # Disable "automatically connect when in range" for the network
        netsh wlan set profileparameter name="$profile" connectionmode=manual
        Write-Host "Disabled automatic connection for network: $profile." -ForegroundColor Green
        Write-Host ""

        # Forget the network profile
        netsh wlan delete profile name="$profile"
        Write-Host "Forgot network: $profile." -ForegroundColor Green
        Write-Host ""
    }
}

# Checking latest command result
if ($?) {
    Write-Host "Done forgetting networks and disabling automatic connection." -ForegroundColor Green
    Write-Host ""
}

# Exit if fail
else {
    Write-Host ""
    Write-Host "Failed to forget networks and disable automatic connection." -ForegroundColor Red
    Write-Host ""

    # Exit with error
    Write-Host "The script ran into an error. Press Enter to exit." -ForegroundColor Red; Read-Host
    Write-Host ""
    Exit $error_configure_wifi_failed
}

# Exit with success code
Write-host "The script has finished running. Exit." -ForegroundColor Green
Write-Host ""
Exit $success


## Debugging - Stop transcript recording - Uncomment to activate logging
#Stop-Transcript