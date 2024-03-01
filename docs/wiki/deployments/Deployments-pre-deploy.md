# Deployment Prerequisites

The following steps outlines the prerequisites, dependencies, and flow essential for orchestrating an end-to-end Azure Landing Zone Vending Machine deployment.

Included orchestration templates in the reference implementation are pre-configured to adhere to these outlined dependencies.

## Getting Started

To deploy this solution, you'll need the following:

1. Microsoft Entra Tenant.
1. The Deployment Identity must have with `Owner` permission to the subscription to which it is deploying into. Owner permission is required to allow the Service Principal Account to create role-based access control assignments. See [configuration instructions below](#permissions-required).

## Orchestration Deployment Sequence

Orchestrations in this reference implementation must be deployed in the following order to ensure consistency across the environment:

| Order | Orchestration                         | Description                   | Prerequisites                                     | Note |
| :---: | ------------------------------------- | ----------------------------- | ------------------------------------------------- | ---- |
|   1   | [main](/src/main.bicep) | Deploys Subscription Vending. | See [Permissions Required](#permissions-required) | N/A  |

## Permissions required

This module can create and use the following resources during its deployment:

- `Microsoft.Subscription/aliases`
- `Microsoft.Management/managementGroups/subscriptions`
- `Microsoft.Consumption/budgets`
- `Microsoft.Resources/deployments` at the following scopes:
  - Tenant - `/`
  - Management Group - `Microsoft.Management/managementGroups`
  - Subscription
  - Resource Group
- `Microsoft.Resources/tags` at the following scopes:
  - Subscription
  - Resource Group
  - Resource
- `Microsoft.Authorization/locks` at the following scopes:
  - Resource Group
- `Microsoft.Authorization/roleAssignments` at the following scopes:
  - Subscription
  - Resource Group
  - Resources
- `Microsoft.Resources/resourceGroups`
- `Microsoft.Network/virtualNetworks`
- `Microsoft.Network/virtualNetworks/virtualNetworkPeerings`
- `Microsoft.Network/virtualHubs/hubVirtualNetworkConnections`
- `Microsoft.Network/networkSecurityGroups`
- `Microsoft.Network/networkSecurityGroups/securityRules`
- `Microsoft.Network/networkWatchers`
- `Microsoft.Insights/actionGroups`

The identity used must have permissions to:

- **Create Subscriptions using the `Microsoft.Subscription/aliases` resource**
  - See documentation on this resource here in: [Create Azure subscriptions programmatically](https://learn.microsoft.com/azure/cost-management-billing/manage/programmatically-create-subscription)
    - See documentation for instructions on how to grant/assign EA roles to SPNs: [Assign roles to Azure Enterprise Agreement service principal name](https://learn.microsoft.com/azure/cost-management-billing/manage/assign-roles-azure-service-principals)
- **Manage the Subscription's Management Group association using the `Microsoft.Management/managementGroups/subscriptions` resource**
  - See documentation on the required permissions here in: [What are Azure management groups? - Moving management groups and subscriptions](https://learn.microsoft.com/azure/governance/management-groups/overview#moving-management-groups-and-subscriptions)
    - **Note:** The identity that creates the Subscription will have the RBAC `Owner` role assigned to the Subscription by default. If you are using an existing Subscription with this module, you must ensure the identity you are using with this module has `Owner` permissions upon that existing Subscription prior to using the module with it.
- **Create the Subscription core resources (Resource Group, Virtual Network, Virtual Network Peerings, Resource Locks, Role Assignments)**
  - The default assigned RBAC `Owner` role on the Subscription for the identity creating it will be sufficient to create the resources in the Subscription.
    - **Note:** If you are using an existing Subscription with this module, you must ensure the identity you are using with this module has `Owner` permissions upon that existing Subscription prior to using the module with it.
  - **Create the "hub side" of the Virtual Network Peerings/Virtual WAN Hub Connections**
    - To create the Virtual Network peerings or Virtual Hub Connections to the Hub Virtual Networks or Virtual WAN Hub, that is in a different Subscription, you must ensure the identity deploying this module has the `Network Contributor` RBAC role assigned upon the Hub Virtual Network or Virtual WAN Hub resources, Resource Group, or Subscription.
