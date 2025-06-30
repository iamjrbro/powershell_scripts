Claro! Aqui está o **passo a passo completo para integrar o script `Generate-IntuneAnomaliesReport` com notificações no Microsoft Teams** usando um webhook:

---

## 🎯 Objetivo

Detectar dispositivos gerenciados pelo Intune que estão inativos há mais de 90 dias e **notificar automaticamente um canal do Teams**.

---

## ✅ PRÉ-REQUISITOS

* Permissões para acessar Microsoft Intune via Graph API (com `Connect-MgGraph`).
* Permissão para adicionar conectores no canal do Microsoft Teams.
* PowerShell 5.1+ ou 7.x com o módulo `Generate-IntuneAnomaliesReport` instalado.

---

## 🧱 ETAPA 1 – Criar Webhook no canal do Teams

1. Acesse o **Microsoft Teams**.
2. Vá até o **canal desejado**.
3. Clique em **“...” > Conectores**.
4. Busque e adicione **“Incoming Webhook”**.
5. Dê um nome como `Alerta Intune`.
6. (Opcional) Adicione um ícone personalizado.
7. Copie o **URL gerado** (ex: `https://outlook.office.com/webhook/...`).
8. Salve esse URL, pois será usado no script.

---

## 🔧 ETAPA 2 – Script PowerShell para gerar relatório e enviar alerta

### Instale os módulos necessários (uma vez):

```powershell
Install-Module -Name Generate-IntuneAnomaliesReport -Force
Install-Module -Name Microsoft.Graph -Force
```

# Autentica no Microsoft Graph
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"

# Carrega o módulo e gera o relatório
Import-Module Generate-IntuneAnomaliesReport
$report = Get-IntuneAnomaliesReport

# Filtra dispositivos com mais de 90 dias sem sincronizar
$inativos = $report | Where-Object {
    ($_.'Last Sync DateTime') -lt (Get-Date).AddDays(-90)
}

# Conta os inativos
$totalInativos = $inativos.Count

# Se houver dispositivos inativos, envia alerta no Teams
if ($totalInativos -gt 0) {
    $teamsWebhookUrl = "https://outlook.office.com/webhook/SEU_WEBHOOK_URL_AQUI"

    # Monta lista de nomes (máximo 10 para evitar mensagem truncada)
    $nomes = $inativos | Select-Object -First 10 -ExpandProperty 'Device Name'
    $listaFormatada = ($nomes | ForEach-Object { "- $_" }) -join "`n"

    # Adiciona nota se houver mais de 10
    if ($totalInativos -gt 10) {
        $listaFormatada += "`n...e mais $($totalInativos - 10) dispositivos."
    }

    # Monta mensagem para Teams
    $mensagem = @{
        title = "🔍 Alerta: Dispositivos Inativos no Intune"
        text  = "Foram encontrados **$totalInativos dispositivos** que não sincronizam há mais de 90 dias:`n$listaFormatada"
    }

    $json = $mensagem | ConvertTo-Json -Depth 3 -Compress
    Invoke-RestMethod -Method Post -Uri $teamsWebhookUrl -Body $json -ContentType 'application/json'
}
