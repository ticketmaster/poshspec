<#
.SYNOPSIS
    Test if a GroupPolicy is present on the client
.DESCRIPTION
    Test if a GroupPolicy is present on the client
.PARAMETER Target
    the group policy name to be checked.
.PARAMETER Should 
    A Script Block defining a Pester Assertion.  
.EXAMPLE
    MachinePolicy 'VeryImportantGPO-1' { should not BeNullOrEmpty }    
.NOTES
    Assertions: BeNullOrEmpty
#>
    
function MachinePolicy {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=1)]
        [Alias('Name')]
        [string]$Target,
        
        [Parameter(Mandatory, Position=2)]
        [scriptblock]$Should
    )

    Process {

        $expression = { Get-CimInstance -ClassName RSOP_GPO -Namespace root/RSOP/Computer -Filter 'Name = "$Target" and Enabled = true and accessDenied = false' }
        
        $params = Get-PoshspecParam -TestName GroupPolicy -TestExpression $expression @PSBoundParameters
        
        Invoke-PoshspecExpression @params
    
    }
}