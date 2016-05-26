<#
.SYNOPSIS
    Check if AppPool Exists
.DESCRIPTION
    Used To Determine if Website Exists
.PARAMETER Target
    The name of the App Pool to be Tested
.PARAMETER Should 
    A Script Block defining a Pester Assertion.  
.EXAMPLE           
     CheckAppPool TestSite { Should be $True}
.NOTES
    #REQUIRES# webadministration module
    Assertions: be
#>
function CheckAppPool {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=1)]
        [Alias('Name')]
        [string]$Target,
        
        [Parameter(Mandatory, Position=2)]
        [scriptblock]$Should
    )

    $expression = {Test-Path -Path "IIS:\AppPools\$Target" -ErrorAction SilentlyContinue}
    
    $params = Get-PoshspecParam -TestName CheckAppPool -TestExpression $expression @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}