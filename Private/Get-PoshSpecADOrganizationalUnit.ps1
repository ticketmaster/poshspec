function Get-PoshSpecADOrganizationalUnit {
    [CmdletBinding()]
    param( 
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    $ous = SearchAd -Name $Name -ObjectType 'OrganizationalUnit'
    foreach ($o in $ous) 
    {   
        $ou = ([hashtable]$o.Properties).getenumerator()
        [pscustomobject]@{
            Name  = [string]($ou | where {$_.Key -eq 'ou'}).value
            Path  = $o.Path.TrimStart('LDAP://')
        }
    }
}