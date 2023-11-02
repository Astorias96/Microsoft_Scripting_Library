#### This Powershell script checks that only authorized user accounts have administrative rights on the target computer
### Written on 27-10-2023 by LemonTree - Last edited on 27-10-2023 by LemonTree
## Latest release comment - Initial release


## Variables
# User-defined variables - Basic settings
$builtin_administrators_group = "Administrators"                                                                                                                                                                                            # Defines the name of the built-in administrator group (Windows)
$console_text_introduction = "Win10 - Unauthorized local administrative accounts cleanup utility"                                                                                                                                           # Defines the console introduction message (for administrators)
$current_date = "date -f yyyy-MM-dd-HH:mm:ss"                                                                                                                                                                                               # Defines the date format to be used for the console output (for administrators)
$excludeAccounts = @("Administrator", "your-admin-user")                                                                                                                                                                                    # Array of accounts to exclude (local administrator and others)
#$log_filepath = "C:\Temp\Win10_Unauthorized_Local_Administrative_Accounts_Cleanup_Utility.log"                                                                                                                                             # Debugging - Defines the path to the logfile. Uncomment this line and both "Start/Stop-Transcript" lines to activate logging (lines 12, 64 and 144)

# System variables - Do not change
$adminUsers = @()                                                                                                                                                                                                                           # Defines an array to store admin user names


# Exit codes
$error_failed_to_remove_admin_rights = "2"                                                                                                                                                                                                  # The script ran into an error - The administrative rights could not be removed from the specified account.
$success = "0"                                                                                                                                                                                                                              # The script execution was successful.


## Functions
# Check if a user is a member of the $builtin_administrators_group group
function IsUserAdministrator($username) {
    $admins = net localgroup $builtin_administrators_group
    return $admins | Select-String -Pattern "^\s*$username$"
}

# Check if the user returned the correct input (Y, y, Yes, yes, N, n, No, no)
function Confirm-Input($user_input) {
    $user_input = $user_input.Trim()
    return ($user_input -eq "Y" -or $user_input -eq "y" -or $user_input -eq "Yes" -or $user_input -eq "yes" -or $user_input -eq "N" -or $user_input -eq "n" -or $user_input -eq "No" -or $user_input -eq "no")
}

# Retrieve the administrator users from the local 'Administrators' group
function Get-AdminUsers {
    # Get a list of all local user accounts
    $localUsers = Get-LocalUser | Where-Object { $excludeAccounts -notcontains $_.Name }
    # Loop through the user accounts and check if they are administrators
    $adminUsers = @()
    foreach ($user in $localUsers) {
        if (IsUserAdministrator($user.Name)) {
            $adminUsers += $user.Name
        }
    }
    
    return $adminUsers
}


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

# Retrieve initial admin user list
$adminUsers = Get-AdminUsers

# Output the accounts with administration rights
if ($adminUsers.Count -gt 0) {

    # Display the user accounts detected as administrators
    $adminUsers | ForEach-Object {
        Write-Host "An unauthorized user account with administration rights was detected:" -ForegroundColor Red
        $userName = $_
        Write-Host "`"$userName`""
        Write-Host ""
        Write-Host "Do you want to remove admin rights from the user account `"${userName}`" (Y/N)?" -ForegroundColor Yellow
        $response = Read-Host

        # Ask for input until it is correct
        while (-not (Confirm-Input $response)) {
            Write-Host -ForegroundColor Red "Invalid input. Please enter Y, y, Yes. yes, N, n, No or no." -ForegroundColor Red
            Write-Host ""
            $response = Read-Host
        }

        # The user decided to remove the administrative rights from the detected user account
        if ($response -eq "Y" -or $response -eq "y" -or $response -eq "Yes" -or $response -eq "yes") {
            Write-Host "`nRemoving admin rights from `"${userName}`"..."
            Write-Host ""
            net localgroup $builtin_administrators_group $userName /delete | Out-Null

            # Checking latest command result
            if ($?) {
                Write-Host "The administrative privileges for the user account `"${userName}`" were successfully removed." -ForegroundColor Green
                Write-Host ""
            }
                    
            # Exit with error code if failed
            else {
                Write-Host "Failed to remove the administrative privileges for the user account `"${userName}`". Press Enter to exit." -ForegroundColor Red; Read-Host
                Write-Host ""
                Exit $error_failed_to_remove_admin_rights
            }
        }

        # The user decided to keep the adminsitrative rights on the detected account
        elseif ($response -eq "N" -or $response -eq "n" -or $response -eq "No" -or $response -eq "no") {
            Write-Host "`nThe administrative privileges for the user account `"${userName}`" were not removed."
            Write-Host ""
        }
    }

}

# No unauthorized admin account was found
else {

    # Constructing message - Output excluded accounts to the user
    foreach ($account in $excludeAccounts) {
        $excludedAccountsMessage += "$account`n"
    }
    
    Write-Host "No users with administrative rights were found, excluding these accounts:" -ForegroundColor Green
    $excludeAccounts | ForEach-Object { Write-Host $_ }
    Write-Host ""
}

# Exit with success code
Write-Host "Exit.`n" -ForegroundColor Green
Remove-Variable -Name adminUsers -ErrorAction SilentlyContinue
Exit $success


## Debugging - Stop transcript recording - Uncomment to activate logging
#Stop-Transcript