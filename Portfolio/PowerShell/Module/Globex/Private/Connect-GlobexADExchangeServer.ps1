function Connect-GlobexADExchangeServer { 
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ServerName,
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.CredentialAttribute()]
        $Credential
        )
    if ($(Get-PSSession | Where-Object { $_.ConfigurationName -eq "Microsoft.Exchange" })) {
        Write-Verbose "Exchange session already established."
        }
    else
        {
        try {
            $ExchangeSession = New-PSSession -ConnectionUri "http://$ServerName.Globex.com/powershell" -ConfigurationName Microsoft.Exchange -Authentication Kerberos -Credential $Credential -Name "GlobexAD Exchange Session"
            Import-PSSession $ExchangeSession -AllowClobber
            }
        catch
            {
            Remove-PSSession $ExchangeSession
            Write-Error "Unable to connect to Exchange."
            }
        }
   Write-Verbose "Connected to Exchange."
}
