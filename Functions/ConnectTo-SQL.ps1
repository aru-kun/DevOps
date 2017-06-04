function ConnectTo-SQL
{
    <#
    .SYNOPSIS
    Function to connect to SQL database.
    
    .DESCRIPTION
    Function to connect to SQL database.
    This can be used for running any type of query against SQL, 
    just avoid using sql comments '--'.
    If you want to receive a data table object as output,
    you need to use the GetTableOutput switch.
    
    .PARAMETER SQLServer
    This is the name of the SQL server you will be connecting to.
    If you do not use this parameter it will use the default value localhost.
    Please note that localhost does not work with named SQL instances.
    Any of the following types of input is accepted:
        Named instances: myServerName\myInstanceName
        Default Instances: myServerName
        IPAddress: 190.190.200.100
        
    .PARAMETER Database
    This is the name of the SQL database you will be connecting to.
    If you do not use this parameter it will use the default value master.
    Please note that you may stil specify the database name in your query statement,
    this works if you need to pull data from multiple databases on the same SQLInstance, 
    you are not limited in the amount of databases you can connect to by this parameter.
    
    .PARAMETER SQLQuery
    You may run any query you would normally run in SSMS with this parameter.
    You may not leave this value as blank, it will error out immediately if you do.
    Please avoid using SQL comments '--'. 
    This param does not like SQL comments and it may cause errors.
    
    .PARAMETER QueryTimeout
    This is the timeout value in seconds for the SQL connection.
    If you do not use this parameter it will use the default value 30.
    If you need to run a query that will take longer you may increase this timeout 
    according to your needs.
    
    .PARAMETER Port
    This is the port number for the SQL connection.
    If you do not use this parameter it will use the default value 1433.
    
    .PARAMETER GetTableOutput
    This is a switch parameter, if you are running a "select" statement and you want
    to return a data table object you can turn this switch on and receive the output
    as a data table.
    If you are running other things like "insert" statements or "update" statements and you 
    don't want to be bothered with an output just don't use this parameter.
    
    .PARAMETER Username
    Only use this parameter if you need to use SQL authentication for your connection
    string, if you are in a domain environment and your windows credentials have access
    then you do not need to use this parameter.
    
    .PARAMETER Password
    This parameter is mandatory if you declare a Username.
    Only use if you need SQL authentication.
    
    .EXAMPLE
    $Query = "SELECT top 10 *  FROM [Sales].[Orders] (nolock)"
    ConnectTo-SQL -IPAddress "190.190.200.100" -Port 1433 -Database "WideWorldImporters" -Query $Query -GetTableOutput
    .EXAMPLE
    $Query = "SELECT top 10 *  FROM [WideWorldImporters].[Sales].[Orders] (nolock)"
    ConnectTo-SQL -ServerName "MySQLServerName" -Query $Query -User "sa" -pwd "password1234" -GetTableOutput
    .EXAMPLE
    $Query = "SELECT top 10 *  FROM [WideWorldImporters].[Sales].[Orders] (nolock)"
    ConnectTo-SQL -Query $Query -GetTableOutput
    .NOTES
    Author: Aru <aruscripttips@gmail.com>
    .LINK
    https://github.com/aru-kun/DevOps/blob/master/Functions/ConnectTo-SQL.ps1
    #>
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
        [Parameter(Mandatory = $false, ParameterSetName = "TrustedConnection", HelpMessage = "Timeout value for query in seconds. Default value is 30")]
        [Parameter(Mandatory = $false, ParameterSetName = "SQLUser", HelpMessage = "Timeout value for query in seconds. Default value is 30")]
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
        if ($Result.HasRows)
        {
            Write-Verbose "Result has rows, filling table"
            $Table = new-object System.Data.DataTable
            $Table.Load($Result)
            $Connection.Close()
            return $Table
        }
        else
        {
            Write-Verbose "Query did not return any results"
            $Connection.Close()
            return $null
        }
    }
    else
    {
        $null = $Command.ExecuteReader()
        $Connection.Close()
    }
}