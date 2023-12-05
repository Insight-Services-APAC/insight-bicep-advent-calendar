$DeploymentName = ('rg' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm'))
$Location = 'australiaeast'
$TemplateFile = 'main.bicep'

New-AzDeployment `
    -Name $DeploymentName `
    -TemplateFile $TemplateFile `
    -Location $Location `
    -WhatIf
