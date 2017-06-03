function ConnectTo-SQL
{
    param
    (
        [Parameter(Position = 0, Mandatory = $True, HelpMessage = "Name of SQL server")]
        [string]$SQLServer = $null,
        [Parameter(Mandatory = $false, HelpMessage = "Name of SQL database")]
        [string]$Database = $null,
        [Parameter(Mandatory = $True, HelpMessage = "Query to be executed, avoid using sql comments '--''")]
        [string]$SQLQuery = $null,
        [Parameter(Mandatory = $false, HelpMessage = "Turn switch on only if a returned data table is desired")]
        [switch]$GetTableOutput
    )
    #Connect to SQL
    $Connection = New-Object System.Data.SQLClient.SQLConnection
    if ($Database)
    {
        $Connection.ConnectionString = "server='$($SQLServer)';database='$($Database)';trusted_connection=true;"
    }
    else
    {
        $Connection.ConnectionString = "server='$($SQLServer)';database='master';trusted_connection=true;"
    }
    $Connection.Open()
    $Command = New-Object System.Data.SQLClient.SQLCommand
    $Command.Connection = $Connection
    $Command.CommandText = $SQLQuery
    $Command.CommandTimeout = 600
    if ($GetTableOutput)
    {
        $Table = new-object [System.Data.DataTable]
        $Result = $Command.ExecuteReader()
        $Table.Load($Result)
        $Connection.Close()
        return $Table
    }
    else
    {
        $Command.ExecuteReader()
        $Connection.Close()
    }
    <#
    if ($Insert)
    {
        $Command.ExecuteReader()
        $Connection.Close()
    }
    #>
}