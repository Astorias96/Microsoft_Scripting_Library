#### This Powershell script disables the automatic power settings (Disk, Hibernate, Monitor, Standby and Dynamic lock) on the target computer for the current user (using powercfg.exe and the registry)
### Written on 03-11-2023 by Lemon Tree - Last edited on 03-11-2023 by Lemon Tree
## Latest release comment - Initial release


## Variables
# User-defined variables - Basic settings
$console_text_introduction = "Disable automatic power settings utility"                                                                                                                                                                     # Defines the console introduction message (for administrators)
$current_date = "date -f yyyy-MM-dd-HH:mm:ss"                                                                                                                                                                                               # Defines the date format to be used for the console output (for administrators)
#$log_filepath = "C:\Temp\Win10_Disable_Automatic_Power_Settings_Utility.log"                                                                                                                                                               # Debugging - Defines the path to the logfile. Uncomment this line and both "Start/Stop-Transcript" lines to activate logging (lines 11, 45 and 138)

# System variables - Do not change
$computer_disk_timeout_ac = "0"                                                                                                                                                                                                             # Defines the disk timeout when the computer is plugged-in (in minutes)
$computer_disk_timeout_dc = "0"                                                                                                                                                                                                             # Defines the disk timeout when the computer is on battery power (in minutes)
$computer_hibernate_timeout_ac = "0"                                                                                                                                                                                                        # Defines the hibernate timeout when the computer is plugged-in (in minutes)
$computer_hibernate_timeout_dc = "0"                                                                                                                                                                                                        # Defines the hibernate timeout when the computer is on battery power (in minutes)
$computer_monitor_timeout_ac = "0"                                                                                                                                                                                                          # Defines the display timeout when the computer is plugged-in (in minutes)
$computer_monitor_timeout_dc = "0"                                                                                                                                                                                                          # Defines the display timeout when the computer is on battery power (in minutes)
$computer_standby_timeout_ac = "0"                                                                                                                                                                                                          # Defines the sleep timeout when the computer is plugged-in (in minutes)
$computer_standby_timeout_dc = "0"                                                                                                                                                                                                          # Defines the sleep timeout when the computer is on battery power (in minutes)
$dynamicLockRegName = "EnableGoodbye"                                                                                                                                                                                                       # Defines the name of the dynamic lock registry key
$dynamicLockRegValue = "0"                                                                                                                                                                                                                  # Defines the value of the dynamic lock registry key
$localUsername = (Get-CimInstance -ClassName Win32_ComputerSystem).Username                                                                                                                                                                 # Determines the currently logged-in username (DOMAIN\USERNAME)
$localUsernameSID = (New-Object System.Security.Principal.NTAccount($localUsername)).Translate([System.Security.Principal.SecurityIdentifier]).Value                                                                                        # Determines the currently logged-in username SID

# Exit codes
$error_configure_power_settings = "2"                                                                                                                                                                                                       # The script ran into an error - The power settings failed to configure for the current user.
$error_registry_dynamic_lock = "3"                                                                                                                                                                                                          # The script ran into an error - The Windows dynamic lock registry failed to apply.
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


## Configure timeout for automatic disk, hibernate, monitor and standby
# Configure disk timeout (in minutes)
powercfg.exe -x -disk-timeout-ac "$computer_disk_timeout_ac";
powercfg.exe -x -disk-timeout-dc "$computer_disk_timeout_dc";

# Configure hibernate timeout (in minutes)
powercfg.exe -x -hibernate-timeout-ac "$computer_hibernate_timeout_ac";
powercfg.exe -x -hibernate-timeout-dc "$computer_hibernate_timeout_dc";

# Configure monitor timeout (in minutes)
powercfg.exe -x -monitor-timeout-ac "$computer_monitor_timeout_ac";
powercfg.exe -x -monitor-timeout-dc "$computer_monitor_timeout_dc";

# Configure standby timeout (in minutes)
powercfg.exe -x -standby-timeout-ac "$computer_standby_timeout_ac";
powercfg.exe -x -standby-timeout-dc "$computer_standby_timeout_dc"

# Checking latest command block result
if ($?) {
    Write-Host ""
    Write-Host "All power settings were successfully configured." -ForegroundColor Green
    Write-Host ""
}

# Exit if fail
else {
    Write-Host ""
    Write-Host "Failed to configure the power settings for the current user. Press Enter to exit." -ForegroundColor Red; Read-Host
    Write-Host ""
    Exit $error_configure_power_settings
}


## Disable Dynamic lock using a registry key
# Check if the registry hive/key exists and create it if not found
$dynamicLockRegPath = "registry::HKEY_USERS\$localUsernameSID\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
$dynamicLockRegPathDigest = "HKEY_USERS\$localUsernameSID\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
if (-not (Test-Path $dynamicLockRegPath)) {

    # Create the registry key if it doesn't exist
    New-Item -Path $dynamicLockRegPath -Force

    # Checking latest command result
    if ($?) {
        Write-Host "Added the registry key: $dynamicLockRegPathDigest\$dynamicLockRegName with value $dynamicLockRegValue." -ForegroundColor Green
        Write-Host ""
    }
                
    # Exit if fail
    else {
        Write-Host "Failed to add the registry key: $dynamicLockRegPathDigest\$dynamicLockRegName with value $dynamicLockRegValue." -ForegroundColor Red
        Write-Host ""
        Write-Host "The script ran into an error. Press Enter to exit." -ForegroundColor Red; Read-Host
        Write-Host ""
        Exit $error_registry_dynamic_lock
    }
}

# Set the registry value
Set-ItemProperty -Path $dynamicLockRegPath -Name $dynamicLockRegName -Value $dynamicLockRegValue -Type DWORD

# Checking latest command result
if ($?) {
    Write-Host "Added the registry key: $dynamicLockRegPathDigest\$dynamicLockRegName with value $dynamicLockRegValue." -ForegroundColor Green
    Write-Host ""
}
            
# Exit if fail
else {
    Write-Host "Failed to add the registry key: $dynamicLockRegPathDigest\$dynamicLockRegName with value $dynamicLockRegValue." -ForegroundColor Red
    Write-Host ""
    Write-Host "The script ran into an error. Press Enter to exit." -ForegroundColor Red; Read-Host
    Write-Host ""
    Exit $error_registry_dynamic_lock
}

# Exit with success code
Write-host "The script has finished running. Exit." -ForegroundColor Green
Write-Host ""
Exit $success


## Debugging - Stop transcript recording - Uncomment to activate logging
#Stop-Transcript
