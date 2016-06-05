 <#
.SYNOPSIS
    Test State of Web Site
.DESCRIPTION
    Used To Determine if Website is Running
.PARAMETER Target
    The name of the Web Site to be Tested
.PARAMETER Should 
    A Script Block defining a Pester Assertion.  
.EXAMPLE           
     WebSiteState TestSite { Should be Started } 
.NOTES
    Assertions: be
#>
    
function WebSiteState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=1)]
        [Alias('Name')]
        [string]$Target,
        
        [Parameter(Mandatory, Position=2)]
        [scriptblock]$Should
    )

    $expression = {Get-WebSiteState -Name '$Target' -ErrorAction SilentlyContinue}
    
    $params = Get-PoshspecParam -TestName WebSiteState -property "Value" -TestExpression $expression @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}
