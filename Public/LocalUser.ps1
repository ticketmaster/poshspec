<#
.SYNOPSIS
    Test if a local user exists and is enabled.
.DESCRIPTION
    Test if a local user exists and is enabled.
.PARAMETER Target
    The local user name to test for. Eg 'Guest'
.PARAMETER Should 
    A Script Block defining a Pester Assertion.  
.EXAMPLE
    LocalGroup 'Guest' { should not BeNullOrEmpty }    
.EXAMPLE
    LocalGroup 'Guest' Disabled { should Be $true }
.NOTES
    Assertions: Be, BeExactly, BeNullOrEmpty, Match, MatchExactly
#>
    
function LocalUser {
    [CmdletBinding(DefaultParameterSetName="Default")]
    param(
        [Parameter(Mandatory, Position=1,ParameterSetName="Default")]
        [Parameter(Mandatory, Position=1,ParameterSetName="Property")]
        [Alias('Name')]
        [string]$Target,

        [Parameter(Position=2,ParameterSetName="Property")]
        [string]$Property,
        
        [Parameter(Mandatory, Position=2,ParameterSetName="Default")]
        [Parameter(Mandatory, Position=3,ParameterSetName="Property")]
        [scriptblock]$Should
    )

    $expression = {Get-CimInstance -ClassName Win32_UserAccount -filter "LocalAccount=True AND` Name='$Target'"}
    
    $params = Get-PoshspecParam -TestName LocalUser -TestExpression $expression @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}