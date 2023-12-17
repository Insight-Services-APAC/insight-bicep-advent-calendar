using '../orchestration/main.bicep'

param existingSubscriptionId = '' // Subscription ID of the existing subscription
param subscriptionMgPlacement = '' // Management Group ID that the Subscription will be placed under
param lzPrefix = 'sap' // Landing Zone prefix
param envPrefix = 'prd'  // environment prefix
param roleAssignments = []
param tags = {    // Required Tags
    applicationName: 'SAP Landing Zone'
    owner: 'Platform Team'
    criticality: 'Tier1'
    costCenter: '1234'
    contactEmail: 'test@outlook.com'
    dataClassification: 'Internal'
}
param budgets = [ // Azure Budget info
    {
        amount: 500
        startDate: '2023-12-01'
        thresholds: [
            80
            100
        ]
        contactEmails: [
            'test@outlook.com'
        ]
    }
]
param actionGroupEmails = [ // Action Group Email(s)
    'test@outlook.com'
]
//param hubVirtualNetworkId = '' // Hub Virtual Network ID
param virtualNetworkPeeringEnabled = false // Virtual Network Peering Enabled
param allowHubVpnGatewayTransit = false // Allow Hub Vpn Gateway Transit
param nextHopIpAddress = '1.1.1.1' // Next Hop IP Address to Firewall (if applicable)
param addressPrefixes = '10.15.0.0/24' // Address Prefixes for the Virtual Network
param subnets = [ // Subnet Array for the Virtual Network
    {
        name: 'app'
        addressPrefix: '10.15.0.0/27'
        networkSecurityGroupName: 'nsg-syd-sap-prd-app'
        securityRules: []
        routeTableName: 'udr-syd-sap-prd-app'
        routes: []
        serviceEndpoints: []
        delegations: []
        privateEndpointNetworkPolicies: 'Enabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
    }
    {
        name: 'db'
        addressPrefix: '10.15.0.32/27'
        networkSecurityGroupName: 'nsg-syd-sap-prd-db'
        securityRules: []
        routeTableName: 'udr-syd-sap-prd-db'
        routes: []
        serviceEndpoints: []
        delegations: []
        privateEndpointNetworkPolicies: 'Enabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
    }
]
