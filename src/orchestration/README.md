# ALZ Bicep - Subscription Wrapper module

module used to wrap the Landing Zone deployment

## Parameters

Parameter name | Required | Description
-------------- | -------- | -----------
location       | No       | The Azure Region to deploy the resources into.
lzPrefix       | No       | Specifies the Landing Zone prefix for the deployment and Azure resources. This is the function of the Landing Zone AIS, SAP, AVD etc.
envPrefix      | No       | Specifies the environment prefix for the deployment.
tags           | No       | An object of tag key & value pairs to be appended to the Azure Subscription and Resource Group.
virtualNetworkEnabled | No       | Whether to create a virtual network or not.
addressPrefixes | No       | The address space of the Virtual Network that will be created by this module, supplied as multiple CIDR blocks in an array, e.g. `["10.0.0.0/16","172.16.0.0/12"]`.
nextHopIpAddress | No       | IP Address of the centralised firewall if used.
subnets        | No       | Specifies the Subnets array - name, address space, configuration.
dnsServerIps   | No       | Array of DNS Server IP addresses for the Virtual Network.
disableBGPRoutePropagation | No       | Switch which allows BGP Propagation to be disabled on the route tables.
ddosProtectionPlanId | No       | ResourceId of the DdosProtectionPlan which will be applied to the Virtual Network.
virtualNetworkPeeringEnabled | No       | Whether to enable peering/connection with the supplied hub Virtual Network or Virtual WAN Virtual Hub.
hubVirtualNetworkId | No       | The resource ID of the Virtual Network or Virtual WAN Hub in the hub to which the created Virtual Network, by this module, will be peered/connected to via Virtual Network Peering or a Virtual WAN Virtual Hub Connection.
allowSpokeForwardedTraffic | No       | Switch to enable/disable forwarded Traffic from outside spoke network.
allowHubVpnGatewayTransit | No       | Switch to enable/disable VPN Gateway Transit for the hub network peering.
roleAssignmentEnabled | No       | Whether to create role assignments or not. If true, supply the array of role assignment objects in the parameter called `roleAssignments`.
roleAssignments | No       | Supply an array of objects containing the details of the role assignments to create.
budgets        | No       | Specifies the Azure Budget details for the Landing Zone.
actionGroupEnabled | No       | Whether to create a Landing Zone Action Group or not.
actionGroupEmails | No       | Specifies an array of email addresses for the Landing Zone action group.

### location

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

The Azure Region to deploy the resources into.

- Default value: `[deployment().location]`

### lzPrefix

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Specifies the Landing Zone prefix for the deployment and Azure resources. This is the function of the Landing Zone AIS, SAP, AVD etc.

### envPrefix

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Specifies the environment prefix for the deployment.

- Allowed values: `dev`, `tst`, `prd`, `sbx`, ``

### tags

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

An object of tag key & value pairs to be appended to the Azure Subscription and Resource Group.

### virtualNetworkEnabled

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Whether to create a virtual network or not.

- Default value: `True`

### addressPrefixes

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

The address space of the Virtual Network that will be created by this module, supplied as multiple CIDR blocks in an array, e.g. `["10.0.0.0/16","172.16.0.0/12"]`.

### nextHopIpAddress

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

IP Address of the centralised firewall if used.

### subnets

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Specifies the Subnets array - name, address space, configuration.

### dnsServerIps

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Array of DNS Server IP addresses for the Virtual Network.

### disableBGPRoutePropagation

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Switch which allows BGP Propagation to be disabled on the route tables.

- Default value: `True`

### ddosProtectionPlanId

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

ResourceId of the DdosProtectionPlan which will be applied to the Virtual Network.

### virtualNetworkPeeringEnabled

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Whether to enable peering/connection with the supplied hub Virtual Network or Virtual WAN Virtual Hub.

- Default value: `True`

### hubVirtualNetworkId

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

The resource ID of the Virtual Network or Virtual WAN Hub in the hub to which the created Virtual Network, by this module, will be peered/connected to via Virtual Network Peering or a Virtual WAN Virtual Hub Connection.

### allowSpokeForwardedTraffic

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Switch to enable/disable forwarded Traffic from outside spoke network.

- Default value: `True`

### allowHubVpnGatewayTransit

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Switch to enable/disable VPN Gateway Transit for the hub network peering.

- Default value: `True`

### roleAssignmentEnabled

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Whether to create role assignments or not. If true, supply the array of role assignment objects in the parameter called `roleAssignments`.

- Default value: `False`

### roleAssignments

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Supply an array of objects containing the details of the role assignments to create.

### budgets

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Specifies the Azure Budget details for the Landing Zone.

### actionGroupEnabled

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Whether to create a Landing Zone Action Group or not.

- Default value: `True`

### actionGroupEmails

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Specifies an array of email addresses for the Landing Zone action group.

## Snippets

### Parameter file

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "metadata": {
        "template": "src/orchestration/main.json"
    },
    "parameters": {
        "location": {
            "value": "[deployment().location]"
        },
        "lzPrefix": {
            "value": ""
        },
        "envPrefix": {
            "value": ""
        },
        "tags": {
            "value": {}
        },
        "virtualNetworkEnabled": {
            "value": true
        },
        "addressPrefixes": {
            "value": ""
        },
        "nextHopIpAddress": {
            "value": ""
        },
        "subnets": {
            "value": []
        },
        "dnsServerIps": {
            "value": []
        },
        "disableBGPRoutePropagation": {
            "value": true
        },
        "ddosProtectionPlanId": {
            "value": ""
        },
        "virtualNetworkPeeringEnabled": {
            "value": true
        },
        "hubVirtualNetworkId": {
            "value": ""
        },
        "allowSpokeForwardedTraffic": {
            "value": true
        },
        "allowHubVpnGatewayTransit": {
            "value": true
        },
        "roleAssignmentEnabled": {
            "value": false
        },
        "roleAssignments": {
            "value": []
        },
        "budgets": {
            "value": []
        },
        "actionGroupEnabled": {
            "value": true
        },
        "actionGroupEmails": {
            "value": []
        }
    }
}
```
