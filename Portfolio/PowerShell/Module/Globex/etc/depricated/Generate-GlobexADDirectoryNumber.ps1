function Generate-GlobexADDirectoryNumber {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,
        ValueFromPipelineByPropertyName=$True,
        ValidateSet("ElkGroveVillage","NYC","Corporate","Minnesota","FtLauderdale")]
        [string[]]$Branch,
        [Parameter(Mandatory=$False)]
        [string[]]$DomainController = "globexad1"
    )
    switch($Branch) {
        ElkGroveVillage { $BranchDirectoryNumberPrefix = "13" }
        NYC { $BranchDirectoryNumberPrefix = "11" }
        Corporate { $BranchDirectoryNumberPrefix = "24" }
        Minnesota { $BranchDirectoryNumberPrefix = "14" }
        FtLauderdale { $BranchDirectoryNumberPrefix = "21" }
        }
	$UsersWithBranchPrefix = Get-ADUser -LDAPFilter "(&(objectClass=person)(telephoneNumber=$($BranchDirectoryNumberPrefix + "*")))" -properties telephoneNumber | `
    Where-Object { $_.telephoneNumber.Length -eq 6 }
	$DirectoryPrefixesInUse = $UsersWithBranchPrefix | foreach {
		New-Object -TypeName PSObject -Property @{
            UserName = $_.UserPrincipalName
            DirectoryNumber = $_.telephoneNumber
            }
	}
	
