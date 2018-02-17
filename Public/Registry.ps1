 <#
.SYNOPSIS
    Test a Registry Key.
.DESCRIPTION
    Test the Existance of a Key or the Value of a given Property.
.PARAMETER Target
    Specifies the path to an item.
.PARAMETER Property
    Specifies a property at the specified Path.
.PARAMETER Should
    A Script Block defining a Pester Assertion.
.EXAMPLE
    Registry HKLM:\SOFTWARE\Microsoft\Rpc\ClientProtocols { Should Exist }
.EXAMPLE
    Registry HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\ "NV Domain" { Should Be mybiz.local  }
.EXAMPLE
    Registry 'HKLM:\SOFTWARE\Callahan Auto\' { Should Not Exist }
.NOTES
    Assertions: Be, BeExactly, Exist, Match, MatchExactly
#>

function Registry {
    [CmdletBinding(DefaultParameterSetName="Default")]
    param(
        [Parameter(Mandatory, Position=1, ParameterSetName="Default")]
        [Parameter(Mandatory, Position=1, ParameterSetName="Property")]
        [Alias("Path")]
        [string]$Target,

        [Parameter(Position=2, ParameterSetName="Property")]
        [string]$Property,

        [Parameter(Mandatory, Position=2, ParameterSetName="Default")]
        [Parameter(Mandatory, Position=3, ParameterSetName="Property")]
        [scriptblock]$Should
    )

    $name = Split-Path -Path $Target -Leaf

    if ($PSBoundParameters.ContainsKey("Property"))
    {
        $expression = {Get-ItemProperty -Path '$Target'}
    }
    else
    {
        $expression = {'$Target'}
    }

    $params = Get-PoshspecParam -TestName Registry -TestExpression $expression -FriendlyName $name @PSBoundParameters

    Invoke-PoshspecExpression @params
}
