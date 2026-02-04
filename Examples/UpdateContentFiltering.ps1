[CmdletBinding(DefaultParameterSetName = 'NetworkName')]
param(
    [Parameter(
        Mandatory = $true,
        ParameterSetName = 'Name'
    )]
    [String] $networkName,    
    [Parameter(
        Mandatory = $true,
        ParameterSetName = 'ID'
    )]
    [String] $networkId,
    [Parameter(
        Mandatory = $true,
        ParameterSetName = 'All'
    )]
    [switch] $All,
    [Parameter(
        Mandatory = $true,
        ParameterSetName = 'Template'
    )]
    [switch] $Templates,
    [String[]] $allowURL,
    [String[]] $blockedURL,
    [string[]] $blockedURLCategories
)

if ($All) {
    $Networks = Get-MerakiNetworks
}
else {
    if ($Templates) {
        $Networks = Get-MerakiOrganizationConfigTemplates
    }
    else {
        if ($networkId) {
            $Networks = @()
            $Networks += Get-MerakiNetwork -networkID $networkId
        }
        else {
            $Networks = @()
            $Networks += Get-MerakiNetwork | Where-Object { $_.Name -eq $networkName }
        }
    }
}

if ( (-not $AllowURL) -and (-not $DenyURL)) {
    $PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new(
            [System.Management.Automation.ParameterBindingException]'At least one of AllowURL and DenyURL must be provided', 
            'MissingRequiredParameter',
            [System.Management.Automation.ErrorCategory]::InvalidArgument, $null)
    )
}

$contentFiltering = Get-MerakiNetworkApplianceContentFiltering -id $networkId

if ($AllowURL) {
    $contentFiltering.AllowUrlPatterns += $AllowURL
}

if ($blockedURL) {
    $contentFiltering.blockedUrlPatterns += $blockedURL
}

if ($blockedURLCategories) {
    $contentFiltering.blockedUrlCategories += $blockedURLCategories
}


Update-MerakiNetworkApplianceContentFiltering -id $networkId -ContentFilteringRules $contentFiltering

