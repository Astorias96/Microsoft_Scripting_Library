$siteDescription=@{}
$siteSubnets=@{}
$subnetDescription=@{}
$sitesDN = "LDAP://CN=Sites," + $([adsi] "LDAP://RootDSE").Get("ConfigurationNamingContext")
$subnetsDN = "LDAP://CN=Subnets,CN=Sites," + $([adsi] "LDAP://RootDSE").Get("ConfigurationNamingContext")
([adsi] $sitesDN).children | ?{$_.objectClass -eq "site"} | %{ $siteName = ([string]$_.cn).toUpper(); $siteDescription[$siteName] = $_.description[0]; }
([adsi] $subnetsDN).children | %{ $siteSubnets[[string](([adsi] "LDAP://$($_.siteObject)").cn)] += $_.cn; $subnetDescription[[string]$_.cn]=$_.description[0] }
$siteDescription.keys | sort | %{ "$_  $($siteDescription[$_])"; $siteSubnets[$_] | %{"`t$_ $($subnetDescription[$_])"} }