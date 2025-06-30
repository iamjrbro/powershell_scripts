# Conectar ao SharePoint Online
Connect-SPOService -Url https://<nomedoseudominio>-admin.sharepoint.com

# Verificar se a integração B2B está ativada
Get-SPOTenant | Select EnableAzureADB2BIntegration

# Se o valor for True, seu tenant será impactado pela mudança.

#Habilitar integração B2B com SharePoint/OneDrive (se ainda não estiver) - se a opção ainda estiver desativada e você quiser preparar sua organização para esse modelo mais seguro, use:

Set-SPOTenant -EnableAzureADB2BIntegration $true