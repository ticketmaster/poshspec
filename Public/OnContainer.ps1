function OnContainer {
    [CmdletBinding()]
    param(
        # Parameter help description
        [Parameter(Mandatory, Position=0, ParameterSetName="Default")]
        [Parameter(Mandatory, Position=0, ParameterSetName="RunAsAdministrator")]
        [String]
        $ContainerName,
        
        # Parameter help description
        [Parameter(Mandatory, Position=1, ParameterSetName="RunAsAdministrator")]
        [Switch]
        $RunAsAdministrator,
        
        # Parameter help description
        [Parameter(Mandatory, Position=1, ParameterSetName="Default")]
        [Parameter(Mandatory, Position=2, ParameterSetName="RunAsAdministrator")]
        [ScriptBlock]
        $Script
    )
  
    $PoshspecRemoteParams = @{ContainerName = $ContainerName}
    if ($RunAsAdministrator)
    {
        $PoshspecRemoteParams.Add("RunAsAdministrator",$true)
    }
    $Script.Invoke()
}