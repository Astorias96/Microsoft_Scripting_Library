#### This Powershell script disables all LAN interfaces on the target computer
### Written on 27-10-2023 by Lemon Tree - Last edited on 02-11-2023 by Lemon Tree
## Latest release comment - Initial release


## Variables
# User-defined variables - Basic settings
$console_text_introduction = "Disable LAN interfaces utility"                                                                                                                                                                               # Defines the console introduction message (for administrators)
$current_date = "date -f yyyy-MM-dd-HH:mm:ss"                                                                                                                                                                                               # Defines the date format to be used for the console output (for administrators)
#$log_filepath = "C:\Temp\NET_Disable_LAN_Interfaces_Utility.log"                                                                                                                                                                           # Debugging - Defines the path to the logfile. Uncomment this line and both "Start/Stop-Transcript" lines to activate logging (lines 11, 33 and 97)

# System variables - Do not change
$lanDevices = Get-WmiObject -Class Win32_NetworkAdapter | Where-Object {($_.AdapterType -like "*Ethernet*" -or $_.Name -like "*LAN*") -and (-not ($_.Name -like "*Wi-Fi*" -or $_.Name -like "*WAN*" -or $_.Name -like "*Wireless*"))}       # List all LAN (Ethernet) devices

# Exit codes
$error_disable_lan_failed = "2"                                                                                                                                                                                                             # The script ran into an error - Disabling the LAN card(s) failed.
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


## Disable LAN interfaces
# Verify that this computer has a LAN device
if ($lanDevices -eq $null) {
    Write-Host "No LAN device was found on this computer. Continue.." -ForegroundColor Green
}

# Disable each LAN device
foreach ($device in $lanDevices) {
    $deviceName = $device.Name

    # Disable LAN network card
    Write-Host "Disabling LAN Device: $deviceName."
    Disable-NetAdapter -Name $deviceName -Confirm:$false;

    # Checking latest command result
    if ($?) {
        Write-Host "`nDisabled LAN Device: $deviceName." -ForegroundColor Green
        Write-Host ""
    }
        
    # Retry with standard name if fail
    else {
        # Retry disabling LAN network card
        Write-Host "Failed to disable LAN Device: $deviceName." -ForegroundColor Red
        Write-Host ""
        Write-Host "Retrying to disable LAN Device using name: Ethernet."
        Write-Host ""
        Write-Host "Disabling LAN Device: Ethernet."
        Disable-NetAdapter -Name "Ethernet" -Confirm:$false | Out-Null

        # Checking latest command result
        if ($?) {
            Write-Host "`nDisabled LAN Device: Ethernet." -ForegroundColor Green
            Write-Host "" 
        }

        # Exit if fail
        else {
            Write-Host "Failed to disable LAN Device: Ethernet." -ForegroundColor Red
            Write-Host ""
            Write-Host "The script ran into an error. Press Enter to exit." -ForegroundColor Red; Read-Host
            Write-Host ""
            Exit $error_disable_lan_failed
        }
    }  
}

# Exit with success code
Write-host "The script has finished running. Exit." -ForegroundColor Green
Write-Host ""
Exit $success


## Debugging - Stop transcript recording - Uncomment to activate logging
#Stop-Transcript