<#
.SYNOPSIS
    Test the Existance of a Driver.
.DESCRIPTION
    Test the Existance of a Driver or the Value of a given Property.
.PARAMETER Target
    Specifies the path to an item.
.PARAMETER Property
    Specifies a property at the specified Path.    
.PARAMETER Should 
    A Script Block defining a Pester Assertion.       
.EXAMPLE
    Driver 'Audio Driver' DriverVersion { Should Be 13.0.1100.286  }
.EXAMPLE
    Driver 'Audio Driver' { Should Exist }
.NOTES
    Assertions: Be, BeExactly, Exist, Match, MatchExactly
#>
function Driver {
 
    [CmdletBinding(DefaultParameterSetName="Default")]
    param(        
        [Parameter(Mandatory, Position=1, ParameterSetName="Default")]
        [Parameter(Mandatory, Position=1, ParameterSetName="Property")]
        [Alias("Path")]
        [string]$Target,
        
        [Parameter(Position=2, ParameterSetName="Property")]
        [ValidateSet("DriverVersion", "DeviceID")]
        [string]$Property,
        
        [Parameter(Mandatory, Position=2, ParameterSetName="Default")]
        [Parameter(Mandatory, Position=3, ParameterSetName="Property")]
        [scriptblock]$Should
    )

    $expression = { Get-WmiObject Win32_PnPSignedDriver | Where-Object DeviceName -Like '$Target'} 
    
    $params = Get-PoshspecParam -TestName Driver -TestExpression $expression @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}
