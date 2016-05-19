 <#
.SYNOPSIS
    Test a local network interface.
.DESCRIPTION
    Test a local network interface and optionally and specific property.
.PARAMETER Target
    Specifies the name of the network adapter to search for.
.PARAMETER Property
    Specifies an optional property to test for on the adapter. 
.PARAMETER Should 
    A Script Block defining a Pester Assertion.
.EXAMPLE
    interface ethernet0 { should not BeNullOrEmpty }
.EXAMPLE
    interface ethernet0 status { should be 'up' }
.EXAMPLE
    Interface Ethernet0 linkspeed { should be '1 gbps' } 
.EXAMPLE
    Interface Ethernet0 macaddress { should be '00-0C-29-F2-69-DD' }
.NOTES
    Assertions: Be, BeNullOrEmpty
#>
function Interface {
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
   
    $expression = {Get-NetAdapter -Name '$Target' -ErrorAction SilentlyContinue}

    $params = Get-PoshspecParam -TestName Interface -TestExpression $expression @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}
