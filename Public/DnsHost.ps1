<#
.SYNOPSIS
    Test DNS resolution to a host.
.DESCRIPTION
    Test DNS resolution to a host.
.PARAMETER Target
    The hostname to resolve in DNS.
.PARAMETER Should 
    A Script Block defining a Pester Assertion.  
.EXAMPLE           
    dnshost nonexistenthost.mymadeupdomain.tld { should be $null }        
.EXAMPLE
    dnshost www.google.com { should not be $null }
.NOTES
    Assertions: be
#>
function DnsHost {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=1)]
        [Alias('Name')]
        [string]$Target,
        
        [Parameter(Mandatory, Position=2)]
        [scriptblock]$Should
    )
  
    $expression = {Resolve-DnsName -Name $Target -DnsOnly -NoHostsFile -ErrorAction SilentlyContinue}
    
    $params = Get-PoshspecParam -TestName DnsHost -TestExpression $expression @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}