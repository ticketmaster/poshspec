<#
.SYNOPSIS
    Test State of Application Pool
.DESCRIPTION
    Used To Determine if Application Pool is Running
.PARAMETER Target
    The name of the App Pool to be Tested
.PARAMETER Should 
    A Script Block defining a Pester Assertion.  
.EXAMPLE           
    AppPoolState TestSite { Should be Started }   
.NOTES
    Assertions: be
#>
function AppPoolState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=1)]
        [Alias('Name')]
        [string]$Target,
        
        [Parameter(Mandatory, Position=2)]
        [scriptblock]$Should
    )

    $expression = {Get-WebAppPoolState -Name '$Target' -ErrorAction SilentlyContinue}
    
    $params = Get-PoshspecParam -TestName AppPoolState -Property "Value" -TestExpression $expression @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}
