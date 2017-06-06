<#
.SYNOPSIS
    Test an Web Site
.DESCRIPTION
    Used To Determine if Web Site is Running and Validate Various Properties
.PARAMETER Target
    The name of the Web Site to be Tested
.PARAMETER Property
    The Property to be expanded. If Ommitted, Property Will Default to Status. Can handle nested objects within properties
.PARAMETER Should
    A Script Block defining a Pester Assertion.
.EXAMPLE
    WebSite TestSite { Should be Started }
.EXAMPLE
    WebSite TestSite 'Applications["/"].Path' { Should be '/' }
.EXAMPLE
    WebSite TestSite ProcessModel.IdentityType { Should be 'ApplicationPoolIdentity'}
.NOTES
    Assertions: be
#>
function WebSite {
    [CmdletBinding(DefaultParameterSetName="Default")]
    param(
        [Parameter(Mandatory, Position=1, ParameterSetName="Default")]
        [Parameter(Mandatory, Position=1, ParameterSetName="Property")]
        [Alias("Path")]
        [string]$Target,

        [Parameter(Position=2, ParameterSetName="Property")]
        [Parameter(Position=2, ParameterSetName="Index")]
        [string]$Property,

        [Parameter(Position=3, ParameterSetName="Index")]

        [Parameter(Mandatory, Position=2, ParameterSetName="Default")]
        [Parameter(Mandatory, Position=3, ParameterSetName="Property")]
        [scriptblock]$Should
    )

    $IISAdmin = Get-Module -Name 'IISAdministration'
    if ($IISAdmin) {
      Import-Module IISAdministration
    }
    else {
      . $GetIISSite
    }

    $expression = $null
    $params = $null

    if (-not $PSBoundParameters.ContainsKey('Property')) {
      $Property = 'State'
      $PSBoundParameters.add('Property', $Property)
      $expression = { Get-IISSite -Name '$Target' -ErrorAction SilentlyContinue }
      $params = Get-PoshspecParam -TestName WebSite -TestExpression $expression @PSBoundParameters
    }

    if ($Property -like '*.*' -or $Property -like '*(*' -or $Property -like '*)*')  {
      $expression = { Get-IISSite -Name '$Target' -ErrorAction SilentlyContinue }
      $PropertyExpression = { $Property }
      $params = Get-PoshspecParam -TestName Website -TestExpression $expression -Target $Target -Should $Should -PropertyExpression $Property
    }

    else {
      $expression = { Get-IISSite -Name '$Target' -ErrorAction SilentlyContinue }
      $params = Get-PoshspecParam -TestName WebSite -TestExpression $expression @PSBoundParameters
    }

    Invoke-PoshspecExpression @params
}

$GetIISSite = {
  function Get-IISSite
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
        Write-Verbose "Getting site $Name"
        Write-Output $ServerManager.Sites[$Name]
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
