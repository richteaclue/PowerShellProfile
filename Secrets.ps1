#########################################
#
# Profile script to set up secrets
#
#########################################

Import-Module Microsoft.PowerShell.SecretManagement

# Secrets should be set with the Set-Secret command, e.g.
# Set-Secret -Name MyStringToken
# (will prompt for value)

#$env:AZP_AGENT_TOKEN = (Get-Secret -Name 'AZP_AGENT_TOKEN' -AsPlainText -ErrorAction Continue)

# Secrets for Azure / Terraform
#$env:ARM_CLIENT_SECRET = (Get-Secret -Name 'ARM_CLIENT_SECRET' -AsPlainText -ErrorAction Continue)
