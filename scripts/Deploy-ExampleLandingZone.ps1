$DeploymentName = ('lzVending' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm'))
$Location = 'australiaeast'
$SubscriptionId = 'a50d2a27-93d9-43b1-957c-2a663ffaf37f'
$TenantId = 'a2ebc691-c318-4ec2-998a-a87c528378e0'
$TemplateFile = '../src/orchestration/main.bicep'
$TemplateParameterFile = '../src/configuration/parameters.bicepparam'

select-azSubscription -SubscriptionId $SubscriptionId -TenantId $TenantId

New-AzDeployment `
    -Name $DeploymentName `
    -TemplateFile $TemplateFile `
    -TemplateParameterFile $TemplateParameterFile `
    -Location $Location `
    -Verbose
