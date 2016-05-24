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
   WebSite TestSite protocol { Should be "http" }
.EXAMPLE           
   WebSite TestSite bindingInformation { Should match '80' }
 .EXAMPLE           
   WebSite TestSite sslFlags { Should be 0 }
.NOTES
    Assertions: Match, Be
#>
    function WebSiteBinding{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=1)]
        [Alias('Name')]
        [string]$Target,
        
        [Parameter(Position=2)]
        [ValidateSet("http","https")]
        [string]$Qualifier,
        
        [Parameter(Position=3)]
        [ValidateSet("sslFlags","protocol","bindingInformation")]
        [string]$Property,

        [Parameter(Mandatory, Position=4)]
        [scriptblock]$Should
    )
    
            $expression = {Get-WebBinding -Name '$Target' -protocol '$Qualifier' -ErrorAction SilentlyContinue }

            $params = Get-PoshspecParam -TestName WebSiteBinding -TestExpression $expression @PSBoundParameters
            
            Invoke-PoshspecExpression @params
}