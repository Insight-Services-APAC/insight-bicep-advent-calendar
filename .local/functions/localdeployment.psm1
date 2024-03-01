
function Install-Bicep() {

  if ($IsWindows) {

    # Create the install folder
    $installPath = "$env:USERPROFILE\.bicep"
    if (-not (Test-Path $installPath)) {
      $installDir = New-Item -ItemType Directory -Path $installPath -Force
      $installDir.Attributes += 'Hidden'
    }

    if (-not (Test-Path (Join-Path $installPath "bicep.exe"))) {
      # Fetch the latest Bicep CLI binary
          (New-Object Net.WebClient).DownloadFile("https://github.com/Azure/bicep/releases/latest/download/bicep-win-x64.exe", "$installPath\bicep.exe")
    }

    # Add bicep to your PATH
    $currentPath = (Get-Item -path "HKCU:\Environment" ).GetValue('Path', '', 'DoNotExpandEnvironmentNames')
    if (-not $currentPath.Contains("%USERPROFILE%\.bicep")) { setx PATH ($currentPath + ";%USERPROFILE%\.bicep") }
    if (-not $env:path.Contains($installPath)) { $env:path += ";$installPath" }

    # Verify you can now access the 'bicep' command.
    bicep -v
    # Done!

  }
  elseif ($IsMacOS) {

    if (-not (Test-Path "/usr/local/bin/bicep")) {
      # Fetch the latest Bicep CLI binary
      curl -Lo bicep https://github.com/Azure/bicep/releases/latest/download/bicep-osx-x64
      # Mark it as executable
      chmod +x ./bicep
      # Add Gatekeeper exception (requires admin)
      sudo spctl --add ./bicep
      # Add bicep to your PATH (requires admin)
      sudo mv ./bicep /usr/local/bin/bicep
    }
    # Verify you can now access the 'bicep' command
    bicep -v
    # Done!
  }
  else {

    if (-not (Test-Path "/usr/local/bin/bicep")) {
      # Fetch the latest Bicep CLI binary
      curl -Lo bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64
      # Mark it as executable
      chmod +x ./bicep
      # Add bicep to your PATH (requires admin)
      sudo mv ./bicep /usr/local/bin/bicep
    }
    # Verify you can now access the 'bicep' command
    bicep -v
    # Done!
  }
}

function Get-Diagnostics {
  $diags = @{}
  if ($env:diagnostics) {
    $diags = (ConvertFrom-Json $env:diagnostics -AsHashtable)
  }
  return $diags
}

function New-LocalEncryptedSecret(
  [Parameter(Mandatory = $true)]
  [securestring]
  $secret
) {
  $isLocal = $env:LOCAL_DEPLOYMENT -eq "True"
  if (-not $isLocal) {
    throw "New-LocalEncryptedSecret called in non-local environment; call Initialize-LocalDeploymentContext first"
  }

  $keyId = $env:LOCAL_DEPLOYMENT_ENCRYPTION_KEY_ID

  # Create hidden encryption key directory in home path
  $encryptionKeyPath = Join-Path $HOME ".encryption-keys"
  $encryptionKeysDir = New-Item -Path $encryptionKeyPath -ItemType Directory -Force
  $encryptionKeysDir.Attributes += 'Hidden'

  # Get or generate key file
  $keyFile = Join-Path $encryptionKeyPath "$keyId.key"
  if (-not (Test-Path $keyFile)) {
    $key = New-Object Byte[] 32
    [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($key)
    $key | Out-File $keyFile
  }
  else {
    $key = Get-Content $keyFile
  }

  # Return encrypted secret
  return ConvertFrom-SecureString -Key $key $secret
}

function Get-LocalEncryptedSecret(
  [Parameter(Mandatory = $true)]
  [string]
  $encryptedSecret
) {
  $isLocal = $env:LOCAL_DEPLOYMENT -eq "True"
  if (-not $isLocal) {
    throw "Get-LocalEncryptedSecret called in non-local environment; call Initialize-LocalDeploymentContext first"
  }

  $encryptionKeyPath = Join-Path $HOME ".encryption-keys"
  $key = Get-Content (Join-Path $encryptionKeyPath "$($env:LOCAL_DEPLOYMENT_ENCRYPTION_KEY_ID).key")
  return ConvertTo-SecureString -Key $key -String $encryptedSecret
}

function Initialize-LocalDeploymentContext(
  [Parameter(Mandatory = $true)]
  [string]
  $ConfigurationDirectory
) {

  Install-Bicep | Write-Verbose

  $env:LOCAL_DEPLOYMENT = "True"
  $env:LOCAL_DEPLOYMENT_PUBLISHED_VARIABLES_FILE = Join-Path $ConfigurationDirectory "published-vars.private.json"

  # Ensure there is a local parameters template file
  $localParametersTemplateFile = (Join-Path $ConfigurationDirectory "deploy-local.private.template.jsonc")
  if (-not (Test-Path $localParametersTemplateFile)) {
    @"
    {
      "Me": {
        "Name": "<Your Name>",
        "Email": "<Your Email>",
        "Initials": "<Your Initials>"
      },
      "TenantId": "<Tenant ID>",
      "SubscriptionId": "<Subscription ID>",
      "AzureRegion": "australiaeast",
      "ConfigurationFiles": {
        "main": "../../src/configuration/dev.parameters.json",
        "standalone": "../../src/configuration/standalone.parameters.json"
      },
      "ParameterOverrides": {
        "lzPrefix": "lctst" // Change this to your initials or something that will be unique for your deployment
      },
      "flags": {
        // Deployment Configuration flags for setting up the environment
        // -------
        "isStandalone": false, // If true, this will deploy the standalone environment resources like vNets etc. See docs/wiki for more information.
        "subscriptionLevelPermission": true, // If true, this tells the pipeline that the service principal has subscription level permissions. If false, it will assume it has resource group level permissions.
        "deploymentKeyVault": false, // If true, this will deploy secrets in the predefined KeyVault in configuration. If false, it deploy secret values as output variables.
        // Feature flags to deploy the different Azure Services to build the 'Azure Data Platform'
        // -------
        "deployDataFactory": true, // Deploys Azure Data Factory
        "deploySynapse": true, // Deploys Azure Synapse Analytics
        "deployDatabricks": true, // Deploys Azure Databricks (vNet injection)
        "deploySQL": true // Deploys Azure SQL Server and Database (used for metadata or data warehousing)
      },
      "StaticSecrets": {
        "vmPassword": "securePassword" // Change this to a secure password for your local dev
        "sqlPassword: "securePassword" // Change this to a secure password for your local dev. The password must be at least 8 characters long and contain characters from three of the following four categories: (uppercase  letters, lowercase letters, digits (0-9), Non-alphanumeric characters such as: !, $, #, or %).
      }
    }
"@ | Out-File $localParametersTemplateFile -Force
    Write-Warning "Detected first time environment creation; review and update $localParametersTemplateFile and then re-execute"
    exit 1
  }

  # Ensure there is a local parameters file
  $localParametersFile = Join-Path $ConfigurationDirectory "deploy-local.private.jsonc"
  if (-not (Test-Path $localParametersFile)) {
    Copy-Item $localParametersTemplateFile $localParametersFile
    Write-Warning "Detected first time run; review and update $localParametersFile and then re-execute"
    exit 1
  }

  Write-Host "Getting parameters from $localParametersFile"
  $content = Get-Content -Raw -Path $localParametersFile
  $parameters = ConvertFrom-Json $content -AsHashtable

  # Extract local secret encryption key
  if (-not $parameters["EncryptionKeyId"]) {
    Write-Warning "No EncryptionKeyId found in $localParametersFile; generating and adding one"
    $parameters["EncryptionKeyId"] = [guid]::NewGuid()
    $parameters | ConvertTo-Json | Out-File $localParametersFile
  }
  $env:LOCAL_DEPLOYMENT_ENCRYPTION_KEY_ID = $parameters["EncryptionKeyId"]

  # Extract local configuration overrides
  $env:LOCAL_DEPLOYMENT_CONFIGURATION_OVERRIDES = ConvertTo-Json $parameters["ParameterOverrides"] -Depth 100

  # Extract static secrets
  $parameters["StaticSecrets"].Keys | ForEach-Object {
    [System.Environment]::SetEnvironmentVariable($_, $parameters["StaticSecrets"][$_], [System.EnvironmentVariableTarget]::Process)
  }

  # Read published variables file
  $publishedVariablesFile = $env:LOCAL_DEPLOYMENT_PUBLISHED_VARIABLES_FILE
  if (Test-Path $publishedVariablesFile) {
    Write-Host "Loading $publishedVariablesFile"
    $existingJson = Get-Content -Path $publishedVariablesFile -Raw -ErrorAction SilentlyContinue
    $existing = ConvertFrom-Json ($existingJson) -AsHashtable

    # Check hash of published variables matches our local parameters
    $localParametersFileHash = (Get-FileHash -Algorithm SHA1 -Path $localParametersFile).Hash
    if ($localParametersFileHash -ne $existing["configurationFileHash"]) {
      Write-Warning "⚠️   Attempt to execute using '$publishedVariablesFile', but the 'configurationFileHash' ($($existing["configurationFileHash"])) didn't match the hash of '$localParametersFile' ($localParametersFileHash). If '$publishedVariablesFile' is acceptable for this execution (e.g. you made a tweak to '$localParametersFile') then please confirm with the prompt below."

      $defaultChoice = "N"
      $confirmation = Read-Host "Are you sure you want to update the 'configurationFileHash'? (Y/N) [$defaultChoice]"
      if ($confirmation -eq "Y" -or $confirmation -eq "y") {
        # User confirmed, perform action
        $updated = $existing
        $updated.configurationFileHash = $localParametersFileHash
        $updatedJson = $updated | ConvertTo-Json -Depth 100
        $updatedJson | Set-Content -Path $publishedVariablesFile
        Write-Host "Updated '$publishedVariablesFile' with new 'configurationFileHash' value of '$localParametersFileHash'."
      }
      else {
        exit
      }
    }

    # Set the deployment job number to be used to track Azure Deployments
    if (-not $existing["DeploymentJobId"]) {
      $jobId = "Local.1"
      $existing.DeploymentJobId = $jobId
      $parameters.DeploymentJobId = $jobId
    }
    else {
      $value = $existing["DeploymentJobId"]
      $number = $value -replace "[^\d]"
      $newNumber = [int]$number + 1
      $jobId = "Local." + $newNumber
      $existing.DeploymentJobId = $jobId
      $parameters.DeploymentJobId = $jobId
    }
    $updated = $existing
    $updatedJson = $updated | ConvertTo-Json -Depth 100
    $updatedJson | Set-Content -Path $publishedVariablesFile

    # Set each value in the published variables file to an encryption variable
    $existing.Keys | ForEach-Object {
      # If it's encrypted then decrypt it
      if ($existing[$_] -match "^encrypted:") {
        $encryptedValue = $existing[$_].Split("encrypted:")[1]
        $value = (Get-LocalEncryptedSecret $encryptedValue) | ConvertFrom-SecureString -AsPlainText
        [System.Environment]::SetEnvironmentVariable($_, $value, [System.EnvironmentVariableTarget]::Process)
      }
      else {
        [System.Environment]::SetEnvironmentVariable($_, $existing[$_], [System.EnvironmentVariableTarget]::Process)
      }
    }
  }
  else {
    # No file found, set an empty file with the current local parameters file hash
    $jobId = "Local.1"
    $parameters.DeploymentJobId = $jobId
    '{"configurationFileHash": "' + $localParametersFileHash + '", "DeploymentJobId": "' + $jobId + '"}' | Out-File $publishedVariablesFile
  }

  # Prepare parameters to be passed into PowerShell scripts (remove the keys that won't be present in the PowerShell)
  $parameters.Remove("EncryptionKeyId")
  $parameters.Remove("ParameterOverrides")
  $parameters.Remove("StaticSecrets")
  $parameters.Remove("`$schema")

  return $parameters
}

Export-ModuleMember -Function * -Verbose:$false
