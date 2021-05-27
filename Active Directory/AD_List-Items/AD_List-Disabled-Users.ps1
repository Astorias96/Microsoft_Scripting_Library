$domain = New-Object System.DirectoryServices.DirectoryEntry
$searcher = New-Object System.DirectoryServices.DirectorySearcher
$searcher.SearchRoot = $domain
$searcher.PageSize = 1000
$searcher.Filter = "(&(objectCategory=User)(userAccountControl:1.2.840.113556.1.4.803:=2))"

$proplist = ("cn","displayName")
foreach ($i in $propList){$prop=$searcher.PropertiesToLoad.Add($i)}

$results = $searcher.FindAll()

foreach ($result in $results){
 "$($result.properties.item("cn"))`t$($result.properties.item("displayName"))"
}
