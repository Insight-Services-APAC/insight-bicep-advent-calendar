using '../../orchestration/lz/main.bicep'

param existingSubscriptionId = '791c8c61-357d-407e-8ac0-e2cb14ab26e1'
param subscriptionMgPlacement = 'mg-dplh-landingzones-corp'
param lzPrefix = 'ads'
param envPrefix = 'dev'
param roleAssignments = [
  {
    roleDefinitionId: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
    principalId: 'db1d7784-4d79-49a9-b911-13e720554078'
    principalType: 'Group'
  }
  {
    roleDefinitionId: '6a81bbe3-738d-592a-a823-bfb3ae389aa0'
    principalId: 'e4d6e12b-9e07-4d61-a1cf-500fb1cb268f'
    principalType: 'Group'
  }
  {
    roleDefinitionId: '23a7af38-fb06-5843-b41e-d38e0fc78214'
    principalId: 'efd00fb2-6200-4ba4-aa71-3afb20fa1b0e'
    principalType: 'ServicePrincipal'
  }
]
param tags = {
  applicationName: 'Landing Zone ADS Dev'
  owner: 'Platform Team'
  criticality: 'Tier2'
  contactEmail: 'ICTSupport@dplh.wa.gov.au'
  costCenter: 'TBD'
  dataClassification: 'Internal'
  environment: 'dev'
}
param budgets = [
  {
    amount: 500
    startDate: '2023-10-01'
    thresholds: [
      80
      100
    ]
    contactEmails: [
      'ICTSupport@dplh.wa.gov.au'
    ]
  }
]
param actionGroupEmails = [
  'ICTSupport@dplh.wa.gov.au'
]
param addressPrefixes = '10.208.152.0/23'
param recoveryVaultEnabled = true
param hubVirtualNetworkId = '/subscriptions/7c750887-0003-4c5e-91cc-919e91c8a683/resourceGroups/arg-syd-platform-conn-vwan/providers/Microsoft.Network/virtualHubs/vhub-syd-platform-conn-ntr2ktfctrvbq-australiaeast'
param dnsServerIps = [
  '10.208.132.132'
]
param subnets = [
  {
    name: 'asp'
    addressPrefix: '10.208.152.0/26'
    networkSecurityGroupName: 'nsg-syd-ads-dev-asp'
    securityRules: []
    enableRouteTable: false
    routeTableName: 'udr-syd-ads-dev-asp'
    routes: []
    serviceEndpoints: []
    delegations: [
      {
        name: 'hostingEnvironment'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
      }
    ]
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  {
    name: 'shared'
    addressPrefix: '10.208.152.128/26'
    networkSecurityGroupName: 'nsg-syd-ads-dev-shared'
    securityRules: []
    enableRouteTable: false
    routeTableName: 'udr-syd-ads-dev-shared'
    routes: []
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  {
    name: 'privateEndpoints'
    addressPrefix: '10.208.152.64/26'
    networkSecurityGroupName: 'nsg-syd-ads-dev-privateEndpoints'
    securityRules: [
      {
        name: 'INBOUND-FROM-virtualNetwork-TO-virtualNetwork-PORT-443-PROT-Tcp-ALLOW'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourcePortRanges: []
          destinationPortRange: '443'
          destinationPortRanges: []
          sourceAddressPrefix: 'VirtualNetwork'
          sourceAddressPrefixes: []
          sourceApplicationSecurityGroupIds: []
          destinationAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefixes: []
          destinationApplicationSecurityGroupIds: []
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
          description: 'Allow HTTPS traffic (Port 443) to the subnet.'
        }
      }
      {
        name: 'INBOUND-FROM-virtualNetwork-TO-virtualNetwork-PORT-1433-PROT-Tcp-ALLOW'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourcePortRanges: []
          destinationPortRange: '1433'
          destinationPortRanges: []
          sourceAddressPrefix: 'VirtualNetwork'
          sourceAddressPrefixes: []
          sourceApplicationSecurityGroupIds: []
          destinationAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefixes: []
          destinationApplicationSecurityGroupIds: []
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
          description: 'Allow MSSQL traffic (Port 1433) to the subnet.'
        }
      }
      {
        name: 'INBOUND-FROM-virtualNetwork-TO-virtualNetwork-PORT-445-PROT-Tcp-ALLOW'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourcePortRanges: []
          destinationPortRange: '445'
          destinationPortRanges: []
          sourceAddressPrefix: 'VirtualNetwork'
          sourceAddressPrefixes: []
          sourceApplicationSecurityGroupIds: []
          destinationAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefixes: []
          destinationApplicationSecurityGroupIds: []
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
          description: 'Allow SMB traffic (Port 445) to the subnet'
        }
      }
    ]
    enableRouteTable: false
    routeTableName: 'udr-syd-ads-dev-privateEndpoints'
    routes: []
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  {
    name: 'batch'
    addressPrefix: '10.208.152.192/26'
    networkSecurityGroupName: 'nsg-syd-ads-dev-batch'
    securityRules: []
    enableRouteTable: false
    routeTableName: 'udr-syd-ads-dev-batch'
    routes: []
    serviceEndpoints: []
    delegations: [
      {
        name: 'hostingEnvironment'
        properties: {
          serviceName: 'Microsoft.Batch/batchAccounts'
        }
      }
    ]
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
]
