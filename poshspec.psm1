try 
{
    Import-Module Pester
}
catch [Exception]
{
    throw 'The Pester module is required to use this module.'
}

#Private - Test Param Builder Function
function Get-PoshspecParam {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $TestName,
        [Parameter(Mandatory)]
        [string]
        $TestExpression,        
        [Parameter(Mandatory)]
        [string]
        $Target,        
        [Parameter()]
        [string]
        $FriendlyName,            
        [Parameter()]
        [string]
        $Property,
        [Parameter()]
        [string]
        $Qualifier,                   
        [Parameter(Mandatory)]
        [scriptblock]
        $Should
    )
    
    $assertion = $Should.ToString().Trim()

    
    $targetName = $Target

    if ($PSBoundParameters.ContainsKey("FriendlyName"))
    {
        $targetName = $Friendlyname
    }
    
    $tokens = [System.Management.Automation.PSParser]::Tokenize($TestExpression,[ref]$null)
    
    $expandedTokens = foreach ($token in $tokens)
    {
        if ($token.Type -eq 'Variable')
        {
            $variable = Get-Variable $token.Content -ErrorAction SilentlyContinue
            if (-not [string]::IsNullOrEmpty($variable.Value))
            {
                $value = "'" + $variable.Value + "'"
                Write-Output -InputObject $value
            }
            else
            {
                Throw "Could not find a variable in scope by the name '$($token.Content)'"
            }
        }
        else
        {
            if ($token.Type -eq 'String') {
                Write-Output -InputObject ('"' + $token.Content + '"')
            } else {
                if ($token.Type -ne 'NewLine') {
                    Write-Output -InputObject $token.Content
                }
            }
        }
    }
    
    $expressionString = $expandedTokens -join " "
    
    if ($PSBoundParameters.ContainsKey("Property"))
    {
        $expressionString += " | Select-Object -ExpandProperty '$Property'"
        
        if ($PSBoundParameters.ContainsKey("Qualifier"))
        {
            $nameString = "{0} property '{1}' for '{2}' at '{3}' {4}" -f $TestName,$Property, $targetName, $Qualifier, $assertion
        }
        else 
        {
            $nameString = "{0} property '{1}' for '{2}' {3}" -f $TestName, $Property, $targetName, $assertion            
        }        
    }
    else 
    {
        $nameString = "{0} '{1}' {2}" -f $TestName, $targetName, $assertion
    }
        
    $expressionString += " | $assertion"
    
    Write-Output -InputObject ([PSCustomObject]@{Name = $nameString; Expression = $expressionString})
}

#Private - Build the It scriptblock based on parameters from Get-PoshspecParam
function Invoke-PoshspecExpression {
    [CmdletBinding()]
    param(
        # Poshspec Param Object
        [Parameter(Mandatory, Position=0)]
        [PSCustomObject]
        $InputObject
    )
    
    It $InputObject.Name {
        Invoke-Expression $InputObject.Expression
    }    
}

<#
.SYNOPSIS
    Test a Service.
.DESCRIPTION
    Test the Status of a given Service.
.PARAMETER Name
    Specifies the service names of service.
.PARAMETER Should 
    A Script Block defining a Pester Assertion.   
.EXAMPLE
    Service w32time { Should Be Running }
.EXAMPLE
    Service bits { Should Be Stopped }
.NOTES
    Only validates the Status property. Assertions: Be
#>
function Service {
    [CmdletBinding()]
    param( 
        [Parameter(Mandatory, Position=1)]
        [Alias("Name")]
        [string]$Target,

        [Parameter(Mandatory, Position=2)]
        [string]$Property,

        [Parameter(Mandatory, Position=3)]
        [scriptblock]$Should
    )
    
    $params = Get-PoshspecParam -TestName Service -TestExpression {Get-Service -Name $Target} @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}

<#
.SYNOPSIS
    Test a File.
.DESCRIPTION
    Test the Existance or Contents of a File..
.PARAMETER Path
    Specifies the path to an item.
.PARAMETER Should 
    A Script Block defining a Pester Assertion.       
.EXAMPLE
    File C:\inetpub\wwwroot\iisstart.htm { Should Exist }
.EXAMPLE
    File C:\inetpub\wwwroot\iisstart.htm { Should Contain 'text-align:center' }
.NOTES
    Assertions: Exist and Contain
#>
function File {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=1)]
        [Alias("Path")]
        [string]$Target,
        
        [Parameter(Mandatory, Position=2)]
        [scriptblock]$Should
    )
    
    $name = Split-Path -Path $Target -Leaf
    $params = Get-PoshspecParam -TestName File -TestExpression {$Target} -FriendlyName $name @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}

<#
.SYNOPSIS
    Test a Registry Key.
.DESCRIPTION
    Test the Existance of a Key or the Value of a given Property.
.PARAMETER Path
    Specifies the path to an item.
.PARAMETER Property
    Specifies a property at the specified Path.    
.PARAMETER Should 
    A Script Block defining a Pester Assertion.       
.EXAMPLE
    Registry HKLM:\SOFTWARE\Microsoft\Rpc\ClientProtocols { Should Exist }
.EXAMPLE
    Registry HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\ "NV Domain" { Should Be mybiz.local  }
.EXAMPLE
    Registry 'HKLM:\SOFTWARE\Callahan Auto\' { Should Not Exist }    
.NOTES
    Assertions: Be, BeExactly, Exist, Match, MatchExactly
#>
function Registry {
    [CmdletBinding(DefaultParameterSetName="Default")]
    param(        
        [Parameter(Mandatory, Position=1, ParameterSetName="Default")]
        [Parameter(Mandatory, Position=1, ParameterSetName="Property")]
        [Alias("Path")]
        [string]$Target,
        
        [Parameter(Position=2, ParameterSetName="Property")]
        [string]$Property,
        
        [Parameter(Mandatory, Position=2, ParameterSetName="Default")]
        [Parameter(Mandatory, Position=3, ParameterSetName="Property")]
        [scriptblock]$Should
    )
    
    $name = Split-Path -Path $Target -Leaf
    
    if ($PSBoundParameters.ContainsKey("Property"))
    {
        $expression = {Get-ItemProperty -Path $Target}
    }
    else 
    {
        $expression = {$Target}
    }
    
    $params = Get-PoshspecParam -TestName Registry -TestExpression $expression -FriendlyName $name @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}

<#
.SYNOPSIS
    Test a Web Service.
.DESCRIPTION
    Test that a Web Service is reachable and optionally returns specific content.
.PARAMETER Uri
    Specifies the Uniform Resource Identifier (URI) of the Internet resource to which the web request is sent.
.PARAMETER Property
    Specifies a property of the WebResponseObject object to test. 
.PARAMETER Should 
    A Script Block defining a Pester Assertion.      
.EXAMPLE
    Http http://localhost StatusCode { Should Be 200 }
.EXAMPLE
    Http http://localhost RawContent { Should Match 'X-Powered-By: ASP.NET' }
.EXAMPLE
    Http http://localhost RawContent { Should Not Match 'X-Powered-By: Cobal' } 
.NOTES
    Assertions: Be, BeExactly, Match, MatchExactly
#>
function Http {
    [CmdletBinding()]
    param(        
        [Parameter(Mandatory, Position=1)]
        [Alias("Uri")]
        [string]$Target,
        
        [Parameter(Mandatory, Position=2)]
        [ValidateSet("BaseResponse", "Content", "Headers", "RawContent", "RawContentLength", "RawContentStream", "StatusCode", "StatusDescription")]
        [string]$Property,

        [Parameter(Mandatory, Position=3)]
        [scriptblock]$Should
    )    
    
    $params = Get-PoshspecParam -TestName Http -TestExpression {Invoke-WebRequest -Uri $Target -ErrorAction SilentlyContinue} @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}

<#
.SYNOPSIS
    Test a a Tcp Port.
.DESCRIPTION
    Test that a Tcp Port is listening and optionally validate any TestNetConnectionResult property.
.PARAMETER Address
    Specifies the Domain Name System (DNS) name or IP address of the target computer.
.PARAMETER Port
    Specifies the TCP port number on the remote computer.
.PARAMETER Property
    Specifies a property of the TestNetConnectionResult object to test.  
.PARAMETER Should 
    A Script Block defining a Pester Assertion.  
.EXAMPLE
    TcpPort localhost 80 PingSucceeded  { Should Be $true }
.EXAMPLE
    TcpPort localhost 80 TcpTestSucceeded { Should Be $true }
.NOTES
    Assertions: Be, BeExactly, Match, MatchExactly
#>
function TcpPort {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=1)]
        [Alias("ComputerName")]
        [string]$Target,

        [Parameter(Mandatory, Position=2)]
        [Alias("Port")]
        [string]$Qualifier,
      
        [Parameter(Mandatory, Position=3)]
        [ValidateSet("AllNameResolutionResults", "BasicNameResolution", "ComputerName", "Detailed", "DNSOnlyRecords", "InterfaceAlias", 
            "InterfaceDescription", "InterfaceIndex", "IsAdmin", "LLMNRNetbiosRecords", "MatchingIPsecRules", "NameResolutionSucceeded", 
            "NetAdapter", "NetRoute", "NetworkIsolationContext", "PingReplyDetails", "PingSucceeded", "RemoteAddress", "RemotePort", 
            "SourceAddress", "TcpClientSocket", "TcpTestSucceeded", "TraceRoute")]
        [string]$Property,        
        
        [Parameter(Mandatory, Position=4)]
        [scriptblock]$Should
    )
    
    $params = Get-PoshspecParam -TestName TcpPort -TestExpression {Test-NetConnection -ComputerName $Target -Port $Qualifier -ErrorAction SilentlyContinue} @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}

<#
.SYNOPSIS
    Test if a Hotfix is installed.
.DESCRIPTION
    Test if a Hotfix is installed.
.PARAMETER Id
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
        # 
        [Parameter(Mandatory,Position=1)]
        [Alias("Id")]
        [string]$Target,

        [Parameter(Mandatory, Position=2)]
        [scriptblock]$Should
    )
    
    $params = Get-PoshspecParam -TestName Hotfix -TestExpression {Get-HotFix -Id $Target -ErrorAction SilentlyContinue} @PSBoundParameters
    
    Invoke-PoshspecExpression @params     
}

<#
.SYNOPSIS
    Test the value of a CimObject Property.
.DESCRIPTION
    Test the value of a CimObject Property. The Class can be provided with the Namespace. See Example.
.PARAMETER ClassName
    Specifies the name of the CIM class for which to retrieve the CIM instances. Can be just the ClassName
    in the default namespace or in the form of namespace/className to access other namespaces.
.PARAMETER Property
    Specifies an instance property to retrieve.
.PARAMETER Should 
    A Script Block defining a Pester Assertion.  
.EXAMPLE
    CimObject Win32_OperatingSystem SystemDirectory { Should Be C:\WINDOWS\system32 }
.EXAMPLE
    CimObject root/StandardCimv2/MSFT_NetOffloadGlobalSetting ReceiveSideScaling { Should Be Enabled }
.NOTES
    Assertions: Be, BeExactly, Match, MatchExactly
#>
function CimObject {
    [CmdletBinding()]
    param(              
        [Parameter(Mandatory, Position=1)]
        [Alias("ClassName")]
        [string]$Target,
         
        [Parameter(Mandatory, Position=2)]
        [string]$Property,
        
        [Parameter(Mandatory, Position=3)]
        [scriptblock]$Should
    )
    
  
    $expression = "Get-CimInstance"   

    if ($Target -match '/')
    {
        $lastIndexOfSlash = $Target.LastIndexOf('/')

        $class = $Target.Substring($lastIndexOfSlash + 1)
        $namespace = $Target.Substring(0,$lastIndexOfSlash)

        $PSBoundParameters["Target"] = $class
        $PSBoundParameters.Add("Qualifier", $namespace)
        
        $expression = {Get-CimInstance -ClassName $Target -Namespace $Qualifier}
    }
    else 
    {
        $expression = {Get-CimInstance -ClassName $Target}
    }
        
    $params = Get-PoshspecParam -TestName CimObject -TestExpression $expression @PSBoundParameters
    
    Invoke-PoshspecExpression @params 
}

<#
.SYNOPSIS
    Test for installed package.
.DESCRIPTION
    Test that a specified package is installed.
.PARAMETER Target
    Specifies the Display Name of the package to search for.
.PARAMETER Property
    Specifies an optional property to test for on the package. 
.PARAMETER Should 
    A Script Block defining a Pester Assertion.
.EXAMPLE
    package 'Microsoft Visual Studio Code' { should not BeNullOrEmpty }
.EXAMPLE
    package 'Microsoft Visual Studio Code' version { should be '1.1.0' }
.EXAMPLE
    package 'NonExistentPackage' { should BeNullOrEmpty } 
.NOTES
    Assertions: Be, BeNullOrEmpty
#>
function Package {
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
       
    $expression = {Get-Package -Name $Target -ErrorAction SilentlyContinue}
    
    $params = Get-PoshspecParam -TestName Package -TestExpression $expression @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}

<#
.SYNOPSIS
    Test if a local group exists.
.DESCRIPTION
    Test if a local group exists.
.PARAMETER Id
    The local group name to test for. Eg 'Administrators'
.PARAMETER Should 
    A Script Block defining a Pester Assertion.  
.EXAMPLE
    LocalGroup 'Administrators' { should not BeNullOrEmpty }    
.EXAMPLE
    LocalGroup 'BadGroup' { should BeNullOrEmpty }
.NOTES
    Assertions: BeNullOrEmpty
#>
function LocalGroup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=1)]
        [Alias('Name')]
        [string]$Target,
        
        [Parameter(Mandatory, Position=2)]
        [scriptblock]$Should
    )
    
    $expression = {Get-CimInstance -ClassName Win32_Group -Filter "Name = '$Target'"}
    
    $params = Get-PoshspecParam -TestName LocalGroup -TestExpression $expression @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}

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
    
    $expression = {Get-NetAdapter -Name $Target -ErrorAction SilentlyContinue}

    $params = Get-PoshspecParam -TestName Interface -TestExpression $expression @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}

<#
.SYNOPSIS
    Test if a folder exists.
.DESCRIPTION
    Test if a folder exists.
.PARAMETER Target
    The path of the folder to search for.
.PARAMETER Should 
    A Script Block defining a Pester Assertion.  
.EXAMPLE
    folder $env:ProgramData { should exist }        
.EXAMPLE
    folder C:\badfolder { should not exist }
.NOTES
    Assertions: exist
#>
function Folder {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=1)]
        [Alias('Path')]
        [string]$Target,
        
        [Parameter(Mandatory, Position=2)]
        [scriptblock]$Should
    )
    
    $params = Get-PoshspecParam -TestName Folder -TestExpression {$Target} @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}

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
    
    $params = Get-PoshspecParam -TestName Interface -TestExpression $expression @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}
