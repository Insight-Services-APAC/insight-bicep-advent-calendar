<!-- markdownlint-disable MD041 -->
## Example 3 - Create New Azure Subscription

Example of how to create an Azure Landing Zone using a new Azure Subscription with a spoke Virtual Network connected to either a Virtual WAN Hub or virtual network hub.

Further details are documented in the [Main Bicep Module](src/modules/README.md)

```bicep
using '../main.bicep'

param subscriptionAliasEnabled = true // Boolean to enable programmatic creation of Azure Subscription
param subscriptionDisplayName = '' // Azure Subscription display name
param subscriptionAliasName = '' // Azure Subscription Alias
param subscriptionBillingScope = 'providers/Microsoft.Billing/billingAccounts/xxxxxxx/enrollmentAccounts/xxxxxx'
param subscriptionWorkload = '' // Either 'Production' or 'DevTest'
param subscriptionMgPlacement = '' //Existing Management Group
param lzPrefix = '' // Landing Zone prefix
param envPrefix = '' // Environment prefix
param roleAssignmentEnabled = true // Boolean for enabling Role Assignments
param roleAssignments = [ // Role Assignment object
    {
        principalId: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
        definition: 'Reader'
        principalType: 'Group'
        relativeScope: '/' // Subscription level scope
    }
    {
        principalId: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
        definition: 'Owner'
        principalType: 'ServicePrincipal'
        relativeScope: '/' // Subscription level scope
    }
]
param tags = { // Tag object for defining tags at the various resource groups and resources
    applicationName: ''
    owner: ''
    criticality: ''
    costCenter: ''
    contactEmail: ''
    dataClassification: ''
}
param budgets = [ // Azure Budget object 
    {
        enabled: true
        amount: 500
        startDate: '2023-11-01' // UTC Date
        thresholds: [
            80
            100
        ]
        contactEmails: [
            'test@outlook.com'
        ]
    }
]
param actionGroupEmails = [ // An array of email addresses for defining the Action Group
    'test@outlook.com'
]
param hubVirtualNetworkId = '' // Azure vWAN Hub or Hub resource ID
param virtualNetworkPeeringEnabled = true // // Boolean for enabling Role Assignments
param nextHopIpAddress = 'x.x.x.x' // IP address of the Hub Firewall
param addressPrefixes = 'x.x.x.x/x' // Spoke virtual network address
param subnets = [ // Subnet array that creates 1 or more subnets and associated resources (NSG, UDR, delegation)
    {
        name: 'app'
        addressPrefix: 'x.x.x.x/x'
        networkSecurityGroupName: ''
        securityRules: []
        routeTableName: ''
        routes: []
        serviceEndpoints: []
        delegations: []
        privateEndpointNetworkPolicies: 'Enabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
    }
    {
        name: 'db'
        addressPrefix: 'x.x.x.x/x'
        networkSecurityGroupName: ''
        securityRules: []
        routeTableName: ''
        routes: []
        serviceEndpoints: []
        delegations: []
        privateEndpointNetworkPolicies: 'Enabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
    }
]

```
