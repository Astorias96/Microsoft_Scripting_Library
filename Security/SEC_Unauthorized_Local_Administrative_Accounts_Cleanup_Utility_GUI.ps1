#### This Powershell script checks that only authorized user accounts have administrative rights on the target computer
### Written on 27-10-2023 by LemonTree - Last edited on 27-10-2023 by LemonTree
## Latest release comment - Initial release


## Variables
# User-defined variables - Basic settings
$builtin_administrators_group = "Administrators"                                                                                                                                                                                            # Defines the name of the built-in administrator group (Windows)
$console_text_introduction = "Win10 - Unauthorized local administrative accounts cleanup utility"                                                                                                                                           # Defines the console introduction message (for administrators)
$current_date = "date -f yyyy-MM-dd-HH:mm:ss"                                                                                                                                                                                               # Defines the date format to be used for the console output (for administrators)
$excludeAccounts = @("Administrator", "your-admin-user")                                                                                                                                                                                    # Array of accounts to exclude (local administrator and others)
#$log_filepath = "C:\Temp\Win10_Unauthorized_Local_Administrative_Accounts_Cleanup_Utility.log"                                                                                                                                             # Debugging - Defines the path to the logfile. Uncomment this line and both "Start/Stop-Transcript" lines to activate logging (lines 12, 64, and 144)

# System variables - Do not change
$adminUsers = @() # Defines an array to store admin user names

# Exit codes
$error_failed_to_remove_admin_rights = "2"                                                                                                                                                                                                  # The script ran into an error - The administrative rights could not be removed from the specified account.
$error_user_cancelled = "3"                                                                                                                                                                                                                 # The script ran into an error - The user cancelled the dialog.
$success = "0"                                                                                                                                                                                                                              # The script execution was successful.


## Functions
# Check if a user is a member of the $builtin_administrators_group group
function IsUserAdministrator($username) {
    $admins = net localgroup $builtin_administrators_group
    return $admins | Select-String -Pattern "^\s*$username$"
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

# Load Windows Forms assemblies for the user dialog
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()


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
    $adminUsers | ForEach-Object {
        Write-Host "An unauthorized user account with administration rights was detected:" -ForegroundColor Red
        $userName = $_
        Write-Host "`"$userName`""
        Write-Host ""
        $userChoice = [System.Windows.Forms.MessageBox]::Show("An unauthorized user account with administration rights was detected. Do you want to remove admin rights from the user account `"$userName`"?", " Confirmation", [System.Windows.Forms.MessageBoxButtons]::YesNoCancel, [System.Windows.Forms.MessageBoxIcon]::Question)

        # The user decided to remove the administrative rights from the detected user account
        if ($userChoice -eq [System.Windows.Forms.DialogResult]::Yes) {
            Write-Host "Removing admin rights from `"$userName`"..."
            Write-Host ""
            net localgroup $builtin_administrators_group $userName /delete | Out-Null

            # Checking latest command result
            if ($?) {
                Write-Host "The administrative privileges for the user account `"$userName`" were successfully removed." -ForegroundColor Green
                Write-Host ""

                # Display a message box with an "OK" button
                [System.Windows.Forms.MessageBox]::Show("The administrative privileges for the user account `"$userName`" were successfully removed.", " Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null

            }
            
            # Exit with error code if failed
            else {
                Write-Host "Failed to remove the administrative privileges for the user account `"$userName`". Exit with error." -ForegroundColor Red
                Write-Host ""

                # Display an error message with an "OK" button
                [System.Windows.Forms.MessageBox]::Show("Failed to remove the administrative privileges for the user account `"$userName`".", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
                Exit $error_failed_to_remove_admin_rights
            }
        }
        
        elseif ($userChoice -eq [System.Windows.Forms.DialogResult]::No) {
            Write-Host "The administrative privileges for the user account `"$userName`" were not removed.`n"

            # Display an information message with an "OK" button
            [System.Windows.Forms.MessageBox]::Show("The administrative privileges for the user account `"$userName`" were not removed.", " Information", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
        }

        else {
            Write-Host "The user has cancelled the dialog. Exit with error." -ForegroundColor Red
            Write-Host ""

            # Display an error message with an "OK" button
            [System.Windows.Forms.MessageBox]::Show("The user has cancelled the dialog.", " Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
            Exit $error_user_cancelled
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

    # Constructing message - Output excluded accounts to the user
    $excludedAccountsMessage = "No users with administrative rights were found, excluding these accounts: "

    # Add excluded accounts to the message
    $excludedAccountsMessage += $("""" + ($excludeAccounts -join """, """) + """")

    # Display the list of excluded accounts in a message box with an "OK" button
    [System.Windows.Forms.MessageBox]::Show($excludedAccountsMessage, "Excluded Accounts", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
}

# Exit with success code
Write-Host "Exit.`n" -ForegroundColor Green

# Create an "Exit" message
$exitMessage = "The utility has finished running successfully."

# Display the "Exit" message in a message box with an "OK" button
[System.Windows.Forms.MessageBox]::Show($exitMessage, " Exit", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null

# Clear variables
Remove-Variable -Name adminUsers -ErrorAction SilentlyContinue

# Exit with success code
Exit $success


## Debugging - Stop transcript recording - Uncomment to activate logging
#Stop-Transcript
