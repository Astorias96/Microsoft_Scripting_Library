$servers = Get-Content .\servers.txt
"Name`tStatus" | Out-File -FilePath .\results.txt
foreach ($server in $servers){
 try{
  $adminGroup = [ADSI]"WinNT://$server/Administrators"
  $adminGroup.add("WinNT://myDomain/myGroup")
  "$server`tSuccess"
  "$server`tSuccess" | Out-File -FilePath .\results.txt -Append
 }
 catch{
  "$server`t" + $_.Exception.Message.ToString().Split(":")[1].Replace("`n","")
  "$server`t" + $_.Exception.Message.ToString().Split(":")[1].Replace("`n","") | Out-File -FilePath .\results.txt -Append
 }
}