<#
Common profile for all terminal environments.
#>

# Import-Module posh-git > $null


# Misc scripts
. "$PSScriptRoot\Utilities.ps1"
. "$PSScriptRoot\Secrets.ps1"
. "$PSScriptRoot\Alias.ps1"


# Currently a rendering issue in VSCode Integrated Host with oh-my-posh
if (($PSVersionTable.PSEdition -eq 'Core') -and ($Host.Name -ne 'Visual Studio Code Host')) {
  . "$PSScriptRoot\OhMyPosh.ps1"
} else {
  # . "$PSScriptRoot\PoshGitPrompt.ps1"
  . "$PSScriptRoot\OhMyPosh.ps1"
}

# Need to install / import ZLocation *after* any prompt scripts
#if (-not (Get-InstalledModule -Name ZLocation -ErrorAction SilentlyContinue)) {
#  Install-Module -Name ZLocation -MinimumVersion 1.3.0
#}

Import-Module ZLocation

# Path modifications
# $path = "C:\Users\rich\AppData\Roaming\Python\Python37\Scripts"
# if (Test-Path $path)
# {
#     $env:PATH = $env:PATH + ";" + $path
# }

# Disable the Python virtual environment prompt in poetry shell (info is handled by OMP)
$env:VIRTUAL_ENV_DISABLE_PROMPT=1


