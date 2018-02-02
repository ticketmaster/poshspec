function Get-PoshSpecCCMHealth
{
  <#
      .SYNOPSIS
      Gets the results of the most recent client health evaluation on a local or remote computer
      .DESCRIPTION
      Parses the ccmevalreport.xml file into a readable format to view the results of the ccmeval task. Can be run on the local or remote computer.
      .EXAMPLE
      Get-PoshSpecCCMHealth
      Returns the ccmeval results from the local machine
      .EXAMPLE             
      Get-PoshSpecCCMHealth -ComputerName PC001
      Returns the ccmeval results from a remote machine
      .EXAMPLE             
      'PC001','PC002' | Get-PoshSpecCCMHealth
      Returns the ccmeval results from a remote machine
      .LINK
      Source: https://smsagent.wordpress.com/2016/02/12/reading-ccmeval-results-directly-from-a-configmgr-client-with-powershell/
  #>
 
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $false,
                ValueFromPipeline = $true
        )]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )
 
    Begin {
        $Script = {

            $CCMEvalReport = "$env:windir\ccm\CcmEvalReport.xml"
            
            if (-not (Test-Path -Path $("$env:windir\ccm") -PathType Container)){
                throw "CCM folder does not exists at [$("$env:windir\ccm")], configmgr client is not installed on this machine"
            }

            if (-not (Test-Path -Path $CCMEvalReport -PathType Leaf)){
                throw "File [$CCMEvalReport] does not exists, please run ccmeval.exe to create a new report"
            }
    
            Write-SRLog "Reading CCMEvalReport.xml from [$CCMEvalReport]"
            $xml = New-Object -TypeName System.Xml.XmlDocument
            $xml.Load($CCMEvalReport)

            Write-Output $xml
        }
    }
 
    Process {
        if ($ComputerName -eq $env:COMPUTERNAME)
        {
            $xml = Invoke-Command -ScriptBlock $Script
        }
        Else
        {
            try
                {
                    $xml = Invoke-Command -ScriptBlock $Script -ComputerName $ComputerName -ErrorAction Stop
                }
            catch
                {
                    if ($Error[0] | Select-String -Pattern 'Access is denied')
                        {
                            $Credentials = $host.ui.PromptForCredential('Credentials required', "Access was denied to $Computername.  Enter credentials to connect.", '', '')
                            $xml = Invoke-Command -ScriptBlock $Script -ComputerName $ComputerName -Credential $Credentials
                        }
                    Else { $_.Exception.Message }
                }
        }

        $xmlsum = $xml.ClientHealthReport.Summary

        $XmlTests = $xml.ClientHealthReport.HealthChecks.HealthCheck

        foreach ($XmlTest in $XmlTests) {

                $Test = [PSCustomObject]@{ 
                  Test = $XmlTest.Description;
                  Result = $XmlTest.'#text';
                  EvaluationTime = [datetime]($xmlsum.EvaluationTime);
                }

            $Results += $Test
        }
        
        Write-Output ($Results | Sort-Object -Property Test)
        
    }
}
