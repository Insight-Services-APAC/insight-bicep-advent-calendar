targetScope = 'managementGroup'

metadata name = 'ALZ Bicep - Subscription Placement module'
metadata description = 'This module is used to place Azure Subscriptions into a Management Group.'
metadata author = 'Insight APAC Platform Engineering'

@sys.description('Array of Subscription Ids that should be moved to the new management group. Default: Empty Array')
param subscriptionIds array = []

@sys.description('Target management group for the subscription. This management group must exist.')
param targetManagementGroupId string

// Resource: Subscription PLacement
resource subscriptionPlacement 'Microsoft.Management/managementGroups/subscriptions@2023-04-01' = [for subscriptionId in subscriptionIds: {
  scope: tenant()
  name: '${targetManagementGroupId}/${subscriptionId}'
}]
