$LocalIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.AddressState -eq "Preferred" -and $_.ValidLifetime -lt "24:00:00"}).IPAddress
$PublicIP = (Invoke-WebRequest ifconfig.me/ip).Content.Trim()
$HostnAME = (hostname)
echo "IP Configuration - $Hostname"
echo ""
echo "Your local  IP is: $LocalIP"
echo "Your public IP is: $PublicIP"
echo ""
