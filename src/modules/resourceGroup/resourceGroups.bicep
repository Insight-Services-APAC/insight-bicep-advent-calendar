targetScope = 'subscription'

metadata name = 'ALZ Bicep - Resource Group module'
metadata description = 'module used to create multiple Resource Groups for Azure Landing Zones'
metadata author = 'Insight APAC Platform Engineering'

@sys.description('An array of Resource Group Names.')
param resourceGroupNames array = []

@sys.description('Azure Region where Resource Group will be created.')
param location string

@sys.description('Tags you would like to be applied to all resources in this module.')
param tags object = {}

// Resource: Resource Groups
resource resourceGroups 'Microsoft.Resources/resourceGroups@2022-09-01' = [for item in resourceGroupNames: {
  name: item
  location: location
  tags: tags
}]

// Output
output resourceGroup array = [for (name, i) in resourceGroupNames: {
  name: resourceGroups[i].name
  resourceId: resourceGroups[i].id
}]
