function Get-GlobexADInvocationContext 
{
    [CmdletBinding()]
    param(
    [Parameter(Mandatory=$False)]
    [string]$UserRunningScriptInvokedFunction = $($MyInvocation.MyCommand.Name)
    )
    $RunDate = $(get-date).ToShortDateString()
	[regex]$IPrx = "(?:\d{1,3}\.){3}\d{1,3}"
    $UserRunningScriptUserName = [Environment]::UserName
    $UserRunningScriptMachineName = [Environment]::MachineName
    $UserRunningScriptNetworkInformation = (Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter "IPEnabled = 'True'").IPAddress
	$UserRunningScriptIpAddress = ($UserRunningScriptNetworkInformation -match $IPrx).ToString()
    [string]$LogPrefixMessage = $($RunDate + " - " + "User: " + $UserRunningScriptUserName + " invoked function named: " + $UserRunningScriptInvokedFunction + " from " + 
    $UserRunningScriptMachineName + " at IP Address: " + $UserRunningScriptIpAddress + ".")
    $GlobexADInvocationContext = New-Object -Type PsObject -Property @{
        RunDate = $RunDate;
        UserName = $UserRunningScriptUserName;
        UserRunningScriptMachineName = $UserRunningScriptMachineName;
        UserRunningScriptIpAddress = $UserRunningScriptIpAddress[0];
        UserRunningScriptInvokedFunction = $UserRunningScriptInvokedFunction;
        LogPrefixMessage = $LogPrefixMessage
        }

    return $GlobexADInvocationContext

}