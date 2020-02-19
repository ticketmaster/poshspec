<#
.SYNOPSIS
    Tests ping capability
.DESCRIPTION
    Test that a remote system is pingable and also that the remote system is allowing ping packets.
.PARAMETER Target
    Specifies the Domain Name System (DNS) name or IP address of the target computer.
.PARAMETER Property
    Specifies a property of the TestNetConnectionResult object to test.  
.PARAMETER Should 
    A Script Block defining a Pester Assertion.  
.EXAMPLE
    Ping localhost PingSucceeded  { Should Be $true }
.EXAMPLE
    Ping remoteserver PingSucceeded { Should Be $true }
.NOTES
    Assertions: Be, BeExactly, Match, MatchExactly
#>
    function Ping {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=1)]
        [Alias("ComputerName")]
        [string]$Target,
      
        [Parameter(Mandatory, Position=2)]
        [ValidateSet("AllNameResolutionResults", "BasicNameResolution", "ComputerName", "Detailed", "DNSOnlyRecords", "InterfaceAlias", 
            "InterfaceDescription", "InterfaceIndex", "IsAdmin", "LLMNRNetbiosRecords", "MatchingIPsecRules", "NameResolutionSucceeded", 
            "NetAdapter", "NetRoute", "NetworkIsolationContext", "PingReplyDetails", "PingSucceeded", "RemoteAddress", "RemotePort", 
            "SourceAddress", "TcpClientSocket", "TcpTestSucceeded", "TraceRoute")]
        [string]$Property,        
        
        [Parameter(Mandatory, Position=3)]
        [scriptblock]$Should
    )

    $params = Get-PoshspecParam -TestName TcpPort -TestExpression {Test-NetConnection -ComputerName $Target -ErrorAction SilentlyContinue} @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}