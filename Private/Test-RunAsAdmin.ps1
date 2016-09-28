Function Test-RunAsAdmin {
    <#
        .SYNOPSIS
         Verifies if the current process is run as admin.

        .DESCRIPTION
         This function verifies whether the current process is running with administrator rights or not.
         If so, it will return a value of $true; otherwise it will return a valud of $false
    #>
    ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}