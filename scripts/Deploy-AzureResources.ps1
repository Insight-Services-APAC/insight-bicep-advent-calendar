<#
  .SYNOPSIS
  This script performs Azure deployments, manages KeyVault secrets, and executes Bicep/ ARM module deployments.

  .DESCRIPTION
  The script initializes a deployment context, idempotently generates secrets, manages KeyVault access policies, and executes Bicep module deployments. It supports verbose logging and error handling.

  .PARAMETER DeploymentJobId
  Specifies the ID of the deployment job.

  .PARAMETER TenantId
  Specifies the Azure Tenant ID.

  .PARAMETER ManagementGroupId
  Specifies the Azure Management Group ID.

  .PARAMETER SubscriptionId
  Specifies the Azure Subscription ID.

  .PARAMETER AzureRegion
  Specifies the Azure region for the deployment.

  .PARAMETER ConfigurationFileKey
  Specifies the key to the configuration file.

  .PARAMETER ResourceGroup
  (Optional) Specifies the Azure Resource Group.

  .PARAMETER Orchestration
  Specifies the Bicep orchestration file to use.

  .PARAMETER ConfigKey
  (Optional) Specifies the configuration key.

  .PARAMETER ConfigurationFiles
  (Optional) A hashtable containing configuration files.

  .PARAMETER Flags
  (Optional) A hashtable containing flags for the deployment.

  .PARAMETER Me
  (Optional) A hashtable with additional information.

  .PARAMETER AdditionalParameters
  (Optional) A hashtable of additional parameters for deployment.

  .PARAMETER Diagnostics
  (Optional) A hashtable containing diagnostic information.

  .PARAMETER SecretsToIdempotentlyGenerate
  (Optional) An array of secrets to generate idempotently.

  .PARAMETER isManagementGroupDeployment
  (Optional) Specifies if the deployment is at the management group level. If yes, it will use the management group ID.

  .EXAMPLE
  .\Deploy-AzureResources.ps1 -DeploymentJobId "ID123" -TenantId "Tenant123" -SubscriptionId "Sub123" -AzureRegion "eastus" -ConfigurationFileKey "ConfigKey1" -Orchestration "OrchestrationFile"

  This example runs the script with mandatory parameters including the deployment job ID, tenant ID, subscription ID, Azure region, configuration file key, and the orchestration file.

.NOTES
Requires PowerShell 7.0.0 or later. The script sets strict mode to the latest version and stops on error.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
Param (

  [Parameter(Mandatory = $true)]
  [string] $DeploymentJobId,

  [Parameter(Mandatory = $true)]
  [string] $TenantId,

  [Parameter(Mandatory = $false)]
  [string] $ManagementGroupId,

  [Parameter(Mandatory = $false)]
  [string] $SubscriptionId,

  [Parameter(Mandatory = $true)]
  [string] $AzureRegion,

  [Parameter(Mandatory = $true)]
  [string] $ConfigurationFileKey,

  [Parameter(Mandatory = $false)]
  [string] $ResourceGroup,

  [Parameter(Mandatory = $true)]
  [string] $Orchestration,

  [Parameter(Mandatory = $false)]
  [string] $ConfigKey,

  [Parameter(Mandatory = $false)]
  [Hashtable] $ConfigurationFiles,

  [Parameter(Mandatory = $false)]
  [Hashtable] $Flags,

  [Parameter(Mandatory = $false)]
  [Hashtable] $Me,

  [Parameter(Mandatory = $false)]
  [Hashtable] $AdditionalParameters,

  [Parameter(Mandatory = $false)]
  [Hashtable] $Diagnostics,

  [Parameter(Mandatory = $false)]
  [string[]] $SecretsToIdempotentlyGenerate,

  [Parameter(Mandatory = $true)]
  [string[]] $PermissionLevels,

  [Parameter(Mandatory = $true)]
  [ValidateSet("Tenant", "ManagementGroup", "Subscription", "ResourceGroup")]
  [string] $DeploymentScope
)

#Requires -Version 7.0.0
Set-StrictMode -Version "Latest"
$ErrorActionPreference = "Stop"

$RootPath = Resolve-Path -Path $PSScriptRoot
Import-Module (Join-Path $RootPath "functions/deployment.psm1") -Force -Verbose:$false


$PSParamaters = $PSBoundParameters

if ($null -eq $ConfigurationFiles[$ConfigurationFileKey]) {
  throw  "⚠️  Configuration file not found for key '$ConfigurationFileKey'. Are you sure your configuration file/ common parameters is correct?"
}
$context = Initialize-DeploymentContext -parameters $PSParamaters -configurationFilePath (Join-Path (Join-Path $RootPath "config") $ConfigurationFiles[$ConfigurationFileKey])

Write-Verbose "Executing bicep module with the following context:"
Write-Verbose ($PSBoundParameters | Format-Table | Out-String)
Write-Verbose ($context | Format-Table | Out-String)

try {

  ###################################
  # Idempotently generate secrets
  ###################################

  $secrets = @{}

  if ($flags.deploymentKeyVault) {
    if ($SecretsToIdempotentlyGenerate -and $SecretsToIdempotentlyGenerate.Count -gt 0) {
      Invoke-WithTemporaryKeyVaultFirewallBypass `
        -keyVaultName $Context.keyVault.name `
        -resourceGroupName $Context.keyVault.resourceGroup `
        -ipAddressToAllow (Get-CurrentIpAddress) `
        -codeToExecute {
        $SecretsToIdempotentlyGenerate | ForEach-Object {
          $secrets[$_] = Get-OrSetKeyVaultGeneratedSecret -keyVaultName $Context.keyVault.name`
            -secretName $_ -generator { Get-Password }
        }
      }
    }
  }

  ###################################
  # Execute bicep module deployment
  ###################################

  $params = Get-AzureDeploymentParams -context $context `
    -params ($AdditionalParameters + $secrets + @{"context" = $Context }) `
    -configKey $ConfigKey `
    -diagnostics $Diagnostics

  switch ($DeploymentScope) {
    "Tenant" {
      if ($PermissionLevels -notcontains "Tenant"){
        Write-Warning "Detected PermissionLevel of Tenant is missing in `$context.PermissionLevels. Cannot Invoke-AzureDeployment without this permission level available."
        $deploymentOutputs = $null
      }
      else
      {
        $deploymentOutputs = Invoke-AzureDeployment -context $context -file $Orchestration -isOrchestration -parameters $params -location $AzureRegion -deploymentScope "Tenant" -WhatIf:$WhatIfPreference -Confirm:$ConfirmPreference
      }
    }
    "ManagementGroup" {
      if ($PermissionLevels -notcontains "ManagementGroup"){
        Write-Warning "Detected PermissionLevel of ManagementGroup is missing in `$context.PermissionLevels. Cannot Invoke-AzureDeployment without this permission level available."
        $deploymentOutputs = $null
      }
      else
      {
        $deploymentOutputs = Invoke-AzureDeployment -context $context -file $Orchestration -isOrchestration -parameters $params -location $AzureRegion -deploymentScope "ManagementGroup" -WhatIf:$WhatIfPreference -Confirm:$ConfirmPreference
      }
    }
    "Subscription" {
      if ($PermissionLevels -notcontains "Subscription"){
        Write-Warning "Detected PermissionLevel of Subscription is missing in `$context.PermissionLevels. Cannot Invoke-AzureDeployment without this permission level available."
      }
      else
      {
        $deploymentOutputs = Invoke-AzureDeployment -context $context -file $Orchestration -isOrchestration -parameters $params -location $AzureRegion -deploymentScope "Subscription" -WhatIf:$WhatIfPreference -Confirm:$ConfirmPreference
      }
    }
    "ResourceGroup" {
      if ($PermissionLevels -notcontains "ResourceGroup"){
        Write-Warning "Detected PermissionLevel of ResourceGroup is missing in `$context.PermissionLevels. Cannot Invoke-AzureDeployment without this permission level available."
        $deploymentOutputs = $null
      }
      else
      {
        if ($ResourceGroup) {
          $deploymentOutputs = Invoke-AzureDeployment -context $context -file $Orchestration -isOrchestration -parameters $params -resourceGroup $ResourceGroup -deploymentScope "ResourceGroup" -WhatIf:$WhatIfPreference -Confirm:$ConfirmPreference
        }
        else {
          Write-Warning "ResourceGroup parameter was not specified. Cannot deploy at ResourceGroup level. Please change your call parameters."
          $deploymentOutputs = $null
        }
      }
    }
  }

  ###################################
  # Publish output variables
  ###################################

  if ($deploymentOutputs) {
    $outputsToPublish = @{}
    $secretOutputsToPublish = @{}

    # Support for Bicep CLI version 0.23.1 and later which seems to nest the version as part of the outputs.
    if ($deploymentOutputs[0] -imatch 'Bicep CLI version') {
      $outputsNested = $deploymentOutputs[1].GetEnumerator()
    }
    else {
      $outputsNested = $deploymentOutputs.GetEnumerator()
    }


    if ($flags.deploymentKeyVault) {
      $usingKeyVault = $outputsNested | Where-Object { $_.Key -match "secretname$" } | Test-Any

      Invoke-WithTemporaryKeyVaultFirewallBypass -skipBypass:(-not $usingKeyVault) `
        -ipAddressToAllow (Get-CurrentIpAddress) `
        -keyVaultName $Context.keyVault.name `
        -resourceGroupName $Context.keyVault.resourceGroup `
        -codeToExecute {

        $outputsNested | ForEach-Object {
          $nestedValue = $_.Value.Value
          if ($_.Key -match "secretname$") {
            $kvSecret = Get-AzKeyVaultSecret -VaultName $Context.keyVault.name -Name $nestedValue
            $secret = $kvSecret.SecretValue | ConvertFrom-SecureString -AsPlainText
            $secretOutputsToPublish[$_.Key -replace "SecretName$", ""] = $secret
          }
          elseif ($nestedValue -is [securestring] -or $_.Key -imatch "secure" -or $_.Key -imatch "secret" -or $_.Key -imatch "password") {
            $secretOutputsToPublish[$_.Key] = $nestedValue
          }
          else {
            $outputsToPublish[$_.Key] = $nestedValue
          }
        }
      }
    }
    else {
      $outputsNested | ForEach-Object {
        $nestedValue = $_.Value.Value
        if ($nestedValue -is [securestring] -or $_.Key -imatch "secure" -or $_.Key -imatch "secret" -or $_.Key -imatch "password") {
          $secretOutputsToPublish[$_.Key] = $nestedValue
        }
        else {
          $outputsToPublish[$_.Key] = $nestedValue
        }
      }
    }

    if ($outputsToPublish.Count -gt 0) {
      Publish-Variables -values $outputsToPublish
    }

    if ($secretOutputsToPublish.Count -gt 0) {
      Publish-Variables -values $secretOutputsToPublish -isSecret
    }

  }

}
catch {
  Write-Exception $_

  throw
}
