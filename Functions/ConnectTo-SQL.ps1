function ConnectTo-SQL
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false, ParameterSetName = "TrustedConnection", HelpMessage = "Name of SQL server. Default value is 'localhost'")]
        [Parameter(Mandatory = $false, ParameterSetName = "SQLUser", HelpMessage = "Name of SQL server. Default value is 'localhost'")]
        [ValidatePattern('.+')]
        [Alias('Server', 'ServerName', 'IPAddress')]
        [string]$SQLServer = 'localhost',
        [Parameter(Mandatory = $false, ParameterSetName = "TrustedConnection", HelpMessage = "Name of SQL database. Default value is 'master'")]
        [Parameter(Mandatory = $false, ParameterSetName = "SQLUser", HelpMessage = "Name of SQL database. Default value is 'master'")]
        [ValidatePattern('.+')]
        [string]$Database = 'master',
        [Parameter(Mandatory = $True, ParameterSetName = "TrustedConnection", HelpMessage = "Query to be executed, avoid using sql comments '--'")]
        [Parameter(Mandatory = $True, ParameterSetName = "SQLUser", HelpMessage = "Query to be executed, avoid using sql comments '--'")]
        [ValidatePattern('.+')]
        [Alias('Query')]
        [string]$SQLQuery = $null,
        [Parameter(Mandatory = $false, ParameterSetName = "TrustedConnection", HelpMessage = "Timeout value for query in seconds. Default value is 600")]
        [Parameter(Mandatory = $false, ParameterSetName = "SQLUser", HelpMessage = "Timeout value for query in seconds. Default value is 600")]
        [Alias('Timeout', 'CommandTimeout')]
        [int]$QueryTimeout = 30,
        [Parameter(Mandatory = $false, ParameterSetName = "TrustedConnection", HelpMessage = "Port number for SQL connection. Default value is 1433")]
        [Parameter(Mandatory = $false, ParameterSetName = "SQLUser", HelpMessage = "Port number for SQL connection. Default value is 1433")]
        [int]$Port = 1433,
        [Parameter(Mandatory = $false, ParameterSetName = "TrustedConnection", HelpMessage = "Turn switch on only if a returned data table is desired")]
        [Parameter(Mandatory = $false, ParameterSetName = "SQLUser", HelpMessage = "Turn switch on only if a returned data table is desired")]
        [switch]$GetTableOutput,
        [Parameter(Mandatory = $false, ParameterSetName = "SQLUser", HelpMessage = "Specify username if connection requires sql authentication.")]
        [ValidatePattern('.+')]
        [Alias('user')]
        [string]$Username = $null,
        [Parameter(Mandatory = $true, ParameterSetName = "SQLUser", HelpMessage = "Specify Password if connection requires sql authentication.")]
        [ValidatePattern('.+')]
        [Alias('pwd')]
        [string]$Password = $null
    )
    Write-Verbose "Creating connection object"
    $Connection = New-Object System.Data.SQLClient.SQLConnection
    Write-Verbose "Building dbconnectionstring"
    Write-Verbose "ParameterSetName: $($PsCmdlet.ParameterSetName)"
    switch ($PsCmdlet.ParameterSetName)
    {
        "TrustedConnection" {$ConnectionString = "server=$($SQLServer),$($Port);database='$($Database)';trusted_connection=true;"}
        "SQLUser" {$ConnectionString = "server=$($SQLServer),$($Port);database='$($Database)';User ID = '$($Username)';Password = '$($Password)';"}
    }
    Write-Verbose "ConnectionString: $($ConnectionString)"
    $Connection.ConnectionString = $ConnectionString
    Write-Verbose "Opening Connection"
    $Connection.Open()
    #Create command object
    $Command = New-Object System.Data.SQLClient.SQLCommand
    Write-Verbose "Building Command object"
    Write-Verbose "Timeout: $($QueryTimeout)"
    Write-Verbose "Query: `r`n$($SQLQuery)"
    $Command.Connection = $Connection
    $Command.CommandText = $SQLQuery
    $Command.CommandTimeout = $QueryTimeout
    Write-Verbose "Running Query"
    #Validate if the GetTableOutput switch is on and if so then it return a table
    if ($GetTableOutput)
    {
        $Result = $Command.ExecuteReader()
        $Connection.Close()
        if ($Result)
        {
            $Table = new-object System.Data.DataTable
            $Table.Load($Result)
            return $Table
        }
        else
        {
            Write-Output "Query did not return any results"
        }
    }
    else
    {
        $null = $Command.ExecuteReader()
        $Connection.Close()
    }
}