Import-Module Az.Accounts -Verbose:$false
Import-Module (Join-Path $PSScriptRoot "keyvault.psm1") -Force -Verbose:$false


function Get-AzKeyVaultsExistingPolices (
  [Parameter(Mandatory = $true)]
  [array] $ResourceGroups,

  [Parameter(Mandatory = $true)]
  [hashtable] $KeyVaults
) {
  $keyvaultAcesssPolicies = @{}
  $KeyVaults.GetEnumerator() | Foreach-Object {
    $key = $_.Name
    $keyVaultName = $_.value
    $keyVaultExists = $false
    foreach ($resourceGroupName in $ResourceGroups) {
      $ifKeyVaultExists = Get-AzResourceIdIfExists -ResourceGroup $resourceGroupName -ResourceType 'Microsoft.KeyVault/vaults' -ResourceName $keyVaultName.ToString()

      if ($ifKeyVaultExists) {
        Write-Host "Found existing configured KeyVault" $keyVaultName "in Resource Group" $resourceGroupName
        $keyVaultExists = $true
        $keyVaultAccessPoliciesFormatted = Get-AzKeyVaultAccessPolicies -keyVaultName $keyVaultName.ToString() -resourceGroupName $resourceGroupName
      }
      break
    }

    if ($keyVaultExists) {
      $keyvaultAcesssPolicies += @{
        $key = @{
          exists   = $true
          policies = @($keyVaultAccessPoliciesFormatted)
        }
      }
    }
    else {
      $keyvaultAcesssPolicies += @{
        $key = @{
          exists   = $false
          policies = @()
        }
      }
    }
  }
  return $keyvaultAcesssPolicies = @{
    "keyVaultExist" = $keyvaultAcesssPolicies
  }
}
function Get-AzResourceIdIfExists(
  [Parameter(Mandatory = $true)]
  [string] $ResourceGroup,

  [Parameter(Mandatory = $true)]
  [string] $ResourceType,

  [Parameter(Mandatory = $true)]
  [string] $ResourceName
) {
  # Get the Azure resource
  $resource = Get-AzResource -ResourceGroupName $ResourceGroup -ResourceType $ResourceType -ResourceName $ResourceName -ErrorAction SilentlyContinue

  if ($resource) {
    # Return true to indicate that the resource was found
    return $resource.ResourceId
  }
  else {
    return $null
  }

}

function Get-AzureDeploymentParams(
  [Parameter(Mandatory = $true)]
  [object] $context,

  [Parameter(Mandatory = $false)]
  [Hashtable] $params,

  [Parameter(Mandatory = $false)]
  [string] $configKey,

  [Parameter(Mandatory = $false)]
  [Hashtable] $diagnostics,

  [Parameter(Mandatory = $false)]
  [string] $purposeTag
) {
  $defaultParams = @{
    "tags" = @{
      "Orchestration"   = $context.Orchestration;
      "DeploymentJobId" = $context.DeploymentJobId;
    }
  }

  if ($purposeTag) {
    $defaultParams.tags.Purpose = $purposeTag
  }

  $valuesFromConfig = @{}
  if ($configKey) {
    $valuesFromConfig = $context[$configKey]
    if (-not $valuesFromConfig) {
      throw "Invalid configuration key $configKey attempted to be used for Azure parameters"
    }
  }

  if (-not $diagnostics) {
    $diagnostics = @{}
  }

  if (-not $params) {
    $params = @{}
    $mainParams = $context.AdditionalParameters
  }
  else {
    $mainParams = $params.context.parameters + $context.AdditionalParameters
  }


  # Add default values from local development to parameters
  $defaultParams.Keys | ForEach-Object {
    $key = $_
    if ($mainParams.ContainsKey($key)) {
      $mainParams[$key] += $defaultParams[$key]
    }
    else {
      $mainParams[$key] = $defaultParams[$key]
    }
  }

  # Add values from config to parameters
  $valuesFromConfig.Keys | ForEach-Object {
    $key = $_
    if ($mainParams.ContainsKey($key)) {
      $mainParams[$key] += $valuesFromConfig[$key]
    }
    else {
      $mainParams[$key] = $valuesFromConfig[$key]
    }
  }

  # Add diaganostics to parameters
  $diagnostics.Keys | ForEach-Object {
    $key = $_
    if ($mainParams.ContainsKey($key)) {
      $mainParams[$key] += $diagnostics[$key]
    }
    else {
      $mainParams[$key] = $diagnostics[$key]
    }
  }

  return $mainParams
}

function Invoke-AzureDeployment {

  [CmdletBinding(SupportsShouldProcess = $true)]
  param(
    [Parameter(Mandatory = $true)]
    [object] $context,

    [Parameter(Mandatory = $true)]
    [string] $file,

    [Parameter(Mandatory = $true)]
    [Hashtable] $parameters,

    [Parameter(Mandatory = $true)]
    [string] $location,

    [Parameter(Mandatory = $false)]
    [string] $resourceGroup,

    [Parameter(Mandatory = $false)]
    [string] $deploymentScope,

    [Parameter(Mandatory = $false)]
    [Switch] $isArm = $false,

    [Parameter(Mandatory = $false)]
    [Switch] $isOrchestration = $false
  )

  $isLocal = $env:LOCAL_DEPLOYMENT -eq "True"
  $templatePathing = $isOrchestration ? "src/orchestration" : "src/module"

  if ($isArm) {
    $templatePath = Resolve-Path (Join-Path $PSScriptRoot "../../$templatePathing/$file.json")
  }
  else {
    $templatePath = Resolve-Path (Join-Path $PSScriptRoot "../../$templatePathing/$file.bicep")

    # Check file is intact
    Write-Host "Verifying '$templatePath' is intact"

    if ($isLocal) {
      # Create local build path if it doesn't exist
      $LocalRootPath = Resolve-Path -Path (Join-Path $PSScriptRoot '../../.local/')
      $buildDirectory = Join-Path $LocalRootPath "build"
      if (-not (Test-Path $buildDirectory)) {
        New-Item -ItemType Directory -Path $buildDirectory | Out-Null
      }
      $bicepBuildPath = "$LocalRootPath\build\$file.json"
    }
    else {
      # Create build path if it doesn't exist
      $RootPath = Resolve-Path -Path (Join-Path $PSScriptRoot '../../'$templatePathing)
      $buildDirectory = Join-Path $RootPath "build"
      if (-not (Test-Path $buildDirectory)) {
        New-Item -ItemType Directory -Path $buildDirectory | Out-Null
      }
      $bicepBuildPath = $buildDirectory + "/" + $file + ".json"
    }

    bicep --version
    bicep build $templatePath --outfile $bicepBuildPath
    $templatePath = $bicepBuildPath

    if ($LASTEXITCODE -ne 0) {
      throw "Invalid bicep file '$templatePath'"
    }
  }

  $name = ("$($context.DeploymentJobId)-").ToUpperInvariant() + $file + "-";
  if ($isLocal) {
    $name = ("$($context.Me.Initials)-$($context.DeploymentJobId)-").ToUpperInvariant() + $file + "-";
  }

  if ($name.Length -gt 43) {
    # Reduce length if deployment job name is too long.
    $name = $name.Substring(0, 43)
  }
  $name = $name + $(Get-Date -Format FileDateTimeUniversal)

  switch ($deploymentScope) {
    "ResourceGroup" {
      if (-not [string]::IsNullOrEmpty($resourceGroup)) {
        $resourceGroup = $resourceGroup.ToLowerInvariant()

        if (-not $WhatIfPreference -and -not $isLocal) {
          Write-Host "$(Get-Date -Format FileDateTimeUniversal) Showing -WhatIf result for Azure deployment '$name' against resource group '$resourceGroup'."
          New-AzResourceGroupDeployment `
            -Name $name `
            -ResourceGroupName $resourceGroup `
            -TemplateFile $templatePath `
            -TemplateParameterObject $parameters `
            -SkipTemplateParameterPrompt `
            -WhatIf
        }

        Write-Host "$(Get-Date -Format FileDateTimeUniversal) Executing Azure deployment '$name' against resource group '$resourceGroup'."
        $deploymentResult = New-AzResourceGroupDeployment `
          -Name $name `
          -ResourceGroupName $resourceGroup `
          -TemplateFile $templatePath `
          -TemplateParameterObject $parameters `
          -ErrorAction Continue `
          -SkipTemplateParameterPrompt `
          -Confirm:$ConfirmPreference `
          -WhatIf:$WhatIfPreference `
          -Verbose
      }
      else {
        throw "Resource group name is required for resource group deployment."
      }
    }
    "Subscription" {
      if (-not $WhatIfPreference -and -not $isLocal) {
        Write-Host "$(Get-Date -Format FileDateTimeUniversal) Showing -WhatIf result for Azure deployment '$name' against subscription '$($context.SubscriptionId)'."
        New-AzSubscriptionDeployment `
          -Name $name `
          -Location $location `
          -TemplateFile $templatePath `
          -TemplateParameterObject $parameters `
          -SkipTemplateParameterPrompt `
          -WhatIf
      }

      Write-Host "$(Get-Date -Format FileDateTimeUniversal) Executing Azure deployment '$name' against subscription '$($context.SubscriptionId)'."
      $deploymentResult = New-AzSubscriptionDeployment `
        -Name $name `
        -Location $location `
        -TemplateFile $templatePath `
        -TemplateParameterObject $parameters `
        -ErrorAction Continue `
        -SkipTemplateParameterPrompt `
        -Confirm:$ConfirmPreference `
        -WhatIf:$WhatIfPreference `
        -Verbose
    }
    "ManagementGroup" {
      if (-not $WhatIfPreference -and -not $isLocal) {
        Write-Host "$(Get-Date -Format FileDateTimeUniversal) Showing -WhatIf result for Azure deployment '$name' against management group '$($context.ManagementGroupId)'."
        New-AzManagementGroupDeployment `
          -Name $name `
          -Location $location `
          -ManagementGroupId $context.ManagementGroupId `
          -TemplateFile $templatePath `
          -TemplateParameterObject $parameters `
          -SkipTemplateParameterPrompt `
          -WhatIf
      }

      Write-Host "$(Get-Date -Format FileDateTimeUniversal) Executing Azure deployment '$name' against management group '$($context.ManagementGroupId)'."
      $deploymentResult = New-AzManagementGroupDeployment `
        -Name $name `
        -Location $location `
        -ManagementGroupId $context.ManagementGroupId `
        -TemplateFile $templatePath `
        -TemplateParameterObject $parameters `
        -ErrorAction Continue `
        -SkipTemplateParameterPrompt `
        -Confirm:$ConfirmPreference `
        -WhatIf:$WhatIfPreference `
        -Verbose
    }
    "Tenant" {
      if (-not $WhatIfPreference -and -not $isLocal) {
        Write-Host "$(Get-Date -Format FileDateTimeUniversal) Showing -WhatIf result for Azure deployment '$name' against tenant '$($context.TenantId)'."
        New-AzTenantDeployment `
          -Name $name `
          -Location $location `
          -TemplateFile $templatePath `
          -TemplateParameterObject $parameters `
          -SkipTemplateParameterPrompt `
          -WhatIf
      }

      Write-Host "$(Get-Date -Format FileDateTimeUniversal) Executing Azure deployment '$name' against tenant '$($context.TenantId)'."
      $deploymentResult = New-AzTenantDeployment `
        -Name $name `
        -Location $location `
        -TemplateFile $templatePath `
        -TemplateParameterObject $parameters `
        -ErrorAction Continue `
        -SkipTemplateParameterPrompt `
        -Confirm:$ConfirmPreference `
        -WhatIf:$WhatIfPreference `
        -Verbose
    }
    default {
      throw "Invalid deployment scope '$deploymentScope'."
    }
  }

  if (-not [string]::IsNullOrEmpty($resourceGroup) -and $deploymentScope -eq "ResourceGroup") {
    $resourceGroup = $resourceGroup.ToLowerInvariant()


  }
  else {


  }

  if (-not $WhatIfPreference) {
`
      if (-not $deploymentResult -or $deploymentResult.ProvisioningState -ne "Succeeded") {
      Write-Host (ConvertTo-Json $deploymentResult)
      throw "An error occurred deploying resources to Azure; see above."
    }

    Write-Host -ForegroundColor Green "`r`n✔️  $(Get-Date -Format FileDateTimeUniversal) Azure deployment '$name' successful.`r`n"

    return $deploymentResult.Outputs

  }
}

function Assert-Guid([string] $displayNameObjectId) {
  try {
    [System.Guid]::Parse($displayNameObjectId)
    return $true
  }
  catch {
    return $false
  }
}

# Combines standard ARM/Bicep parameters with directly specified values ($with) and environment-specific JSON config values ($configKey)
function Get-Params([Parameter(Mandatory = $true)] [object] $context, [Hashtable] $with, [string] $configKey, [Hashtable] $diagnostics, [string] $purpose) {
  $standardParams = @{
    "tagObject" = @{
      "CompanyName" = $context.CompanyName;
      "Location"    = $context.LocationCode;
      "Application" = $context.AppName;
      "Environment" = $context.EnvironmentCode;
    }
  }
  $configValues = @{}

  if ($purpose) {
    $standardParams.tagObject.Purpose = $purpose
  }
  if ($configKey -and $context[$configKey]) {
    $configValues = $context[$configKey]
  }
  if (-not $with) {
    $with = @{}
  }
  if (-not $diagnostics) {
    $diagnostics = @{}
  }
  return $standardParams + $with + $configValues + $diagnostics
}

Export-ModuleMember -Function * -Verbose:$false
