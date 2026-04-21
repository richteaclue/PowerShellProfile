# Powershell Profile

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
