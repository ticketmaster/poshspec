<#
.SYNOPSIS
    Check if Site Exists
.DESCRIPTION
    Used To Determine if Website Exists
.PARAMETER Target
    The name of the Web Site to be Tested
.PARAMETER Should 
    A Script Block defining a Pester Assertion.  
.EXAMPLE           
     CheckSite  TestSite { Should be $True}
.NOTES
    #REQUIRES# webadministration module
    Assertions: be
#>
function CheckSite {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=1)]
        [Alias('Name')]
        [string]$Target,
        
        [Parameter(Mandatory, Position=2)]
        [scriptblock]$Should
    )  

    $expression = {Test-Path -Path "IIS:\Sites\$Target" -ErrorAction SilentlyContinue}
    
    $params = Get-PoshspecParam -TestName CheckSite -TestExpression $expression @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}
