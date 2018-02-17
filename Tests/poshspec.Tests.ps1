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
        Mock Get-PoshSpecCCMHealth { 
            $Result = [PSCustomObject]@{ 
                Test = "CCM Agent health check";
                Result = "Passed";
                EvaluationTime = (Get-Date);
            }    
            return $Result     
        }        

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
                $results.Expression | Should Be "Invoke-WebRequest -Uri 'http://localhost' -UseBasicParsing -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'StatusCode' | Should Be 200"
            }
        }

        Context 'TcpPort' {

            $results = TcpPort localhost 80 PingSucceeded { Should Be $True }

            It "Should return the correct test Name" {
                $results.Name | Should Be "TcpPort property 'PingSucceeded' for 'localhost' at '80' Should Be `$True"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Test-NetConnection -ComputerName localhost -Port 80 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'PingSucceeded' | Should Be $True"
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

        Context 'CimObject with PropertyExpression' {

            $results = CimObject 'root/Microsoft/Windows/TaskScheduler/MSFT_ScheduledTask' 'Where({$_.TaskName -match "xbl"}).Count' {Should be '2'}

            It "Should return the correct test Name" {
                $results.Name | Should Be "CimObject property 'Count' for 'MSFT_ScheduledTask' at 'Where({`$_.TaskName -match `"xbl`"})' Should be '2'"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "(Get-CimInstance -ClassName MSFT_ScheduledTask -Namespace root/Microsoft/Windows/TaskScheduler).Where({`$_.TaskName -match `"xbl`"}).Count | Should be '2'"
            }
        }

        Context 'Package' {

            $results = Package 'Microsoft Visual Studio Code' { should exist }

            It 'Should return a correct test name' {
                $results.Name | Should Be "Package 'Microsoft Visual Studio Code' should exist"
            }

            It 'Should return a correct text expression' {
                $results.Expression | Should Be 'Get-Package -Name "Microsoft Visual Studio Code" -ErrorAction SilentlyContinue | Select-Object -First 1 | should exist'
            }
        }

        Context 'Package w/ properties' {

            $results = Package 'Microsoft Visual Studio Code' version { Should be '1.1.0' }

            It 'Should return a correct test name' {
                $results.Name | Should Be "Package property 'version' for 'Microsoft Visual Studio Code' Should be '1.1.0'"
            }

            It 'Should return a correct text expression' {
                $results.Expression | Should Be "Get-Package -Name ""Microsoft Visual Studio Code"" -ErrorAction SilentlyContinue | Select-Object -First 1 | Select-Object -ExpandProperty 'version' | Should be '1.1.0'"
            }
        }

        Context 'Package w/Single Quotes' {

            $results = Package "Name 'subname'" { should exist }

            It 'Should return a correct test name' {
                $results.Name | Should Be "Package 'Name 'subname'' should exist"
            }

            It 'Should return a correct text expression' {
                $results.Expression | Should Be "Get-Package -Name ""Name 'subname'"" -ErrorAction SilentlyContinue | Select-Object -First 1 | should exist"
            }
        }

        Context 'LocalGroup' {

            $results = LocalGroup 'Administrators' { should exist }

            It 'Should return a correct test name' {
                $results.Name | Should Be "LocalGroup 'Administrators' should exist"
            }

            It 'Should return a correct text expression' {
                $results.Expression | Should Be 'Get-CimInstance -ClassName Win32_Group -Filter "Name = ''Administrators''" | should exist'
            }
        }

        Context 'Share' {

            $results = Share 'MyShare' { should exist }

            It 'Should return a correct test name' {
                $results.Name | Should Be "Share 'MyShare' should exist"
            }

            It 'Should return a correct text expression' {
                $results.Expression | Should Be 'Get-CimInstance -ClassName Win32_Share -Filter "Name = ''MyShare''" | should exist'
            }
        }

        Context 'Interface' {
            $results = Interface ethernet0 { should exist }

            It 'Should return a correct test name' {
                $results.Name | Should Be "Interface 'ethernet0' should exist"
            }

            It 'Should return a correct text expression' {
                $results.Expression | Should Be "Get-NetAdapter -Name 'ethernet0' -ErrorAction SilentlyContinue | should exist"
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
            $results = DnsHost www.google.com { should exist }

            It "Should return the correct test Name" {
                $results.Name | Should Be "DnsHost 'www.google.com' should exist"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Resolve-DnsName -Name www.google.com -DnsOnly -NoHostsFile -ErrorAction SilentlyContinue | should exist"
            }
        }

        Context 'WebSite' {
            $results = WebSite TestSite { Should be 'Started' }

            It "Should return the correct test Name" {
                $results.Name | Should Be "WebSite property 'State' for 'TestSite' Should be 'Started'"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Get-IISSite -Name 'TestSite' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'State' | Should be 'Started'"
            }
        }

        Context 'WebSite with non-default Property' {
          $results = WebSite TestSite ManagedPipelineMode { Should be 'Integrated' }
          It "Should return the correct test Name" {
            $results.Name | Should Be "WebSite property 'ManagedPipelineMode' for 'TestSite' Should be 'Integrated'"
          }

          It "Should return the correct test Expression" {
            $results.Expression | Should Be "Get-IISSite -Name 'TestSite' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'ManagedPipelineMode' | Should be 'Integrated'"
          }
        }

        Context 'WebSite with nested Property' {
          $results = WebSite TestSite 'Applications["/"].Path' { Should be '/' }
          It "Should return the correct test Name" {
            $results.Name | Should Be "WebSite property 'Path' for 'TestSite' at 'Applications[`"/`"]' Should be '/'"
          }

          It "Should return the correct test Expression" {
            $results.Expression | Should Be "(Get-IISSite -Name 'TestSite' -ErrorAction SilentlyContinue).Applications[`"/`"].Path | Should be '/'"
          }
        }

        Context 'WebSite with Method Invocation' {
          $results = WebSite TestSite 'Bindings.Count' { Should be '1' }
          It "Should return the correct test Name" {
            $results.Name | Should Be "WebSite property 'Count' for 'TestSite' at 'Bindings' Should be '1'"
          }

          It "Should return the correct test Expression" {
            $results.Expression | Should Be "(Get-IISSite -Name 'TestSite' -ErrorAction SilentlyContinue).Bindings.Count | Should be '1'"
          }
        }
        Context 'AppPool' {
            $results = AppPool TestSite { Should be 'Started' }

            It "Should return the correct test Name" {
                $results.Name | Should Be "AppPool property 'State' for 'TestSite' Should be 'Started'"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Get-IISAppPool -Name 'TestSite' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'State' | Should be 'Started'"
            }
        }

        Context 'AppPool with non-default Property' {
          $results = AppPool TestSite ManagedPipelineMode { Should be 'Integrated' }
          It "Should return the correct test Name" {
            $results.Name | Should Be "AppPool property 'ManagedPipelineMode' for 'TestSite' Should be 'Integrated'"
          }

          It "Should return the correct test Expression" {
            $results.Expression | Should Be "Get-IISAppPool -Name 'TestSite' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'ManagedPipelineMode' | Should be 'Integrated'"
          }
        }

        Context 'AppPool with nested Property' {
          $results = AppPool TestSite ProcessModel.IdentityType { Should be 'ApplicationPoolIdentity' }
          It "Should return the correct test Name" {
            $results.Name | Should Be "AppPool property 'IdentityType' for 'TestSite' at 'ProcessModel' Should be 'ApplicationPoolIdentity'"
          }

          It "Should return the correct test Expression" {
            $results.Expression | Should Be "(Get-IISAppPool -Name 'TestSite' -ErrorAction SilentlyContinue).ProcessModel.IdentityType | Should be 'ApplicationPoolIdentity'"
          }
        }

        Context 'AppPool with Method Invocation' {
          $results = AppPool TestSite 'ToString()' { Should be 'Microsoft.Web.Administration.ApplicationPool' }
          It "Should return the correct test Name" {
            $results.Name | Should Be "AppPool property 'ToString()' for 'TestSite' Should be 'Microsoft.Web.Administration.ApplicationPool'"
          }

          It "Should return the correct test Expression" {
            $results.Expression | Should Be "(Get-IISAppPool -Name 'TestSite' -ErrorAction SilentlyContinue).ToString() | Should be 'Microsoft.Web.Administration.ApplicationPool'"
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
                $results.Expression | Should Be "@('HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\\Software\Microsoft\Windows\CurrentVersion\Uninstall\*') | Where-Object { Test-Path $_ } | Get-ItemProperty | Where-Object DisplayName -Match 'Microsoft .NET Framework 4.6.1' | Should Exist"
            }
        }

        Context 'SoftwareProduct w/Property' {

            $results = SoftwareProduct 'Microsoft .NET Framework 4.6.1' DisplayVersion { Should Be 4.6.01055 }

            It "Should return the correct test Name" {
                $results.Name | Should Be "SoftwareProduct property 'DisplayVersion' for 'Microsoft .NET Framework 4.6.1' Should Be 4.6.01055"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "@('HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\\Software\Microsoft\Windows\CurrentVersion\Uninstall\*') | Where-Object { Test-Path $_ } | Get-ItemProperty | Where-Object DisplayName -Match 'Microsoft .NET Framework 4.6.1' | Select-Object -ExpandProperty 'DisplayVersion' | Should Be 4.6.01055"
            }
        }

        Context 'Volume' {

            $results = Volume 'C' DriveType { Should Be 'Fixed' }

            It "Should return the correct test Name" {
                $results.Name | Should Be "Volume property 'DriveType' for 'C' Should Be 'Fixed'"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "GetVolume -Name 'C' | Select-Object -ExpandProperty 'DriveType' | Should Be 'Fixed'"
            }
        }

        Context 'AuditPolicy' {

            $results = AuditPolicy System 'Security System Extension' { Should Be 'Success' }

            It "Should return the correct test Name" {
                $results.Name | Should Be "AuditPolicy 'Security System Extension' Should Be 'Success'"
            }
            It "Should return the correct test Expression" {
                $results.Expression | Should Be "GetAuditPolicy -Category 'System' -Subcategory 'Security System Extension' | Should Be 'Success'"
            }
        }

        Context 'LocalUser' {

            $results = LocalUser Guest Disabled { Should Be $True }

            It "Should return the correct test Name" {
                $results.Name | Should Be "LocalUser property 'Disabled' for 'Guest' Should Be `$True"
            }
            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Get-CimInstance -ClassName Win32_UserAccount -filter `"LocalAccount=True AND Name='Guest'`" | Select-Object -ExpandProperty 'Disabled' | Should Be $True"
            }
        }

        Context 'UserRightsAssignment' {
            Mock Test-RunAsAdmin { return $true }
            $results = UserRightsAssignment ByRight 'SeNetworkLogonRight' { Should Be @("BUILTIN\Users","BUILTIN\Administrators") }

            It "Should return the correct test Name" {
                $results.Name | Should Be "UserRightsAssignment 'SeNetworkLogonRight' Should Be @(`"BUILTIN\Users`",`"BUILTIN\Administrators`")"
            }
            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Get-AccountsWithUserRight -Right 'SeNetworkLogonRight' | Select-Object -ExpandProperty Account | Should Be @(`"BUILTIN\Users`",`"BUILTIN\Administrators`")"
            }
        }

        Context 'ServerFeature' {

            $results = ServerFeature 'Telnet-Client' 'Installed' { Should Be $False }

            It "Should return the correct test Name" {
                $results.Name | Should Be "ServerFeature property 'Installed' for 'Telnet-Client' Should Be `$False"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "GetFeature -Name Telnet-Client | Select-Object -ExpandProperty 'Installed' | Should be $False"
            }
        }

        Context 'Bitlocker' {

            $results = Bitlocker VolumeStatus { Should Be 'FullyEncrypted' }

            It "Should return the correct test Name" {
                $results.Name | Should Be "Bitlocker 'VolumeStatus' Should Be 'FullyEncrypted'"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Get-BitlockerVolume VolumeStatus | Select-Object -ExpandProperty  | Should Be 'FullyEncrypted'"
            }
        }

        Context 'BranchCache' {

            $results = BranchCache CurrentClientMode  { Should Be 'Enabled' }

            It "Should return the correct test Name" {
                $results.Name | Should Be "BranchCache 'CurrentClientMode' Should Be 'Enabled'"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Get-BCClientConfiguration | Select-Object -ExpandProperty CurrentClientMode | Should Be 'Enabled'"
            }
        }

        Context 'MachinePolicy' {

            $results = MachinePolicy 'VeryImportantGPO-1' { should not BeNullOrEmpty }

            It "Should return the correct test Name" {
                $results.Name | Should Be "GroupPolicy 'VeryImportantGPO-1' should not BeNullOrEmpty"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Get-CimInstance -ClassName RSOP_GPO -Namespace root/RSOP/Computer -Filter 'Name = `"VeryImportantGPO-1`" and Enabled = true and accessDenied = false`' | should not BeNullOrEmpty"
            }
        }

        Context 'Driver' {

            $results = Driver 'Audio Driver' DriverVersion { Should Be 13.0.1100.286  }

            It "Should return the correct test Name" {
                $results.Name | Should Be "Driver property 'DriverVersion' for 'Audio Driver' Should Be 13.0.1100.286"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Get-WmiObject Win32_PnPSignedDriver | Where-Object DeviceName -Like 'Audio Driver' | Select-Object -ExpandProperty 'DriverVersion' | Should Be 13.0.1100.286"
            }
        }

        Context 'MalwareProtection' {

            $results = MalwareProtection AntispywareEnabled { Should Be True }

            It "Should return the correct test Name" {
                $results.Name | Should Be "MalwareProtection 'AntispywareEnabled' Should Be True"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Get-MpComputerStatus | Select-Object -ExpandProperty AntispywareEnabled | Should Be True"
            }
        }

        Context 'PSModule' {

            $results = PSModule 'WorkplaceValidation' { Should Exist }

            It "Should return the correct test Name" {
                $results.Name | Should Be "PSModule 'WorkplaceValidation' Should Exist"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "Get-Module -Name WorkplaceValidation -ListAvailable -ErrorAction SilentlyContinue | Select-Object -First 1 | Select-Object -ExpandProperty 'Path' | should not benullorempty"
            }
        }

        Context 'CCMHealthCheck' {

            $results = CCMHealthCheck { Should Be 'Passed' }

            It "Should return the correct test Name" {
                $results.Name | Should Be "has CCM Client Check 'CCM Agent health check' result 'Passed'"
            }

            It "Should return the correct test Expression" {
                $results.Expression | Should Be "'Passed' | Should Be 'Passed'"
            }
        }

    }
}

Remove-Module Poshspec
