#### This Powershell script disables the network proxy on the target computer for the current user (using the registry)
### Written on 27-10-2023 by Lemon Tree - Last edited on 02-11-2023 by Lemon Tree
## Latest release comment - Initial release


## Variables
# User-defined variables - Basic settings
$console_text_introduction = "Disable network proxy utility"                                                                                                                                                                                # Defines the console introduction message (for administrators)
$current_date = "date -f yyyy-MM-dd-HH:mm:ss"                                                                                                                                                                                               # Defines the date format to be used for the console output (for administrators)
#$log_filepath = "C:\Temp\NET_Disable_Network_Proxy_Utility.log"                                                                                                                                                                            # Debugging - Defines the path to the logfile. Uncomment this line and both "Start/Stop-Transcript" lines to activate logging (lines 11, 42 and 254)

# System variables - Do not change
$autoProxyRegName = "DefaultConnectionSettings"                                                                                                                                                                                             # Defines the name of the automatic proxy registry key
$autoProxyURLRegName = "AutoConfigURL"                                                                                                                                                                                                      # Defines the name of the automatic proxy URL registry key
$autoProxyURLRegValue = ""                                                                                                                                                                                                                  # Defines the value of the automatic proxy URL registry key                                                                                                                                                                                                              
$localUsername = (Get-CimInstance -ClassName Win32_ComputerSystem).Username                                                                                                                                                                 # Determines the currently logged-in username (DOMAIN\USERNAME)
$localUsernameSID = (New-Object System.Security.Principal.NTAccount($localUsername)).Translate([System.Security.Principal.SecurityIdentifier]).Value                                                                                        # Determines the currently logged-in username SID
$proxyRegName = "ProxyEnable"                                                                                                                                                                                                               # Defines the name of the proxy registry key
$proxyRegValue = "0"                                                                                                                                                                                                                        # Defines the value of the proxy registry key
$proxyURLRegName = "ProxyServer"                                                                                                                                                                                                            # Defines the name of the proxy URL registry key
$proxyURLRegValue = ""                                                                                                                                                                                                                      # Defines the value of the proxy URL registry key

# Exit codes
$error_registry_autoproxy = "3"                                                                                                                                                                                                             # The script ran into an error - The automatic network proxy could not be disabled.
$error_registry_proxy = "2"                                                                                                                                                                                                                 # The script ran into an error - The network proxy could not be disabled.
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


## Disable proxy using registry keys
# Proxy Enable/Disable
$proxyRegPath = "registry::HKEY_USERS\$localUsernameSID\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ProxyEnable"
$proxyRegPathDigest = "HKEY_USERS\$localUsernameSID\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ProxyEnable"

# Check if the registry key exists and create it if not found
if (-not (Test-Path $proxyRegPath)) {

    # Create the registry key if it doesn't exist
    New-Item -Path $proxyRegPath -Force;
    New-ItemProperty -Path $proxyRegPath -Name $proxyRegName -Value $proxyRegValue -PropertyType DWORD
    
    # Checking latest command result
    if ($?) {
        Write-Host "Added the registry key: $proxyRegPathDigest\$proxyRegName with value $proxyRegValue." -ForegroundColor Green
        Write-Host ""
    }
                    
    # Exit if fail
    else {
        Write-Host "Failed to add the registry key: $proxyRegPathDigest\$proxyRegName with value $proxyRegValue." -ForegroundColor Red
        Write-Host ""
        Write-Host "The script ran into an error. Press Enter to exit." -ForegroundColor Red; Read-Host
        Write-Host ""
        Exit $error_registry_proxy
    }
}

# Set the key value
else {
    # Set the registry value
    Set-ItemProperty -Path $proxyRegPath -Name $proxyRegName -Value $proxyRegValue -Type DWORD

    # Checking latest command result
    if ($?) {
    Write-Host "Added the registry key: $proxyRegPathDigest\$proxyRegName with value $proxyRegValue." -ForegroundColor Green
    Write-Host ""
    }
                    
    # Exit if fail
    else {
        Write-Host "Failed to add the registry key: $proxyRegPathDigest\$proxyRegName with value $proxyRegValue." -ForegroundColor Red
        Write-Host ""
        Write-Host "The script ran into an error. Press Enter to exit." -ForegroundColor Red; Read-Host
        Write-Host ""
        Exit $error_registry_proxy
    }
}

# Proxy URL
$proxyURLRegPath = "registry::HKEY_USERS\$localUsernameSID\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ProxyEnable"
$proxyURLRegPathDigest = "HKEY_USERS\$localUsernameSID\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ProxyEnable"

# Check if the registry key exists and create it if not found
if (-not (Test-Path $proxyRegPath)) {

    # Create the registry key if it doesn't exist
    New-Item -Path $proxyURLRegPath -Force;
    New-ItemProperty -Path $proxyURLRegPath -Name $proxyURLRegName -Value $proxyURLRegValue -PropertyType DWORD

    # Checking latest command result
    if ($?) {
        Write-Host "Added the registry key: $proxyURLRegPathDigest\$proxyURLRegName with value $proxyURLRegValue." -ForegroundColor Green
        Write-Host ""
    }
                    
    # Exit if fail
    else {
        Write-Host "Failed to add the registry key: $proxyURLRegPathDigest\$proxyURLRegName with value $proxyURLRegValue." -ForegroundColor Red
        Write-Host ""
        Write-Host "The script ran into an error. Press Enter to exit." -ForegroundColor Red; Read-Host
        Write-Host ""
        Exit $error_registry_proxy
    }
}

# Set the key value
else {
    # Set the registry value
    Set-ItemProperty -Path $proxyURLRegPath -Name $proxyURLRegName -Value $proxyURLRegValue -Type DWORD

    # Checking latest command result
    if ($?) {
    Write-Host "Added the registry key: $proxyURLRegPathDigest\$proxyURLRegName with value $proxyURLRegValue." -ForegroundColor Green
    Write-Host ""
    }
                    
    # Exit if fail
    else {
        Write-Host "Failed to add the registry key: $proxyURLRegPathDigest\$proxyURLRegName with value $proxyURLRegValue." -ForegroundColor Red
        Write-Host ""
        Write-Host "The script ran into an error. Press Enter to exit." -ForegroundColor Red; Read-Host
        Write-Host ""
        Exit $error_registry_proxy
    }
}

# Automatic Proxy Enable/Disable
$autoProxyRegPath = "registry::HKEY_USERS\$localUsernameSID\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections"
$autoProxyRegPathDigest = "HKEY_USERS\$localUsernameSID\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections"
$autoProxyRegValue = (Get-ItemProperty -Path $autoProxyRegPath -Name DefaultConnectionSettings).DefaultConnectionSettings
$autoProxyRegValue[8] = 1

# Check if the registry key exists and create it if not found
if (-not (Test-Path $autoProxyRegPath)) {

    # Create the registry key if it doesn't exist
    New-Item -Path $autoProxyRegPath -Force;
    New-ItemProperty -Path $autoProxyRegPath -Name $autoProxyRegName -Value $autoProxyRegValue -PropertyType Binary

    # Checking latest command result
    if ($?) {
        Write-Host "Added the registry key: $autoProxyRegPathDigest\$autoProxyRegName with value $autoProxyRegValue." -ForegroundColor Green
        Write-Host ""
    }
            
    # Exit if fail
    else {
        Write-Host "Failed to add the registry key: $autoProxyRegPathDigest\$autoProxyRegName with value $autoProxyRegValue." -ForegroundColor Red
        Write-Host ""
        Write-Host "The script ran into an error. Press Enter to exit." -ForegroundColor Red; Read-Host
        Write-Host ""
        Exit $error_registry_autoproxy
    }
}

# Set the key value
else {
    # Set the registry value
    Set-ItemProperty -Path $autoProxyRegPath -Name $autoProxyRegName -Value $autoProxyRegValue -Type Binary

    # Checking latest command result
    if ($?) {
        Write-Host "Added the registry key: $autoProxyRegPathDigest\$autoProxyRegName with value $autoProxyRegValue." -ForegroundColor Green
        Write-Host ""
    }
            
    # Exit if fail
    else {
        Write-Host "Failed to add the registry key: $autoProxyRegPathDigest\$autoProxyRegName with value $autoProxyRegValue." -ForegroundColor Red
        Write-Host ""
        Write-Host "The script ran into an error. Press Enter to exit." -ForegroundColor Red; Read-Host
        Write-Host ""
        Exit $error_registry_autoproxy
    }
}

# Automatic Proxy URL
$autoProxyURLRegPath = "registry::HKEY_USERS\$localUsernameSID\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ProxyEnable"
$autoProxyURLRegPathDigest = "HKEY_USERS\$localUsernameSID\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ProxyEnable"

# Check if the registry key exists and create it if not found
if (-not (Test-Path $autoProxyURLRegPath)) {

    # Create the registry key if it doesn't exist
    New-Item -Path $autoProxyURLRegPath -Force;
    New-ItemProperty -Path $autoProxyURLRegPath -Name $autoProxyURLRegName -Value $autoProxyURLRegValue -PropertyType DWORD

    # Checking latest command result
    if ($?) {
        Write-Host "Added the registry key: $autoProxyURLRegPathDigest\$autoProxyURLRegName with value $autoProxyURLRegValue." -ForegroundColor Green
        Write-Host ""
    }
            
    # Exit if fail
    else {
        Write-Host "Failed to add the registry key: $autoProxyURLRegPathDigest\$autoProxyURLRegName with value $autoProxyURLRegValue." -ForegroundColor Red
        Write-Host ""
        Write-Host "The script ran into an error. Press Enter to exit." -ForegroundColor Red; Read-Host
        Write-Host ""
        Exit $error_registry_autoproxy
    }
}

# Set the key value
else {
    # Set the registry value
    Set-ItemProperty -Path $autoProxyURLRegPath -Name $autoProxyURLRegName -Value $autoProxyURLRegValue -Type DWORD

    # Checking latest command result
    if ($?) {
        Write-Host "Added the registry key: $autoProxyURLRegPathDigest\$autoProxyURLRegName with value $autoProxyURLRegValue." -ForegroundColor Green
        Write-Host ""
    }
            
    # Exit if fail
    else {
        Write-Host "Failed to add the registry key: $autoProxyURLRegPathDigest\$autoProxyURLRegName with value $autoProxyURLRegValue." -ForegroundColor Red
        Write-Host ""
        Write-Host "The script ran into an error. Press Enter to exit." -ForegroundColor Red; Read-Host
        Write-Host ""
        Exit $error_registry_autoproxy
    }
}

# Exit with success code
Write-host "The script has finished running. Exit." -ForegroundColor Green
Write-Host ""
Exit $success


## Debugging - Stop transcript recording - Uncomment to activate logging
#Stop-Transcript