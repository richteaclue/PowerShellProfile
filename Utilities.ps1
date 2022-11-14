#########################################
#
# Profile script to set up utility commands
#
#########################################

function which($name)
{
    Get-Command $name | Select-Object -ExpandProperty Definition
}

function Test-Administrator
{
    return ([Security.Principal.WindowsPrincipal] `
                [Security.Principal.WindowsIdentity]::GetCurrent() `
            ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-ModuleLoaded($name)
{
    if (Get-Module -Name $name) {
        return $true
    } else {
        return $false
    }
}

<#
.SYNOPSIS
    Removes Git branches that only exist in the local repository.
.PARAMETER Force
    Perform the operation without prompting for confirmation.
#>
function Remove-GitStaleBranches
{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # This switch allows the user to override the prompt for confirmation
        [switch]$Force
    )

    begin { }
    process {
        git remote prune origin
        $orphans = (git branch -vv | `
             Where-Object {$_ -match '\[origin/.*: gone\]'} | `
             ForEach-Object {$_.split(" ", [StringSplitOptions]'RemoveEmptyEntries')[0]})
        if ($null -eq $orphans) {
            Write-Host 'Nothing to do: all local branches have a corresponding remote'
            return
        }

        $unmerged = git branch --no-merged

        $orphanList = $orphans -join "`n"
        if ($PSCmdlet.ShouldProcess('Target')) {
            if (-not ($Force -or $PSCmdlet.ShouldContinue(
                "Do you want to continue?`nThe following branches will be deleted:`n$orphanList",
                'Delete orphaned local branches'
                ))) {
                return # user replied no
            }

            $orphans | ForEach-Object { 
                if ($unmerged -match $_) {
                    # Branch is unmerged - confirm delete
                    if ($PSCmdlet.ShouldContinue(
                        "Delete branch anyway (and lose changes)?`nThe branch '$_' is not fully merged",
                         'Unmerged changes detected'
                         )) {
                        git branch -D $_ 
                    }
                } else {
                    # Branch is merged
                    git branch -d $_ 
                }
            }
        }
    }
    end { }
}

function Set-FileDate {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true, Mandatory = $true, Position = 0)]
        [string[]]$Path,
        [Parameter(Mandatory = $false, Position = 1)]
        [datetime]$NewDate = (Get-Date),
        [switch]$Force
    )
    Add-Content $Path $null
    Get-Item $Path -Force:$Force | ForEach-Object { $_.LastWriteTime = $NewDate }
}
Set-Alias Touch Set-FileDate -Description "Updates the LastWriteTime for the file(s)"

function Start-JMeter {
    $jmeterLocation = 'C:\Users\rich.tebb\bin\apache-jmeter-5.3\bin'

    if (-not (Test-Path $jmeterLocation -PathType Container)) {
        throw "JMeter installation directory '$jmeterLocation' not found"
    }

    $jmeter = Join-Path $jmeterLocation 'jmeter.bat'
    $jmeterlog = Join-Path $jmeterLocation 'jmeter.log'

    Start-Process $jmeter -WindowStyle Hidden -ArgumentList @('-j', $jmeterlog)
}
Set-Alias jmeter Start-JMeter -Description 'Starts JMeter'