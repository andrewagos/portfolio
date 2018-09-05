function New-MySqlConnection { 
[CmdletBinding()]
    param(
	    [string]$dwhMySqlUserName,
	    [string]$dwhMySqlPwd,
	    [string]$dwhMySqlServer,
	    [string]$dwhMySqldatabase)

  $connStr = "server=" + $dwhMySqlServer + ";port=3306;uid=" + $dwhMySqlUserName + ";pwd=" + $dwhMySqlPwd + ";database="+$dwhMySqldatabase+";Pooling=FALSE"
  $conn = New-Object MySql.Data.MySqlClient.MySqlConnection($connStr)
  $conn.Open()
  $cmd = New-Object MySql.Data.MySqlClient.MySqlCommand("USE $($dwhMySqldatabase)", $conn)
  return $conn
 
}

