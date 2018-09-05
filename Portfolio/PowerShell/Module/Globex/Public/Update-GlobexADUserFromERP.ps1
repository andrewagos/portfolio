## Update AD User from ERP
#requires -version 3
#requires -module ActiveDirectory

function Update-GlobexADUserFromERP { 
[CmdletBinding()]
    param (
        [Parameter(
            Mandatory=$True,
            Position=0,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ValueFromRemainingArguments=$false)]
        [Alias("ADDistinguishedName")]
        [string[]]$DistinguishedName,
        [Parameter(
            Mandatory=$True,
            Position=1,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ValueFromRemainingArguments=$false)]
		[string]$Department,
        [Parameter(
            Mandatory=$True,
            Position=2,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ValueFromRemainingArguments=$false)]
        [Alias('PrimaryJob')]
		[string]$JobNumber,
        [Parameter(
            Mandatory=$True,
            Position=3,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ValueFromRemainingArguments=$false)]
		[string]$SupervisorEmployeeNumber,
        [Parameter(
            Mandatory=$True,
            Position=4,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ValueFromRemainingArguments=$false)]
		[string]$State,
        [Parameter(
            Mandatory=$True,
            Position=5,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ValueFromRemainingArguments=$false)]
		[string]$Division,
		[Parameter(
            Mandatory=$True,
            Position=6,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ValueFromRemainingArguments=$false)]
		[string]$Office,
		[Parameter(
            Mandatory=$True,
            Position=7,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ValueFromRemainingArguments=$false)]
		[Alias('ADEmailAddress')]
		[string]$EmailAddress,
        [Parameter(
            Mandatory=$True,
            Position=8,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ValueFromRemainingArguments=$false)]
        [Alias('JobCity')]
        [string]$City,
        [Parameter(
            Mandatory=$false)]
        [string]$OutPath="c:\Temp\Outfile.csv"
            
	)

begin 
{
    $LogObject = $(Get-GlobexADInvocationContext -UserRunningScriptInvokedFunction $($MyInvocation.MyCommand.Name))
	$LogObject | Log-GlobexADInvocationContext
}
 
    process {
        foreach ($user in $DistinguishedName) {
            Write-Output "Setting $DistinguishedName"
            $EmployeeNumber = $_.EmployeeNumber
            $SupervisorEmployeeNumber = $_.SupervisorEmployeeNumber
            $SupervisorLastName = $_.SupervisorLastName
            $Department = $_.Department
            $Division = $_.Division
            $Office = $_.Office
            $State = $_.State
            $City = $_.City
            $ADDistinguishedName = $_.ADDistinguishedName
            $CurrentObjectState = Get-Aduser -Identity $ADDistinguishedName -properties EmployeeNumber,Department,JobNumber,ManagedBy,State,Division,Office,EmailAddress
            Write-Output "Backing up settings..."
            $CurrentObjectState | Export-CSV $OutPath -append -NoTypeInformation -Force
            $SupervisorDistinguishedName = Get-AdUser -filter { EmployeeNumber -like $SupervisorEmployeeNumber } -Properties EmployeeNumber | Select DistinguishedName
            $NewObjectState = New-Object -Type PSObject -Property @{
                Department = $Department
                Division = $Division
                Office = $Office
                State = $State
                ManagedBy = $SupervisorDistinguishedName.DistinguishedName
                DistinguishedName = $ADDistinguishedName
            }
            try 
			{
                Set-Aduser -identity $NewObjectState.DistinguishedName -add @{Department=$NewObjectstate.Department}
            } 
			catch 
			{
                Set-Aduser -identity $NewObjectState.DistinguishedName -replace @{Department=$NewObjectstate.Department}
            }
            try 
			{
                Set-Aduser -identity $NewObjectState.DistinguishedName -add @{Division=$NewObjectstate.Division}
            } 
			catch 
			{
                Set-Aduser -identity $NewObjectState.DistinguishedName -replace @{Division=$NewObjectstate.Division}
            }
            try 
			{
                Set-Aduser -identity $NewObjectState.DistinguishedName -add @{Office=$NewObjectstate.Office}
            } 
			catch 
			{
                Set-Aduser -identity $NewObjectState.DistinguishedName -office $Office
            }
            try 
			{
                Set-Aduser -identity $NewObjectState.DistinguishedName -add @{State=$NewObjectstate.State}
            } catch 
			{
                Set-Aduser -identity $NewObjectState.DistinguishedName -State $State
            }
            try 
			{
                Set-Aduser -identity $NewObjectState.DistinguishedName -add @{Manager=$NewObjectstate.ManagedBy}
            } 
			catch 
			{
                Set-Aduser -identity $NewObjectState.DistinguishedName -replace @{Manager=$NewObjectstate.ManagedBy}
            }
            try 
			{
                Set-ADuser -Identity $NewObjectState.DistinguishedName -Add @{City=$NewObjectState.City}
            } 
			catch 
			{
                Set-ADuser -Identity $NewObjectState.DistinguishedName -replace @{City=$NewObjectState.City}
            }
        }
	}
	end
	{
	}
}
