<#
.SYNOPSIS
    Test an Application Pool
.DESCRIPTION
    Used To Determine if Application Pool is Running and Validate Various Properties
.PARAMETER Target
    The name of the App Pool to be Tested
.PARAMETER Property
    The Property to be expanded. If Ommitted, Property Will Default to Status. Can handle nested objects within properties
.PARAMETER Should
    A Script Block defining a Pester Assertion.
.EXAMPLE
    AppPool TestSite { Should be Started }
.EXAMPLE
    AppPool TestSite ManagedPipelineMode { Should be 'Integrated' }
.EXAMPLE
    AppPool TestSite ProcessModel.IdentityType { Should be 'ApplicationPoolIdentity'}
.NOTES
    Assertions: be
#>
function AppPool {
    [CmdletBinding(DefaultParameterSetName="Default")]
    param(
        [Parameter(Mandatory, Position=1, ParameterSetName="Default")]
        [Parameter(Mandatory, Position=1, ParameterSetName="Property")]
        [Alias("Path")]
        [string]$Target,

        [Parameter(Position=2, ParameterSetName="Property")]
        [string]$Property,

        [Parameter(Mandatory, Position=2, ParameterSetName="Default")]
        [Parameter(Mandatory, Position=3, ParameterSetName="Property")]
        [scriptblock]$Should
    )

    $IISAdmin = Get-Module -Name 'IISAdministration'
    if ($IISAdmin) {
      Import-Module IISAdministration
    }
    else {
      . $GetIISAppPool
    }

    $expression = $null
    $params = $null

    if (-not $PSBoundParameters.ContainsKey('Property')) {
      $Property = 'State'
      $PSBoundParameters.add('Property', $Property)
      $expression = { Get-IISAppPool -Name '$Target' -ErrorAction SilentlyContinue }
      $params = Get-PoshspecParam -TestName AppPool -TestExpression $expression @PSBoundParameters
    }

    if ($Property -like '*.*' -or $Property -like '*(*' -or $Property -like '*)*') {
      $expression = { Get-IISAppPool -Name '$Target' -ErrorAction SilentlyContinue }
      $params = Get-PoshspecParam -TestName AppPool -TestExpression $expression -Target $Target -Should $Should -PropertyExpression $Property
    }

    else {
      $expression = { Get-IISAppPool -Name '$Target' -ErrorAction SilentlyContinue }
      $params = Get-PoshspecParam -TestName AppPool -TestExpression $expression @PSBoundParameters
    }

    Invoke-PoshspecExpression @params
}

$GetIISAppPool = {
  function Get-IisAppPool
  {
    [CmdletBinding()]
    Param
    (
      [Parameter(Mandatory=$true,
                 Position=1)]
      [string]$Name
    )

    Begin
    {
      [System.Reflection.Assembly]::LoadFrom("$($Env:windir)\system32\inetsrv\Microsoft.Web.Administration.dll") | Out-Null
      $ServerManager = [Microsoft.Web.Administration.ServerManager]::OpenRemote("localhost")
    }

    Process
    {
      try
      {
        Write-Verbose "Getting application pool $Name"
        Write-Output $ServerManager.ApplicationPools[$Name]
      }

      catch
      {
        Write-Warning $Error[0]
      }
    }

    End
    {
      $ServerManager.Dispose()
    }
  }
}
