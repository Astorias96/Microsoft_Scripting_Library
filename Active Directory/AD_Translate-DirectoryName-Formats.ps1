#Name Translator Initialization Types
$ADS_NAME_INITTYPE_DOMAIN   = 1
$ADS_NAME_INITTYPE_SERVER   = 2
$ADS_NAME_INITTYPE_GC       = 3

#Name Transator Name Types
$DISTINGUISHEDNAME     = 1
$CANONICALNAME         = 2
$NT4NAME               = 3
$DISPLAYNAME           = 4
$DOMAINSIMPLE          = 5
$ENTERPRISESIMPLE      = 6
$GUID                  = 7
$UNKNOWN               = 8
$USERPRINCIPALNAME     = 9
$CANONICALEX          = 10
$SERVICEPRINCIPALNAME = 11
$SIDORSIDHISTORY      = 12

if($args.count -ne 1){ "`nUsage: ./nametranslate.ps1 <userName>`n"; Exit; }

$ns=New-Object -ComObject NameTranslate
[System.__ComObject].InvokeMember(“init”,”InvokeMethod”,$null,$ns,($ADS_NAME_INITTYPE_GC,$null))
[System.__ComObject].InvokeMember(“Set”,”InvokeMethod”,$null,$ns,($UNKNOWN,$args[0]))

$dn = [System.__ComObject].InvokeMember(“Get”,”InvokeMethod”,$null,$ns,$DISTINGUISHEDNAME)
$canon = [System.__ComObject].InvokeMember(“Get”,”InvokeMethod”,$null,$ns,$CANONICALNAME)
$display = [System.__ComObject].InvokeMember(“Get”,”InvokeMethod”,$null,$ns,$DISPLAYNAME)
$nt4name = [System.__ComObject].InvokeMember(“Get”,”InvokeMethod”,$null,$ns,$NT4NAME)

"Distinguished Name:`t$dn"
"    Canonical Name:`t$canon"
"      Display Name:`t$display"
"          NT4 Name:`t$nt4name"