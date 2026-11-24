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
