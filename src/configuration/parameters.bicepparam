import { namePrefixes, locPrefixes } from '../../src/configuration/shared/shared.bicep'

using '../orchestration/main.bicep'

param lzPrefix = 'sap'
param envPrefix = 'prd'
param roleAssignmentEnabled = true
param roleAssignments = []
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
param nextHopIpAddress = '10.1.1.1'
param addressPrefixes = '10.15.0.0/24'
param subnets = [
    {
        name: 'app'
        addressPrefix: '10.15.0.0/27'
        networkSecurityGroupName: '${namePrefixes.networkSecurityGroup}-${locPrefixes.australiaEast}-${lzPrefix}-${envPrefix}-app'
        securityRules: []
        routeTableName: '${namePrefixes.routeTable}-${locPrefixes.australiaEast}-${lzPrefix}-${envPrefix}-app'
        routes: []
        serviceEndpoints: []
        delegations: []
        privateEndpointNetworkPolicies: 'Enabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
    }
    {
        name: 'db'
        addressPrefix: '10.15.0.32/27'
        networkSecurityGroupName: '${namePrefixes.networkSecurityGroup}-${locPrefixes.australiaEast}-${lzPrefix}-${envPrefix}-db'
        securityRules: []
        routeTableName: '${namePrefixes.routeTable}-${locPrefixes.australiaEast}-${lzPrefix}-${envPrefix}-db'
        routes: []
        serviceEndpoints: []
        delegations: []
        privateEndpointNetworkPolicies: 'Enabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
    }
]
