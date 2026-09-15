<#
.SYNOPSIS
Identifica dispositivos Intune sem sincronização há mais de 90 dias e envia um alerta para um canal do Teams.

.DESCRIPTION
Utiliza o módulo Generate-IntuneAnomaliesReport para gerar o inventário, filtra dispositivos com mais de 90 dias sem sincronização e envia um resumo por webhook.

.PREREQUISITES
Requer Microsoft Graph, o módulo Generate-IntuneAnomaliesReport e um webhook válido do Teams.
#>

# Instale os módulos necessários uma vez, se ainda não estiverem disponíveis.
# Install-Module -Name Generate-IntuneAnomaliesReport -Force
# Install-Module -Name Microsoft.Graph -Force

# Conecta ao Microsoft Graph com permissão de leitura dos dispositivos gerenciados.
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"

# Importa o módulo e gera o relatório de anomalias.
Import-Module Generate-IntuneAnomaliesReport
$report = Get-IntuneAnomaliesReport

# Filtra dispositivos com mais de 90 dias sem sincronização.
$inativos = $report | Where-Object {
    ($_.'Last Sync DateTime') -lt (Get-Date).AddDays(-90)
}

# Conta os dispositivos inativos.
$totalInativos = $inativos.Count

# Se houver dispositivos inativos, envia um alerta para o Teams.
if ($totalInativos -gt 0) {
    # Substitua pelo webhook utilizado no ambiente.
    $teamsWebhookUrl = "https://outlook.office.com/webhook/SEU_WEBHOOK_URL_AQUI"

    # Limita a lista exibida aos dez primeiros dispositivos.
    $nomes = $inativos | Select-Object -First 10 -ExpandProperty 'Device Name'
    $listaFormatada = ($nomes | ForEach-Object { "- $_" }) -join "`n"

    # Informa quantos dispositivos adicionais ficaram fora da lista resumida.
    if ($totalInativos -gt 10) {
        $listaFormatada += "`n...e mais $($totalInativos - 10) dispositivos."
    }

    # Monta a mensagem enviada ao Teams.
    $mensagem = @{
        title = " Alerta: Dispositivos Inativos no Intune"
        text  = "Foram encontrados **$totalInativos dispositivos** que não sincronizam há mais de 90 dias:`n$listaFormatada"
    }

    $json = $mensagem | ConvertTo-Json -Depth 3 -Compress
    Invoke-RestMethod -Method Post -Uri $teamsWebhookUrl -Body $json -ContentType 'application/json'
}
