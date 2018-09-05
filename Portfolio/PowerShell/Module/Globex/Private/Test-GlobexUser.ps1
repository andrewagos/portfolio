
function Test-HarvardUser {
	[CmdletBinding()]
    param (
        [string]$username
    )
    try {
        Get-ADUser -Identity $username | Out-Null
        return $true
    }
    catch 
    {
        return $false
    }
}