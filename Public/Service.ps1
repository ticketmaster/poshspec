<#
.SYNOPSIS
    Test a Service.
.DESCRIPTION
    Test the Status of a given Service.
.PARAMETER Name
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
    [CmdletBinding()]
    param( 
        [Parameter(Mandatory, Position=1)]
        [Alias("Name")]
        [string]$Target,

        [Parameter(Mandatory, Position=2)]
        [string]$Property,

        [Parameter(Mandatory, Position=3)]
        [scriptblock]$Should
    )

    $params = Get-PoshspecParam -TestName Service -TestExpression {Get-Service -Name '$Target'} @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}