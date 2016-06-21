$ModuleManifestName = 'poshspec.psd1'
Import-Module $PSScriptRoot\..\$ModuleManifestName

Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $PSScriptRoot\..\$ModuleManifestName
        $? | Should Be $true
    }
}

Describe 'Get-PoshspecParam' {
    InModuleScope PoshSpec {
        Context 'One Parameter' {
            $results = Get-PoshspecParam -TestName MyTest -TestExpression {Get-Item '$Target'} -Target Name -Should { Should Exist }

            It "Should return the correct test Name" {
                $results.Name | Should Be "MyTest 'Name' Should Exist"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Get-Item 'name' | Should Exist"
            }            
        }
        
        Context 'One Parameter with a space' {
            $results = Get-PoshspecParam -TestName MyTest -TestExpression {Get-Item '$Target'} -Target "Spaced Value" -Should { Should Exist }

            It "Should return the correct test Name" {
                $results.Name | Should Be "MyTest 'Spaced Value' Should Exist"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Get-Item 'Spaced Value' | Should Exist"
            }            
        }        
        
        Context 'Two Parameters' {
            $results = Get-PoshspecParam -TestName MyTest -TestExpression {Get-Item '$Target' '$Property'} -Target Name -Property Something -Should { Should Exist }

            It "Should return the correct test Name" {
                $results.Name | Should Be "MyTest property 'Something' for 'Name' Should Exist"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Get-Item 'name' 'Something' | Select-Object -ExpandProperty 'Something' | Should Exist"
            }                
        }
        
        Context 'Three Parameters' {
            $results = Get-PoshspecParam -TestName MyTest -TestExpression {Get-Item '$Target' '$Property' '$Qualifier'} -Target Name -Property Something -Qualifier 1 -Should { Should Exist }

            It "Should return the correct test Name" {
                $results.Name | Should Be "MyTest property 'Something' for 'Name' at '1' Should Exist"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Get-Item 'name' 'Something' '1' | Select-Object -ExpandProperty 'Something' | Should Exist"
            }            
        }        
    }    
}

Describe 'Test Functions' {
    InModuleScope PoshSpec {
        Mock Invoke-PoshspecExpression {return $InputObject}
        
        Context 'Service' {
         
            $results = Service w32time Status { Should Be Running }

            It "Should return the correct test Name" {
                $results.Name | Should Be "Service property 'Status' for 'w32time' Should Be Running"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Get-Service -Name 'w32time' | Select-Object -ExpandProperty 'Status' | Should Be Running"
            }
        }
        
        Context 'File' {

            $results = File C:\inetpub\wwwroot\iisstart.htm { Should Exist }

            It "Should return the correct test Name" {
                $results.Name | Should Be "File 'iisstart.htm' Should Exist"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "'C:\inetpub\wwwroot\iisstart.htm' | Should Exist"
            }
        }
        
        Context 'Registry w/o Properties' {

            $results = Registry HKLM:\SOFTWARE\Microsoft\Rpc\ClientProtocols { Should Exist }
            
            It "Should return the correct test Name" {
                $results.Name | Should Be "Registry 'ClientProtocols' Should Exist"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "'HKLM:\SOFTWARE\Microsoft\Rpc\ClientProtocols' | Should Exist"
            }
        }
        
        Context 'Registry with Properties' {
            
            $results = Registry HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\ "NV Domain" { Should Be mybiz.local  }        
            
            It "Should return the correct test Name" {
                $results.Name | Should Be "Registry property 'NV Domain' for 'Parameters' Should Be mybiz.local"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\' | Select-Object -ExpandProperty 'NV Domain' | Should Be mybiz.local"
            }            
        }
        
        Context 'HTTP' {
            
            $results = Http http://localhost StatusCode { Should Be 200 }
            
            It "Should return the correct test Name" {
                $results.Name | Should Be "Http property 'StatusCode' for 'http://localhost' Should Be 200"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Invoke-WebRequest -Uri 'http://localhost' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'StatusCode' | Should Be 200"
            }            
        }
        
        Context 'TcpPort' {

            $results = TcpPort localhost 80 PingSucceeded { Should Be $true }
            
            It "Should return the correct test Name" {
                $results.Name | Should Be "TcpPort property 'PingSucceeded' for 'localhost' at '80' Should Be `$true"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Test-NetConnection -ComputerName localhost -Port 80 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'PingSucceeded' | Should Be `$true"
            }            
        } 
        
        Context 'Hotfix' {
         
            $results = Hotfix KB1234567 { Should Exist }
            
            It "Should return the correct test Name" {
                $results.Name | Should Be "Hotfix 'KB1234567' Should Exist"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Get-HotFix -Id KB1234567 -ErrorAction SilentlyContinue | Should Exist"
            }
        }
        
        Context 'CimObject w/o Namespace' {
         
            $results = CimObject Win32_OperatingSystem SystemDirectory { Should Be C:\WINDOWS\system32 }

            It "Should return the correct test Name" {
                $results.Name | Should Be "CimObject property 'SystemDirectory' for 'Win32_OperatingSystem' Should Be C:\WINDOWS\system32"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty 'SystemDirectory' | Should Be C:\WINDOWS\system32"
            }
        }        
        Context 'CimObject with Namespace' {
         
            $results = CimObject root/Microsoft/Windows/DesiredStateConfiguration/MSFT_DSCConfigurationStatus Error { Should BeNullOrEmpty }

            It "Should return the correct test Name" {
                $results.Name | Should Be "CimObject property 'Error' for 'MSFT_DSCConfigurationStatus' at 'root/Microsoft/Windows/DesiredStateConfiguration' Should BeNullOrEmpty"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Get-CimInstance -ClassName MSFT_DSCConfigurationStatus -Namespace root/Microsoft/Windows/DesiredStateConfiguration | Select-Object -ExpandProperty 'Error' | Should BeNullOrEmpty"
            }
        } 
        
        Context 'Package' {
            
            $results = Package 'Microsoft Visual Studio Code' { Should Not BeNullOrEmpty }
            
            It 'Should return a correct test name' {
                $results.Name | Should Be "Package 'Microsoft Visual Studio Code' Should Not BeNullOrEmpty"
            }
            
            It 'Should return a correct text expression' {
                $results.Expression | Should Be "Get-Package -Name 'Microsoft Visual Studio Code' -ErrorAction SilentlyContinue | Should Not BeNullOrEmpty"
            }
        }
        
        Context 'Package w/ properties' {
            
            $results = Package 'Microsoft Visual Studio Code' version { Should be '1.1.0' }
            
            It 'Should return a correct test name' {
                $results.Name | Should Be "Package property 'version' for 'Microsoft Visual Studio Code' Should be '1.1.0'"
            }
            
            It 'Should return a correct text expression' {
                $results.Expression | Should Be "Get-Package -Name 'Microsoft Visual Studio Code' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'version' | Should be '1.1.0'"
            }
        }
        
        Context 'LocalGroup' {
            
            $results = LocalGroup 'Administrators' { Should Not BeNullOrEmpty }
            
            It 'Should return a correct test name' {
                $results.Name | Should Be "LocalGroup 'Administrators' Should Not BeNullOrEmpty"
            }
            
            It 'Should return a correct text expression' {
                $results.Expression | Should Be 'Get-CimInstance -ClassName Win32_Group -Filter "Name = ''Administrators''" | Should Not BeNullOrEmpty'
            }
        }
        
        Context 'Interface' {
            $results = Interface ethernet0 { Should Not BeNullOrEmpty }
            
            It 'Should return a correct test name' {
                $results.Name | Should Be "Interface 'ethernet0' Should Not BeNullOrEmpty"
            }
            
            It 'Should return a correct text expression' {
                $results.Expression | Should Be "Get-NetAdapter -Name 'ethernet0' -ErrorAction SilentlyContinue | Should Not BeNullOrEmpty"
            }
        }
        
        Context 'Interface w/ properties' {
            $results = interface ethernet0 status { should be 'up' }
            
            It 'Should return a correct test name' {
                $results.Name | Should Be "Interface property 'status' for 'ethernet0' should be 'up'"
            }
            
            It 'Should return a correct text expression' {
                $results.Expression | Should Be "Get-NetAdapter -Name 'ethernet0' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'status' | Should Be 'up'"
            }
        }
        
        Context 'Folder' {
            $results = Folder $env:ProgramData { should exist }

            It "Should return the correct test Name" {
                $results.Name | Should Be "Folder 'C:\ProgramData' Should Exist"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "'C:\ProgramData' | Should Exist"
            }
        }
        
        Context 'Dnshost' {
            $results = DnsHost www.google.com { should not BeNullOrEmpty }

            It "Should return the correct test Name" {
                $results.Name | Should Be "DnsHost 'www.google.com' Should Not BeNullOrEmpty"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Resolve-DnsName -Name www.google.com -DnsOnly -NoHostsFile -ErrorAction SilentlyContinue | Should Not BeNullOrEmpty"
            }
        }  
             
        Context 'WebSite' {
            $results =    WebSite TestSite state { Should be 'Started' }

            It "Should return the correct test Name" {
                $results.Name | Should Be "WebSite property 'state' for 'TestSite' Should be 'Started'"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Get-WebSite -Name 'TestSite' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'state' | Should be 'Started'"
            }
        } 
              
        Context 'WebSiteBinding' {
            $results = WebSiteBinding TestSite http protocol { Should be 'http' }

            It "Should return the correct test Name" {
                $results.Name | Should Be "WebSiteBinding property 'protocol' for 'TestSite' at 'http' Should be 'http'"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Get-WebBinding -Name 'TestSite' -protocol 'http' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'protocol' | Should be 'http'"
            }
        }             
        Context 'AppPoolState' {
            $results = AppPoolState TestSite { Should be 'Started' }

            It "Should return the correct test Name" {
                $results.Name | Should Be "AppPoolState property 'Value' for 'TestSite' Should be 'Started'"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Get-WebAppPoolState -Name 'TestSite' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'Value' | Should be 'Started'"
            }
        } 
              
        Context 'CheckAppPool' {
            $results = CheckAppPool TestSite { Should be $true }

            It "Should return the correct test Name" {
                $results.Name | Should Be "CheckAppPool 'TestSite' Should be `$true"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Test-Path -Path `"IIS:\AppPools\TestSite`" -ErrorAction SilentlyContinue | Should be `$true"
            }
        }

        Context 'WebSiteState' {
            $results = WebSiteState TestSite { Should be 'Started'}

            It "Should return the correct test Name" {
                $results.Name | Should Be "WebSiteState property 'value' for 'TestSite' Should be 'Started'"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Get-WebSiteState -Name 'TestSite' -ErrorAction SilentlyContinue | Select-Object -expandproperty 'Value' | Should be 'Started'"
            }
        }
                      
                      
        Context 'Firewall' {
            $results =    Firewall putty.exe Action { Should be 'Allow' }

            It "Should return the correct test Name" {
                $results.Name | Should Be "Firewall property 'Action' for 'putty.exe' Should be 'Allow'"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Get-NetFirewallRule -DisplayName 'putty.exe' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'Action' | Should be 'Allow'"
            }
        }
        
        
        Context 'SoftwareProduct' {
            
            $results = SoftwareProduct 'Microsoft .NET Framework 4.6.1' { Should Exist }

            It "Should return the correct test Name" {
                $results.Name | Should Be "SoftwareProduct 'Microsoft .NET Framework 4.6.1' Should Exist"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Get-ItemProperty -Path hklm:\\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object DisplayName -Match 'Microsoft .NET Framework 4.6.1' | Should Exist"
            }
        }
        
        Context 'SoftwareProduct w/Property' {
            
            $results = SoftwareProduct 'Microsoft .NET Framework 4.6.1' DisplayVersion { Should Be 4.6.01055 }

            It "Should return the correct test Name" {
                $results.Name | Should Be "SoftwareProduct property 'DisplayVersion' for 'Microsoft .NET Framework 4.6.1' Should Be 4.6.01055"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Get-ItemProperty -Path hklm:\\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object DisplayName -Match 'Microsoft .NET Framework 4.6.1' | Select-Object -ExpandProperty 'DisplayVersion' | Should Be 4.6.01055"
            }
        }
        
        Context 'Volume' {
            
            $results = Volume C HealthStatus { Should be 'Healthy' }

            It "Should return the correct test Name" {
                $results.Name | Should Be "Volume property 'HealthStatus' for 'C' Should be 'Healthy'"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Get-Volume -DriveLetter 'C' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'HealthStatus' | Should Be 'Healthy'"
            }
        }
        
        Context 'PhysicalDisk' {
            
            $results = PhysicalDisk physicalDisk0 HealthStatus { Should be 'Healthy' }

            It "Should return the correct test Name" {
                $results.Name | Should Be "PhysicalDisk property 'HealthStatus' for 'physicalDisk0' Should be 'Healthy'"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Get-PhysicalDisk -FriendlyName 'physicaldisk0' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'HealthStatus' | Should Be 'Healthy'"
            }
        }
    }
}

Remove-Module Poshspec
