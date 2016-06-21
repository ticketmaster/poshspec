 <#
.SYNOPSIS
    Test for physical disks on machine
.DESCRIPTION
    Test for physical disk health and storage
.PARAMETER Target
    Specifies the friendly name of the physical disk
.PARAMETER Property
    Specifies an optional property to test for on the physical disk.
.PARAMETER Should 
    A Script Block defining a Pester Assertion.
.EXAMPLE
    PhysicalDisk physicalDisk0 OperationalStatus { Should be 'OK' }
.EXAMPLE
     PhysicalDisk physicalDisk0 HealthStatus { Should be 'Healthy' }
.NOTES
    Assertions: Be, BeNullOrEmpty
#> 
  
function PhysicalDisk {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=1)]
        [Alias('Name')]
        [string]$Target,
        
        [Parameter(Position=2)]
        [ValidateSet("CanPool","OperationalStatus","HealthStatus","Usage","Size")]
        [string]$Property,

        [Parameter(Mandatory, Position=3)]
        [scriptblock]$Should
    )
     
    $expression = {Get-PhysicalDisk -FriendlyName '$Target' -ErrorAction SilentlyContinue}
    
    $params = Get-PoshspecParam -TestName PhysicalDisk -TestExpression $expression @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}
