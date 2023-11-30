targetScope = 'tenant'

metadata name = 'ALZ Bicep - Subscription creation module'
metadata description = 'This module is used to create a new Azure Subscription.'
metadata author = 'Insight APAC Platform Engineering'

@maxLength(63)
@sys.description('The name of the subscription alias. The string must be comprised of a-z, A-Z, 0-9, - and _. The maximum length is 63 characters.')
param subscriptionDisplayName string

@maxLength(63)
@sys.description('The name of the subscription alias. The string must be comprised of a-z, A-Z, 0-9, -, _ and space. The maximum length is 63 characters.')
param subscriptionAliasName string

@sys.description('The billing scope for the new subscription alias. A valid billing scope starts with `/providers/Microsoft.Billing/billingAccounts/` and is case sensitive. Default: Empty String')
param subscriptionBillingScope string

@allowed([
  'DevTest'
  'Production'
])
@sys.description('The workload type can be either `Production` or `DevTest` and is case sensitive.')
param subscriptionWorkload string = 'Production'

// Resource: Subscription Placement
resource subscriptionAlias 'Microsoft.Subscription/aliases@2021-10-01' = {
  name: subscriptionAliasName
  properties: {
    workload: subscriptionWorkload
    displayName: subscriptionDisplayName
    billingScope: subscriptionBillingScope
  }
}

// Outputs
output subscriptionId string = subscriptionAlias.properties.subscriptionId
output subscriptionResourceId string = '/subscriptions/${subscriptionAlias.properties.subscriptionId}'
