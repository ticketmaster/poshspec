 <#
.SYNOPSIS
    Test for installed package.
.DESCRIPTION
    Test that a specified package is installed.
.PARAMETER Target
    Specifies the Display Name of the package to search for.
.PARAMETER Property
    Specifies an optional property to test for on the package. 
.PARAMETER Should 
    A Script Block defining a Pester Assertion.
.EXAMPLE
    package 'Microsoft Visual Studio Code' { should not BeNullOrEmpty }
.EXAMPLE
    package 'Microsoft Visual Studio Code' version { should be '1.1.0' }
.EXAMPLE
    package 'NonExistentPackage' { should BeNullOrEmpty } 
.NOTES
    Assertions: Be, BeNullOrEmpty
#> 
  
function Package {
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
     
    $expression = {Get-Package -Name "$Target" -ErrorAction SilentlyContinue | Select-Object -First 1}
    
    $params = Get-PoshspecParam -TestName Package -TestExpression $expression @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}
