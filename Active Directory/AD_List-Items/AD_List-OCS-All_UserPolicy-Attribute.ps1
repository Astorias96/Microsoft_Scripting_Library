#get the username from the commandline or use the current username
if($args.count -eq 0){
 $adinfo=New-Object -Com "adsysteminfo"
 $username=[System.__ComObject].InvokeMember("username",[System.Reflection.BindingFlags]::GetProperty,$null,$adinfo,$null)
}else{
 $username=$args[0]
}
#setup a System.DirectoryServices search
$filter = "(&(objectCategory=User)(¦(cn=" + $username + ")(samaccountname=" + $username + ")(displayName=" + $username + ")(distinguishedName=" + $username + ")))"
$domain = New-Object System.DirectoryServices.DirectoryEntry
$searcher = New-Object System.DirectoryServices.DirectorySearcher
$searcher.SearchRoot = $domain
$searcher.PageSize = 1000
$searcher.Filter = $filter
$results = $searcher.FindAll()
if($results.count -eq 0){ "User Not Found"; }else{
 #walk through the users we found
 ""
 foreach ($result in $results){
  $user=$result.GetDirectoryEntry();
  "        -------------------------------------------------------"
  ""
  "`tOCS Properties for:`t" + $user.cn + " (" + $user.displayName + ")"
  # is the user enabled?
  $enabled = "False"
  $enabled=$user.Get("msRTCSIP-UserEnabled")
  trap [System.Runtime.InteropServices.COMException]{
   continue;
  }
  "`t  User OCS Enabled:`t" + $enabled
  if($enabled -eq "True"){
   #user SIP and Pool or Server Name
   "`t  User SIP Address:`t" + $user.Get("msRTCSIP-PrimaryUserAddress");
   $pool = New-Object System.DirectoryServices.DirectoryEntry("LDAP://" + $user.Get("msRTCSIP-PrimaryHomeServer").Substring(28))
   "`t   OCS Pool/Server:`t" + $pool.dNSHostName
   #counfounded policies!
   $policies = $user.Get("msRTCSIP-UserPolicy")
   foreach($policy in $policies){
    $policyDN=[System.__ComObject].InvokeMember("DNString",[System.Reflection.BindingFlags]::GetProperty,$null,$policy,$null)
    $policyBIN=[System.__ComObject].InvokeMember("BinaryValue",[System.Reflection.BindingFlags]::GetProperty,$null,$policy,$null)
    $bits=""
    foreach ($byte in $policyBIN){  $bits=$bits + [string] $byte; }
    $policyType = ""
    if($bits -eq "1000"){ $policyType = "`t    Meeting Policy"; }
    if($bits -eq "2000"){ $policyType = "`t      Voice Policy"; }
    if($bits -eq "4000"){ $policyType = "`t   Presence Policy"; }
    $policyObj = New-Object System.DirectoryServices.DirectoryEntry("LDAP://" + $policyDN)
    $policyName=([xml] $policyObj.Get("msrtcsip-policycontent")).instance.property[0].InnerText
    $policyType +":`t" + $policyName;
   }
   #archiving
   $archive = $user.Get("msRTCSIP-ArchivingEnabled")
   if($archive -eq 0){ $archive = "False"; }else{ $archive = "True"; }
   "`t Archiving Enabled:`t" + $archive;
   #federation
   $federation = $user.Get("msRTCSIP-FederationEnabled")
   if($federation -eq 0){ $federation = "False"; }else{ $federation = "True"; }
   "`tFederation Enabled:`t" + $federation;
   #option flags
   $flags = $user.Get("msRTCSIP-OptionFlags")
   if(($flags -band 1) -eq 1){ $pim = "True"; }else{ $pim = "False"; }
   if(($flags -band 16) -eq 16){ $rcc = "True"; }else{ $rcc = "False"; }
   if(($flags -band 64) -eq 64){ $oam = "True"; }else{ $oam = "False"; }
   if(($flags -band 128) -eq 128){ $uce = "True"; }else{ $uce = "False"; }
   if(($flags -band 256) -eq 256){ $ep = "True"; }else{ $ep = "False"; }
   if(($flags -band 512) -eq 512){ $rcd = "True"; }else{ $rcd = "False"; }
   if(($flags -band 1024) -eq 1024){ $aa = "True"; }else{ $aa = "False"; }
   ""
   "         Public IM Enabled:`t" + $pim
   "       Remote Call Control:`t" + $rcc
   "        Anonymous Meetings:`t" + $oam
   "             Unified Comms:`t" + $uce
   "         Enhanced Presence:`t" + $ep
   "        Rmt Call Dual CTRL:`t" + $rcd
   "            Auto Attendant:`t" + $aa
  }
  ""
 }
 "        -------------------------------------------------------"
 ""
}