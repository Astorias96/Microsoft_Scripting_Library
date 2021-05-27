$configurationContainer = ([adsi] "LDAP://RootDSE").Get("ConfigurationNamingContext")
$partitions = ([adsi] "LDAP://CN=Partitions,$configurationContainer").psbase.children

foreach($partition in $partitions)
{
 if($partition.netbiosName -ne ""){
  $partitionDN=$partition.ncName
  $dnsName=$partitionDN.toString().replace("DC=",".").replace(",","").substring(1)
  $domain=$partition.netbiosName
  "`n$domain"
  md c:\scripts\powershell\dfsbackup\$domain
  $dfsContainer=[adsi] "LDAP://cn=Dfs-Configuration,cn=System,$partitionDN"
  $dfsRoots = $dfsContainer.psbase.children
  foreach($dfsRoot in $dfsRoots){
   $root=$dfsRoot.cn
   "`n$root"
   dfsutil root export "\\$dnsName\$root" "c:\scripts\powershell\dfsbackup\$domain\$root.xml"
  }
 }
}