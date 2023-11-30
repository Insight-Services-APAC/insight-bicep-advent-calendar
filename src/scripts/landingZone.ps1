$DeploymentName = ('lzVending' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm'))
$Location = 'australiaeast'
$ManagementGroupId = 'mg-alz'
$TemplateFile = '..\orchestration\main.bicep'
$TemplateParameterFile = '..\configuration\sub-sap-prd-01.parameters.bicepparam'

New-AzManagementGroupDeployment `
    -Name $DeploymentName `
    -TemplateFile $TemplateFile `
    -TemplateParameterFile $TemplateParameterFile `
    -Location $Location `
    -ManagementGroupId $ManagementGroupId `
    -Verbose