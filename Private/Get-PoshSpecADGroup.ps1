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

    $groups = SearchAd -Name $Name -ObjectType 'Group'
    foreach ($g in $groups) 
    {   
        $group = [adsi]$g.path
        $groupType = [string]$group.groupType

        [pscustomobject]@{
            SamAccountName  = [string]$group.sAMAccountName
            Name            = [string]$group.name
            Scope           = $groupTypes[[int]$groupType].Scope
            Type            = $groupTypes[[int]$groupType].Type
        }
    }
}