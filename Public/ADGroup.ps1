<#
.SYNOPSIS
    Test an Active Directory group.
.DESCRIPTION
    Tests multiple attributes associated with an Active Directory group.
.PARAMETER Target
    Specifies the samAccountNames of one or more Active Directory groups.
.PARAMETER Should 
    A Script Block defining a Pester Assertion.   
.EXAMPLE
    ADGroup GroupOne Scope { Should be 'DomainLocal' }
.EXAMPLE
    ADGroup jschmoe Category { Should be 'Security' }
#>
function ADGroup {
    [CmdletBinding(DefaultParameterSetName='prop')]
    param( 
        [Parameter(Mandatory, Position=1)]
        [Alias("Name")]
        [string]$Target,

        [Parameter(Position=2, ParameterSetName='prop')]
        [ValidateSet('Scope','Category')]
        [string]$Property,

        [Parameter(Position=2, ParameterSetName='noprop')]
        [Parameter(Position=3, ParameterSetName='prop')]
        [scriptblock]$Should
    )

    $testExpression = {
        Get-PoshSpecADGroup -Name '$Target'
    }

    $params = Get-PoshspecParam -TestName ADGroup -TestExpression $testExpression @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}