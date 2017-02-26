<#
.SYNOPSIS
    Test an Active Directory user.
.DESCRIPTION
    Tests multiple attributes associated with an Active Directory user.
.PARAMETER Target
    Specifies the samAccountNames of one or more Active Directory users.
.PARAMETER Should 
    A Script Block defining a Pester Assertion.   
.EXAMPLE
    ADUser jschmoe Enabled { Should be $true }
.EXAMPLE
    ADUser jschmoe GivenName { Should be 'Joe' }
#>
function ADUser {
    [CmdletBinding(DefaultParameterSetName='prop')]
    param( 
        [Parameter(Mandatory, Position=1)]
        [Alias("UserName")]
        [string]$Target,

        [Parameter(Position=2, ParameterSetName='prop')]
        [ValidateSet('Enabled','GivenName','SurName')]
        [string]$Property,

        [Parameter(Position=2, ParameterSetName='noprop')]
        [Parameter(Position=3, ParameterSetName='prop')]
        [scriptblock]$Should
    )

    $testExpression = {
        Get-PoshSpecADUser -Name '$Target'
    }

    $params = Get-PoshspecParam -TestName ADUser -TestExpression $testExpression @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}