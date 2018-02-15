 <#
.SYNOPSIS
    Test for installed powershell modules.
.DESCRIPTION
    Test that a specified powershell module is installed.
.PARAMETER Target
    Specifies the Name of the powershell module to search for.
.PARAMETER Property
    Specifies an optional property to test for on the module. 
.PARAMETER Should 
    A Script Block defining a Pester Assertion.
.EXAMPLE
    PSModule 'WorkplaceValidation' { Should Exist }
.EXAMPLE
    PSModule 'WorkplaceValidation' Version { Should BeGreaterThan '1.0.0.0' }
.NOTES
    Assertions: Be, BeNullOrEmpty, Exist, BeGreaterThan
#> 
  
function PSModule {
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
     
     if (-not $Property) {
        $expression = {Get-Module -Name $Target -ListAvailable -ErrorAction SilentlyContinue | Select-Object -First 1 | Select-Object -ExpandProperty 'Path'}
     } else { 
        $expression = {Get-Module -Name $Target -ListAvailable -ErrorAction SilentlyContinue | Select-Object -First 1 }
     }
    
    $params = Get-PoshspecParam -TestName PSModule -TestExpression $expression @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}
