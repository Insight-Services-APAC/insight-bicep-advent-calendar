targetScope = 'managementGroup'

@sys.description('The Azure Region to deploy the resources into.')
param location string = deployment().location

@description('The Subscription Id for the deployment.')
@maxLength(36)
param subscriptionId string = ''

@description('Whether to move the Subscription to the specified Management Group supplied in the parameter `subscriptionManagementGroupId`.')
param subscriptionManagementGroupAssociationEnabled bool = true

@description('The Management Group Id to place the subscription in.')
param subscriptionMgPlacement string = ''

@maxLength(10)
@sys.description('Specifies the Landing Zone prefix for the deployment and Azure resources. This is the function of the Landing Zone AIS, SAP, AVD etc.')
param lzPrefix string = ''

@allowed([
  'dev'
  'tst'
  'prd'
  'sbx'
  ''
])
@sys.description('Specifies the environment prefix for the deployment.')
param envPrefix string = ''

@sys.description('An object of tag key & value pairs to be appended to the Azure Subscription and Resource Group.')
param tags object = {}

@sys.description('Whether to create a virtual network or not.')
param virtualNetworkEnabled bool = true

@sys.description('The address space of the Virtual Network that will be created by this module, supplied as multiple CIDR blocks in an array, e.g. `["10.0.0.0/16","172.16.0.0/12"]`.')
param addressPrefixes string = ''

@sys.description('IP Address of the centralised firewall if used.')
param nextHopIpAddress string = ''

@sys.description('Specifies the Subnets array - name, address space, configuration.')
param subnets array = []

@sys.description('Array of DNS Server IP addresses for the Virtual Network.')
param dnsServerIps array = []

@sys.description('Switch which allows BGP Propagation to be disabled on the route tables.')
param disableBGPRoutePropagation bool = true

@sys.description('ResourceId of the DdosProtectionPlan which will be applied to the Virtual Network.')
param ddosProtectionPlanId string = ''

@sys.description('Whether to enable peering/connection with the supplied hub Virtual Network or Virtual WAN Virtual Hub.')
param virtualNetworkPeeringEnabled bool = true

@sys.description('The resource ID of the Virtual Network or Virtual WAN Hub in the hub to which the created Virtual Network, by this module, will be peered/connected to via Virtual Network Peering or a Virtual WAN Virtual Hub Connection.')
param hubVirtualNetworkId string = ''

@sys.description('Switch to enable/disable forwarded Traffic from outside spoke network.')
param allowSpokeForwardedTraffic bool = true

@sys.description('Switch to enable/disable VPN Gateway Transit for the hub network peering.')
param allowHubVpnGatewayTransit bool = true

@sys.description('Enables the ability for the Virtual WAN Hub Connection to learn the default route 0.0.0.0/0 from the Hub.')
param virtualNetworkVwanEnableInternetSecurity bool = true

@sys.description('The resource ID of the virtual hub route table to associate to the virtual hub connection (this virtual network). If left blank/empty default route table will be associated.')
param virtualNetworkVwanAssociatedRouteTableResourceId string = ''

@sys.description('An array of virtual hub route table resource IDs to propogate routes to. If left blank/empty default route table will be propogated to only.')
param virtualNetworkVwanPropagatedRouteTablesResourceIds array = []

@sys.description('An array of virtual hub route table labels to propogate routes to. If left blank/empty default label will be propogated to only.')
param virtualNetworkVwanPropagatedLabels array = []

@sys.description('Indicates whether routing intent is enabled on the Virtual HUB within the virtual WAN.')
param vHubRoutingIntentEnabled bool = true

@sys.description('Whether to create role assignments or not. If true, supply the array of role assignment objects in the parameter called `roleAssignments`.')
param roleAssignmentEnabled bool = false

@sys.description('Supply an array of objects containing the details of the role assignments to create.')
param roleAssignments array = []

@description('Specifies the Azure Budget details for the Landing Zone.')
param budgets array = []

@sys.description('Whether to create a Landing Zone Action Group or not.')
param actionGroupEnabled bool = true

@sys.description('Specifies an array of email addresses for the Landing Zone action group.')
param actionGroupEmails array = []

var namePrefixes = loadYamlContent('../../configuration/shared/namePrefixes.yml')
var locationPrefixes = loadYamlContent('../../configuration/shared/locationPrefixes.yml')
var commonResourceGroups = json(loadTextContent('../../configuration/shared/resourceGroups.json')).resourceGroups

var locPrefix = toLower('${locationPrefixes.australiaeast}')
var argPrefix = toLower('${namePrefixes.resourceGroup}-${locPrefix}-${lzPrefix}-${envPrefix}')
var vntPrefix = toLower('${namePrefixes.virtualNetwork}-${locPrefix}-${lzPrefix}-${envPrefix}')

var deploymentNameWrappers = {
  vnetAddressSpace: replace(addressPrefixes, '/', '_')
}

// Check hubVirtualNetworkId to see if it's a virtual WAN connection instead of normal virtual network peering
var virtualHubResourceIdChecked = (!empty(hubVirtualNetworkId) && contains(hubVirtualNetworkId, '/providers/Microsoft.Network/virtualHubs/') ? hubVirtualNetworkId : '')
var hubVirtualNetworkResourceIdChecked = (!empty(hubVirtualNetworkId) && contains(hubVirtualNetworkId, '/providers/Microsoft.Network/virtualNetworks/') ? hubVirtualNetworkId : '')

var hubVirtualNetworkName = (!empty(hubVirtualNetworkId) && contains(hubVirtualNetworkId, '/providers/Microsoft.Network/virtualNetworks/') ? split(hubVirtualNetworkId, '/')[8] : '')
var hubVirtualNetworkSubscriptionId = (!empty(hubVirtualNetworkId) && contains(hubVirtualNetworkId, '/providers/Microsoft.Network/virtualNetworks/') ? split(hubVirtualNetworkId, '/')[2] : '')
var hubVirtualNetworkResourceGroup = (!empty(hubVirtualNetworkId) && contains(hubVirtualNetworkId, '/providers/Microsoft.Network/virtualNetworks/') ? split(hubVirtualNetworkId, '/')[4] : '')

var virtualWanHubName = (!empty(virtualHubResourceIdChecked) ? split(virtualHubResourceIdChecked, '/')[8] : '')
var virtualWanHubSubscriptionId = (!empty(virtualHubResourceIdChecked) ? split(virtualHubResourceIdChecked, '/')[2] : '')
var virtualWanHubResourceGroupName = (!empty(virtualHubResourceIdChecked) ? split(virtualHubResourceIdChecked, '/')[4] : '')
var virtualWanHubConnectionAssociatedRouteTable = !empty(virtualNetworkVwanAssociatedRouteTableResourceId) ? virtualNetworkVwanAssociatedRouteTableResourceId : '${virtualHubResourceIdChecked}/hubRouteTables/defaultRouteTable'
var virutalWanHubDefaultRouteTableId = {
  id: '${virtualHubResourceIdChecked}/hubRouteTables/defaultRouteTable'
}
var virtualWanHubConnectionPropogatedRouteTables = !empty(virtualNetworkVwanPropagatedRouteTablesResourceIds) ? virtualNetworkVwanPropagatedRouteTablesResourceIds : array(virutalWanHubDefaultRouteTableId)
var virtualWanHubConnectionPropogatedLabels = !empty(virtualNetworkVwanPropagatedLabels) ? virtualNetworkVwanPropagatedLabels : [ 'default' ]

var resourceGroups = {
  network: '${argPrefix}-network'
}

var resourceNames = {
  virtualNetwork: '${vntPrefix}-${deploymentNameWrappers.vnetAddressSpace}'
}

// Module: Subscription Placement
module subscriptionPlacement '../../modules/subscriptionPlacement/subscriptionPlacement.bicep' = if (subscriptionManagementGroupAssociationEnabled && !empty(subscriptionMgPlacement)) {
  scope: managementGroup(subscriptionMgPlacement)
  name: 'subscriptionPlacement-${guid(deployment().name)}'
  params: {
    targetManagementGroupId: subscriptionMgPlacement
    subscriptionIds: [
      subscriptionId
    ]
  }
}

// Module: Subscription Tags
module subscriptionTags '../CARML/resources/tags/main.bicep' = if (!empty(tags)) {
  scope: subscription(subscriptionId)
  name: 'subTags-${guid(deployment().name)}'
  params: {
    subscriptionId: subscriptionId
    location: location
    onlyUpdate: true
    tags: tags
  }
}

// Module: Subscription Budget
module subscriptionbudget '../CARML/consumption/budget/main.bicep' = [for (bg, index) in budgets: if (!empty(budgets)) {
  name: take('subBudget-${guid(deployment().name)}-${index}', 64)
  scope: subscription(subscriptionId)
  params: {
    name: 'budget'
    location: location
    amount: bg.amount
    startDate: bg.startDate
    thresholds: bg.thresholds
    contactEmails: bg.contactEmails
  }
}]

// Module: Role Assignments
module roleAssignment '../CARML/authorization/role-assignment/main.bicep' = [for assignment in roleAssignments: if (roleAssignmentEnabled && !empty(roleAssignments)) {
  name: take('roleAssignments-${uniqueString(assignment.principalId)}', 64)
  params: {
    location: location
    principalId: assignment.principalId
    roleDefinitionIdOrName: assignment.definition
    subscriptionId: subscriptionId
    resourceGroupName: (contains(assignment.relativeScope, '/resourceGroups/') ? split(assignment.relativeScope, '/')[2] : '')
  }
}]

// Module: Resource Groups (Common)
module sharedResourceGroups '../resourceGroup/resourceGroups.bicep' = [for item in commonResourceGroups: {
  name: item
  scope: subscription(subscriptionId)
  params: {
    resourceGroupNames: commonResourceGroups
    location: location
    tags: tags
  }
}]

// Module: Action Group
module actionGroup 'br/public:avm-res-insights-actiongroup:0.1.1' = if (actionGroupEnabled && !empty(actionGroupEmails)) {
  name: 'actionGroup-${guid(deployment().name)}'
  scope: resourceGroup(subscriptionId, 'alertsRG')
  dependsOn: [
    sharedResourceGroups
  ]
  params: {
    location: 'Global'
    name: '${lzPrefix}${envPrefix}ActionGroup'
    groupShortName: '${lzPrefix}${envPrefix}AG'
    emailReceivers: [for email in actionGroupEmails: {
      emailAddress: email
      name: split(email, '@')[0]
      useCommonAlertSchema: true
    }]
  }
}

// Module: Resource Groups (Network)
module resourceGroupForNetwork '../CARML/resources/resource-group/main.bicep' = if (virtualNetworkEnabled) {
  name: 'resourceGroupForNetwork-${guid(deployment().name)}'
  scope: subscription(subscriptionId)
  params: {
    name: resourceGroups.network
    location: location
    tags: tags
  }
}

// Module: Network Watcher
module networkWatcher '../CARML/network/network-watcher/main.bicep' = if (virtualNetworkEnabled) {
  name: 'networkWatcher-${guid(deployment().name)}'
  scope: resourceGroup(subscriptionId, 'networkWatcherRG')
  dependsOn: [
    sharedResourceGroups
  ]
  params: {
    location: location
    tags: tags
  }
}

// Module: Spoke Networking
module spokeNetworking '../spokeNetworking/spokeNetworking.bicep' = if (virtualNetworkEnabled && !empty(addressPrefixes)) {
  scope: resourceGroup(subscriptionId, resourceGroups.network)
  name: 'spokeNetworking-${guid(deployment().name)}'
  dependsOn: [
    resourceGroupForNetwork
  ]
  params: {
    spokeNetworkName: resourceNames.virtualNetwork
    addressPrefixes: addressPrefixes
    ddosProtectionPlanId: ddosProtectionPlanId
    dnsServerIps: dnsServerIps
    nextHopIPAddress: nextHopIpAddress
    subnets: subnets
    disableBGPRoutePropagation: disableBGPRoutePropagation
    tags: tags
    location: location
  }
}

// Module: Virtual Network Peering (Hub to Spoke)
module hubPeeringToSpoke '../vnetPeering/vnetPeering.bicep' = if (virtualNetworkEnabled && virtualNetworkPeeringEnabled && !empty(hubVirtualNetworkResourceIdChecked) && !empty(addressPrefixes) && !empty(hubVirtualNetworkResourceGroup) && !empty(hubVirtualNetworkSubscriptionId)) {
  scope: resourceGroup(hubVirtualNetworkSubscriptionId, hubVirtualNetworkResourceGroup)
  name: 'hubPeeringToSpoke-${guid(deployment().name)}'
  params: {
    sourceVirtualNetworkName: hubVirtualNetworkName
    destinationVirtualNetworkName: (!empty(hubVirtualNetworkName) ? spokeNetworking.outputs.spokeVirtualNetworkName : '')
    destinationVirtualNetworkId: (!empty(hubVirtualNetworkName) ? spokeNetworking.outputs.spokeVirtualNetworkId : '')
    allowForwardedTraffic: allowSpokeForwardedTraffic
    allowGatewayTransit: allowHubVpnGatewayTransit
  }
}

// Module: Virtual Network Peering (Spoke to Hub)
module spokePeeringToHub '../vnetPeering/vnetPeering.bicep' = if (virtualNetworkEnabled && virtualNetworkPeeringEnabled && !empty(hubVirtualNetworkResourceIdChecked) && !empty(addressPrefixes) && !empty(hubVirtualNetworkResourceGroup) && !empty(hubVirtualNetworkSubscriptionId)) {
  scope: resourceGroup(subscriptionId, resourceGroups.network)
  name: 'spokePeeringToHub-${guid(deployment().name)}'
  params: {
    sourceVirtualNetworkName: (!empty(hubVirtualNetworkName) ? spokeNetworking.outputs.spokeVirtualNetworkName : '')
    destinationVirtualNetworkName: hubVirtualNetworkName
    destinationVirtualNetworkId: hubVirtualNetworkId
    allowForwardedTraffic: allowSpokeForwardedTraffic
    useRemoteGateways: allowHubVpnGatewayTransit
  }
}

module spokePeeringToVwanHub '../CARML/network/virtual-hub/hub-virtual-network-connection/main.bicep' = if (virtualNetworkEnabled && virtualNetworkPeeringEnabled && !empty(virtualHubResourceIdChecked) && !empty(addressPrefixes) && !empty(virtualWanHubResourceGroupName) && !empty(virtualWanHubSubscriptionId)) {
  dependsOn: [
    resourceGroupForNetwork
  ]
  scope: resourceGroup(virtualWanHubSubscriptionId, virtualWanHubResourceGroupName)
  name: 'spokePeeringToVwanHub-${guid(deployment().name)}'
  params: {
    name: 'vhc-${guid(virtualHubResourceIdChecked, spokeNetworking.outputs.spokeVirtualNetworkName, resourceGroups.network, location, subscriptionId)}'
    virtualHubName: virtualWanHubName
    remoteVirtualNetworkId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroups.network}/providers/Microsoft.Network/virtualNetworks/${spokeNetworking.outputs.spokeVirtualNetworkName}'
    enableInternetSecurity: virtualNetworkVwanEnableInternetSecurity
    routingConfiguration: !vHubRoutingIntentEnabled ? {
      associatedRouteTable: {
        id: virtualWanHubConnectionAssociatedRouteTable
      }
      propagatedRouteTables: {
        ids: virtualWanHubConnectionPropogatedRouteTables
        labels: virtualWanHubConnectionPropogatedLabels
      }
    } : {}
  }
}
