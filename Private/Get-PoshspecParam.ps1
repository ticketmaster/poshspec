function Get-PoshspecParam {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $TestName,
        [Parameter(Mandatory)]
        [string]
        $TestExpression,        
        [Parameter(Mandatory)]
        [string]
        $Target,        
        [Parameter()]
        [string]
        $FriendlyName,            
        [Parameter()]
        [string]
        $Property,
        [Parameter()]
        [string]
        $Qualifier,                   
        [Parameter()]
        [scriptblock]
        $Should = { Should Exist }
    )
    
    $assertion = $Should.ToString().Trim()

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

    $expressionString = $ExecutionContext.InvokeCommand.ExpandString($expressionString)
    
    switch ($assertion) {
        'Should Exist' {
            $expressionString += " | should not benullorempty"
        }
        'Should Not Exist' {
            $expressionString += " | should benullorempty"
        }
        Default {
            $expressionString += " | $assertion"
        }
    }
    
    Write-Output -InputObject ([PSCustomObject]@{Name = $nameString; Expression = $expressionString})
}
