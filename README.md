# Powershell Profile

The following modules need to be installed:

- ZLocation (>= 1.4.3)

- PSReadLine (>= 2.2.6)

- Microsoft.PowerShell.SecretManagement (>= 1.1.2)

Also need to install [Oh My Posh](https://ohmyposh.dev/docs/installation/windows).

For example:

```ps
Install-Module PSReadline
Install-Module Microsoft.PowerShell.SecretManagement
Install-Module ZLocation
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))
```

Once you have installed Oh My Posh, run

```ps
oh-my-posh font install
```

and select the Meslo face (or any other, this is the one I prefer).

__Note:__ you may need to restart the shell a few times, especially after
installing Oh My Posh.
