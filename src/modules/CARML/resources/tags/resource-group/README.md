# Resources Tags Resource Group `[Microsoft.Resources/tags]`

This module deploys a Resource Tag on a Resource Group scope.

## Navigation

- [Resources Tags Resource Group `[Microsoft.Resources/tags]`](#resources-tags-resource-group-microsoftresourcestags)
  - [Navigation](#navigation)
  - [Resource Types](#resource-types)
  - [Parameters](#parameters)
    - [Optional Parameters](#optional-parameters)
    - [Parameter: `enableDefaultTelemetry`](#parameter-enabledefaulttelemetry)
    - [Parameter: `onlyUpdate`](#parameter-onlyupdate)
    - [Parameter: `tags`](#parameter-tags)
  - [Outputs](#outputs)
  - [Cross-referenced modules](#cross-referenced-modules)

## Resource Types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Resources/tags` | [2021-04-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Resources/2021-04-01/tags) |

## Parameters

### Optional Parameters

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`enableDefaultTelemetry`](#parameter-enabledefaulttelemetry) | bool | Enable telemetry via a Globally Unique Identifier (GUID). |
| [`onlyUpdate`](#parameter-onlyupdate) | bool | Instead of overwriting the existing tags, combine them with the new tags. |
| [`tags`](#parameter-tags) | object | Tags for the resource group. If not provided, removes existing tags. |

### Parameter: `enableDefaultTelemetry`

Enable telemetry via a Globally Unique Identifier (GUID).

- Required: No
- Type: bool
- Default: `True`

### Parameter: `onlyUpdate`

Instead of overwriting the existing tags, combine them with the new tags.

- Required: No
- Type: bool
- Default: `False`

### Parameter: `tags`

Tags for the resource group. If not provided, removes existing tags.

- Required: No
- Type: object

## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `name` | string | The name of the tags resource. |
| `resourceGroupName` | string | The name of the resource group the tags were applied to. |
| `resourceId` | string | The resource ID of the applied tags. |
| `tags` | object | The applied tags. |

## Cross-referenced modules

- _None_
