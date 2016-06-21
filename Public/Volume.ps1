 <#
.SYNOPSIS
    Test the volume specified 
.DESCRIPTION
    Can be specified to target a specific volume for testing
.PARAMETER Target
    Specifies the Drive Letter of the volume to test
.PARAMETER Property
    Specifies an optional property to test for on the volume
.PARAMETER Should 
    A Script Block defining a Pester Assertion.
.EXAMPLE
 Volume C HealthStatus { Should be 'Healthy' }
.EXAMPLE
 Volume C FileSystem { Should be 'NTFS' }

.NOTES
    Assertions: Be
#> 
  
function Volume {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=1)]
        [Alias('Name')]
        [string]$Target,
        
        [Parameter(Position=2)]
        [ValidateSet("FileSystem","DriveType","HealthStatus","SizeRemaining","size")]
        [string]$Property,

        [Parameter(Mandatory, Position=3)]
        [scriptblock]$Should
    )
     
    $expression = {Get-Volume -DriveLetter '$Target' -ErrorAction SilentlyContinue}
    
    $params = Get-PoshspecParam -TestName Volume -TestExpression $expression @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}
