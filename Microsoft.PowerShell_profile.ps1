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
# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
