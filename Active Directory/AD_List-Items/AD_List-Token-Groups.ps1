$username=$args[0]

if($args.count -lt 1){
 "Usage: ./list-Token-Groups.ps1 <username>"
}

$groups=@{}

$gc="GC://" + $([adsi] "LDAP://RootDSE").Get("RootDomainNamingContext")

$filter = "(&(objectCategory=User)(|(cn=" + $username + ")(samaccountname=" + $username + ")(displayName=" + $username + ")(distinguishedName=" + $username + ")))"
$domain = New-Object System.DirectoryServices.DirectoryEntry($gc)
$searcher = New-Object System.DirectoryServices.DirectorySearcher
$searcher.SearchRoot = $domain
$searcher.Filter = $filter
$results = $searcher.FindAll()
if($results.count -eq 0){ "User Not Found"; }else{
 foreach ($result in $results){
  $user=$result.GetDirectoryEntry();
  $user.GetInfoEx(@("tokenGroups"),0)
  $tokenGroups=$user.Get("tokenGroups")
  foreach ($token in $tokenGroups){
   $principal = New-Object System.Security.Principal.SecurityIdentifier($token,0)
   $group = $principal.Translate([System.Security.Principal.NTAccount])
   $groups[$group]=1
  }
 }
}

$groups.keys | sort-object