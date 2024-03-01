using '../orchestration/main.bicep'

param lzPrefix = 'sap'
param envPrefix = 'prd'
param roleAssignmentEnabled = true
param roleAssignments = [
    {
        principalId: '2b33ff60-edf0-4216-b2a6-66ec07050fd4'
        definition: 'Reader'
        principalType: 'Group'
        relativeScope: '/'
    }
    {
        principalId: '20bbeee1-e70c-43d3-8c2c-b66fefa31acf'
        definition: 'Owner'
        principalType: 'ServicePrincipal'
        relativeScope: '/'
    }
]
param tags = {
    applicationName: 'SAP Landing Zone'
    owner: 'Platform Team'
    criticality: 'Tier1'
    costCenter: '1234'
    contactEmail: 'stephen.tulp@outlook.com'
    dataClassification: 'Internal'
}
param budgets = [
    {
        enabled: true
        amount: 500
        startDate: '2024-03-01'
        thresholds: [
            80
            100
        ]
        contactEmails: [
            'test@outlook.com'
        ]
    }
]
param actionGroupEmails = [
    'test@outlook.com'
]
param virtualNetworkPeeringEnabled = false
param allowHubVpnGatewayTransit = false
param addressPrefixes = '10.15.0.0/24'
param subnets = [
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
