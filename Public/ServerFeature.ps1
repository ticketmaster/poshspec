
 <#
.SYNOPSIS
    Test if a Windows feature is installed.
.DESCRIPTION
    Test if a Windows feature is installed.

    Note that this function uses 'Get-WindowsFeature' to retrieve the list of features installed.
    This cmdlet does not work on a desktop operating system to retieve the list of locally installed
    features and as such is not supported on the desktop.
.PARAMETER Target
    The Windows feature name to test for
.PARAMETER Property
    The optional property on the feature to test for. If not specified, will default to the 'Installed' property.
.PARAMETER Should
    A Script Block defining a Pester Assertion.
.EXAMPLE
    ServerFeature Web-Server { Should be $true }
.EXAMPLE
    ServerFeature TelnetClient { Should Be $false }
.EXAMPLE
    ServerFeature Web-Server InstallState { Should Be 'Installed' }
.EXAMPLE
    ServerFeature Remote-Access InstallState { Should Be 'Available' }
.NOTES
    Assertions: Be, BeNullOrEmpty
#>
   function ServerFeature {
    [CmdletBinding(DefaultParameterSetName='prop')]
    param(
        [Parameter(Mandatory, Position=1)]
        [string]$Target,

        [Parameter(Position=2, ParameterSetName='prop')]
        [ValidateSet('BestPracticesModelId', 'DependsOn', 'Depth', 'DisplayName', 'FeatureType', 'Installed', 'InstallState',
            'Name', 'Notification', 'Parent', 'Path', 'ServerComponentDescriptor', 'SubFeatures', 'SystemService')]
        [string]$Property = 'Installed',

        [Parameter(Mandatory, Position=2, ParameterSetName='noprop')]
        [Parameter(Mandatory, Position=3, ParameterSetName='prop')]
        [scriptblock]$Should
    )

    if (-not $PSBoundParameters.ContainsKey('Property')) {
        $Property = 'Installed'
        $PSBoundParameters.Add('Property', $Property)
    }

    # Wrapping 'Get-WindowsFeature' in a function so the progress bar can be supressed
    function GetFeature([string]$Name) {
        $progPref = $ProgressPreference
        $ProgressPreference = 'SilentlyContinue'
        $f = Get-WindowsFeature -Name $Name -ErrorAction SilentlyContinue
        $ProgressPreference = $progPref
        $f
    }

    $expression = { GetFeature -Name $Target }

    $params = Get-PoshspecParam -TestName ServerFeature -TestExpression $expression @PSBoundParameters

    Invoke-PoshspecExpression @params
}
