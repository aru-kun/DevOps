function ConnectTo-SQL
{
    param
    (
        [Parameter(Mandatory = $false, ParameterSetName = "TrustedConnection", HelpMessage = "Name of SQL server. Default value is 'localhost'")]
        [Parameter(Mandatory = $false, ParameterSetName = "SQLUser", HelpMessage = "Name of SQL server. Default value is 'localhost'")]
        [string]$SQLServer = 'localhost',
        [Parameter(Mandatory = $false, ParameterSetName = "TrustedConnection", HelpMessage = "Name of SQL database. Default value is 'master'")]
        [Parameter(Mandatory = $false, ParameterSetName = "SQLUser", HelpMessage = "Name of SQL database. Default value is 'master'")]
        [string]$Database = 'master',
        [Parameter(Mandatory = $True, ParameterSetName = "TrustedConnection", HelpMessage = "Query to be executed, avoid using sql comments '--'")]
        [Parameter(Mandatory = $True, ParameterSetName = "SQLUser", HelpMessage = "Query to be executed, avoid using sql comments '--'")]
        [Alias('Query')]
        [string]$SQLQuery = $null,
        [Parameter(Mandatory = $false, ParameterSetName = "TrustedConnection", HelpMessage = "Timeout value for query in seconds. Default value is 600")]
        [Parameter(Mandatory = $false, ParameterSetName = "SQLUser", HelpMessage = "Timeout value for query in seconds. Default value is 600")]
        [Alias('Timeout', 'CommandTimeout')]
        [int]$QueryTimeout = 30,
        [Parameter(Mandatory = $false, ParameterSetName = "TrustedConnection", HelpMessage = "Turn switch on only if a returned data table is desired")]
        [Parameter(Mandatory = $false, ParameterSetName = "SQLUser", HelpMessage = "Turn switch on only if a returned data table is desired")]
        [switch]$GetTableOutput,
        [Parameter(Mandatory = $false, ParameterSetName = "SQLUser", HelpMessage = "Specify username if connection requires sql authentication.")]
        [Alias('user')]
        [string]$Username = $null,
        [Parameter(Mandatory = $true, ParameterSetName = "SQLUser", HelpMessage = "Specify Password if connection requires sql authentication.")]
        [Alias('pwd')]
        [string]$Password = $null
    )
    #Create connection object
    $Connection = New-Object System.Data.SQLClient.SQLConnection
    #build dbconnectionstring
    switch ($PsCmdlet.ParameterSetName)
    {
        "TrustedConnection" {$ConnectionString = "server='$($SQLServer)';database='$($Database)';trusted_connection=true;"}
        "SQLUser" {$ConnectionString = "server='$($SQLServer)';database='$($Database)';User ID = '$($Username)';Password = '$($Password)';"}
    }
    $Connection.ConnectionString = $ConnectionString
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