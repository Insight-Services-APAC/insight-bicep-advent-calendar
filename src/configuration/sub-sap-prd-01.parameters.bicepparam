using '../orchestration/main.bicep'

param existingSubscriptionId = 'a50d2a27-93d9-43b1-957c-2a663ffaf37f' // Subscription ID of the existing subscription
param subscriptionMgPlacement = 'mg-alz-landingzones-corp' // Management Group ID that the Subscription will be placed under
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
param budgets = [ // Budget info
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
//param nextHopIpAddress = '' // Next Hop IP Address to Firewall
param addressPrefixes = '10.15.0.0/24' // Address Prefixes for the Virtual Network
param subnets = [ // Subnets for the Virtual Network
    {
        name: 'app'
        addressPrefix: '10.15.0.0/27'
        networkSecurityGroupName: 'nsg-syd-sap-prd-app'
        securityRules: []
        enableRouteTable: true
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
        enableRouteTable: true
        routeTableName: 'udr-syd-sap-prd-db'
        routes: []
        serviceEndpoints: []
        delegations: []
        privateEndpointNetworkPolicies: 'Enabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
    }
]
