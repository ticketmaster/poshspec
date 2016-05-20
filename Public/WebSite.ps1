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
.EXAMPLE           
   WebSite TestSite state { Should be 'Started' }
.EXAMPLE           
   Website TestSite physicalPath { Should be 'C:\IIS\Files\index.html' } 
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
        [ValidateSet("sslFlags","protocol","bindingInformation","state","physicalPath")]
        [string]$Property,
        
        [Parameter(Mandatory, Position=3)]
        [scriptblock]$Should
    )
    
    switch ($Property){
        protocol{
            $expression = {Get-WebBinding -Name '$Target' -ErrorAction SilentlyContinue }
            $params = Get-PoshspecParam -TestName WebSite -TestExpression $expression @PSBoundParameters
                
            Invoke-PoshspecExpression @params 
        }
        state{
            $expression = {Get-WebSite -Name '$Target' -ErrorAction SilentlyContinue }
            
            $params = Get-PoshspecParam -TestName WebSite -TestExpression $expression @PSBoundParameters
            
            Invoke-PoshspecExpression @params
        }
        bindingInformation{
            $expression = {Get-WebBinding -Name '$Target' -ErrorAction SilentlyContinue }
            
            $params = Get-PoshspecParam -TestName WebSite -TestExpression $expression @PSBoundParameters
            
            Invoke-PoshspecExpression @params
        }
        physicalPath{
            $expression = {Get-WebSite -Name '$Target' -ErrorAction SilentlyContinue }
            
            $params = Get-PoshspecParam -TestName WebSite -TestExpression $expression @PSBoundParameters
            
            Invoke-PoshspecExpression @params
        }
        sslFlags{
            $expression = {Get-WebBinding -Name '$Target' -ErrorAction SilentlyContinue }
            
            $params = Get-PoshspecParam -TestName WebSite -TestExpression $expression @PSBoundParameters
            
            Invoke-PoshspecExpression @params
        }      
    }

}