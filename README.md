# PoshSpec
An infrastructure testing DSL running in Pester. The goal is to expand the Pester DSL to assist in the development of infrastructure validation scripts.

## Install from the Gallery
```powershell
PS> Install-Module -Name poshspec
```

## Documentation 
[Wiki](https://github.com/Ticketmaster/poshspec/wiki/Introduction)

Describe 'WebSite' {
   WebSite TestSite protocol { Should be "http" }
   WebSite TestSite bindingInformation { Should match '80' }
   WebSite TestSite sslFlags { Should be 0 }
   WebSite TestSite state { Should be 'Started' }
   Website TestSite physicalPath { Should be 'C:\IIS\Files\TestSite' } 
   CheckAppPool TestSite { Should be $True}
   AppPoolState TestSite { Should be Started } 
}