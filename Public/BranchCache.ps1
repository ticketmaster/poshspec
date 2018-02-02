<#
.SYNOPSIS
    Tests BranchCache settings
.DESCRIPTION
    Tests BranchCache settings
.PARAMETER Property
    Specifies a property of the Get-BCClientConfiguration cmdlet return object 
.PARAMETER Should 
    A Script Block defining a Pester Assertion.       
.EXAMPLE
    BranchCache CurrentClientMode  { Should Be 'Enabled' }
.NOTES
    Assertions: Be, BeExactly, Exist, Match, MatchExactly
#>
function BranchCache {
 
    [CmdletBinding()]
    param(        

        [Parameter(Mandatory, Position=0)]
        [ValidateSet(
            'Caption',
            'Description',
            'DistributedCachingIsEnabled',
            'ElementName',
            'HostedCacheDiscoveryEnabled',
            'HostedCacheServerList',
            'InstanceID',
            'MinimumSmbLatencyInMilliseconds',
            'ServeDistributedCachingPeersOnBatteryPower',
            'CurrentClientMode',
            'HostedCacheVersion',
            'PreferredContentInformationVersion'
        )]
        [string]$Target,
                
        [Parameter(Mandatory, Position=1)]
        [scriptblock]$Should
    )

    Process {
        
        $expression = { Get-BCClientConfiguration | Select-Object -ExpandProperty $Target }
        
        $params = Get-PoshspecParam -TestName BranchCache -TestExpression $expression @PSBoundParameters
        
        Invoke-PoshspecExpression @params

    }
}
