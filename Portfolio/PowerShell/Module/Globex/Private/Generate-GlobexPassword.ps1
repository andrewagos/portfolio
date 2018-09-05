function Generate-GlobexPassword {
   [CmdletBinding()]
   $GUID = [guid]::NewGuid().guid.split('-')
 
   return ("Globex" + $GUID[1])
 
}
