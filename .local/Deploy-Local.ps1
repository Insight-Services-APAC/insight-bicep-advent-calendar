<#
  .SYNOPSIS
    Deploys various Azure resources and services from local.

  .DESCRIPTION
    This script deploys various Azure resources and services from local. It supports deployment of individual orchestrations as well as the entire solution.

  .PARAMETER Orchestration
    Specifies the Orchestration to deploy. The modules are ResourceGroups, Core, GraphQL etc. The default value is "AllModules", which deploys all modules.

  .EXAMPLE
    .\Deploy-Local.ps1 -Orchestration "Main"
    This command deploys the main orchestration.

  .EXAMPLE
    .\Deploy-Local.ps1 -Orchestration "Networking"
    This command deploys the Networking orchestration file.

  .NOTES
    This script requires version 7.0.0 or later of PowerShell. It also requires the "localdeployment.psm1" and "deployment.psm1" modules in the relevant "functions" directory. The script uses the "Initialize-LocalDeploymentContext" function to initialize the deployment context with configuration data in the "config" directory.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
Param(
  [Parameter(Mandatory = $false)]
  [string] $Orchestration = "AllOrchestrations"
)

#Requires -Version 7.0.0
Set-StrictMode -Version "Latest"
$ErrorActionPreference = "Stop"

$LocalRootPath = Resolve-Path -Path $PSScriptRoot
$ScriptsRootPath = Resolve-Path -Path (Join-Path $PSScriptRoot "..\scripts")

Import-Module (Join-Path $LocalRootPath "functions/localdeployment.psm1") -Force -Verbose:$false
Import-Module (Join-Path $ScriptsRootPath "functions/deployment.psm1") -Force -Verbose:$false

try {

  $parameters = Initialize-LocalDeploymentContext -configurationDirectory (Join-Path $LocalRootPath "config")

  ######################################################
  # Main Orchestration, Example Configuration
  ######################################################
  if ($Orchestration -eq "Main") {
    & $ScriptsRootPath/Deploy-AzureResources.ps1 @parameters -Verbose:$VerbosePreference -WhatIf:$WhatIfPreference -Confirm:$ConfirmPreference `
      -ConfigurationFileKey "example" `
      -Orchestration "main" `
      -DeploymentScope "Subscription" `
      -AdditionalParameters @{}
  }
}
catch {
  Write-Exception $_
  throw
}
