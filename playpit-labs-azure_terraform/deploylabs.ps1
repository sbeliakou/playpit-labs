Param(
    [string] $ResourceGroupName,
    [string] $adminUsername,
    [string] $adminPassword,
    [string] $ResourceGroupLocation = 'westeurope',
    [string] $KeyVaultName = $($ResourceGroupName + '-KeyVault'),
    [string] $ServicePrincipalName = $($ResourceGroupName.ToLowerInvariant() + 'spn'),
    [string] $vmAdminPassSecretName = 'vmAdminPassSecretName'
)

#Create a Resource Group for Deploying Resources
$DeploymentRG = New-AzResourceGroup `
    -Name $ResourceGroupName `
    -Location $ResourceGroupLocation `
    -Force `
    -Verbose

if ($null -eq (Get-AzKeyVault -VaultName $KeyVaultName -ResourceGroupName $DeploymentRG.ResourceGroupName)) {
    
    Write-Verbose "Creating a new KeyVault resource" -Verbose
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

    Write-Verbose "Getting the KeyVault object" -Verbose
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
    
if ($null -eq (Get-AzADServicePrincipal -DisplayName $ServicePrincipalName)) {
    Write-Verbose "Creating $ServicePrincipalName Service Principal" -Verbose
    #Create a Service Principal
    $ADServicePrincipal = New-AzADServicePrincipal `
        -DisplayName $ServicePrincipalName `
        -Scope $DeploymentRG.ResourceId `
        -Role "Contributor" `
        -Verbose
    
    Write-Verbose "Creating $($ServicePrincipalName + 'secret') secret in KeyVault" -Verbose
    #Create a secret in KeyVault
    $ADServicePrincipalSecret = Set-AzKeyVaultSecret `
        -VaultName $KeyVault.VaultName `
        -Name $($ServicePrincipalName + 'secret') `
        -SecretValue $ADServicePrincipal.Secret `
        -Verbose
}
else {
    Write-Verbose "Getting the value of the $ServicePrincipalName Service Principal" -Verbose
    #Getting the value of the Service Principal
    $ADServicePrincipal = Get-AzADServicePrincipal -DisplayName $ServicePrincipalName
    New-AzRoleAssignment `
    -Scope $DeploymentRG.ResourceId `
    -RoleDefinitionName "Contributor" `
    -ObjectId $ADServicePrincipal.Id `
    -ErrorAction SilentlyContinue `
    -Verbose
        
    if ($null -eq (Get-AzKeyVaultSecret -VaultName $KeyVault.VaultName -Name $($ServicePrincipalName + 'secret'))) {

        Write-Verbose "Generating a new password for $ServicePrincipalName Service Principal" -Verbose
        #Create a new Service Principal Credential using a generated password
        $newServicePrincipalPass = (New-AzADSpCredential -ObjectId $ADServicePrincipal.Id -Verbose).Secret
    
        Write-Verbose "Setting the generated password in KeyVault" -Verbose
        #Update the secret value in Key Vault
        $ADServicePrincipalSecret = Set-AzKeyVaultSecret `
            -VaultName $KeyVault.VaultName `
            -Name $($ServicePrincipalName + 'secret') `
            -SecretValue $newServicePrincipalPass `
            -Verbose
    }
    Write-Verbose "Getting the password of $ServicePrincipalName Service Principal from the KeyVault" -Verbose
    $ADServicePrincipalSecret = Get-AzKeyVaultSecret -VaultName $KeyVault.VaultName -Name $($ServicePrincipalName + 'secret')
}

terraform init

terraform apply `
    -var admin_username="$adminUsername" `
    -var admin_password="$adminPassword" `
    -var resource_group_name="$($DeploymentRG.ResourceGroupName)" `
    -var client_id="$($ADServicePrincipal.ApplicationId.Guid)" `
    -var client_secret="$($ADServicePrincipalSecret.SecretValueText)" `
    -var subscription_id="$((Get-AzSubscription).Id)" `
    -var tenant_id="$((Get-AzSubscription).TenantId)" `
    -auto-approve

Start-Process chrome.exe "http://$(terraform output fqdn):8081"