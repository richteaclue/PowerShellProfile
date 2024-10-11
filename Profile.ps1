<#
Common profile for all terminal environments.
#>

Import-Module posh-git > $null


# Misc scripts
. "$PSScriptRoot\Utilities.ps1"
. "$PSScriptRoot\Secrets.ps1"
. "$PSScriptRoot\Alias.ps1"


if (Test-Path env:WT_SESSION) {
  # Windows Terminal
  . "$PSScriptRoot\OhMyPosh.ps1"
} elseif ( $env:TERM_PROGRAM -eq 'vscode') {
  # VS Code
  # Currently a rendering issue in VSCode Integrated Host with oh-my-posh
. "$PSScriptRoot\PoshGitPrompt.ps1"
}

# Need to install / import ZLocation *after* any prompt scripts
#if (-not (Get-InstalledModule -Name ZLocation -ErrorAction SilentlyContinue)) {
#  Install-Module -Name ZLocation -MinimumVersion 1.3.0
#}

Import-Module ZLocation

# Path modifications

# Disable the Python virtual environment prompt in poetry shell (the info is displayed by oh-my-posh instead)
$env:VIRTUAL_ENV_DISABLE_PROMPT=1


