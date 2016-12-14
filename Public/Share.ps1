<#
.SYNOPSIS
    Test if a share exists.
.DESCRIPTION
    Test if a share exists.
.PARAMETER Target
    The share name to test for. Eg 'C$' or 'MyShare'
.PARAMETER Should 
    A Script Block defining a Pester Assertion.  
.EXAMPLE
    Share 'MyShare' { should not BeNullOrEmpty }    
.EXAMPLE
    Share 'BadShare' { should BeNullOrEmpty }
.NOTES
    Assertions: BeNullOrEmpty
#>
    
function Share {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=1)]
        [Alias('Name')]
        [string]$Target,
        
        [Parameter(Mandatory, Position=2)]
        [scriptblock]$Should
    )

    $expression = {Get-CimInstance -ClassName Win32_Share -Filter "Name = '$Target'"}
    
    $params = Get-PoshspecParam -TestName Share -TestExpression $expression @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}