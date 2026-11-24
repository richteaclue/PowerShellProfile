# Powershell Profile

## Environment policies

[Profile.ps1](Profile.ps1) defines `Get-ProfileEnvironment` and a
`$profilePolicies` table controlling the prompt, Oh My Posh theme, and async
initialization:

| Environment ID | Detection | Prompt | Initialization |
| --- | --- | --- | --- |
| `nuget` | Host name `Package Manager Host` | Preserve the host prompt; skip terminal setup | None |
| `vscode-powershell` | Host name `Visual Studio Code Host` | posh-git | Synchronous |
| `vscode-terminal` | `TERM_PROGRAM` is `vscode` | Oh My Posh, simplified theme | Synchronous |
| `windows-terminal` | Nonempty `WT_SESSION` | Oh My Posh, full theme | Async |
| `visual-studio-developer` | Nonempty `VCIDEInstallDir`, without a match above | posh-git | Synchronous |
| `console` / unlisted IDs | Fallback policy (`default`) | posh-git | Async |

Detection follows the table's order. In particular, inherited `WT_SESSION`
cannot override a VS Code host or terminal. `VCIDEInstallDir` is a developer
environment marker, not proof of which terminal displays the session; a
recognized terminal takes precedence.

Run `Get-ProfileEnvironment` to inspect the detected ID. Change the policy table
to adjust behavior. The OMP theme is selected explicitly by the policy, not by
`VSCODE_INJECTION`. Zoxide initializes after the selected prompt so its
directory-learning hook wraps that prompt.

These policies apply when this common profile is loaded. They do not install or
restore the separate Windows PowerShell 5.1 profiles.

## Installation

The following modules need to be installed:

- PSReadLine (>= 2.2.6)

- Microsoft.PowerShell.SecretManagement (>= 1.1.2)

- posh-git

Also need to install [Oh My Posh](https://ohmyposh.dev/docs/installation/windows).

For example:

```ps
Install-Module PSReadline -Force
Install-Module Microsoft.PowerShell.SecretManagement  -Force
Install-Module posh-git -Force
winget install JanDeDobbeleer.OhMyPosh --force
winget install ajeetdsouza.zoxide --force
winget install junegunn.fzf --force
```

Once you have installed Oh My Posh, run

```ps
oh-my-posh font install
```

and select the Meslo face (or any other, this is the one I prefer).

__Note:__ you may need to restart the shell a few times, especially after
installing Oh My Posh.

## Tests

With Pester installed, run:

```ps
Invoke-Pester .\Tests\Profile.Tests.ps1
```
