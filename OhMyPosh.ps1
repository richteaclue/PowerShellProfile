#########################################
#
# Profile script to configure prompt for PowerShell Core
#
#########################################

$colors = @{
    Command = "`e[93m"
    Comment = "`e[32m"
    ContinuationPrompt = "`e[37m"
    Emphasis = "`e[96m"
    Error = "`e[91m"
    Keyword = "`e[92m"
    Member = "`e[97m"
    Number = "`e[97m"
    Operator = "`e[74m"
    Parameter = "`e[74m"
    #Prediction = "`e[38;5;238m"
    Selection = "`e[30;47m"
    String  = "$([char]0x1b)[38;5;100m"
    Type = "`e[37m"
    Variable = "`e[92m"
    Default = "`e[37m"
}

Set-PSReadLineOption -Colors $colors

# Assumes posh-git module is installed & imported

$env:POSH_SESSION_DEFAULT_USER = 'Rich.Tebb'
oh-my-posh --init --shell pwsh --config '~/Documents/PowerShell/PoshThemes/GonzoDog.omp.yaml' | Invoke-Expression
