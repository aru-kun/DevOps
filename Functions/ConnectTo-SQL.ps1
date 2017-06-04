function ConnectTo-SQL
{
    param
    (
        [Parameter(Position = 0, Mandatory = $True, HelpMessage = "Name of SQL server")]
        [string]$SQLServer = $null,
        [Parameter(Mandatory = $false, HelpMessage = "Name of SQL database")]
        [string]$Database = 'master',
        [Parameter(Mandatory = $True, HelpMessage = "Query to be executed, avoid using sql comments '--''")]
        [string]$SQLQuery = $null,
        [Parameter(Mandatory = $false, HelpMessage = "Timeout value for query in seconds. Default value is 600")]
        [int]$QueryTimeout = 30,
        [Parameter(Mandatory = $false, HelpMessage = "Turn switch on only if a returned data table is desired")]
        [switch]$GetTableOutput
    )
    #Connect to SQL
    $Connection = New-Object System.Data.SQLClient.SQLConnection
    $Connection.ConnectionString = "server='$($SQLServer)';database='$($Database)';trusted_connection=true;"
    $Connection.Open()
    $Command = New-Object System.Data.SQLClient.SQLCommand
    $Command.Connection = $Connection
    $Command.CommandText = $SQLQuery
    $Command.CommandTimeout = $QueryTimeout
    if ($GetTableOutput)
    {
        $Table = new-object System.Data.DataTable
        $Result = $Command.ExecuteReader()
        $Table.Load($Result)
        $Connection.Close()
        return $Table
    }
    else
    {
        $null = $Command.ExecuteReader()
        $Connection.Close()
    }
}