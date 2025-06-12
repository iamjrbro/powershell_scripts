Install-Module -Name Microsoft.Online.SharePoint.PowerShell

# Autenticar no SharePoint Online
$adminSiteUrl = "https://<seu-tenant>-admin.sharepoint.com"
Connect-SPOService -Url $adminSiteUrl

# 1. Verificar nível de compartilhamento externo no tenant
$sharingTenant = Get-SPOTenant
Write-Host "Nível de compartilhamento externo do tenant: $($sharingTenant.SharingCapability)"
switch ($sharingTenant.SharingCapability) {
    0 { Write-Host "Compartilhamento externo está desativado." }
    1 { Write-Host "Apenas convidados existentes podem acessar." }
    2 { Write-Host "Convidados novos e existentes podem acessar." }
    3 { Write-Host "Compartilhamento com qualquer pessoa (menos seguro)." }
}

# 2. Verificar sites habilitados para compartilhamento externo
$sites = Get-SPOSite -Limit All | Where-Object { $_.SharingCapability -ne "Disabled" }
Write-Host "`nSites com compartilhamento externo habilitado:"
$sites | Select-Object Url, SharingCapability | Format-Table

# 3. Verificar se o site desejado está habilitado para Syntex
# (verifica se é um "site moderno" com suporte e permissões adequadas)
$siteUrl = "https://<seu-tenant>.sharepoint.com/sites/<nomedosite>"
$site = Get-SPOSite -Identity $siteUrl
Write-Host "`Detalhes do site $siteUrl:"
Write-Host "  Status: $($site.Status)"
Write-Host "  Armazenamento: $($site.StorageUsageCurrent) MB"
Write-Host "  Compartilhamento: $($site.SharingCapability)"

# 4. Verificar se o agente do Syntex está ativado via Azure (mensagem orientativa)
Write-Host "`nPara ativar os agentes do SharePoint Syntex, acesse o portal do Azure:"
Write-Host "https://portal.azure.com > Assinaturas > [sua assinatura] > Syntex > Habilitar agentes"

# 5. Instrução adicional para verificar via portal admin
Write-Host "`n Acesse https://admin.microsoft.com > Syntex > eSignature para verificar se o Word (Ambiente de Trabalho) está listado como aplicativo ativo."

# 6. Recomendações finais
Write-Host "`n Script concluído. Revise os pontos acima e aguarde até 24h para replicação total após ativação de políticas e Syntex."
