<#
.SYNOPSIS
Verifica e habilita a integração B2B do SharePoint Online com o Microsoft Entra ID.

.DESCRIPTION
Conecta ao SharePoint Online, consulta o estado de EnableAzureADB2BIntegration e, se necessário, habilita a integração para SharePoint e OneDrive.

.NOTES
Revise o impacto da alteração no tenant antes de habilitar a configuração.
#>

# Conecta ao SharePoint Online.
Connect-SPOService -Url https://<nomedoseudominio>-admin.sharepoint.com

# Verifica se a integração B2B está habilitada.
Get-SPOTenant | Select EnableAzureADB2BIntegration

# Se o valor for True, o tenant já utiliza a integração B2B.

# Habilita a integração B2B com SharePoint e OneDrive, caso ainda esteja desativada.
Set-SPOTenant -EnableAzureADB2BIntegration $true
