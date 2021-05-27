$domain = New-Object System.DirectoryServices.DirectoryEntry
$searcher = New-Object System.DirectoryServices.DirectorySearcher
$searcher.SearchRoot = $domain
$searcher.PageSize = 100
$searcher.Filter = "(objectCategory=Computer)"

$proplist = ("name","pwdLastSet")
foreach ($i in $propList){$prop=$searcher.PropertiesToLoad.Add($i)}

$results = $searcher.FindAll()

foreach ($result in $results){
 $pwdlastset=[Int64]($result.properties.Item("pwdlastset")[0])
 $pwdAge=New-TimeSpan $([datetime]::FromFileTime([int64]::Parse($pwdlastset))) $(Get-Date)
 if($pwdAge.days -gt 60){
  "$($result.properties.Item("name"))`t$($pwdAge.days)"
 }
}