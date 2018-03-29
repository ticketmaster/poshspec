<#
.SYNOPSIS
    Test the installed Software Packages.
.DESCRIPTION
    Test the Existance of a Software Package or the Value of a given Property.
.PARAMETER Target
    Specifies the path to an item.
.PARAMETER Property
    Specifies a property at the specified Path.
.PARAMETER Should
    A Script Block defining a Pester Assertion.
.EXAMPLE
    SoftwareProduct 'Microsoft .NET Framework 4.6.1' { Should Exist }
.EXAMPLE
    SoftwareProduct 'Microsoft SQL Server 2016' DisplayVersion { Should Be 13.0.1100.286  }
.EXAMPLE
    SoftwareProduct 'IIS 10.0 Express' InstallLocation { Should Match 'C:\Program Files (x86)' }
.NOTES
    Assertions: Be, BeExactly, Exist, Match, MatchExactly
#>
function SoftwareProduct {

    [CmdletBinding(DefaultParameterSetName="Default")]
    param(
        [Parameter(Mandatory, Position=1, ParameterSetName="Default")]
        [Parameter(Mandatory, Position=1, ParameterSetName="Property")]
        [Alias("Path")]
        [string]$Target,

        [Parameter(Position=2, ParameterSetName="Property")]
        [ValidateSet("DisplayVersion", "InstallLocation", "EstimatedSize")]
        [string]$Property,

        [Parameter(Mandatory, Position=2, ParameterSetName="Default")]
        [Parameter(Mandatory, Position=3, ParameterSetName="Property")]
        [scriptblock]$Should
    )

    End {
        #$expression = {@('HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\\Software\Microsoft\Windows\CurrentVersion\Uninstall\*') | Where-Object { Test-Path $_ } | Get-ItemProperty | Where-Object DisplayName -Match '$Target'}
        $expression = {TestSoftware $Target $Property}
        $params = Get-PoshspecParam -TestName SoftwareProduct -TestExpression $expression @PSBoundParameters

        Invoke-PoshspecExpression @params
    }

    Begin {
        function TestSoftware ([string]$name, [string]$property)
            {
                $keys = @('HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\\Software\Microsoft\Windows\CurrentVersion\Uninstall\*')

                foreach ($key in $keys) {
                    if (Test-Path $key) {
                        $value = Get-ItemProperty -Path $key |
                            Where-Object {$_.$property -Match [regex]::Escape($name)}

                            if ($null -ne $value) {
                                return $true
                            }
                    }

                }

                return $false

        }
    }
}
