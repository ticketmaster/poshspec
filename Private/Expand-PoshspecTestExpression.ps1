function Expand-PoshspecTestExpression
{
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true, Position=0)]
    [string]
    $ObjectExpression,

    [Parameter(Mandatory=$true, Position=1)]
    [string]
    $PropertyExpression
  )

  $cmd = [scriptblock]::Create('(' + $ObjectExpression + ')' + '.' + $PropertyExpression)
  Write-Output $cmd.ToString()
}
