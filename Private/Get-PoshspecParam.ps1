function Get-PoshspecParam {
    [CmdletBinding(DefaultParameterSetName="Default")]
    param(
        [Parameter(Mandatory=$true, ParameterSetName="Default")]
        [Parameter(Mandatory=$true, ParameterSetName="PropertyExpression")]
        [string]
        $TestName,
        [Parameter(Mandatory=$true, ParameterSetName="Default")]
        [Parameter(Mandatory=$true, ParameterSetName="PropertyExpression")]
        [string]
        $TestExpression,
        [Parameter(Mandatory=$true, ParameterSetName="Default")]
        [Parameter(Mandatory=$true, ParameterSetName="PropertyExpression")]
        [string]
        $Target,
        [Parameter(ParameterSetName="Default")]
        [string]
        $FriendlyName,
        [Parameter(ParameterSetName="Default")]
        [string]
        $Property,
        [Parameter(Mandatory=$true, ParameterSetName="PropertyExpression")]
        [string]
        $PropertyExpression,
        [Parameter(ParameterSetName="Default")]
        [Parameter(ParameterSetName="PropertyExpression")]
        [string]
        $Qualifier,
        [Parameter(Mandatory=$true, ParameterSetName="Default")]
        [Parameter(Mandatory=$true, ParameterSetName="PropertyExpression")]
        [scriptblock]
        $Should
    )

    $assertion = $Should.ToString().Trim()
    $expressionString = $TestExpression.ToString().Trim()
    $PropertyExpression = $PropertyExpression.ToString().Trim()
    if ($PSBoundParameters.ContainsKey("PropertyExpression"))
    {
      $expressionString = $ExecutionContext.InvokeCommand.ExpandString($expressionString)
      $expressionString = Expand-PoshspecTestExpression $expressionString $PropertyExpression
      if ($PropertyExpression -like '*.*') {
        $lastIndexOfPeriod = $PropertyExpression.LastIndexOf('.')
        $Qualifier = $PropertyExpression.substring(0, $lastIndexOfPeriod)
        $NewProperty = $PropertyExpression.substring($lastIndexOfPeriod + 1)
        $nameString = "{0} property '{1}' for '{2}' at '{3}' {4}" -f $TestName, $NewProperty, $Target, $Qualifier, $assertion
      }
      else {
        $nameString = "{0} property '{1}' for '{2}' {3}" -f $TestName, $PropertyExpression, $Target, $assertion
      }
      $expressionString += " | $assertion"
      Write-Output -InputObject ([PSCustomObject]@{Name = $nameString; Expression = $expressionString})
    }
    else
    {
      if (-not $PSBoundParameters.ContainsKey("FriendlyName"))
      {
          $FriendlyName = $Target
      }

      $expressionString = $TestExpression.ToString().Trim()

      if ($PSBoundParameters.ContainsKey("Property"))
      {
          $expressionString += " | Select-Object -ExpandProperty '$Property'"

          if ($PSBoundParameters.ContainsKey("Qualifier"))
          {
              $nameString = "{0} property '{1}' for '{2}' at '{3}' {4}" -f $TestName,$Property, $FriendlyName, $Qualifier, $assertion
          }
          else
          {
              $nameString = "{0} property '{1}' for '{2}' {3}" -f $TestName, $Property, $FriendlyName, $assertion
          }
      }
      else
      {
          $nameString = "{0} '{1}' {2}" -f $TestName, $FriendlyName, $assertion
      }
      $expressionString += " | $assertion"
      $expressionString = $ExecutionContext.InvokeCommand.ExpandString($expressionString)
      Write-Output -InputObject ([PSCustomObject]@{Name = $nameString; Expression = $expressionString})
    }
}
