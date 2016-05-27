<#
.SYNOPSIS
    Firewall Settings
.DESCRIPTION
    Used To Determine if Firewall is Running Desired Settings
.PARAMETER Target
    The name of the Firewall DisplayName to be Tested
.PARAMETER Property
    The name of the Property of the Firewall Object to be Tested
.PARAMETER Should 
    A Script Block defining a Pester Assertion.  
.EXAMPLE           
   Firewall putty.exe Enabled { Should be "$True" }
.EXAMPLE 
   Firewall putty.exe Action { Should be 'Allow' }
.EXAMPLE 
   Firewall putty.exe Private { Should be 'Public' }  
.NOTES
    Assertions: Be
#>
    function Firewall{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=1)]
        [Alias('Name')]
        [string]$Target,
        
        [Parameter(Position=2)]
        [ValidateSet("Name","DisplayName","Description","DisplayGroup","Group","Enabled","Profile","Direction","Action","EdgeTraversalPolicy","LooseSourceMapping","LocalOnlyMapping","PrimaryStatus","Status","EnforcementStatus","PolicyStoreSource","PolicyStoreSourceType")]
        [string]$Property,

        [Parameter(Mandatory, Position=3)]
        [scriptblock]$Should
    )
    
            $expression = {Get-NetFirewallRule -DisplayName '$Target' -ErrorAction SilentlyContinue }
            
            $params = Get-PoshspecParam -TestName Firewall -TestExpression $expression @PSBoundParameters
            
            Invoke-PoshspecExpression @params
}