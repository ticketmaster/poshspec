<#
.SYNOPSIS
    WebSiteBinding Settings
.DESCRIPTION
    Used To Determine if Website is Running Desired Settings
.PARAMETER Target
    The name of the Web Site to be Tested
.PARAMETER Qualifier
 The  qualifier to be used to further specify the test [http or https]
.PARAMETER Property
    The name of the Property of the Web Site to be Tested
.PARAMETER Should 
    A Script Block defining a Pester Assertion.  
.EXAMPLE           
   WebSite TestSite http protocol { Should be "http" }
.EXAMPLE           
   WebSite TestSite https bindingInformation { Should match '443' }
 .EXAMPLE           
   WebSite TestSite https sslFlags { Should be 1 }
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