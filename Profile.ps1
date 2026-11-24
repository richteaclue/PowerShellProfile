<#
Common profile for all terminal environments.
#>

function Get-ProfileEnvironment {
  param(
    [string]$HostName = $Host.Name,
    [string]$TermProgram = $env:TERM_PROGRAM,
    [string]$WindowsTerminalSession = $env:WT_SESSION,
    [string]$VisualStudioInstallDir = $env:VCIDEInstallDir
  )

  if ($HostName -eq 'Package Manager Host') {
    return 'nuget'
  }
  if ($HostName -eq 'Visual Studio Code Host') {
    return 'vscode-powershell'
  }
  if ($TermProgram -eq 'vscode') {
    return 'vscode-terminal'
  }
  if ($WindowsTerminalSession) {
    return 'windows-terminal'
  }
  if ($VisualStudioInstallDir) {
    return 'visual-studio-developer'
  }
  return 'console'
}

$profilePolicies = @{
  'windows-terminal' = @{
    Prompt = 'oh-my-posh'
    Theme = 'GonzoDog.omp.yaml'
  }
  'vscode-terminal' = @{
    Prompt = 'oh-my-posh'
    Theme = 'GonzoDogCopilot.omp.yaml'
  }
  'vscode-powershell' = @{
    Prompt = 'posh-git'
  }
  'visual-studio-developer' = @{
    Prompt = 'posh-git'
  }
  'nuget' = @{
    Prompt = 'none'
  }
  'default' = @{
    Prompt = 'posh-git'
  }
}

$profileEnvironment = Get-ProfileEnvironment
$profilePolicy = if ($profilePolicies.ContainsKey($profileEnvironment)) {
  $profilePolicies[$profileEnvironment]
} else {
  $profilePolicies['default']
}

if ($profilePolicy.Prompt -eq 'none') {
  return
}

# Path modifications

# Disable the Python virtual environment prompt in poetry shell (the info is displayed by oh-my-posh instead)
$env:VIRTUAL_ENV_DISABLE_PROMPT=1

# Prevent adding to command history if the command starts with a space
Set-PSReadLineOption -AddToHistoryHandler {
  param($command)
  if ($command -like ' *') {
      return $false
  }
  return $true
}

$root = $PSScriptRoot
if (-not ($root)) {
  $root = (Join-Path $HOME 'Documents\PowerShell')
}

. (Join-Path $root "Utilities.ps1")
. (Join-Path $root "Alias.ps1")

if ($profilePolicy.Prompt -eq 'oh-my-posh') {
  # Requires installing oh-my-posh with winget: `winget install JanDeDobbeleer.OhMyPosh --source winget`
  # Also requires installing a Nerd Font and setting it in the Windows Terminal settings, e.g. "CascadiaCove NFM"
  # Download fonts from https://www.nerdfonts.com/font-downloads
  $omp = Get-Command (Join-Path $root "OhMyPosh.ps1") | Select-Object -ExpandProperty ScriptBlock
  New-Module -ScriptBlock $omp -ArgumentList $profilePolicy.Theme -ErrorAction Stop |
    Import-Module -Global -ErrorAction Stop
} elseif ($profilePolicy.Prompt -eq 'posh-git') {
  Import-Module posh-git -Global -ErrorAction Stop
  . (Join-Path $root "PoshGitPrompt.ps1")
  function Global:prompt {
    & $GitPromptScriptBlock
  }
} else {
  throw "Unsupported prompt mechanism '$($profilePolicy.Prompt)' for environment '$profileEnvironment'."
}

# Reinstall zoxide's prompt hook when reloading the profile after changing the prompt.
# Dependency: https://github.com/ajeetdsouza/zoxide
$zoxideInit = zoxide init powershell
if ($LASTEXITCODE -ne 0 -or -not $zoxideInit) {
  throw "zoxide initialization failed (exit code $LASTEXITCODE)."
}
$global:__zoxide_hooked = 0
Invoke-Expression ($zoxideInit | Out-String)
