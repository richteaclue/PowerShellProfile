<#
Initializes the console colors etc. for the PowerShell command window.
 #>

 function Initialize-Console
 {
     if ((Get-Command 'Test-Administrator') -and (Test-Administrator)) {
         $HOST.UI.RawUI.BackgroundColor = "DarkBlue"
         $HOST.UI.RawUI.ForegroundColor = "White"
     } else {
         $HOST.UI.RawUI.BackgroundColor = "Black"
         $HOST.UI.RawUI.ForegroundColor = "White"
     }
 }
 
 Initialize-Console