<#
.SYNOPSIS
    Test an Active Directory organizational unit.
.DESCRIPTION
    Tests multiple attributes associated with an Active Directory organizational unit.
.PARAMETER Target
    Specifies the samAccountNames of one or more Active Directory organizational units.
.PARAMETER Should 
    A Script Block defining a Pester Assertion.
.EXAMPLE
    ADOrganizationalUnit Computers
#>
function ADOrganizationalUnit {
    [CmdletBinding(DefaultParameterSetName='prop')]
    param( 
        [Parameter(Mandatory, Position=1)]
        [Alias("Name")]
        [string]$Target,

        [Parameter(Position=2, ParameterSetName='noprop')]
        [Parameter(Position=3, ParameterSetName='prop')]
        [scriptblock]$Should
    )

    $testExpression = {
        Get-PoshSpecADOrganizationalUnit -Name '$Target'
    }

    $params = Get-PoshspecParam -TestName ADOrganizationalUnit -TestExpression $testExpression @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}