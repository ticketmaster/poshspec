<#
.SYNOPSIS
    Test a Service.
.DESCRIPTION
    Test the Status of a given Service.
.PARAMETER Target
    Specifies the service names of service.
.PARAMETER Should 
    A Script Block defining a Pester Assertion.   
.EXAMPLE
    Service w32time { Should Be Running }
.EXAMPLE
    Service bits { Should Be Stopped }
.NOTES
    Only validates the Status property. Assertions: Be
#>
function Service {
    [CmdletBinding(DefaultParameterSetName='prop')]
    param( 
        [Parameter(Mandatory, Position=1)]
        [Alias("Name")]
        [string]$Target,

        [Parameter(Position=2, ParameterSetName='prop')]
        [string]$Property = 'Status',

        [Parameter(Mandatory, Position=2, ParameterSetName='noprop')]
        [Parameter(Mandatory, Position=3, ParameterSetName='prop')]
        [scriptblock]$Should
    )

    if (-not $PSBoundParameters.ContainsKey('Property')) {
        $Property = 'Status'
        $PSBoundParameters.Add('Property', $Property)
    }

    $params = Get-PoshspecParam -TestName Service -TestExpression {Get-Service -Name '$Target'} @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}