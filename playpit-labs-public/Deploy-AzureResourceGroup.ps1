Param(
    [string] $ResourceGroupName = '',
    [string] $adminPassword = '',
    [string] $adminUsername = '',
    [string] $ResourceGroupLocation = 'westeurope',
    [string] $StorageResourceGroupName = 'ARM_Deploy_Staging',
    [string] $StorageAccountName,
    [string] $KeyVaultName = $($ResourceGroupName + '-KeyVault'),
    [string] $vmAdminPassSecretName = 'vmAdminPassSecretName',
    [string] $StorageContainerName = $ResourceGroupName.ToLowerInvariant() + '-stageartifacts',
    [string] $TemplateFile = 'main.json',
    [string] $TemplateParametersFile = 'parameters.json',
    [string] $LinkedTemplatePath = 'linked'
)

#Create a random name for Storage Account
$StorageAccountName = ($ResourceGroupName + 'stage' + ((Get-AzContext).Subscription.SubscriptionId).Replace('-', '').substring(0, 10)).ToLower().Replace('-', '')

#Create a Resource Group for Deploying Resources
$DeploymentRG = New-AzResourceGroup `
    -Name $ResourceGroupName `
    -Location $ResourceGroupLocation `
    -Force `
    -Verbose

#Create a Resource Group for Uploading Files to Container
$ArtifactsRG = New-AzResourceGroup `
    -Name $StorageResourceGroupName `
    -Location $ResourceGroupLocation `
    -Force `
    -Verbose

if ($null -eq (Get-AzKeyVault -VaultName $KeyVaultName -ResourceGroupName $DeploymentRG.ResourceGroupName)) {
    
    #Create KeyVault Resource
    $KeyVault = New-AzKeyVault `
        -Name $KeyVaultName `
        -ResourceGroupName $DeploymentRG.ResourceGroupName `
        -Location $DeploymentRG.Location `
        -EnabledForDeployment `
        -EnabledForTemplateDeployment `
        -Verbose
}
else {
    
    #Getting the value of the Key Vault
    $KeyVault = Get-AzKeyVault -VaultName $KeyVaultName -ResourceGroupName $DeploymentRG.ResourceGroupName
}
    
#Set Access Policy in Key Vault
Set-AzKeyVaultAccessPolicy `
    -VaultName $KeyVault.VaultName `
    -ResourceGroupName $DeploymentRG.ResourceGroupName `
    -UserPrincipalName (Get-AzContext).Account.Id `
    -PermissionsToSecrets set, get, list `
    -Verbose
    
if ($null -eq (Get-AzKeyVaultSecret -VaultName $KeyVault.VaultName -Name $vmAdminPassSecretName)) {

    #Generate SecretValue for SQL Server Login Password
    $vmAdminPass = $adminPassword | ConvertTo-SecureString -AsPlainText -Force
    
    #Create a secret in Key Vault
    $secret = Set-AzKeyVaultSecret `
        -VaultName $KeyVault.VaultName `
        -Name $vmAdminPassSecretName `
        -SecretValue $vmAdminPass `
        -Verbose    
}
else {

    #Getting the secret of the Key Vault
    $secret = Get-AzKeyVaultSecret -VaultName $KeyVault.VaultName -Name $vmAdminPassSecretName
}

#Create the Storage Account Resource
if ($null -eq (Get-AzStorageAccount | Where-Object { $_.StorageAccountName -eq $StorageAccountName })) {
    $StorageAccount = New-AzStorageAccount `
        -ResourceGroupName $ArtifactsRG.ResourceGroupName `
        -Name $StorageAccountName `
        -Location $ArtifactsRG.Location `
        -Type 'Standard_LRS' `
        -Verbose
}
else {
    $StorageAccount = Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ArtifactsRG.ResourceGroupName
}

#Create a Container resource
if ($null -eq (Get-AzStorageContainer -Name $StorageContainerName -Context $StorageAccount.Context -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $StorageContainerName })) {
    New-AzStorageContainer `
        -Name $StorageContainerName `
        -Context $StorageAccount.Context `
        -Verbose
}

#Create SAS Token and create Hashtable
$OptionalParameters = New-Object -TypeName Hashtable -Verbose
$OptionalParameters['keyVaultId'] = $KeyVault.ResourceId
$OptionalParameters['vmAdminPassSecretName'] = $secret.Name
$OptionalParameters['vmAdminUsername'] = $adminUsername
$OptionalParameters['_artifactsLocation'] = $StorageAccount.Context.BlobEndPoint + $StorageContainerName
$OptionalParameters['_artifactsLocationSasToken'] = ConvertTo-SecureString `
    -AsPlainText `
    -Force `
(New-AzStorageContainerSASToken `
        -Container $StorageContainerName `
        -Context $StorageAccount.Context `
        -Permission "r" `
        -ExpiryTime (Get-Date).AddHours(4)) `
    -Verbose

#Uploading all files to Container
Get-ChildItem -File -Recurse -Path $PSScriptRoot | Set-AzStorageBlobContent `
    -Container $StorageContainerName `
    -Context $StorageAccount.Context `
    -Force

#Create Deployment
$Deployment = New-AzResourceGroupDeployment `
    -Name ((Get-ChildItem $PSScriptRoot\$TemplateFile).BaseName + '-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')) `
    -ResourceGroupName $DeploymentRG.ResourceGroupName `
    -TemplateFile $PSScriptRoot\$TemplateFile `
    -TemplateParameterFile $PSScriptRoot\$TemplateParametersFile `
    @OptionalParameters `
    -Force `
    -Verbose

Start-Process chrome.exe "http://$($Deployment.Outputs.fqdn.value):8081"