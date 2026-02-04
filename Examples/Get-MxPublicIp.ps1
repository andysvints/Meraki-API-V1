using namespace System.Management.Automation
using namespace System.Collections.Generic

#Requires -Modules Meraki-API-V1,AWS.Tools.SecretsManager

param(
    [string]$OutputFolder = "./"
)

if ($OutputFolder) {
    if (-not (Test-Path -Path $OutputFolder)) {
        throw "Output folder does not exist!"
    }
    if (-not ($OutputFolder.EndsWith("/"))) {
        $OutputFolder = "{0}/" -f $OutputFolder
    }
} 

$DateString = Get-Date -Format "ddMMyyyy"
$ReportName = "{0}MerakiWanIPs-{1}.csv" -f $OutputFolder, $DateString

$Orgs = Get-MerakiOrganizations
foreach ($Org in $Orgs) {
    $OrgApplianceStatuses = $Null
    $OrgApplianceStatuses = Get-MerakiOrganizationDeviceStatus -OrgId $Org.id -Filter "productTypes[]=appliance&status=online"
    $OrgApplianceStatuses | ForEach-Object {
        $_ | Add-Member -MemberType NoteProperty -Name "Organization" -Value $Org.Name
    }
    $ApplianceStatuses += $OrgApplianceStatuses
}


$ApplianceStatuses | Select-Object Organization, NetworkName, Model, PublicIp | Export-Csv -Path $ReportName


