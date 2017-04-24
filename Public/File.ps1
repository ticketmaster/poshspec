<#
.SYNOPSIS
    Test a File.
.DESCRIPTION
    Test the Existance or Contents of a File..
.PARAMETER Target
    Specifies the path to an item.
.PARAMETER Should
    A Script Block defining a Pester Assertion.
.EXAMPLE
    File C:\inetpub\wwwroot\iisstart.htm { Should Exist }
.EXAMPLE
    File C:\inetpub\wwwroot\iisstart.htm { Should Contain 'text-align:center' }
.NOTES
    Assertions: Exist and Contain
#>
  function File {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=1)]
        [Alias("Path")]
        [string]$Target,

        [Parameter(Mandatory, Position=2)]
        [scriptblock]$Should
    )

    $name = Split-Path -Path $Target -Leaf
    $params = Get-PoshspecParam -TestName File -TestExpression {'$Target'} -FriendlyName $name @PSBoundParameters

    Invoke-PoshspecExpression @params
}
