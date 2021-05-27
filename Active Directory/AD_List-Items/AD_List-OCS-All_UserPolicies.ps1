$configurationContainer = ([adsi] "LDAP://RootDSE").Get("ConfigurationNamingContext")
$policyContainer = [adsi] "LDAP://CN=Policies,CN=RTC Service,CN=Services,$configurationContainer"
$policies = $policyContainer.psbase.children
foreach($policy in $policies)
{
 $content=([xml] $policy.Get("msrtcsip-policycontent")).instance.property
 $policyType=$policy.Get("msrtcsip-policyType")
 $dn=$policy.distinguishedName
 "--------------------------------------------------------------------"
 ""
 "DN: $dn"
 "Policy Type: $policyType"
 $content ¦ ft
}