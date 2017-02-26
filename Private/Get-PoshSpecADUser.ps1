function Get-PoshSpecADUser {
    [CmdletBinding()]
    param( 
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    $ACCOUNTDISABLE       = 0x000002
    $DONT_EXPIRE_PASSWORD = 0x010000
    $PASSWORD_EXPIRED     = 0x800000
    
    $users = SearchAd -Name $Name
    foreach ($user in $users) 
    {   
        [pscustomobject]@{
            SamAccountName       = $user.sAMAccountName
            Name                 = $user.name
            GivenName            = $user.givenName
            SurName              = $user.surName
            Mail                 = $user.mail
            Enabled              = -not [bool]($user.userAccountControl -band $ACCOUNTDISABLE)
            PasswordNeverExpires = [bool]($user.userAccountControl -band $DONT_EXPIRE_PASSWORD)
            PasswordExpired      = [bool]($user.userAccountControl -band $PASSWORD_EXPIRED)
        }
    }
}

function SearchAd {
    param($Name)

    $searcher = [adsisearcher]"(&(objectClass=user)(objectCategory=person)(Name=$Name))"
    $searcher.FindAll()
}