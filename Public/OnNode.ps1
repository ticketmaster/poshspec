function OnNode {
    [CmdletBinding(DefaultParameterSetName='Default')]
    param(
        # Parameter help description
        [Parameter(Mandatory, Position=0, ParameterSetName="Default")]
        [Parameter(Mandatory, Position=0, ParameterSetName="Credential")]
        [String]
        $ComputerName,
        
        # Parameter help description
        [Parameter(Mandatory, Position=1, ParameterSetName="Credential")]
        [System.Management.Automation.PSCredential]
        $Credential,
        
        # Parameter help description
        [Parameter(Mandatory, Position=1, ParameterSetName="Default")]
        [Parameter(Mandatory, Position=2, ParameterSetName="Credential")]
        [ScriptBlock]
        $Script
    )
  
    $PoshspecRemoteParams = @{ComputerName = $ComputerName}
    if ($PSBoundParameters.ContainsKey("Credential"))
    {
        $PoshspecRemoteParams.Add("Credential",$Credential)
    }
    $Script.Invoke()
}