<#
.SYNOPSIS
    Tests Bitlocker settings
.DESCRIPTION
    Checks Bitlocker settings. If no target is specified the system drive will be validated.
.PARAMETER Property
    Specifies a property of the Get-BitlockerVolume cmdlet return object 
.PARAMETER Should 
    A Script Block defining a Pester Assertion.       
.EXAMPLE
    Bitlocker VolumeStatus  { Should Be 'FullyEncrypted' }
.EXAMPLE
    Bitlocker EncryptionPercentage  { Should Be 100 }
.EXAMPLE
       Bitlocker ProtectionStatus  { Should Be 'On' }
.NOTES
    Assertions: Be, BeExactly, Exist, Match, MatchExactly
#>
function Bitlocker {
 
    [CmdletBinding(DefaultParameterSetName="Default")]
    param(        
        [Parameter(Mandatory=$False, Position=1, ParameterSetName="Default")]
        [Parameter(Mandatory=$False, Position=1, ParameterSetName="Property")]
        [Alias("Path")]
        [string]$Target=($Env:SystemDrive),

        [Parameter(Mandatory=$False, Position=2, ParameterSetName="Property")]
        [ValidateSet(
            'AutoUnlockEnabled',
            'AutoUnlockKeyStored',
            'CapacityGB',
            'EncryptionMethod',
            'EncryptionPercentage',
            'KeyProtector',
            'LockStatus',
            'MetadataVersion',
            'MountPoint',
            'ProtectionStatus',
            'VolumeStatus',
            'VolumeType',
            'WipePercentage'
        )]
        [string]$Property,
                
        [Parameter(Mandatory, Position=3, ParameterSetName="Property")]
        [Parameter(Mandatory, Position=2, ParameterSetName="Default")]
        [scriptblock]$Should
    )
    Process {
            
        $expression = { Get-BitlockerVolume $Target | Select-Object -ExpandProperty $Property }
    
        $params = Get-PoshspecParam -TestName Bitlocker -TestExpression $expression @PSBoundParameters
    
        Invoke-PoshspecExpression @params
    }
}
