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
    
    $users = SearchAd -Name $Name -ObjectType 'User'
    foreach ($user in $users) 
    {   
        $output = @{
            SamAccountName       = $user.sAMAccountName
            Name                 = $user.name
            GivenName            = $user.givenName
            SurName              = $user.surName
            Mail                 = $user.mail
            Department           = [string]([adsi]$user.path).department
            Enabled              = -not [bool]($user.userAccountControl -band $ACCOUNTDISABLE)
            PasswordNeverExpires = [bool]($user.userAccountControl -band $DONT_EXPIRE_PASSWORD)
            PasswordExpired      = [bool]($user.userAccountControl -band $PASSWORD_EXPIRED)
        }

        $pathSplit = $user.path.TrimStart('LDAP://') -split ','
        $output.OrganizationalUnit = $pathSplit[1..$pathSplit.Length] -join ','

        [pscustomobject]$output
    }
}