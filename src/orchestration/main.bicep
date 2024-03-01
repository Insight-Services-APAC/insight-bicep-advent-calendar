targetScope = 'subscription'

metadata name = 'ALZ Bicep - Subscription Wrapper module'
metadata description = 'module used to wrap the Landing Zone deployment'
metadata author = 'Insight APAC Platform Engineering'

@description('The Azure Region to deploy the resources into.')
param location string = deployment().location

@maxLength(5)
@description('Specifies the Landing Zone prefix for the deployment and Azure resources. This is the function of the Landing Zone AIS, SAP, AVD etc.')
param lzPrefix string = ''

@allowed([
  'dev'
  'tst'
  'prd'
  'sbx'
  ''
])
@description('Specifies the environment prefix for the deployment.')
param envPrefix string = ''

@description('An object of tag key & value pairs to be appended to the Azure Subscription and Resource Group.')
param tags object = {}

@description('Whether to create a virtual network or not.')
param virtualNetworkEnabled bool = true

@description('The address space of the Virtual Network that will be created by this module, supplied as multiple CIDR blocks in an array, e.g. `["10.0.0.0/16","172.16.0.0/12"]`.')
param addressPrefixes string = ''

@description('IP Address of the centralised firewall if used.')
param nextHopIpAddress string = ''

@description('Specifies the Subnets array - name, address space, configuration.')
param subnets array = []

@description('Array of DNS Server IP addresses for the Virtual Network.')
param dnsServerIps array = []

@description('Switch which allows BGP Propagation to be disabled on the route tables.')
param disableBGPRoutePropagation bool = true

@description('ResourceId of the DdosProtectionPlan which will be applied to the Virtual Network.')
param ddosProtectionPlanId string = ''

@description('Whether to enable peering/connection with the supplied hub Virtual Network or Virtual WAN Virtual Hub.')
param virtualNetworkPeeringEnabled bool = true

@description('The resource ID of the Virtual Network or Virtual WAN Hub in the hub to which the created Virtual Network, by this module, will be peered/connected to via Virtual Network Peering or a Virtual WAN Virtual Hub Connection.')
param hubVirtualNetworkId string = ''

@description('Switch to enable/disable forwarded Traffic from outside spoke network.')
param allowSpokeForwardedTraffic bool = true

@description('Switch to enable/disable VPN Gateway Transit for the hub network peering.')
param allowHubVpnGatewayTransit bool = true

@description('Whether to create role assignments or not. If true, supply the array of role assignment objects in the parameter called `roleAssignments`.')
param roleAssignmentEnabled bool = false

@description('Supply an array of objects containing the details of the role assignments to create.')
param roleAssignments array = []

@description('Specifies the Azure Budget details for the Landing Zone.')
param budgets array = []

@description('Whether to create a Landing Zone Action Group or not.')
param actionGroupEnabled bool = true

@description('Specifies an array of email addresses for the Landing Zone action group.')
param actionGroupEmails array = []

var namePrefixes = loadYamlContent('../configuration/shared/namePrefixes.yml')
var locationPrefixes = loadYamlContent('../configuration/shared/locationPrefixes.yml')
var commonResourceGroups = loadYamlContent('../configuration/shared/resourceGroups.yml').resourceGroups

var locPrefix = toLower('${locationPrefixes.australiaeast}')
var argPrefix = toLower('${namePrefixes.resourceGroup}-${locPrefix}-${lzPrefix}-${envPrefix}')
var vntPrefix = toLower('${namePrefixes.virtualNetwork}-${locPrefix}-${lzPrefix}-${envPrefix}')

var deploymentNameWrappers = {
  vnetAddressSpace: replace(addressPrefixes, '/', '_')
}

// Check hubVirtualNetworkId to see if it's a virtual WAN connection instead of normal virtual network peering
var hubVirtualNetworkResourceIdChecked = (!empty(hubVirtualNetworkId) && contains(hubVirtualNetworkId, '/providers/Microsoft.Network/virtualNetworks/') ? hubVirtualNetworkId : '')

var hubVirtualNetworkName = (!empty(hubVirtualNetworkId) && contains(hubVirtualNetworkId, '/providers/Microsoft.Network/virtualNetworks/') ? split(hubVirtualNetworkId, '/')[8] : '')
var hubVirtualNetworkSubscriptionId = (!empty(hubVirtualNetworkId) && contains(hubVirtualNetworkId, '/providers/Microsoft.Network/virtualNetworks/') ? split(hubVirtualNetworkId, '/')[2] : '')
var hubVirtualNetworkResourceGroup = (!empty(hubVirtualNetworkId) && contains(hubVirtualNetworkId, '/providers/Microsoft.Network/virtualNetworks/') ? split(hubVirtualNetworkId, '/')[4] : '')


var resourceGroups = {
  network: '${argPrefix}-network'
}

var resourceNames = {
  virtualNetwork: '${vntPrefix}-${deploymentNameWrappers.vnetAddressSpace}'
}

// Module: Subscription Tags
module subscriptionTags '../modules/CARML/resources/tags/main.bicep' = if (!empty(tags)) {
  scope: subscription()
  name: take('subTags-${guid(deployment().name)}', 64)
  params: {
    location: location
    onlyUpdate: true
    tags: tags
  }
}

// Module: Subscription Budget
module subscriptionbudget '../modules/CARML/consumption/budget/main.bicep' = [for (bg, index) in budgets: if (!empty(budgets) && bg.enabled) {
  name: take('subBudget-${guid(deployment().name)}-${index}', 64)
  scope: subscription()
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
module roleAssignment '../modules/CARML/authorization/role-assignment/subscription/main.bicep' = [for assignment in roleAssignments: if (roleAssignmentEnabled && !empty(roleAssignments)) {
  name: take('roleAssignments-${uniqueString(assignment.principalId)}', 64)
  params: {
    location: location
    principalId: assignment.principalId
    roleDefinitionIdOrName: assignment.definition
  }
}]

// Module: Resource Groups (Common)
module sharedResourceGroups '../modules/resourceGroup/resourceGroups.bicep' = [for item in commonResourceGroups: {
  name: item
  scope: subscription()
  params: {
    resourceGroupNames: commonResourceGroups
    location: location
    tags: tags
  }
}]

// Module: Action Group
module actionGroup 'br/public:avm-res-insights-actiongroup:0.1.1' = if (actionGroupEnabled && !empty(actionGroupEmails)) {
  name: take('actionGroup-${guid(deployment().name)}', 64)
  scope: resourceGroup('alertsRG')
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
module resourceGroupForNetwork 'br/public:avm/res/resources/resource-group:0.2.2' = if (virtualNetworkEnabled) {
  name: take('resourceGroupForNetwork-${guid(deployment().name)}', 64)
  scope: subscription()
  params: {
    name: resourceGroups.network
    location: location
    tags: tags
  }
}

// Module: Network Watcher
module networkWatcher '../modules/CARML/network/network-watcher/main.bicep' = if (virtualNetworkEnabled) {
  name: take('networkWatcher-${guid(deployment().name)}', 64)
  scope: resourceGroup('networkWatcherRG')
  dependsOn: [
    sharedResourceGroups
  ]
  params: {
    location: location
    tags: tags
  }
}

// Module: Spoke Networking
module spokeNetworking '../modules/spokeNetworking/spokeNetworking.bicep' = if (virtualNetworkEnabled && !empty(addressPrefixes)) {
  scope: resourceGroup(resourceGroups.network)
  name: take('spokeNetworking-${guid(deployment().name)}', 64)
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
module hubPeeringToSpoke '../modules/vnetPeering/vnetPeering.bicep' = if (virtualNetworkEnabled && virtualNetworkPeeringEnabled && !empty(hubVirtualNetworkResourceIdChecked) && !empty(addressPrefixes) && !empty(hubVirtualNetworkResourceGroup) && !empty(hubVirtualNetworkSubscriptionId)) {
  scope: resourceGroup(hubVirtualNetworkSubscriptionId, hubVirtualNetworkResourceGroup)
  name: take('hubPeeringToSpoke-${guid(deployment().name)}', 64)
  params: {
    sourceVirtualNetworkName: hubVirtualNetworkName
    destinationVirtualNetworkName: (!empty(hubVirtualNetworkName) ? spokeNetworking.outputs.spokeVirtualNetworkName : '')
    destinationVirtualNetworkId: (!empty(hubVirtualNetworkName) ? spokeNetworking.outputs.spokeVirtualNetworkId : '')
    allowForwardedTraffic: allowSpokeForwardedTraffic
    allowGatewayTransit: allowHubVpnGatewayTransit
  }
}

// Module: Virtual Network Peering (Spoke to Hub)
module spokePeeringToHub '../modules/vnetPeering/vnetPeering.bicep' = if (virtualNetworkEnabled && virtualNetworkPeeringEnabled && !empty(hubVirtualNetworkResourceIdChecked) && !empty(addressPrefixes) && !empty(hubVirtualNetworkResourceGroup) && !empty(hubVirtualNetworkSubscriptionId)) {
  scope: resourceGroup(resourceGroups.network)
  name: take('spokePeeringToHub-${guid(deployment().name)}', 64)
  params: {
    sourceVirtualNetworkName: (!empty(hubVirtualNetworkName) ? spokeNetworking.outputs.spokeVirtualNetworkName : '')
    destinationVirtualNetworkName: hubVirtualNetworkName
    destinationVirtualNetworkId: hubVirtualNetworkId
    allowForwardedTraffic: allowSpokeForwardedTraffic
    useRemoteGateways: allowHubVpnGatewayTransit
  }
}
