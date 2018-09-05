
function Generate-GlobexUsername {
	[CmdletBinding()]
	param(
	[string[]]$FirstName,
	[string[]]$LastName
	)
 
   # try first initial lastname, loop
   [int]$i = 1
   $Username = $FirstName.Substring(0,$i)+$LastName.ToLower()

 
   # if first test fails, trap errors
   while((Test-HarvardUser $Username) -and ($i -lt 5)) {
       $i++
	   if ($i -eq 2) {
	      $Username = $Firstname.ToLower() + "." + $LastName.ToLower()
	   }
	   if ($i -eq 3) {
	      $UserName = $FirstName.SubString(0,1)+"."+$LastName.ToLower()
	   }
       if ($i -eq 4) {
          $UserName = $null
          Write-Error "I ran out of usernames."
       }
   }
 
   #unique username returned
   
   return $Username
}
