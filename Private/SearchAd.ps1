function SearchAd {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('User','Group','OrganizationalUnit')]
        [string]$ObjectType
    )

    $searchString = switch ($ObjectType) {
        'Group' {
            "(&(objectClass=group)(objectCategory=group)(name=$Name))"
        }
        'User' {
            "(&(objectClass=person)(name=$Name))"
        }
        'OrganizationalUnit' {
            "(&(objectClass=organizationalUnit)(name=$Name))"
        }
        Default {}
    }
    $searcher = [adsisearcher]$searchString
    $searcher.FindAll()
}