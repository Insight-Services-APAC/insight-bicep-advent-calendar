metadata name = 'Resource Group Bicep Template'
metadata description = 'Resource Group Example'
metadata author = 'Stephen Tulp - Insight'

targetScope = 'subscription'

@description('The Azure Region to deploy the resources into.')
param location string = deployment().location

@description('An object of Tag key & value pairs to be appended to a Subscription.')
param tags object = {
  applicationName: 'SAP Landing Zone'
  owner: 'Platform Team'
  criticality: 'Tier1'
  costCenter: '1234'
  contactEmail: 'test@test.com'
  dataClassification: 'Internal'
}

var resourceGroups = {
  network: 'arg-syd-sap-prd-network'
  shared: 'arg-syd-sap-prd-shared'
}

// Module: Resource Group (Shared)
module resourceGroupShared 'resource-group/main.bicep' = {
  name: 'resourceGroupShared-${guid(deployment().name)}'
  params: {
    name: resourceGroups.shared
    location: location
    tags: tags
  }
}

// Resource: Resource Group (Network)
resource resourceGroupNetwork 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroups.network
  location: location
  tags: tags
}

output resourceGroupShared string = resourceGroupShared.name
output resourceGroupNetwork string = resourceGroupNetwork.name
