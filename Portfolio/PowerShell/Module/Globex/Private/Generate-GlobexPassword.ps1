function Generate-HarvardPassword {
   [CmdletBinding()]
   #there is a better way to do this I'm sure.
   $GUID = [guid]::NewGuid().guid.split('-')
 
   return ("Globex" + $GUID[1])
 
}
