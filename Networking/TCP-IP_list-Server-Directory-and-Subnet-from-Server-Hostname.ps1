

function toBinary ($dottedDecimal){
 $dottedDecimal.split(".") | %{$binary=$binary + $([convert]::toString($_,2).padleft(8,"0"))}
 return $binary
}

if($args.count -ne 1){ "`nUsage: ./whatSite.ps1 <serverName>`n"; Exit; }
$hostEntry= [System.Net.Dns]::GetHostByName($args[0])
if($hostEntry){
 $ipAddress=toBinary ($hostEntry.AddressList[0].IPAddressToString)
}else{
 Write-Warning "Host not found!"
 Exit
}

$sites=@{}
$subnetsDN="LDAP://CN=Subnets,CN=Sites," + $([adsi] "LDAP://RootDSE").Get("ConfigurationNamingContext")

"`nGathering Site Information..."
foreach ($subnet in $([adsi] $subnetsDN).psbase.children){
 $site=[adsi] "LDAP://$($subnet.siteObject)"
 if($site.cn -ne $null){
  ($networkID,$netbits)=$($subnet.cn).split("/")
  $binNetID=(toBinary $networkID).substring(0,$netbits)
  $sites[$binNetID]=([string]$site.cn).toUpper()
 }
}

$i=32
do {$tryNetID=$ipAddress.substring(0,$i);
 if($sites[$tryNetID]){
  "`n$($args[0]) is in site $($sites[$tryNetID])`n"
  Exit
 }
 $i--
} while ($i -gt 0)

Write-Warning "`n$($args[0]) is not in a defined site`n"

