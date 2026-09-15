<#
.SYNOPSIS
Audita configurações de compartilhamento externo e informações de um site do SharePoint Online.

.DESCRIPTION
Conecta ao SharePoint Online, consulta a configuração de compartilhamento externo do tenant, lista sites com compartilhamento habilitado e exibe informações básicas de um site específico.

.NOTES
O bloco final apenas consulta informações do site. A descrição original mencionava Syntex, mas os comandos apresentados não habilitam nem configuram o SharePoint Syntex.
#>

# Instala o módulo do SharePoint Online, caso necessário.
Install-Module -Name Microsoft.Online.SharePoint.PowerShell

# Autentica no SharePoint Online.
$adminSiteUrl = "https://<seu-tenant>-admin.sharepoint.com"
Connect-SPOService -Url $adminSiteUrl

# 1. Consulta o nível de compartilhamento externo configurado no tenant.
$sharingTenant = Get-SPOTenant
Write-Host "Nível de compartilhamento externo do tenant: $($sharingTenant.SharingCapability)"
switch ($sharingTenant.SharingCapability) {
    0 { Write-Host "Compartilhamento externo está desativado." }
    1 { Write-Host "Apenas convidados existentes podem acessar." }
    2 { Write-Host "Convidados novos e existentes podem acessar." }
    3 { Write-Host "Compartilhamento com qualquer pessoa (menos seguro)." }
}

# 2. Lista sites com compartilhamento externo habilitado.
$sites = Get-SPOSite -Limit All | Where-Object { $_.SharingCapability -ne "Disabled" }
Write-Host "`nSites com compartilhamento externo habilitado:"
$sites | Select-Object Url, SharingCapability | Format-Table

# 3. Consulta informações básicas do site desejado.
$siteUrl = "https://<seu-tenant>.sharepoint.com/sites/<nomedosite>"
$site = Get-SPOSite -Identity $siteUrl
Write-Host "`nDetalhes do site $siteUrl"
Write-Host "  Status: $($site.Status)"
Write-Host "  Armazenamento: $($site.StorageUsageCurrent) MB"
Write-Host "  Compartilhamento: $($site.SharingCapability)"
