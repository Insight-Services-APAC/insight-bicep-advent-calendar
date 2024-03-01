<!-- markdownlint-disable MD041 -->
## Example 1 - Landing Zone (Subscription) with a spoke Virtual Network peered to a Hub Virtual Network

Example of how to create an Azure Landing Zone using an existing Azure Subscription with a spoke Virtual Network peered to a Hub Virtual Network.

Further details are documented in the [SubscriptionWrapper Bicep Module](src/modules/subscriptionWrapper/README.md)

```bicep
using '../main.bicep'

param existingSubscriptionId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' //Existing Subscription ID
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
param hubVirtualNetworkId = '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/xxxxxxxxxxxxx/providers/Microsoft.Network/virtualNetworks/xxxxxxxxxxxx' // Hub virtual network resource ID
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
