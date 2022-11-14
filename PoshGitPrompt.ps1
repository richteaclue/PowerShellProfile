#########################################
#
# Profile script to configure prompt for PowerShell Core
#
#########################################

# try {
#   $module = Get-InstalledModule posh-git -ErrorAction SilentlyContinue

#   if (-not $module) {
#     Install-Module posh-git -AllowPrerelease -ErrorAction Stop
#   }
# }
# catch {
#   exit(1)
# }

# Import-Module posh-git

# Requires posh-git 1.0.0-beta3 or later
$GitPromptSettings.DefaultPromptAbbreviateHomeDirectory = $true
$GitPromptSettings.DefaultPromptSuffix = ' $(">" * ($nestedPromptLevel + 1)) '
$GitPromptSettings.DefaultPromptWriteStatusFirst = $true

# See https://github.com/dahlbyk/posh-git/issues/469
$GitPromptSettings.DefaultPromptPath = '$(Get-ShortPromptPath)'

$GitPromptSettings.DefaultPromptPath.ForegroundColor = [ConsoleColor]::Yellow
$GitPromptSettings.BeforeStatus.ForegroundColor = [ConsoleColor]::DarkYellow
$GitPromptSettings.AfterStatus.ForegroundColor = [ConsoleColor]::DarkYellow

$GitPromptSettings.DefaultPromptSuffix = ' $(Get-PromptSuffix) '

function Get-PromptSuffix {
  $adminPrompt = ""
  $promptTerminator = ">"
  if ((Get-Command 'Test-Administrator') -and (Test-Administrator)) {
    $adminPrompt = "[ADMIN] "
    $promptTerminator = "#"
  }
  $terminator = ($promptTerminator * ($nestedPromptLevel + 1))
  return $adminPrompt + $terminator
}

function Get-PathStringComparison {
  # File system paths are case-sensitive on Linux and case-insensitive on Windows and macOS
  if (($PSVersionTable.PSVersion.Major -ge 6) -and $IsLinux) {
    [System.StringComparison]::Ordinal
  }
  else {
    [System.StringComparison]::OrdinalIgnoreCase
  }
}
function Get-ShortPromptPath {
  $pathInfo = $ExecutionContext.SessionState.Path.CurrentLocation
  $currentPath = if ($pathInfo.Drive) { $pathInfo.Path } else { $pathInfo.ProviderPath }
  $stringComparison = Get-PathStringComparison

  if ($currentPath.Equals($Home, $stringComparison)) {
    $currentPath = "~"
  } else {
    $currentPath = Split-Path -Leaf $pathInfo
  }

  return $currentPath
}
