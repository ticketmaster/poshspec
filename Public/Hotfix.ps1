 <#
.SYNOPSIS
    Test if a Hotfix is installed.
.DESCRIPTION
    Test if a Hotfix is installed.
.PARAMETER Target
    The Hotfix ID. Eg KB1112233
.PARAMETER Should 
    A Script Block defining a Pester Assertion.  
.EXAMPLE
    Hotfix KB3116900 { Should Not BeNullOrEmpty}
.EXAMPLE
    Hotfix KB1112233 { Should BeNullOrEmpty}
.NOTES
    Assertions: BeNullOrEmpty
#>
   function Hotfix {
    [CmdletBinding()]
    param(
        
        [Parameter(Mandatory,Position=1)]
        [Alias("Id")]
        [string]$Target,

        [Parameter(Mandatory, Position=2)]
        [scriptblock]$Should
    )
     
    $params = Get-PoshspecParam -TestName Hotfix -TestExpression {Get-HotFix -Id $Target -ErrorAction SilentlyContinue} @PSBoundParameters
    
    Invoke-PoshspecExpression @params     
}
