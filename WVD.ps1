Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com"
New-RdsTenant -Name JWTEST -AadTenantId 5f0266b8-5cac-4a72-8360-7249bf0090a6 -AzureSubscriptionId ced40ccb-e789-4ad3-8f89-804627f7a2d1





$myTenantName = "JWTEST"
Import-Module AzureAD
$aadContext = Connect-AzureAD
$svcPrincipal = New-AzureADApplication -AvailableToOtherTenants $true -DisplayName "Windows Virtual Desktop Svc Principal"
$svcPrincipalCreds = New-AzureADApplicationPasswordCredential -ObjectId $svcPrincipal.ObjectId

Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com"
New-RdsRoleAssignment -RoleDefinitionName "RDS Owner" -ApplicationId $svcPrincipal.AppId -TenantName $myTenantName


$creds = New-Object System.Management.Automation.PSCredential($svcPrincipal.AppId, (ConvertTo-SecureString $svcPrincipalCreds.Value -AsPlainText -Force))
Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com" -Credential $creds -ServicePrincipal -AadTenantId $aadContext.TenantId.Guid

$svcPrincipalCreds.Value
$aadContext.TenantId.Guid
$svcPrincipal.AppId


DoFaAMwnsB51HI67CDQ7Kxjzxn1actCRp3r98VlJYLk=
5f0266b8-5cac-4a72-8360-7249bf0090a6
2761b9cd-fb3a-4089-9a41-72bcfc2b7a7a