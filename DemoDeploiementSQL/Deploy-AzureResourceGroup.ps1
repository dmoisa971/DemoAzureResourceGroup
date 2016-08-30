#Définition des variables utilisée pour générer le groupe de ressources
#et pour ensuite déployer le template avec le fichier de paramètre
$localisation = 'West Europe'
$resourceGroupName = 'testdeploiementarmpowershell'
$deploymentName = 'testdeploiement'
$keyVaultName = "testdeploiementvaultdmo"
$keyVaultSqlAdminPasswordSecretName = "sqlPassword"
$serverPassword = "motDePasse2016!Admin#"   
$templateFilePath = 'D:\Solutions\Azure\ARM\DemoAzureResourceGroup\DemoDeploiementSQL\Templates\azuredeploy.json'
$templateParametersFilePath = 'D:\Solutions\Azure\ARM\DemoAzureResourceGroup\DemoDeploiementSQL\Templates\azuredeploy.parameters.json'

#Creation du groupe de ressources
{
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $localisation  -Verbose -Force
}

#Creation du KeyVault pour la gestion du mot de passe de l'administrateur du serveur
{
    New-AzureRmKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroupName -Location $localisation -EnabledForDeployment -EnabledForTemplateDeployment
}

#Creation d'une règle d'accès au container Key Vault (n'est nécessaire que dans le cas ou vous avez une sortie vous informatant q'aucune policy n'est mise en place
#au niveau du container Key Vault
{
    Set-AzureRmKeyVaultAccessPolicy -VaultName $keyVaultName -UserPrincipalName 'demodmo@outlook.fr' -PermissionsToKeys create,import,delete,list,get -PermissionsToSecrets set,delete,get
}

#Gestion du mot de passe avec notre container KeyVault
{
    $sqlAdminPassword = ConvertTo-SecureString -String $serverPassword -AsPlainText -Force

    Set-AzureKeyVaultSecret -VaultName $keyVaultName -Name $keyVaultSqlAdminPasswordSecretName -SecretValue $sqlAdminPassword
}


#Déploiement du template dans le groupe de ressources

{
      New-AzureRmResourceGroupDeployment -Name $deploymentName -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath -TemplateParameterFile $templateParametersFilePath -Verbose -Force

}