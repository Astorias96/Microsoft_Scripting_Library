$sourceUser=Read-Host "Please enter the username (to copy the AD groups from)"
$targetUser=Read-Host "Please enter the target user (to copy the AD groups to)"

$logfile="c:\LOG\CopyAdGroup.log"
$userSource=$sourceUser
$userTarget=ù$targetUserù
$Time = Get-Date
Add-content $logfile -value $Time -Encoding UTF8
Add-content $logfile -value "______________________________"
Add-content $logfile -value "Copying AD groups from $userSource to $userTarget" -Encoding UTF8
$sourceGroups = (Get-ADPrincipalGroupMembership -Identity $userSource).SamAccountName
foreach ($group in $sourceGroups)
{
Add-content $logfile -value "Adding $userTarget to $group" -Encoding UTF8
try
{
$log=Add-ADPrincipalGroupMembership -Identity $userTarget -MemberOf $group
Add-content $logfile -value $log -Encoding UTF8
}
catch
{
Add-content $logfile $($Error[0].Exception.Message) -Encoding UTF8
Continue
}
}
Add-content $logfile -value "______________________________"