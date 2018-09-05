[string]$BranchDirectoryNumberPrefix = "13"
$UsersWithBranchPrefix = Get-ADUser -LDAPFilter "(&(objectClass=person)(telephoneNumber=$($BranchDirectoryNumberPrefix + "*")))" -properties telephoneNumber | `
    Where-Object { $_.telephoneNumber.Length -eq 6 }
$DirectoryPrefixesInUse = $UsersWithBranchPrefix | foreach {
		New-Object -TypeName PSObject -Property @{
            UserName = $_.UserPrincipalName
            DirectoryNumber = $_.telephoneNumber
            }
	}