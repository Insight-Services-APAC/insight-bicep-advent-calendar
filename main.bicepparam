using './main.bicep'

param name = ''
param location = ''
param openAILocation = 'canadaeast'
param openAISku = 'S0'
param openAIApiVersion = '2023-03-15-preview'
param chatGptDeploymentCapacity = 30
param chatGptDeploymentName = 'chat-gpt-35-turbo'
param chatGptModelName = 'gpt-35-turbo'
param chatGptModelVersion = '0613'
param embeddingDeploymentName = 'embedding'
param embeddingDeploymentCapacity = 10
param embeddingModelName = 'text-embedding-ada-002'
param formRecognizerSkuName = 'S0'
param searchServiceIndexName = 'azure-chat'
param searchServiceSkuName = 'standard'
param searchServiceAPIVersion = '2023-07-01-Preview'
param resourceGroupName = ''

