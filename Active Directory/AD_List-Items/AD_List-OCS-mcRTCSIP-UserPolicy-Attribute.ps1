$user = New-Object System.DirectoryServices.DirectoryEntry("LDAP://CN=myUser,CN=Users,DC=myDomain,DC=com")

$policyType=@{"1000" = "`t    Meeting Policy"; "2000" = "`t      Voice Policy"; "4000" = "`t   Presence Policy";}

"`nReading msRTCSIP-UserPolicy attribute for " + $user.displayName + "`n"

$policies = $user.Get("msRTCSIP-UserPolicy")

foreach($policy in $policies){
 $policyDN = [System.__ComObject].InvokeMember("DNString",[System.Reflection.BindingFlags]::GetProperty,$null,$policy,$null)
 $policyBIN = [System.__ComObject].InvokeMember("BinaryValue",[System.Reflection.BindingFlags]::GetProperty,$null,$policy,$null)
 $bits=""
 foreach ($byte in $policyBIN){ $bits=$bits + [string] $byte }
 $policyObj = New-Object System.DirectoryServices.DirectoryEntry("LDAP://" + $policyDN)
 $policyName=([xml] $policyObj.Get("msrtcsip-policycontent")).instance.property[0].InnerText
 "$($policyType[$bits]):  $policyName"
}
""