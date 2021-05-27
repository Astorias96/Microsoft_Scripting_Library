$domain = New-Object System.DirectoryServices.DirectoryEntry
$searcher = New-Object System.DirectoryServices.DirectorySearcher
$searcher.SearchRoot = $domain
$searcher.PageSize = 1000
$searcher.Filter = "(&(objectCategory=User)(uidNumber=*))"

$proplist = ("cn","displayName","uidNumber","gidNumber","unixHomeDirectory","loginShell")
foreach ($i in $propList){$prop=$searcher.PropertiesToLoad.Add($i)}

$results = $searcher.FindAll()

$results ¦ %{ $_.properties; "" }