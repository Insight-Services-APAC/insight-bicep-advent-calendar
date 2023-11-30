metadata name = 'ALZ Bicep - Spoke networking module'
metadata description = 'module used to create a spoke virtual network, including virtual network, subnets, NSGs and route tables'
metadata author = 'Insight APAC Platform Engineering'

@sys.description('The Azure Region to deploy the resources into.')
param location string = resourceGroup().location

@sys.description('Tags that will be applied to all resources in this module.')
param tags object = {}

@sys.description('The Name of the Spoke Virtual Network.')
param spokeNetworkName string = 'vnet-spoke'

@sys.description('The IP address range for the virtual network.')
param addressPrefixes string = '10.11.0.0/16'

@sys.description('DdosProtectionPlan Id which will be applied to the Virtual Network.')
param ddosProtectionPlanId string = ''

@sys.description('Array of DNS Server IP addresses for VNet.')
param dnsServerIps array = []

@sys.description('The subnet values for each subnet in the virtual network.')
param subnets array = []

@sys.description('Switch which allows BGP Propagation to be disabled on the route tables.')
param disableBGPRoutePropagation bool = false

@sys.description('Next hop IP address where network traffic should route to leveraged with DNS Proxy.')
param nextHopIPAddress string = ''

var sharedRoutes = loadYamlContent('../../configuration/shared/routes.yml').routes
var sharedNSGrulesInbound = json(loadTextContent('../../configuration/shared/nsgRulesInbound.json')).networkSecurityGroupSecurityRulesInbound
var sharedNSGrulesOutbound = json(loadTextContent('../../configuration/shared/nsgRulesOutbound.json')).networkSecurityGroupSecurityRulesOutbound

// Resource: Spoke Virtual Network
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: spokeNetworkName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefixes
      ]
    }
    enableDdosProtection: (!empty(ddosProtectionPlanId) ? true : false)
    ddosProtectionPlan: (!empty(ddosProtectionPlanId) ? true : false) ? {
      id: ddosProtectionPlanId
    } : null
    dhcpOptions: (!empty(dnsServerIps) ? true : false) ? {
      dnsServers: dnsServerIps
    } : null
    subnets: [for (subnet, index) in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        addressPrefixes: []
        networkSecurityGroup: (!empty(subnet.name)) ? {
          id: resourceId('Microsoft.Network/networkSecurityGroups', '${subnet.networkSecurityGroupName}')
        } : null
        routeTable: (!empty(subnet.name) && subnet.enableRouteTable) ? {
          id: resourceId('Microsoft.Network/routeTables', '${subnet.routeTableName}')
        } : null
        delegations: subnet.delegations
        privateEndpointNetworkPolicies: subnet.privateEndpointNetworkPolicies
        privateLinkServiceNetworkPolicies: subnet.privateLinkServiceNetworkPolicies
        serviceEndpointPolicies: []
        serviceEndpoints: subnet.serviceEndpoints
      }
    }]
  }
  dependsOn: [
    routeTable
    networkSecurityGroup
  ]
}

// Module: Route Table
module routeTable '../CARML/network/route-table/main.bicep' = [for (subnet, i) in subnets: if (!empty(nextHopIPAddress)) {
  name: 'rt-${i}'
  scope: resourceGroup()
  params: {
    name: subnet.routeTableName
    location: location
    tags: tags
        routes: concat(sharedRoutes, subnet.routes)
    disableBgpRoutePropagation: disableBGPRoutePropagation

  }
}]

// Module: Network Security Group
module networkSecurityGroup '../CARML/network/network-security-group/main.bicep' = [for (subnet, i) in subnets: {
  name: 'nsg-${i}'
  scope: resourceGroup()
  params: {
    name: subnet.networkSecurityGroupName
    location: location
    securityRules: concat(sharedNSGrulesInbound, subnet.securityRules, sharedNSGrulesOutbound)
    tags: tags
  }
}]

// Outputs
output spokeVirtualNetworkName string = virtualNetwork.name
output spokeVirtualNetworkId string = virtualNetwork.id
output spokeSubnets array = [for i in range(0, length(subnets)): {
  name: virtualNetwork.properties.subnets[i].name
  id: virtualNetwork.properties.subnets[i].id
}]
