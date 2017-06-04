function ConnectTo-SQL
{
    param
    (
        [Parameter(Mandatory = $false, HelpMessage = "Name of SQL server. Default value is 'localhost'")]
        [string]$SQLServer = 'localhost',
        [Parameter(Mandatory = $false, HelpMessage = "Name of SQL database. Default value is 'master'")]
        [string]$Database = 'master',
        [Parameter(Mandatory = $True, HelpMessage = "Query to be executed, avoid using sql comments '--'")]
        [string]$SQLQuery = $null,
        [Parameter(Mandatory = $false, HelpMessage = "Timeout value for query in seconds. Default value is 600")]
        [int]$QueryTimeout = 30,
        [Parameter(Mandatory = $false, HelpMessage = "Turn switch on only if a returned data table is desired")]
        [switch]$GetTableOutput
    )
    #Create connection object
    $Connection = New-Object System.Data.SQLClient.SQLConnection
    #build dbconnectionstring
    $Connection.ConnectionString = "server='$($SQLServer)';database='$($Database)';trusted_connection=true;"
    #Open connection
    $Connection.Open()
    #Create command object
    $Command = New-Object System.Data.SQLClient.SQLCommand
    #Give command all the pieces it needs to run
    $Command.Connection = $Connection
    $Command.CommandText = $SQLQuery
    $Command.CommandTimeout = $QueryTimeout
    #Validate if the GetTableOutput switch is on and if so then it return a table
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