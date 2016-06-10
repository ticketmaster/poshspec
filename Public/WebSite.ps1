<#
.SYNOPSIS
    WebSite Settings
.DESCRIPTION
    Used To Determine if Website is Running Desired Settings
.PARAMETER Target
    The name of the Web Site to be Tested
.PARAMETER Property
    The name of the Property of the Web Site to be Tested
.PARAMETER Should 
    A Script Block defining a Pester Assertion.  
.EXAMPLE           
   WebSite TestSite state { Should be 'Started' }
.EXAMPLE           
   Website TestSite physicalPath { Should be 'C:\IIS\Files\index.html' } 
.EXAMPLE           
   Website TestSite binding { Should Match '*:80*' } 
.EXAMPLE           
   Website TestSite name { Should be 'testsite' } 
 .EXAMPLE           
   Website TestSite ID { Should be 1 }   
.NOTES
    Assertions: Match, Be
#>
    function WebSite{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=1)]
        [Alias('Name')]
        [string]$Target,
        
        [Parameter(Position=2)]
        [ValidateSet("bindings","name","ID","state","physicalPath")]
        [string]$Property,

        [Parameter(Mandatory, Position=3)]
        [scriptblock]$Should
    )
    
            $expression = {Get-WebSite -Name '$Target' -ErrorAction SilentlyContinue }
            
            $params = Get-PoshspecParam -TestName WebSite -TestExpression $expression @PSBoundParameters
            
            Invoke-PoshspecExpression @params
}