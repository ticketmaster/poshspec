<#
.SYNOPSIS
    Test sql connections
.DESCRIPTION
    This function will test connectivity to a SQL server.  It does not run any select statements.
.PARAMETER Target
    The database computer name to test.  Include the instance, if needed.
.PARAMETER Qualifier
    The connection string uri
.PARAMETER Property
    Specifies a property of the database to test
.PARAMETER Should
    A Script Block defining a Pester Assertion.
.EXAMPLE
   Sql "server60" "Integrated Security=SSPI;Persist Security Info=False;Initial Catalog=ReportingDB;Data Source=server60" AccessToken { Should Be $null }
.EXAMPLE
   Sql "server60" $ConnectionString State { Should Match "Closed" }
.NOTES
    Assertions: Be, BeExactly, Match, Exist
    Hint:       The connection string can be stored as variable in the declaration file.
                $connectionString =  "Integrated Security=SSPI;Persist Security Info=False;Initial Catalog=ReportingDB;Data Source=server60"
                Sql "server60" $ConnectionString AccessToken { Should Be $null }
#>

function Sql {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=1)]
        [Alias('Computername','Computername\Instance')]
        [string]$Target,

		[PARAMETER(Position=2)]
		[Alias('ConnectionString')]
		[string]$Qualifier,

		[PARAMETER(Position=3)]
		[ValidateSet('AccessToken', 'ClientConnectionId', 'ConnectionString', 'ConnectionTimeout', 'Container', 'Credential', 'Database', 'DataSource', 'FireInfoMessageEventOnUserErrors', 'PacketSize', 'ServerVersion', 'Site', 'State', 'StatisticsEnabled', 'WorkstationId')]
        [string]$Property,

        [Parameter(Mandatory,Position=4)]
        [scriptblock]$Should
    )

	$ConnectionString = $Qualifier

	$expression =  {New-Object System.Data.SqlClient.SqlConnection '$ConnectionString'}

    $params = Get-PoshspecParam -TestName Sql -TestExpression $expression @PSBoundParameters

    Invoke-PoshspecExpression @params
}