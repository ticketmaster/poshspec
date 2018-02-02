 <#
.SYNOPSIS
    Tests CCM Health
.DESCRIPTION
    Tests CCM Health. Runs a CCMEval task and reports the result.
.PARAMETER Should 
    A Script Block defining a Pester Assertion.       
.EXAMPLE
    This is the only way to use this function:

    CCMHealthCheck { Should Be 'Passed' }

    It will validate if all ccm healthchecks have a passed result.
.NOTES
    Assertions: Exist
#>
function CCMHealthCheck {
 
    [CmdletBinding()]
    param(        
        [Parameter(Mandatory, Position=1)]
        [scriptblock]$Should
    )

    Process {

        try {
            # Get the client health forcing reevaluation
            $Tests = Get-PoshSpecCCMHealth
        } catch {                    
            throw "Could not load ccm health xml from local client. $_"
        }

        foreach ($Test in $Tests) {

            if ($Test.Result -eq 'Not Applicable'){continue}
            else {

                $params = [PSCustomObject]@{
                    Name = "has CCM Client Check '$($Test.Test)' result 'Passed'"
                    Expression = "'$($Test.Result)' | Should Be 'Passed'"
                }
        
                Invoke-PoshspecExpression @params
            }
        
    }

    }
}

