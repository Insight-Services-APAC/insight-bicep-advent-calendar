<!-- markdownlint-disable MD041 -->

## Getting Started

This repository has been created to enable the creation, deployment and delivery of Azure Landing Zones into a Microsoft Entra Tenant utilizing [Bicep](https://aka.ms/bicep) as the Infrastructure-as-Code (IaC) tooling and language of choice.

## Using this repository

There are multiple ways to consume the Bicep modules.

- Clone this repository
- Fork & Clone this repository
- Download a `.zip` copy of this repo
- Upload a copy of the locally cloned/downloaded modules to your own:
  - Git Repository
  - Private Bicep Module Registry
    - See:
      - [Create private registry for Bicep modules](https://docs.microsoft.com/azure/azure-resource-manager/bicep/private-module-registry)
  - Template Specs
    - See:
      - [Azure Resource Manager template specs in Bicep](https://docs.microsoft.com/azure/azure-resource-manager/bicep/template-specs)

The option to use will be different per consumer based on their experience, skill levels and technology stack.

## Local Development

### VS Code/ Insight experience

This repository contains the [.local](/.local) experience. For more information, see [Local Development](LocalDev.md).

### PowerShell Example

An example PowerShell example can be found here and is outlined below `src\scripts\landingZone.ps1`

```powershell

$DeploymentName = ('lzVending-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm'))
$Location = 'australiaeast'
$ManagementGroupId = 'mg-alz'
$TemplateFile = '..\main.bicep'
$TemplateParameterFile = '..\configuration\sub-sap-prd-01.parameters.bicepparam'

New-AzManagementGroupDeployment `
    -Name $DeploymentName `
    -TemplateFile $TemplateFile `
    -TemplateParameterFile $TemplateParameterFile `
    -Location $Location `
    -ManagementGroupId $ManagementGroupId `
    -Verbose
```
