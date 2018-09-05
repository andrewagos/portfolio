##  Query GlobexADUser Object using MS SQL Data
#requires -version 3
#requires -module ActiveDirectory

function Get-GlobexADUserFromERP {
[CmdletBinding()]
    param (
        [Parameter(
            Mandatory=$False,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ValueFromRemainingArguments=$false)]
        [string]$Firstname,
        [Parameter(
            Mandatory=$False,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ValueFromRemainingArguments=$false)]
        [string]$LastName,
        [Parameter(
            Mandatory=$False,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            ValueFromRemainingArguments=$false)]
        [int]$EmployeeNumber = $null,
        [Parameter(
            Mandatory=$False,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
        [string]$SamAccountName,
        [Parameter(
            Mandatory=$False)]
        [switch]$UseERP = $False
        )

	begin
	{
		$LookupType = $null
		if ($EmployeeNumber) 
		{
			$LookupType = "EmployeeNumber"
		} 
		else 
		{
        if ($SamAccountName) 
		{
            $LookupType = "SamAccountName"
		} 
		else 
		{ 
			if ($Lastname -and $Firstname) 
			{
                $LookupType = "FirstandLast" 
			}
			else 
			{
                if ($Lastname) 
				{
			        $LookupType = "LastName"
			        Write-Warning "$($LookupType) is not well supported.  This script will attempt to lookup EmployeeNumber from AD."
		        } 
				else 
				{
			        $LookupType = "FirstName"
			        Write-Warning "$($LookupType) is not well supported.  This script will attempt to lookup EmployeeNumber from AD."
			    }
            }
		}
        }
        $ReportingSqlServer = "localhost"
        $ReportingSqlUserName = "username"
        $ReportingSqlDatabase = "ERP"
		# 201803 - find a better way to do this - production will use readhost for pwd
        $ReportingSqlPwd = $(Get-Content -Path \PowershellGlobexADModule\etc\$ReportingSqlServer.pwd).ToString()
        $ReportingSqlCPwd = ConvertTo-SecureString $ReportingSqlPwd -AsPlainText -Force
        $ReportingSqlCredential = New-Object System.Management.Automation.PSCredential $ReportingSqlUserName, $ReportingSqlCPwd
		#Log The Invocation
        $LogObject = $(Get-GlobexADInvocationContext -UserRunningScriptInvokedFunction $($MyInvocation.MyCommand.Name))
        $LogObject | Log-GlobexADInvocationContext
	}
	Process
	{
        if ($LookupType) 
		{
            Write-Verbose "Lookup type is $lookuptype"
        } 
		else 
		{
            Write-Error "Lookup type is $LookupType"
            break;
        }
		switch ($LookupType) 
		{
			'EmployeeNumber' { $user = Get-ADUser -Filter { EmployeeNumber -eq $EmployeeNumber } -Properties EmployeeNumber,EmailAddress }
			'LastName' { $user = Get-ADUser -Filter { Surname -like $LastName } -Properties EmployeeNumber,EmailAddress }
			'Firstname' { $user = Get-ADUser -Filter { DisplayName -like $Firstname } -Properties EmployeeNumber,EmailAddress }
            'SamAccountName' { $user = Get-ADUser -Identity $SamAccountName -Properties EmployeeNumber,EmailAddress }
		}
	
		if ($user.Count -ne 1) 
		{
			Write-Warning "Issues with returned data?"
		}
        if ($user.EmployeeNumber) 
		{ 
            Write-Verbose "EmployeeNumber found.  Querying ERP with this data."
            $LookupType = "EmployeeNumber"
        } 
		else 
		{
            Write-Warning "Still using $LookupType.  This could cause inconsistent data."
        }
        
        switch ($LookupType) 
		{
				'EmployeeNumber' {  
					$SqlParameters = New-Object -TypeName PSObject -Property @{
						EmployeeNumber = $user.EmployeeNumber
						ADStatus = $user.Enabled
						ADDistinguishedName = $user.DistinguishedName
						ADEmailAddress = $user.EmailAddress
						}
					$Query = "select
									PayEmployees.EmployeeNumber,
									PayEmployeesClassifications.Description as ""Department"",
									PayEmployees.PrimaryJob,
									EmployeeSupervisors_name.LastName as ""SupervisorLastname"",
									EmployeeSupervisors_name.EmployeeNumber as ""SupervisorEmployeeNumber"",
									Jobs.JobCity,
									Jobs.JobState as ""State"",
									JobsTier2.Description as ""Division"",
									JobsTier1.Description as ""Office"",
									@ADStatus as ""ADStatus"",
									@ADDistinguishedName as ""ADDistinguishedName"",
									@ADEmailAddress as ""ADEmailAddress""
								from PAY_EMPLOYEES PayEmployees
								inner join PAY_EMPLOYEES_Supervisors EmployeeSupervisors
									on PayEmployees.SupervisorID = EmployeeSupervisors.ID
								inner join PAY_EMPLOYEES EmployeeSupervisors_name
									on EmployeeSupervisors_name.EmployeeNumber = EmployeeSupervisors.EmployeeNumber
								inner join PAY_EMPLOYEES_Classifications PayEmployeesClassifications
									on PayEmployeesClassifications.ID = PayEmployees.ClassificationID
								inner join JOBS Jobs
									on Jobs.JobNumber = PayEmployees.PrimaryJob
								inner join JOBS_TierPatterns_Tier2 JobsTier2
									on Jobs.Tier2ID = JobsTier2.ID
								inner join JOBS_TierPatterns_Tier1 JobsTier1
									on Jobs.Tier1ID = JobsTier1.ID
								where PayEmployees.EmployeeNumber = @EmployeeNumber"
	
					$SqlParameters = ConvertPSObjectToHashtable $SqlParameters
					
				}
				'Lastname' {
					# Unsupported at this time.
				}
				'FirstName' {
					# Unsupported at this time.  Remove this lookup type as it would be inconsistent anyway.
				}
				'SamAccountName' {
					# Unsupported at this time.
				}
		}
		$result = Invoke-Sqlcmd2 -Server $ReportingSqlServer -Database $ReportingSqlDatabase -Query $Query -SqlParameters $SqlParameters -As PSObject -Credential $ReportingSqlCredential
	}
	end
	{
        return $result
	}
}
