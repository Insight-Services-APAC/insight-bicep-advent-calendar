
metadata name = 'ALZ Bicep - Virtual Network Peering module'
metadata description = 'Module used to set up Virtual Network Peering between Virtual Networks'
metadata author = 'Insight APAC Platform Engineering'

@description('The Name of Vnet Peering resource.')
param name string = '${sourceVirtualNetworkName}-${destinationVirtualNetworkName}'

@description('Virtual Network ID of Virtual Network destination.')
param destinationVirtualNetworkId string = ''

@description('Name of source Virtual Network we are peering.')
param sourceVirtualNetworkName string

@description('Name of destination virtual network we are peering.')
param destinationVirtualNetworkName string

@description('Switch to enable/disable Virtual Network Access for the Network Peer.')
param allowVirtualNetworkAccess bool = true

@description('Switch to enable/disable forwarded traffic for the Network Peer.')
param allowForwardedTraffic bool = true

@description('Switch to enable/disable gateway transit for the Network Peer.')
param allowGatewayTransit bool = false

@description('Switch to enable/disable remote gateway for the Network Peer.')
param useRemoteGateways bool = false

// Resource: Virtual Network Peering
resource virtualNetworkPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-01-01' = {
  name: '${sourceVirtualNetworkName}/${name}'
  properties: {
    allowVirtualNetworkAccess: allowVirtualNetworkAccess
    allowForwardedTraffic: allowForwardedTraffic
    allowGatewayTransit: allowGatewayTransit
    useRemoteGateways: useRemoteGateways
    remoteVirtualNetwork: {
      id: destinationVirtualNetworkId
    }
  }
}
