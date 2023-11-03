#### This Powershell script configures the specified Wi-Fi network on the target computer (using a netsh profile)
### Written on 27-10-2023 by Lemon Tree - Last edited on 02-11-2023 by Lemon Tree
## Latest release comment - Initial release


## Variables
# User-defined variables - Basic settings
$console_text_introduction = "Configure Wi-Fi WPA2PSK network utility"                                                                                                                                                                      # Defines the console introduction message (for administrators)
$current_date = "date -f yyyy-MM-dd-HH:mm:ss"                                                                                                                                                                                               # Defines the date format to be used for the console output (for administrators)
#$log_filepath = "C:\Temp\NET_Configure_WiFi_WPA2PSK_Network_Utility.log"                                                                                                                                                                   # Debugging - Defines the path to the logfile. Uncomment this line and both "Start/Stop-Transcript" lines to activate logging (lines 11, 36 and 210)

# System variables - Do not change
$ssid = ""                                                                                                                                                                                                                                  # Replace with your desired SSID - The script will prompt you during execution if left empty
$wifiDevice = Get-WmiObject -Class Win32_NetworkAdapter | Where-Object {($_.Name -like "*Wi-Fi*" -or $_.Name -like "*Wireless*") -and (-not ($_.Name -like "*Wi-Fi Direct*"))}                                                              # List Wi-Fi device
$wifiDeviceName = $wifiDevice.Name                                                                                                                                                                                                          # List Wi-Fi card name
$wifiDeviceStatus = $wifiDevice.Status                                                                                                                                                                                                      # List Wi-Fi card status (on/off)

# Exit codes
$error_configure_wifi_failed = "2"                                                                                                                                                                                                          # The script ran into an error - The Wi-Fi could not be configured with the provided parameters.
$error_no_wifi_device_found = "3"                                                                                                                                                                                                           # The script ran into an error - No wireless adapter was found on this computer.
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


## Configure the specified Wifi network
# Verify that this computer has a WI-Fi device
if ($wifiDevice -eq $null) {
    Write-Host "No Wi-Fi device was found on this computer." -ForegroundColor Red
    Write-Host ""
    Write-Host "The script ran into an error. Press Enter to exit." -ForegroundColor Red; Read-Host
    Write-Host ""
    Exit $error_no_wifi_device_found
}

# Enable the Wi-Fi card
if ($wifiDeviceStatus -ne "OK") {
    Write-Host "Enabling Wi-Fi Device: $wifiDeviceName."
    $wifiDevice.Enable()

    # Checking latest command result
    if ($?) {
        Write-Host "Enabled Wi-Fi Device: $wifiDeviceName. Continue.." -ForegroundColor Green
        Write-Host ""
    }
        
    # Exit if fail
    else {
        Write-Host "Failed to enable Wi-Fi Device: $wifiDeviceName." -ForegroundColor Red
        Write-Host ""
        Write-Host "The script ran into an error. Press Enter to exit." -ForegroundColor Red; Read-Host
        Write-Host ""
        Exit $error_enable_wifi_failed
    }
}

# Communicate that Wi-Fi device is already enabled
else {
    Write-Host "Wi-Fi Device '$wifiDeviceName' is already enabled." -ForegroundColor Green
    Write-Host ""
}


## Configure the Wi-Fi SSID and set the WPA2 key
# Check if àssid was specified in the user variables
if ($ssid) {
    Write-Host "The SSID is set in the user variables. The wireless network $ssid will be configured on this computer." -ForegroundColor Green
    Write-Host ""
}

# Prompting the user for $wp2key if not set
else {
    Write-Host "The SSID is not set in the user variables." -ForegroundColor Yellow
    Write-Host ""
    $ssid = Read-Host "Enter the desired network name (SSID)"
    Write-Host ""
}

# Prompting the user for $wp2key
$wpa2Key = Read-Host "Enter the network key for $ssid" -AsSecureString

# Run the netsh wlan show interface command and capture the output
$wifiInterfaceInfo = netsh wlan show interface

# Split the output into lines and search for the "Name" field
$lines = $wifiInterfaceInfo -split "`r`n"
$wifiDeviceInterface = $lines | Where-Object { $_ -match "Name\s*:\s*(.+)"} | ForEach-Object { $matches[1].Trim() }
Write-Host ""

if ($wifiDeviceInterface) {
    Write-Host "The wireless interface name is: $wifiDeviceInterface" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "Could not extract wireless interface name from the output." -ForegroundColor Red
    Write-Host ""
    Write-Host "The script ran into an error. Press Enter to exit." -ForegroundColor Red; Read-Host
    Write-Host ""
    Exit $error_configure_wifi_failed
}

Write-Host "Configuring Wi-Fi SSID: $ssid."
Write-Host ""

# Convert the WPA2 Key SecureString to plain text (temporary variable)
#$wpa2KeyPlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($wpa2Key))
$wpa2KeyBytes = [System.Runtime.InteropServices.Marshal]::SecureStringToGlobalAllocUnicode($wpa2Key)
$wpa2KeyPlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($wpa2KeyBytes)
[System.Runtime.InteropServices.Marshal]::ZeroFreeGlobalAllocUnicode($wpa2KeyBytes)

# Convert the $ssid to hex for use in $ssid_hex (XML profile)
$ssid_hex = [System.BitConverter]::ToString([System.Text.Encoding]::ASCII.GetBytes($ssid)).Replace("-", "")

# Generate a temporary XML profile file
$xmlProfile = @"
<?xml version="1.0"?>
<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
    <name>$ssid</name>
    <SSIDConfig>
        <SSID>
			<hex>$ssid_hex</hex>
            <name>$ssid</name>
        </SSID>
		<nonBroadcast>true</nonBroadcast>
    </SSIDConfig>
    <connectionType>ESS</connectionType>
    <connectionMode>auto</connectionMode>
    <autoSwitch>true</autoSwitch>
    <MSM>
        <security>
            <authEncryption>
                <authentication>WPA2PSK</authentication>
                <encryption>AES</encryption>
                <useOneX>false</useOneX>
            </authEncryption>
            <sharedKey>
                <keyType>passPhrase</keyType>
                <protected>false</protected>
                <keyMaterial>$wpa2KeyPlainText</keyMaterial>
            </sharedKey>
        </security>
    </MSM>
</WLANProfile>
"@

# Save the XML profile to a file
$xmlProfile | Set-Content -Path "$PSScriptRoot\$ssid.xml"

# Create a Wi-Fi profile
cd $PSScriptRoot; netsh wlan add profile filename="$ssid.xml"

# Connect to the Wi-Fi network
netsh wlan connect name="$ssid" ssid="$ssid" interface="$wifiDeviceInterface"

# Checking latest command result
if ($?) {
    Write-Host ""
    Write-Host "Successfully configured Wi-Fi $ssid. Continue.." -ForegroundColor Green
    Write-Host ""

    # Delete temporary variable
    Remove-Variable -Name wpa2KeyPlainText

    # Clean up the temporary XML profile file
    Remove-Item -Path "$PSScriptRoot\$ssid.xml"
}
        
# Exit if fail
else {
    Write-Host ""
    Write-Host "Failed to configure Wi-Fi $ssid." -ForegroundColor Red
    Write-Host ""

    # Delete temporary variable
    Remove-Variable -Name wpa2KeyPlainText

    # Clean up the temporary XML profile file
    Remove-Item -Path "$PSScriptRoot\$ssid.xml"
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