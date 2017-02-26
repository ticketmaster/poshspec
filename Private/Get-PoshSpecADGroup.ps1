function Get-PoshSpecADGroup {
    [CmdletBinding()]
    param( 
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    $groupTypes = @{
        -2147483646 = @{
            Scope = 'Global'
            Type = 'Security'
        }
        -2147483644 = @{
            Scope = 'DomainLocal'
            Type = 'Security'
        }
        -2147483643 = @{
            Scope = 'Global'
            Type = 'Security'
        }
        -2147483640 = @{
            Scope = 'Universal'
            Type = 'Security'
        }
        2 = @{
            Scope = 'Global'
            Type = 'Distribution'
        }
        4 = @{
            Scope = 'DomainLocal'
            Type = 'Distribution'
        }
        8 = @{
            Scope = 'Universal'
            Type = 'Distribution'
        }
    }

    $groups = SearchAd -Name $Name
    foreach ($group in $groups) 
    {   
        $type = (([hashtable]$group.Properties).getenumerator() | where {$_.Key -eq 'groupType'}).value
        [pscustomobject]@{
            SamAccountName  = $group.sAMAccountName
            Name            = $group.name
            Scope           = $groupTypes[$type].Scope
            Type            = $groupTypes[$type].Type
        }
    }
}

function SearchAd {
    param($Name)

    $searcher = [adsisearcher]"(&(objectClass=group)(objectCategory=group)(name=$Name))"
    $searcher.FindAll()
}