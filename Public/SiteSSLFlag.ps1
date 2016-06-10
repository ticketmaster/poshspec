<#
.SYNOPSIS
    Check if Site Using SSL Binding
.DESCRIPTION
    Used To Determine if Website has SSL Binding
.PARAMETER Target
    The name of the Web Site to be Tested
.PARAMETER Should 
    A Script Block defining a Pester Assertion.  
.EXAMPLE           
     CheckSite  TestSite { Should be $True}
.NOTES
    Assertions: be
#>
function SiteSSLFlag {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=1)]
        [Alias('Name')]
        [string]$Target,
        
        [Parameter(Mandatory, Position=2)]
        [scriptblock]$Should
    )
    
    $expression = {Get-WebBinding -Name '$Target' -ErrorAction SilentlyContinue}
    
    $params = Get-PoshspecParam -TestName SiteSSLFlag -Property "sslFlags" -TestExpression $expression @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}

