<#
Common profile for all terminal environments.
#>

###############################################################################
# NOTE: for performance reasons, this profile uses async initialization. This
# means that a dummy prompt will be displayed before all modules are loaded, and
# then gets updated after all modules are loaded. This is done to make the
# terminal responsive as soon as possible. The async initialization is done by
# registering an idle event that runs the initialization script. See
# https://www.kotsenas.com/posts/pwsh-profiling-async-startup for more
# information.
###############################################################################

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

# Async PS startup for responsiveness, see https://www.kotsenas.com/posts/pwsh-profiling-async-startup
function prompt {
  # We will override this prompt, however because it is loading async we want to communicate that the real prompt is still loading.
  "[async init]: PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) ";
}

$root = $PSScriptRoot
if (-not ($root)) {
  $root = (Join-Path $HOME 'Documents\PowerShell')
}

. (Join-Path $root "Utilities.ps1")
. (Join-Path $root "Alias.ps1")

$omp = Get-Command (Join-Path $root "OhMyPosh.ps1") | Select-Object -ExpandProperty ScriptBlock
$pgp = Get-Command (Join-Path $root "PoshGitPrompt.ps1") | Select-Object -ExpandProperty ScriptBlock

$actions = @(
  {
    Import-Module posh-git
  },
  {
    Import-Module Microsoft.PowerShell.SecretManagement

    # Secrets should be set with the Set-Secret command, e.g.
    # Set-Secret -Name MyStringToken
    # (will prompt for value)

    #$env:AZP_AGENT_TOKEN = (Get-Secret -Name 'AZP_AGENT_TOKEN' -AsPlainText -ErrorAction Continue)

    # Secrets for Azure / Terraform
    #$env:ARM_CLIENT_SECRET = (Get-Secret -Name 'ARM_CLIENT_SECRET' -AsPlainText -ErrorAction Continue)
  },
  {
    Import-Module -Name Terminal-Icons -Global
  }
)

if (Test-Path env:WT_SESSION) {
  $actions += $omp
} elseif ( $env:TERM_PROGRAM -eq 'vscode') {
  # VS Code
  # Currently a rendering issue in VSCode Integrated Host with oh-my-posh, so we use Posh-Git prompt
  $actions += $pgp
  $actions += {
    function Global:prompt {
      # Your non-prompt logic here
  
      # Have posh-git display its default prompt
      & $GitPromptScriptBlock
    }
  }
} else {
  $actions += $pgp
  $actions += {
    function Global:prompt {
      # Your non-prompt logic here
  
      # Have posh-git display its default prompt
      & $GitPromptScriptBlock
    }
  }
}

$actions +=
{
  # Dependency: https://github.com/ajeetdsouza/zoxide
  Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

$__initQueue = [System.Collections.Queue](New-Object System.Collections.Queue)
$actions | ForEach-Object { $__initQueue.Enqueue($_) }

# Register our idle callback; use `-SupportEvent` to hide the registration from the user
Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -SupportEvent -Action {
  Write-Output "Running idle script..."
  if ($__initQueue.Count -gt 0) {
    & $__initQueue.Dequeue()
  } else {
    # NOTE: Use `-Force` when unregistering because we used `-SupportEvent` when registering
    Unregister-Event -SubscriptionId $EventSubscriber.SubscriptionId -Force

    # Remove our queue variable to avoid polluting the environment
    Remove-Variable -Name '__initQueue' -Scope Global -Force

    # Re-render the prompt so we get pretty colors ASAP!
    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
  }
}
