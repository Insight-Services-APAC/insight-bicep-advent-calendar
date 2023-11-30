targetScope = 'managementGroup'

metadata name = 'Azure Landing Zone Vending'
metadata description = 'These are the input parameters for the Bicep module'
metadata author = 'Insight APAC Platform Engineering'

// Subscription Creation Module Parameters
@metadata({
  example: false
})
@sys.description('''Whether to create a new Azure Subscription using the subscriptionCreation module. If false, then supply the existingSubscriptionId parameter instead to deploy resources to an existing subscription.'

- Type: Boolean''')
param subscriptionAliasEnabled bool = false

@metadata({
  example: 'sub-sap-dev-01'
})
@maxLength(63)
@sys.description('''The name of the subscription alias. The string must be comprised of a-z, A-Z, 0-9, - and _. The maximum length is 63 characters.

The string must be comprised of `a-z`, `A-Z`, `0-9`, `-`, `_` and `` (space). The maximum length is 63 characters.

> The value for this parameter and the parameter named `subscriptionAliasName` are usually set to the same value for simplicity. But they can be different if required for a reason.
> **Not required when providing an existing Subscription ID via the parameter `existingSubscriptionId`**

- Type: String
- Default value: `''` *(empty string)*''')
param subscriptionDisplayName string = ''

@metadata({
  example: 'sub-sap-dev-01'
})
@maxLength(63)
@sys.description('''The name of the Subscription Alias, that will be created by this module.

The string must be comprised of `a-z`, `A-Z`, `0-9`, `-`, `_` and `` (space). The maximum length is 63 characters.

> **Not required when providing an exisiting Subscription ID via the paramater `existingSubscriptionId`**

- Type: String
- Default value: `''` *(empty string)*''')
param subscriptionAliasName string = ''

@metadata({
  example: 'providers/Microsoft.Billing/billingAccounts/1234567/enrollmentAccounts/123456'
})
@sys.description('''The Billing Scope for the new Subscription alias, that will be created by this module.

A valid Billing Scope starts with `/providers/Microsoft.Billing/billingAccounts/` and is case sensitive.

> See below [example in parameter file](#parameter-file) for an example
> **Not required when providing an exisiting Subscription ID via the paramater `existingSubscriptionId`**

- Type: String
- Default value: `''` *(empty string)*''')
param subscriptionBillingScope string = ''

@metadata({
  example: 'Production'
})
@allowed([
  'DevTest'
  'Production'
])
@sys.description('''The workload type can be either `Production` or `DevTest` and is case sensitive.

> **Not required when providing an exisiting Subscription ID via the paramater `existingSubscriptionId`**

- Type: String''')
param subscriptionWorkload string = 'Production'

// Subscription Wrapper Module Parameters
@metadata({
  example: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
})
@maxLength(36)
@sys.description('''An existing subscription ID. Use this when you do not want the module to create a new subscription. But do want to manage the management group membership. A subscription ID should be provided in the example format `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`.

- Type: String
- Default value: `''` *(empty string)*''')
param existingSubscriptionId string = ''

@metadata({
  example: true
})
@sys.description('''Whether to move the Subscription to the specified Management Group supplied in the parameter `subscriptionManagementGroupId`.

- Type: Boolean''')
param subscriptionManagementGroupAssociationEnabled bool = true

@metadata({
  example: '/providers/Microsoft.Management/managementGroups/mg-alz-landingzones'
})
@sys.description('''The destination Management Group ID for the new Subscription that will be created by this module (or the existing one provided in the parameter `existingSubscriptionId`).

**IMPORTANT:** Do not supply the display name of the Management Group. The Management Group ID forms part of the Azure Resource ID. e.g., `/providers/Microsoft.Management/managementGroups/{managementGroupId}`.

- Type: String
- Default value: `''` *(empty string)*''')
param subscriptionMgPlacement string = ''

@metadata({
  example: 'australiaeast'
})
@sys.description('''The Azure Region to deploy the Landing Zone into.

- Type: String''')
param location string = deployment().location

@metadata({
  example: 'sap'
})
@maxLength(10)
@sys.description('''Specifies the Landing Zone prefix for the deployment and Azure resources. This is the function of the Landing Zone AIS, SAP, AVD etc.')

- Type: String
- Default value: `''` *(empty string)*''')
param lzPrefix string = ''

@metadata({
  example: 'dev'
})
@allowed([
  'dev'
  'tst'
  'prd'
  'sbx'
  ''
])
@sys.description('''Specifies the environment prefix for the deployment.

- Type: String
- Default value: `''` *(empty string)*''')
param envPrefix string = ''

@metadata({
  example: {
    tagKey1: 'value'
    'tagKey-2': 'value'
  }
})
@sys.description('''An object of Tag key & value pairs to be appended to a Subscription.

> **NOTE:** Tags will only be overwritten if existing tag exists with same key as provided in this parameter; values provided here win.

- Type: *Object*
- Default value: `{}` *(empty object)*''')
param tags object = {}

// Spoke Networking Module Parameters
@metadata({
  example: true
})
@sys.description('''Whether to create a virtual network or not.

If set to `true` ensure you also provide values for the following parameters at a minimum:

- `addressPrefixes`

> Other parameters may need to be set based on other parameters that you enable that are listed above. Check each parameters documentation for further information.

- Type: Boolean''')
param virtualNetworkEnabled bool = true

@metadata({
  example: [
    '10.0.0.0/16'
  ]
})
@sys.description('''The address space of the Virtual Network that will be created by this module, supplied as multiple CIDR blocks in an array, e.g. `["10.0.0.0/16","172.16.0.0/12"]`

- Type: `[]` Array
- Default value: `[]` *(empty array)*''')
param addressPrefixes string = ''

@metadata({
  example: '10.1.1.1'
})
@sys.description('''IP Address of the centralised firewall that will be used as the next hop address.'

- Type: String
- Default value: `''` *(empty string)*''')
param nextHopIpAddress string = ''

@metadata({
  example: [
    '10.1.1.1' //Update
  ]
})
@sys.description('''Specifies the Subnets array - name, address space, configuration.

- Type: `[]` Array
- Default value: `[]` *(empty array)*''')
param subnets array = []

@metadata({
  example: [
    '10.1.1.2'
    '10.1.1.3'
  ]
})
@sys.description('''Array of DNS Server IP addresses for the VNet.'

- Type: `[]` Array
- Default value: `[]` *(empty array)*''')
param dnsServerIps array = []

@metadata({
  example: true
})
@sys.description('''Switch which allows BGP Propagation to be disabled on the route tables.'

- Type: Boolean''')
param disableBGPRoutePropagation bool = true

@metadata({
  example: ''
})
@sys.description('''ResourceId of the DdosProtectionPlan which will be applied to the Virtual Network.')

- Type: String
- Default value: `''` *(empty string)*''')
param ddosProtectionPlanId string = ''

// Virtual Networking Peering & vWAN Modules Parameters
@metadata({
  example: true
})
@sys.description('''Whether to enable peering/connection with the supplied hub Virtual Network or Virtual WAN Virtual Hub.

- Type: Boolean''')
param virtualNetworkPeeringEnabled bool = true

@metadata({
  example: '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/xxxxxxxxxx/providers/Microsoft.Network/virtualNetworks/xxxxxxxxxx'
})
@sys.description('''The resource ID of the Virtual Network or Virtual WAN Hub in the hub to which the created Virtual Network, by this module, will be peered/connected to via Virtual Network Peering or a Virtual WAN Virtual Hub Connection.

**Example Expected Values:**

- Hub Virtual Network Resource ID: `/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/xxxxxxxxxx/providers/Microsoft.Network/virtualNetworks/xxxxxxxxxx`
- Virtual WAN Virtual Hub Resource ID: `/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/xxxxxxxxxx/providers/Microsoft.Network/virtualHubs/xxxxxxxxxx`

- Type: String
- Default value: `''` *(empty string)*''')
param hubVirtualNetworkId string = ''

@metadata({
  example: true
})
@sys.description('''Switch to enable/disable forwarded Traffic from outside spoke network.

- Type: Boolean''')
param allowSpokeForwardedTraffic bool = true

@metadata({
  example: true
})
@sys.description('''Switch to enable/disable VPN Gateway for the hub network peering.

- Type: Boolean''')
param allowHubVpnGatewayTransit bool = true

@metadata({
  example: true
})
@sys.description('''Enables the ability for the Virtual WAN Hub Connection to learn the default route 0.0.0.0/0 from the Hub.

- Type: Boolean''')
param virtualNetworkVwanEnableInternetSecurity bool = true

@metadata({
  example: '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/xxxxxxxxxx/providers/Microsoft.Network/virtualHubs/xxxxxxxxx/hubRouteTables/xxxxxxxxx'
})
@sys.description('''The resource ID of the virtual hub route table to associate to the virtual hub connection (this virtual network). If left blank/empty the `defaultRouteTable` will be associated.

- Type: String
- Default value: `''` *(empty string)* = Which means if the parameter `virtualNetworkPeeringEnabled` is `true` and also the parameter `hubNetworkResourceId` is not empty then the `defaultRouteTable` will be associated of the provided Virtual Hub in the parameter `hubNetworkResourceId`.
- e.g. `/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/xxxxxxxxxx/providers/Microsoft.Network/virtualHubs/xxxxxxxxx/hubRouteTables/defaultRouteTable`''')
param virtualNetworkVwanAssociatedRouteTableResourceId string = ''

@metadata({
  example: [
    {
      id: '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/xxxxxxxxxx/providers/Microsoft.Network/virtualHubs/xxxxxxxxx/hubRouteTables/defaultRouteTable'
    }
    {
      id: '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/xxxxxxxxxx/providers/Microsoft.Network/virtualHubs/xxxxxxxxx/hubRouteTables/xxxxxxxxx'
    }
  ]
})
@sys.description('''An array of of objects of virtual hub route table resource IDs to propagate routes to. If left blank/empty the `defaultRouteTable` will be propagated to only.

Each object must contain the following `key`:

- `id` = The Resource ID of the Virtual WAN Virtual Hub Route Table IDs you wish to propagate too

> **IMPORTANT:** If you provide any Route Tables in this array of objects you must ensure you include also the `defaultRouteTable` Resource ID as an object in the array as it is not added by default when a value is provided for this parameter.

- Type: `[]` Array
- Default value: `[]` *(empty array)*''')
param virtualNetworkVwanPropagatedRouteTablesResourceIds array = []

@metadata({
  example: [
    'default'
    'anotherLabel'
  ]
})
@sys.description('''An array of virtual hub route table labels to propagate routes to. If left blank/empty the default label will be propagated to only.

- Type: `[]` Array
- Default value: `[]` *(empty array)*''')
param virtualNetworkVwanPropagatedLabels array = []

@metadata({
  example: false
})
@sys.description('''Indicates whether routing intent is enabled on the Virtual Hub within the Virtual WAN.

- Type: Boolean''')
param vHubRoutingIntentEnabled bool = false

// Role Assignment Modules Parameters
@metadata({
  example: true
})
@sys.description('''Whether to create role assignments or not. If true, supply the array of role assignment objects in the parameter called `roleAssignments`.

- Type: Boolean''')
param roleAssignmentEnabled bool = true

@metadata({
  example: [
    {
      principalId: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
      definition: 'Contributor'
      relativeScope: ''
    }
    {
      principalId: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
      definition: '/providers/Microsoft.Authorization/roleDefinitions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
      relativeScope: ''
    }
    {
      principalId: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
      definition: 'Reader'
      relativeScope: '/resourceGroups/rsg-networking-001'
    }
    {
      principalId: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
      definition: '/providers/Microsoft.Authorization/roleDefinitions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
      relativeScope: '/resourceGroups/rsg-networking-001'
    }
  ]
})
@sys.description('''Supply an array of objects containing the details of the role assignments to create.

Each object must contain the following `keys`:

- `principalId` = The Object ID of the User, Group, SPN, Managed Identity to assign the RBAC role too.
- `definition` = The Name of built-In RBAC Roles or a Resource ID of a Built-in or custom RBAC Role Definition.
- `relativeScope` = 2 options can be provided for input value:
    1. `''` *(empty string)* = Make RBAC Role Assignment to Subscription scope
    2. `'/resourceGroups/<RESOURCE GROUP NAME>'` = Make RBAC Role Assignment to specified Resource Group

- Type: `[]` Array
- Default value: `[]` *(empty array)*''')
param roleAssignments array = []

@metadata({
  example: [
    'test@outlook.com'
    'test1@outlook.com'
  ]
})
@sys.description('''Specifies an array of email addresses for the Landing Zone action group.'

- Type: `[]` Array
- Default value: `[]` *(empty array)*''')
param actionGroupEmails array = []

@metadata({
  example: [
    {
      amount: 500
      thresholds: [
        80
        100
      ]
      contactEmails: [
        'test@outlook.com'
      ]
    }
  ]
})
@sys.description('''Specifies an array of budget configuration for the Landing Zone.

- Type: `[]` Array
- Default value: `[]` *(empty array)*''')
param budgets array = []

// Orchestration Variables
var existingSubscriptionIDEmptyCheck = empty(existingSubscriptionId) ? 'No Subscription Id Provided' : existingSubscriptionId

// Module: Subscription Creation
module subscriptionCreation '../modules/subscriptionCreation/subscriptionCreation.bicep' = if (subscriptionAliasEnabled && empty(existingSubscriptionId)) {
  scope: tenant()
  name: 'subscriptionCreation-${guid(deployment().name)}'
  params: {
    subscriptionBillingScope: subscriptionBillingScope
    subscriptionAliasName: subscriptionAliasName
    subscriptionDisplayName: subscriptionDisplayName
    subscriptionWorkload: subscriptionWorkload
  }
}

// Module: Subscription Wrapper
module subscriptionWrapper '../modules/subscriptionWrapper/subscriptionWrapper.bicep' = if ((subscriptionAliasEnabled || !empty(existingSubscriptionId)) && virtualNetworkEnabled) {
  name: 'subscriptionWrapper-${guid(deployment().name)}'
  params: {
    location: location
    subscriptionId: (subscriptionAliasEnabled && empty(existingSubscriptionId)) ? subscriptionCreation.outputs.subscriptionId : existingSubscriptionId
    subscriptionManagementGroupAssociationEnabled: subscriptionManagementGroupAssociationEnabled
    subscriptionMgPlacement: subscriptionMgPlacement
    tags: tags
    lzPrefix: lzPrefix
    envPrefix: envPrefix
    virtualNetworkEnabled: virtualNetworkEnabled
    addressPrefixes: addressPrefixes
    nextHopIpAddress: nextHopIpAddress
    subnets: subnets
    dnsServerIps: dnsServerIps
    disableBGPRoutePropagation: disableBGPRoutePropagation
    ddosProtectionPlanId: ddosProtectionPlanId
    virtualNetworkPeeringEnabled: virtualNetworkPeeringEnabled
    hubVirtualNetworkId: hubVirtualNetworkId
    allowSpokeForwardedTraffic: allowSpokeForwardedTraffic
    virtualNetworkVwanEnableInternetSecurity: virtualNetworkVwanEnableInternetSecurity
    virtualNetworkVwanAssociatedRouteTableResourceId: virtualNetworkVwanAssociatedRouteTableResourceId
    virtualNetworkVwanPropagatedRouteTablesResourceIds: virtualNetworkVwanPropagatedRouteTablesResourceIds
    virtualNetworkVwanPropagatedLabels: virtualNetworkVwanPropagatedLabels
    vHubRoutingIntentEnabled: vHubRoutingIntentEnabled
    allowHubVpnGatewayTransit: allowHubVpnGatewayTransit
    roleAssignmentEnabled: roleAssignmentEnabled
    roleAssignments: roleAssignments
    actionGroupEmails: actionGroupEmails
    budgets: budgets
  }
}

// Output
@sys.description('The Subscription Id that has either been created or provided.')
output subscriptionId string = (subscriptionAliasEnabled && empty(existingSubscriptionId)) ? subscriptionCreation.outputs.subscriptionId : contains(existingSubscriptionIDEmptyCheck, 'No Subscription Id Provided') ? existingSubscriptionIDEmptyCheck : '${existingSubscriptionId}'

@sys.description('The Subscription Resource Id that has been created or provided.')
output subscriptionResourceId string = (subscriptionAliasEnabled && empty(existingSubscriptionId)) ? subscriptionCreation.outputs.subscriptionResourceId : contains(existingSubscriptionIDEmptyCheck, 'No Subscription Id Provided') ? existingSubscriptionIDEmptyCheck : '/subscriptions/${existingSubscriptionId}'
