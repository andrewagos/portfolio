
function Get-GlobexADServiceDeskTicket {
[CmdletBinding()]
	param (
        [Parameter(
		    Mandatory=$False)]
        [string]$HelpdeskURL = "https://helpdesk.globex.com/",
        [Parameter(
            Mandatory=$True)]
		[int]$TicketNumber,
        [string]$APIKey = $(Get-Content \GlobexAD\etc\apikey.key),
		[switch]$ReturnBoolean
    )
	$InputData = @{
		OPERATION_NAME = "GET_REQUEST"
		TECHNICIAN_KEY = $APIKey
		}
    $HelpdeskAPI = "sdpapi/request/"
    $Format = "json"
	$HelpdeskURI = $HelpdeskURL + $HelpdeskAPI
	$HelpdeskURIForRequest = $HelpdeskURI + $TicketNumber
	$data = Invoke-WebRequest -Uri $HelpdeskURIForRequest -Body $InputData -Method POST -TimeoutSec 10
	$Result = New-Object System.Xml.XmlDocument
	$Result.LoadXml($data.Content) 
    if ($ReturnBoolean) {
        if ($Result) {
            return $True
        } else {
            return $False
        }
    } else {
        $TicketDetailsHashTable = $Result.API.response.operation.Details.parameter
        $TicketDetails = New-Object -TypeName PSObject -Property @{
            TicketNumber = $($TicketDetailsHashTable | ? { $_.Name -eq 'workorderid'} | select Value).Value;
            Requester = $($TicketDetailsHashTable | ? { $_.Name -eq 'requester'} | select Value).Value;
            Category = $($TicketDetailsHashTable | ? { $_.Name -eq 'category'} | select Value).Value;
            Subcategory = $($TicketDetailsHashTable | ? { $_.Name -eq 'subcategory'} | select Value).Value;
            Technician = $($TicketDetailsHashTable | ? { $_.Name -eq 'technician'} | select Value).Value;
            }
        return $TicketDetails
    }

}
    
       