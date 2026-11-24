#########################################
#
# Profile script to configure prompt for PowerShell Core
#
#########################################

param(
  [string]$Theme = 'GonzoDog.omp.yaml'
)

$esc = [char]0x1b
$colors = @{
    Command = "${esc}[93m"
    Comment = "${esc}[32m"
    ContinuationPrompt = "${esc}[37m"
    Emphasis = "${esc}[96m"
    Error = "${esc}[91m"
    Keyword = "${esc}[92m"
    Member = "${esc}[97m"
    Number = "${esc}[97m"
    Operator = "${esc}[74m"
    Parameter = "${esc}[74m"
    #Prediction = "${esc}[38;5;238m"
    Selection = "${esc}[30;47m"
    String  = "${esc}[38;5;100m"
    Type = "${esc}[37m"
    Variable = "${esc}[92m"
    Default = "${esc}[37m"
}

Set-PSReadLineOption -Colors $colors

$env:POSH_SESSION_DEFAULT_USER = 'Rich.Tebb'
$theme_path = Join-Path $PSScriptRoot "PoshThemes\$Theme"

$ompInit = oh-my-posh init pwsh --config $theme_path
if ($LASTEXITCODE -ne 0 -or -not $ompInit) {
  throw "Oh My Posh initialization failed (exit code $LASTEXITCODE)."
}
Invoke-Expression ($ompInit | Out-String)
