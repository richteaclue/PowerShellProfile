$profilePath = Join-Path $PSScriptRoot '..\Profile.ps1'
$tokens = $null
$parseErrors = $null
$ast = [System.Management.Automation.Language.Parser]::ParseFile(
    $profilePath, [ref]$tokens, [ref]$parseErrors)
if ($parseErrors.Count) {
    throw ($parseErrors | Out-String)
}
$detector = $ast.Find({
    param($node)
    $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and
        $node.Name -eq 'Get-ProfileEnvironment'
}, $false)
. ([scriptblock]::Create($detector.Extent.Text))

Describe 'Profile environment detection' {
    $cases = @(
        @{
            Name = 'NuGet overrides inherited terminal markers'
            HostName = 'Package Manager Host'
            TermProgram = 'vscode'
            WindowsTerminalSession = 'inherited'
            VisualStudioInstallDir = 'C:\VS'
            Expected = 'nuget'
        },
        @{
            Name = 'the extension console overrides all inherited markers'
            HostName = 'Visual Studio Code Host'
            TermProgram = 'vscode'
            WindowsTerminalSession = 'inherited'
            VisualStudioInstallDir = 'C:\VS'
            Expected = 'vscode-powershell'
        },
        @{
            Name = 'the extension console does not require TERM_PROGRAM'
            HostName = 'Visual Studio Code Host'
            TermProgram = ''
            WindowsTerminalSession = ''
            VisualStudioInstallDir = ''
            Expected = 'vscode-powershell'
        },
        @{
            Name = 'the ordinary VS Code terminal overrides inherited WT_SESSION'
            HostName = 'ConsoleHost'
            TermProgram = 'vscode'
            WindowsTerminalSession = 'inherited'
            VisualStudioInstallDir = 'C:\VS'
            Expected = 'vscode-terminal'
        },
        @{
            Name = 'Windows Terminal takes precedence over developer environment'
            HostName = 'ConsoleHost'
            TermProgram = ''
            WindowsTerminalSession = 'session'
            VisualStudioInstallDir = 'C:\VS'
            Expected = 'windows-terminal'
        },
        @{
            Name = 'the developer shell is identified without a terminal marker'
            HostName = 'ConsoleHost'
            TermProgram = ''
            WindowsTerminalSession = ''
            VisualStudioInstallDir = 'C:\VS'
            Expected = 'visual-studio-developer'
        },
        @{
            Name = 'an unrecognized terminal uses the console fallback'
            HostName = 'ConsoleHost'
            TermProgram = 'other-terminal'
            WindowsTerminalSession = ''
            VisualStudioInstallDir = ''
            Expected = 'console'
        }
    )

    It '<Name>' -TestCases $cases {
        param($Name, $HostName, $TermProgram, $WindowsTerminalSession,
            $VisualStudioInstallDir, $Expected)

        Get-ProfileEnvironment -HostName $HostName -TermProgram $TermProgram `
            -WindowsTerminalSession $WindowsTerminalSession `
            -VisualStudioInstallDir $VisualStudioInstallDir | Should Be $Expected
    }
}

Describe 'Synchronous profile initialization' {
    $startupCases = @(
        @{ Name = 'Windows Terminal'; Environment = 'windows-terminal'; Prompt = 'omp' },
        @{ Name = 'VS Code terminal'; Environment = 'vscode-terminal'; Prompt = 'omp' },
        @{ Name = 'VS Code extension console'; Environment = 'vscode-powershell'; Prompt = 'posh-git' },
        @{ Name = 'other console'; Environment = 'console'; Prompt = 'posh-git' }
    )

    It '<Name> initializes the prompt and zoxide before returning and survives a reload' -TestCases $startupCases {
        param($Name, $Environment, $Prompt)

        $child = @'
$ErrorActionPreference = 'Stop'
$root = $env:PROFILE_TEST_ROOT
$env:TERM_PROGRAM = $null
$env:WT_SESSION = $null
$env:VCIDEInstallDir = $null
switch ('__ENVIRONMENT__') {
    'windows-terminal' { $env:WT_SESSION = 'test-session' }
    'vscode-terminal' { $env:TERM_PROGRAM = 'vscode'; $env:WT_SESSION = 'inherited' }
}
$source = Get-Content -LiteralPath (Join-Path $root 'Profile.ps1') -Raw
if ('__ENVIRONMENT__' -eq 'vscode-powershell') {
    $original = '$profileEnvironment = Get-ProfileEnvironment'
    if (-not $source.Contains($original)) { throw 'Environment detector call not found' }
    $source = $source.Replace($original, "$original -HostName 'Visual Studio Code Host'")
}
$profileScript = [scriptblock]::Create($source)
foreach ($run in 1..2) {
    . $profileScript
    if ($profileEnvironment -ne '__ENVIRONMENT__') { throw "Unexpected environment: $profileEnvironment" }
    if (Get-EventSubscriber -Force | Where-Object SourceIdentifier -eq 'PowerShell.OnIdle') {
        throw 'Unexpected idle subscription'
    }
    if (Get-Variable __initQueue -Scope Global -ErrorAction Ignore) { throw 'Unexpected initialization queue' }
    if (Get-Module Microsoft.PowerShell.SecretManagement) { throw 'SecretManagement loaded eagerly' }
    if (-not (Get-Command z -ErrorAction Ignore)) { throw 'z is unavailable' }
    if ('__PROMPT__' -eq 'omp') {
        if (Get-Module posh-git) { throw 'posh-git loaded eagerly in an OMP environment' }
        if (-not (Get-Module oh-my-posh-core)) { throw 'OMP did not load' }
        if (-not $global:__zoxide_prompt_old.ToString().Contains('Set-PoshContext')) {
            throw 'zoxide did not wrap OMP'
        }
    } else {
        if (-not (Get-Module posh-git)) { throw 'posh-git did not load' }
        if (-not $global:__zoxide_prompt_old.ToString().Contains('GitPromptScriptBlock')) {
            throw 'zoxide did not wrap posh-git'
        }
    }
    $destination = if ($run -eq 1) { Join-Path $root 'PoshThemes' } else { $root }
    z $destination
    if ((Get-Location).ProviderPath -ne $destination) { throw 'z navigation failed' }
    $null = prompt
    $knownDirectories = @(zoxide query --list)
    if ($LASTEXITCODE -ne 0 -or $destination -notin $knownDirectories) {
        throw "zoxide did not learn $destination"
    }
}
$null = Get-SecretVault
if (-not (Get-Module Microsoft.PowerShell.SecretManagement)) { throw 'SecretManagement did not autoload' }
'@
        $child = $child.Replace('__ENVIRONMENT__', $Environment).Replace('__PROMPT__', $Prompt)
        $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($child))
        $oldRoot = $env:PROFILE_TEST_ROOT
        $oldDataDir = $env:_ZO_DATA_DIR
        try {
            $env:PROFILE_TEST_ROOT = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
            $env:_ZO_DATA_DIR = Join-Path $TestDrive $Environment
            $null = New-Item -ItemType Directory -Path $env:_ZO_DATA_DIR
            $output = & (Join-Path $PSHOME 'pwsh.exe') -NoLogo -NoProfile -EncodedCommand $encoded 2>&1
            if ($LASTEXITCODE -ne 0) { throw ($output | Out-String) }
        }
        finally {
            $env:PROFILE_TEST_ROOT = $oldRoot
            $env:_ZO_DATA_DIR = $oldDataDir
        }
    }
}
