# Log Invocations to MySql Table
# This script requires either loading the MySQL driver (dlls) or installing the drivers in running machine.  Type is included with this module.

function Log-GlobexADInvocationContext {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory=$False,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ValueFromRemainingArguments=$false)]
        [string]$RunDate,
        [Parameter(
            Mandatory=$False,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ValueFromRemainingArguments=$false)]
        [string]$LogPrefixMessage,
        [Parameter(
            Mandatory=$False,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ValueFromRemainingArguments=$false)]
        [string]$Username,
        [Parameter(
            Mandatory=$False,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ValueFromRemainingArguments=$false)]
        [string]$UserRunningScriptInvokedFunction,
        [Parameter(
            Mandatory=$False,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ValueFromRemainingArguments=$false)]
        [string]$UserRunningScriptMachineName,
        [Parameter(
            Mandatory=$False,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ValueFromRemainingArguments=$false)]
        [string]$UserRunningScriptIPAddress
        )
begin {
	# Get Configuration, this should be in a different file
	$dwhMySqlServer = "localhost"
    $dwhMySqlUserName = "root"
    $dwhMySqlDatabase = "database"
    $dwhMySqlServerInstance = "host.databasee"
    $dwhMySqlPwd = $(Get-Content -Path \PowershellGlobexADModule\etc\$dwhMySqlServer.pwd).ToString()

}
process {
    $SQLParameters = New-Object -Type psobject -Property @{
        RunDate = $RunDate
        LogPrefixMessage = $LogPrefixMessage
        Username = $Username
        UserRunningScriptInvokedFunction = $UserRunningScriptInvokedFunction
        UserRunningScriptMachineName = $UserRunningScriptMachineName
        UserRunningScriptIPAddress = $UserRunningScriptIPAddress
        }
	$Query = "INSERT into LOG_AD_POSH values (NULL,@RunDate,@UserName,@UserRunningScriptInvokedFunction,@UserRunningScriptMachineName,@UserRunningScriptIPAddress)"
    $connection = New-Object MySql.Data.MySqlClient.MySqlConnection
    $ConnectionString = "Server=$dwhMySqlServer;Port=3306;Database=$dwhMySqlDatabase;Uid=$dwhMySqlUserName;Pwd=$dwhMySqlPwd;"
    $connection.ConnectionString = $ConnectionString
    Write-Verbose "Opening Connection..."
    $connection.Open()
	# send use command to database over connection
    $opencmd = New-Object MySql.Data.MySqlClient.MySqlCommand("USE $dwhMySqlDatabase", $connection)
    $command = New-Object MySql.Data.MySqlClient.MySqlCommand
    $command.CommandText = $query
    $command.Connection = $connection
    $command.Prepare()
	#construct query
    $command.Parameters.AddWithValue("@RunDate","") | Out-Null
    $command.Parameters.AddWithValue("@UserName","") | Out-Null
    $command.Parameters.AddWithValue("@UserRunningScriptInvokedFunction","") | Out-Null
    $command.Parameters.AddWithValue("@UserRunningScriptMachineName","") | Out-Null
    $command.Parameters.AddWithValue("@UserRunningScriptIpAddress","") | Out-Null
    $command.Parameters["@RunDate"].Value = $SqlParameters.RunDate
    $command.Parameters["@UserName"].Value = $SqlParameters.UserName
    $command.Parameters["@UserRunningScriptInvokedFunction"].Value = $SqlParameters.UserRunningScriptInvokedFunction
    $command.Parameters["@UserRunningScriptMachineName"].Value = $SqlParameters.UserRunningScriptMachineName
    $command.Parameters["@UserRunningScriptIpAddress"].Value = $SqlParameters.UserRunningScriptIpAddress
	# instanciate adapter and execute
    $dataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($command)
    $dataSet = New-Object System.Data.DataSet
	$recordCount = $dataAdapter.Fill($dataSet, "data")
	# result is a little difficult to read
    $result = $dataSet.Tables["data"]
}
end
{
	if($result)
	{
		return $true
	}
	else
	{
		return $false
	}
}
}