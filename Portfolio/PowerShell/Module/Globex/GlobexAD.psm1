
	$Public = @( Get-Childitem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
	$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )
	[void][system.reflection.Assembly]::LoadFrom($($PSScriptRoot + "\lib\mysql\MySQL.Data.dll"))
	Foreach ($import in @($Public + $Private))
	{
		Try
		{
			. $import.fullname
		}
		Catch
		{
			Write-Error -Message "Failed to import function $($import.fullname): $_"
		}
	}
	
	