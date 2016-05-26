<#
.SYNOPSIS
    Test if a local group exists.
.DESCRIPTION
    Test if a local group exists.
.PARAMETER Target
    The local group name to test for. Eg 'Administrators'
.PARAMETER Should 
    A Script Block defining a Pester Assertion.  
.EXAMPLE
    LocalGroup 'Administrators' { should not BeNullOrEmpty }    
.EXAMPLE
    LocalGroup 'BadGroup' { should BeNullOrEmpty }
.NOTES
    Assertions: BeNullOrEmpty
#>
    
function LocalGroup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=1)]
        [Alias('Name')]
        [string]$Target,
        
        [Parameter(Mandatory, Position=2)]
        [scriptblock]$Should
    )

    $expression = {Get-CimInstance -ClassName Win32_Group -Filter "Name = '$Target'"}
    
    $params = Get-PoshspecParam -TestName LocalGroup -TestExpression $expression @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}