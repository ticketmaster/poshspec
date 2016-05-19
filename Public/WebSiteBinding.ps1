<#
.SYNOPSIS
    Test Binding of Web Site
.DESCRIPTION
    Used To Determine if Website is Running Desired Binding
.PARAMETER Target
    The name of the Web Site to be Tested
.PARAMETER Should 
    A Script Block defining a Pester Assertion.  
.EXAMPLE           
     WebSiteBinding TestSite {Should Match '80'} 
.NOTES
    Assertions: Match
#>
    function WebSiteBinding {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=1)]
        [Alias('Name')]
        [string]$Target,
        
        [Parameter(Mandatory, Position=2)]
        [scriptblock]$Should
    )
    
    $expression = {Get-WebBinding -Name '$Target' -ErrorAction SilentlyContinue }
    
    $params = Get-PoshspecParam -TestName WebSiteBinding -Property "BindingInformation" -TestExpression $expression @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}