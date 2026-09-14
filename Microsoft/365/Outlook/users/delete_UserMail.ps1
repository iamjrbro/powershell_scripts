<#
.SYNOPSIS
Localiza e remove mensagens do Exchange Online usando uma Compliance Search.

.DESCRIPTION
Conecta ao Security & Compliance PowerShell, cria uma busca por remetente e assunto, inicia a pesquisa, executa uma ação de purge SoftDelete e permite acompanhar o status.

.WARNING
A ação de purge remove mensagens da caixa de correio conforme o tipo de exclusão configurado. Revise a consulta antes de executar.
#>

# Conecta ao Security & Compliance PowerShell em uma sessão somente de pesquisa.
Connect-IPPSSession -EnableSearchOnlySession

# Define a consulta para localizar as mensagens que devem ser removidas.
New-ComplianceSearch `
  -Name "RemoveEmail" `
  -ExchangeLocation All `
  -ContentMatchQuery 'From:"user.upn@domain.com" AND Subject:"EMAIL SUBJECT"'

# Inicia a pesquisa.
Start-ComplianceSearch -Identity "RemoveEmail"

# Cria a ação de purge para as mensagens encontradas.
New-ComplianceSearchAction `
  -SearchName "RemoveEmail" `
  -Purge `
  -PurgeType SoftDelete

# Consulta o status da pesquisa e da ação de purge.
Get-ComplianceSearch -Identity "RemoveEmail" | Select Name,Status,Items,Size

# Opcional: acompanha o status a cada 10 segundos.
while ($true) {
    Get-ComplianceSearch -Identity "RemoveEmail" | Select Name,Status,Items,Size
    Start-Sleep -Seconds 10
    Clear-Host
}
