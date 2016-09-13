 <#
.SYNOPSIS
    Test an Audit Policy.
.DESCRIPTION
    Test the setting of a particular audit policy .
.PARAMETER Target
    Specifies the category of the Audit Policy.
.PARAMETER Qualifier
    Specifies the subcategory of the Audit policy.   
.PARAMETER Should 
    A Script Block defining a Pester Assertion.       
.EXAMPLE
    AuditPolicy System "Security System Extension" { Should Be Success }
.EXAMPLE
    AuditPolicy "Logon/Logoff" Logon { Should Be "Success and Failure"  }
.EXAMPLE
    AuditPolicy "Account Management" "User Account Management" { Should Not Be "No Auditing" }    
.NOTES
    Assertions: Be, BeExactly, Match, MatchExactly
#>
 
function AuditPolicy {
    [CmdletBinding(DefaultParameterSetName="Default")]
    param(
        [Parameter(Mandatory, Position=1)]
        [Alias("Category")]
        [ValidateSet(
            "System",
            "Logon/Logoff",
            "Object Access",
            "Privilege Use",
            "Detailed Tracking",
            "Policy Change",
            "Account Management",
            "DS Access",
            "Account Logon"
        )]
        $Qualifier,    
        [Parameter(Mandatory, Position=2)]
        [Alias("Subcategory")]
        [ValidateSet(
            "Security System Extension",
            "System Integrity",
            "IPsec Driver",
            "Other System Events",
            "Security State Change",
            "Logon",
            "Logoff",
            "Account Lockout",
            "IPsec Main Mode",
            "IPsec Quick Mode",
            "IPsec Extended Mode",
            "Special Logon",
            "Other Logon/Logoff Events",
            "Network Policy Server",
            "File System",
            "Registry",
            "Kernel Object",
            "SAM",
            "Certification Services",
            "Application Generated",
            "Handle Manipulation",
            "File Share",
            "Filtering Platform Packet Drop",
            "Filtering Platform Connection",
            "Other Object Access Events",
            "Detailed File Share",
            "Sensitive Privilege Use",
            "Non Sensitive Privilege Use",
            "Other Privilege Use Events",
            "Process Termination",
            "DPAPI Activity",
            "RPC Events",
            "Process Creation",
            "Audit Policy Change",
            "Authentication Policy Change",
            "Authorization Policy Change",
            "MPSSVC Rule-Level Policy Change",
            "Filtering Platform Policy Change",
            "Other Policy Change Events",
            "User Account Management",
            "Computer Account Management",
            "Security Group Management",
            "Distribution Group Management",
            "Application Group Management",
            "Other Account Management Events",
            "Directory Service Changes",
            "Directory Service Replication",
            "Detailed Directory Service Replication",
            "Directory Service Access",
            "Kerberos Service Ticket Operations",
            "Other Account Logon Events",
            "Kerberos Authentication Service",
            "Credential Validation"
        )]
        [string]$Target,
        
        [Parameter(Mandatory, Position=3)]
        [scriptblock]$Should
    )
    Function GetAuditPolicy([string]$Category,[string]$Subcategory) {
        If (Test-RunAsAdmin){
            auditpol /get /category:$Category |
                Where-Object -FilterScript {$_ -match "^\s+$Subcategory"} | 
                    ForEach-Object -Process {($_.trim() -split "\s{2,}")[1]}
        } Else {
            Throw "You must run as Administrator to test AuditPolicy"
        }
    }
    $expression = {GetAuditPolicy -Category '$Qualifier' -Subcategory '$Target'}

    $params = Get-PoshspecParam -TestName AuditPolicy -TestExpression $expression @PSBoundParameters
    
    Invoke-PoshspecExpression @params
}