<#
.SYNOPSIS
    Test user rights assignments by user or by right.
.DESCRIPTION
    Test to ensure that a specific account has particular rights assignments. You can specify to query either
    by account, in which case your Should block will verify against the possible rights assigned to the account
    being tested; or by right, in which case your Should block will verify against the possible accounts that
    might have the right assigned to them.
.PARAMETER Qualifier
    Whether to test one user account for all rights assigned to it (ByAccount) or to test one right
    for all accounts which have it (ByRight).
.PARAMETER Target
    The user right or account to test for. Possible user rights:
    - SeTrustedCredManAccessPrivilege      Access Credential Manager as a trusted caller
    - SeNetworkLogonRight                  Access this computer from the network
    - SeTcbPrivilege                       Act as part of the operating system
    - SeMachineAccountPrivilege            Add workstations to domain
    - SeIncreaseQuotaPrivilege             Adjust memory quotas for a process
    - SeInteractiveLogonRight              Allow log on locally
    - SeRemoteInteractiveLogonRight        Allow log on through Remote Desktop Services
    - SeBackupPrivilege                    Back up files and directories
    - SeChangeNotifyPrivilege              Bypass traverse checking
    - SeSystemtimePrivilege                Change the system time
    - SeTimeZonePrivilege                  Change the time zone
    - SeCreatePagefilePrivilege            Create a pagefile
    - SeCreateTokenPrivilege               Create a token object
    - SeCreateGlobalPrivilege              Create global objects
    - SeCreatePermanentPrivilege           Create permanent shared objects
    - SeCreateSymbolicLinkPrivilege        Create symbolic links
    - SeDebugPrivilege                     Debug programs
    - SeDenyNetworkLogonRight              Deny access this computer from the network
    - SeDenyBatchLogonRight                Deny log on as a batch job
    - SeDenyServiceLogonRight              Deny log on as a service
    - SeDenyInteractiveLogonRight          Deny log on locally
    - SeDenyRemoteInteractiveLogonRight    Deny log on through Remote Desktop Services
    - SeEnableDelegationPrivilege          Enable computer and user accounts to be trusted for delegation
    - SeRemoteShutdownPrivilege            Force shutdown from a remote system
    - SeAuditPrivilege                     Generate security audits
    - SeImpersonatePrivilege               Impersonate a client after authentication
    - SeIncreaseWorkingSetPrivilege        Increase a process working set
    - SeIncreaseBasePriorityPrivilege      Increase scheduling priority
    - SeLoadDriverPrivilege                Load and unload device drivers
    - SeLockMemoryPrivilege                Lock pages in memory
    - SeBatchLogonRight                    Log on as a batch job
    - SeServiceLogonRight                  Log on as a service
    - SeSecurityPrivilege                  Manage auditing and security log
    - SeRelabelPrivilege                   Modify an object label
    - SeSystemEnvironmentPrivilege         Modify firmware environment values
    - SeManageVolumePrivilege              Perform volume maintenance tasks
    - SeProfileSingleProcessPrivilege      Profile single process
    - SeSystemProfilePrivilege             Profile system performance
    - SeUnsolicitedInputPrivilege          "Read unsolicited input from a terminal device"
    - SeUndockPrivilege                    Remove computer from docking station
    - SeAssignPrimaryTokenPrivilege        Replace a process level token
    - SeRestorePrivilege                   Restore files and directories
    - SeShutdownPrivilege                  Shut down the system
    - SeSyncAgentPrivilege                 Synchronize directory service data
    - SeTakeOwnershipPrivilege             Take ownership of files or other objects
.PARAMETER Should
    A Script Block defining a Pester Assertion.
.EXAMPLE
    UserRightsAssignment ByRight 'SeNetworkLogonRight' { Should Be @("BUILTIN\Users","BUILTIN\Administrators") }
.EXAMPLE
    UserRightsAssignment ByAccount 'BUILTIN\Users' { should Not Match "SeServiceLogonRight" }
.NOTES
    Assertions: Be, BeExactly, BeNullOrEmpty, Match, MatchExactly
#>

function UserRightsAssignment {
    [CmdletBinding(DefaultParameterSetName="Default")]
    param(
        [Parameter(Mandatory, Position=1)]
        [ValidateSet('ByRight','ByAccount')]
        [string]$Qualifier,

        [Parameter(Mandatory, Position=2)]
        [Alias('Right')]
        [string]$Target,

        [Parameter(Mandatory, Position=3)]
        [scriptblock]$Should
    )

    If (Test-RunAsAdmin){
        If ($Qualifier -eq "ByRight") {
            $expression = { Get-AccountsWithUserRight -Right '$Target' | Select-Object -ExpandProperty Account}
        } ElseIf ($Qualifier -eq "ByAccount") {
            $expression = { Get-UserRightsGrantedToAccount -Account '$Target' | Select-Object -ExpandProperty Right}
        }
    } Else {
        Throw "You must run as Administrator to test UserRightsAssignment"
    }


    $params = Get-PoshspecParam -TestName UserRightsAssignment -TestExpression $expression @PSBoundParameters

    Invoke-PoshspecExpression @params
}