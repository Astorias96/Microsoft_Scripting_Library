#### This Powershell script compares two registry files and sends the output to a file (the path is specified in the user variables)
### Written on 02-11-2023 by Lemon Tree - Last edited on 02-11-2023 by Lemon Tree
## Latest release comment - Initial release


## Variables
# User-defined variables - Basic settings
$console_text_introduction = "Compare registry files utility"                                                                                                                                                                               # Defines the console introduction message (for administrators)
$current_date = "date -f yyyy-MM-dd-HH:mm:ss"                                                                                                                                                                                               # Defines the date format to be used for the console output (for administrators)
#$log_filepath = "C:\Temp\Win10_Compare_Registry_Files_Utility.log"                                                                                                                                                                         # Debugging - Defines the path to the logfile. Uncomment this line and both "Start/Stop-Transcript" lines to activate logging (lines 11, 33 and 114)
$reg1_before_change = ""                                                                                                                                                                                                                    # Defines the path to the exported registry files that will be compared against - BEFORE the change - The script will prompt you during execution if left empty
$reg2_after_change = ""                                                                                                                                                                                                                     # Defines the path to the exported registry files that will be compared against - AFTER the change - The script will prompt you during execution if left empty
$reg_logfile = "C:\Temp\Win10_Compare_Registry_Files_Utility_Result.txt"                                                                                                                                                                    # Defines the path to the result file (containing the registry differences that were found) - The script will prompt you during execution if left empty

# Exit codes
$error_compare_registry = "2"                                                                                                                                                                                                               # The script ran into an error - The registry comparaison went into an error.
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

## Verify that variables are set (and take necessary actions if they are not)
# Check if $reg_before was specified in the user variables
if ($reg_before) {
    Write-Host "The registry filepath variable (BEFORE change) is set in the user variables." -ForegroundColor Green
    Write-Host "The specified path is: $reg_before"
    Write-Host ""
}

# Prompting the user for the variable if not set
else {
    Write-Host "The registry filepath variable (BEFORE change) is not set in the user variables." -ForegroundColor Yellow
    Write-Host ""
    $reg_before = Read-Host "Enter the filepath to the registry file (BEFORE change)"
    Write-Host ""
}

# Check if $reg_after was specified in the user variables
if ($reg_after) {
    Write-Host "The registry file variable (AFTER change) is set in the user variables." -ForegroundColor Green
    Write-Host "The specified path is: $reg_after"
    Write-Host ""
}

# Prompting the user for the variable if not set
else {
    Write-Host "The registry file variable (AFTER change) is not set in the user variables." -ForegroundColor Yellow
    Write-Host ""
    $reg_after = Read-Host "Enter the filepath to the registry file (AFTER change)"
    Write-Host ""
}

# Check if $reg_logfile was specified in the user variables
if ($reg_after) {
    Write-Host "The result logfile is set in the user variables." -ForegroundColor Green
    Write-Host "The specified path is: $reg_logfile"
    Write-Host ""
}

# Prompting the user for the variable if not set
else {
    Write-Host "The result logfile is not set in the user variables." -ForegroundColor Yellow
    Write-Host ""
    $reg_after = Read-Host "Enter the filepath to the desired result logfile"
    Write-Host ""
}

## Compare the two registry files
Write-Host "All variables are set, starting comparison. This can take several minutes, please keep this window open." -ForegroundColor Yellow
Write-Host ""
Compare-Object $(Get-Content "$reg_before") $(Get-Content "$reg_after") >> "$reg_logfile"

# Checking latest command result
if ($?) {
    # Exit with success code
    Write-host "The script has finished running. The result logfile was saved here:" -ForegroundColor Green
    Write-Host "$reg_logfile"
    Write-Host "`nExit." -ForegroundColor Green
    Write-Host ""
    Exit $success
}

# Exit if fail
else {
    Write-host "The script ran into an error. Press Enter to exit." -ForegroundColor Red; Read-Host
    Write-Host ""
    Exit $error_compare_registry
}


## Debugging - Stop transcript recording - Uncomment to activate logging
#Stop-Transcript