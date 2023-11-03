#### This Powershell script disables all bluetooth interfaces on the target computer
### Written on 27-10-2023 by Lemon Tree - Last edited on 02-11-2023 by Lemon Tree
## Latest release comment - Initial release


## Variables
# User-defined variables - Basic settings
$console_text_introduction = "Disable Bluetooth interfaces utility"                                                                                                                                                                         # Defines the console introduction message (for administrators)
$current_date = "date -f yyyy-MM-dd-HH:mm:ss"                                                                                                                                                                                               # Defines the date format to be used for the console output (for administrators)
#$log_filepath = "C:\Temp\NET_Disable_Bluetooth_Interfaces_Utility.log"                                                                                                                                                                     # Debugging - Defines the path to the logfile. Uncomment this line and both "Start/Stop-Transcript" lines to activate logging (lines 11, 33 and 90)

# System variables - Do not change
$bluetoothDevices = Get-WmiObject -Class Win32_NetworkAdapter | Where-Object {$_.Name -like "*Bluetooth*"}                                                                                                                                  # List all Bluetooth devices

# Exit codes
$error_disable_bluetooth_failed = "2"                                                                                                                                                                                                       # The script ran into an error - Disabling the Bluetooth card failed.
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


## Disable Bluetooth devices on target computer
# Verify that this computer has a bluetooth device
if ($bluetoothDevices -eq $null) {
    Write-Host "No Bluetooth device was found on this computer. Continue.." -ForegroundColor Green
    Write-Host ""
}

# Disable each Bluetooth device
foreach ($device in $bluetoothDevices) {
    $deviceName = $device.Name
    $deviceStatus = $device.Status

    # Check if the device is currently enabled
    if ($deviceStatus -eq "OK") {
        Write-Host "Disabling Bluetooth Device: $deviceName."
        $device.Disable()
        
        # Checking latest command result
        if ($?) {
            Write-Host "Disabled Bluetooth Device: $deviceName." -ForegroundColor Green
            Write-Host ""
        }

        # Exit if fail
        else {
            Write-Host "Failed to disable Bluetooth Device: $deviceName." -ForegroundColor Red
            Write-Host ""
            Write-Host "The script ran into an error. Press Enter to exit." -ForegroundColor Red; Read-Host
            Write-Host ""
            Exit $error_disable_bluetooth_failed
        }      
    }
    
    # Communicate that Bluetooth device is already disabled
    else {
        Write-Host "Bluetooth Device '$deviceName' is already disabled." -ForegroundColor Green
        Write-Host ""
    }
}

# Exit with success code
Write-host "The script has finished running. Exit." -ForegroundColor Green
Write-Host ""
Exit $success


## Debugging - Stop transcript recording - Uncomment to activate logging
#Stop-Transcript