function Add-GlobexADServiceDeskNotes {
[CmdletBinding()]
	param (
		[string]$TicketNumber,
		[string]$APIKey = $(Get-Content \GlobexAD\etc\apikey.key),
		[string]$NoteToAdd
	)


    $NoteInputBody = @"
<?xml version='1.0' encoding='utf-8'?>
    <Operation>
        <Details>
            <Notes>
                <Note>
                    <isPublic>false</isPublic>
                    <notesText>$NoteToAdd</notesText>
                </Note>
            </Notes>
        </Details>
    </Operation>
"@
	$InputData = @{
		OPERATION_NAME = "ADD_NOTE"
		TECHNICIAN_KEY = $APIKey
        INPUT_DATA = $NoteInputBody
	}

    
    $HelpdeskURL = "https://helpdesk.globex.com/"
    $HelpdeskAPI = "sdpapi/request/"
    $Format = "json"
    $HelpdeskURI = $HelpdeskURL + $HelpdeskAPI
    $HelpdeskURIForRequest = $HelpdeskURI + $TicketNumber
    
    $HelpdeskURIForRequestNotes = $HelpdeskURIForRequest + "/notes/"
    $data = Invoke-WebRequest -Uri $HelpdeskURIForRequestNotes -Body $InputData -Method POST -TimeoutSec 10
    $Result = New-Object System.Xml.XmlDocument
    $Result.LoadXml($data.Content) 

$ResultStatus = $result.API.response.operation.result | select status

if ($ResultStatus.status -eq "Failed") {
    Write-Error $_
    Write-Error "The request failed. $(($Result.API.response.operation.result | select message).Message)"
    return $False
    } else {
    return $True 
    }
	
}
