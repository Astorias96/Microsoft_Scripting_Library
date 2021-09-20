

function toBinary ($dottedDecimal){
 $dottedDecimal.split(".") ¦ %{$binary=$binary + $([convert]::toString($_,2).padleft(8,"0"))}
 return $binary
}

function toDottedDecimal ($binary){
 do {$dottedDecimal += "." + [string]$([convert]::toInt32($binary.substring($i,8),2)); $i+=8 } while ($i -le 24)
 return $dottedDecimal.substring(1)
}

#read args and convert to binary
if($args.count -ne 2){ "`nUsage: .\subnetCalc.ps1 <ipaddress> <subnetmask>`n"; Exit }
$ipBinary = toBinary $args[0]
$smBinary = toBinary $args[1]

#how many bits are the network ID
$netBits=$smBinary.indexOf("0")

#validate the subnet mask
if(($smBinary.length -ne 32) -or ($smBinary.substring($netBits).contains("1") -eq $true)) {
 Write-Warning "Subnet Mask is invalid!"
 Exit
}

#validate that the IP address
if(($ipBinary.length -ne 32) -or ($ipBinary.substring($netBits) -eq "00000000") -or ($ipBinary.substring($netBits) -eq "11111111")) {
 Write-Warning "IP Address is invalid!"
 Exit
}

#identify subnet boundaries
$networkID = toDottedDecimal $($ipBinary.substring(0,$netBits).padright(32,"0"))
$firstAddress = toDottedDecimal $($ipBinary.substring(0,$netBits).padright(31,"0") + "1")
$lastAddress = toDottedDecimal $($ipBinary.substring(0,$netBits).padright(31,"1") + "0")
$broadCast = toDottedDecimal $($ipBinary.substring(0,$netBits).padright(32,"1"))

#write output
"`n   Network ID:`t$networkID/$netBits"
"First Address:`t$firstAddress  <-- typically the default gateway"
" Last Address:`t$lastAddress"
"    Broadcast:`t$broadCast`n"

