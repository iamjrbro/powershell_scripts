Inicie o PowerShell como Administrador e confirme que você tem permissões (Global Administrator ou roles delegadas adequadas). Instale/atualize módulos se necessário.

1. Conectar aos módulos necessários (executar uma vez)

# Instalar/Atualizar módulos (faça isso se ainda não tiver)
Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force
Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser -Force
Install-Module -Name MicrosoftTeams -Scope CurrentUser -Force
Install-Module -Name Microsoft.Graph.Security -Scope CurrentUser -Force

# Conectar ao Microsoft Graph (delegated)
Connect-MgGraph -Scopes "Policy.ReadWrite.ApplicationConfiguration","SecurityEvents.ReadWrite.All","SecurityEvents.Read.All","InformationProtectionPolicy.ReadWrite.All","Compliance.ReadWrite.Dlp","TeamSettings.ReadWrite.All"

# Conectar ao Exchange Online (requer MFA/admin)
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -UserPrincipalName seu.admin@dominio.com

# Conectar ao Teams (separado; algumas configurações são via Teams module)
Connect-MicrosoftTeams -AccountId seu.admin@dominio.com
Criar/ativar uma política Safe Links (via REST fallback)
Observação: o portal do Defender cria políticas Safe Links; via PowerShell a disponibilidade de cmdlets varia. O script abaixo tenta o método preferencial (quando houver cmdlet funcional) e faz fallback para o Graph (REST). Ajuste DisplayName, Description e Users conforme seu piloto/escopo.

# Parâmetros
$policyName = "SafeLinks-Teams-Default"
$policyDescription = "Safe Links para Teams - reescrever links e checar em tempo real"
$usersOrGroups = @("/users/ALL")  # exemplo simplificado; substitua por array de IDs ou filtros conforme necessário

# Tentar via cmdlet (se disponível) - exemplo conceptual (muitos tenants não terão esse cmdlet)
try {
    # OBS: esse cmdlet pode não existir em sua versão do módulo; é um attempt-concept
    New-SafeLinksPolicy -Name $policyName -EnableSafeLinksForTeams $true -EnableRealTimeScanning $true -Description $policyDescription -AssignedUsers $usersOrGroups
    Write-Output "Safe Links policy criada via cmdlet."
} catch {
    Write-Warning "Cmdlet New-SafeLinksPolicy não disponível ou falhou. Tentando via Microsoft Graph (REST). Erro: $_"

    # Fallback: criar policy via Microsoft Graph REST (exemplo de payload — ajustar conforme documentacao)
    $uri = "https://graph.microsoft.com/beta/security/tiIndicators" # placeholder: endpoint real de Safe Links difere; ver docs
    $payload = @{
        displayName = $policyName
        description = $policyDescription
        # payload exemplificativo — revise schema oficial antes de aplicar
        settings = @{
            rewriteUrls = $true
            scanInRealTime = $true
            applyTo = "teams"
            assignment = @{
                includedUsers = @("All")
            }
        }
    }

    # Enviar (o endpoint correto deve ser consultado na documentação do Defender; este é um fallback genérico)
    $json = $payload | ConvertTo-Json -Depth 10
    $resp = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/beta/security/threatIntelligence/safeguardPolicies" -Body $json
    Write-Output "Tentativa de criação via Graph (beta) retornou: $($resp | ConvertTo-Json -Depth 5)"
}
Importante: política Safe Links tem esquema específico e geralmente é melhor criar pelo portal Defender quando possível; o script acima mostra fluxo de fallback e template de como automatizar com REST — ajuste o URI/JSON consultando a documentação oficial.

Criar Safe Attachments policy (proteção de arquivos no Teams / SharePoint)

# Parâmetros
$saName = "SafeAttachments-Teams-Default"
$saDesc = "Scan de anexos para Teams/SharePoint/OneDrive - bloquear arquivos maliciosos"

try {
    # Conceitual: New-SafeAttachmentsPolicy pode não existir - tentamos e caímos no fallback
    New-SafeAttachmentsPolicy -Name $saName -Action Block -ApplyToTeams $true -ApplyToSharePoint $true -ApplyToOneDrive $true
    Write-Output "Safe Attachments policy criada via cmdlet."
} catch {
    Write-Warning "Cmdlet não disponível. Criando via REST (Graph/Defender) - ajustar endpoint conforme versão."

    $payload = @{
        displayName = $saName
        description = $saDesc
        settings = @{
            action = "block"   # ou "replace", "monitor"
            targetServices = @("teams","sharepoint","onedrive")
            scanContent = $true
        }
    }

    $json = $payload | ConvertTo-Json -Depth 10
    $resp = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/beta/security/attackSimulationPolicies" -Body $json
    Write-Output "Resposta Safe Attachments via Graph (beta): $($resp | ConvertTo-Json -Depth 5)"
}
Novamente: verifique o endpoint e schema exato na documentação do Microsoft 365 Defender; o script fornece estrutura para automatizar via Graph.

2. Criar política DLP para Teams (purview) — exemplo prático que bloqueia envio de CPF/SSN em chats e usa o módulo do Exchange Online/Compliance para criar uma regra DLP simples. Em alguns tenants os cmdlets residem no compliance PowerShell remoto (Connect-IPPSSession). O script cria uma policy de DLP e uma regra que bloqueia conteúdo sensível em Teams chat.

# Conectar ao Security & Compliance PowerShell (Exchange Online/Compliance)
# Requer que seu usuário tenha permissões de Compliance admin
Import-Module ExchangeOnlineManagement
Connect-IPPSSession -UserPrincipalName seu.admin@dominio.com

# Parâmetros da política
$policyName = "DLP-Teams-No-CPF"
$ruleName = "DLP-Block-CPF-Teams"

# Criar nova policy DLP (exemplo usando built-in template "PII" ou personalizado)
# OBS: o comando New-DlpCompliancePolicy pode variar; se não existir, use o portal e depois faça automação via Graph
try {
    $policy = New-DlpCompliancePolicy -Name $policyName -Mode Enforce -Comment "Bloquear CPF/SSN em Teams chat" -PolicyVersion "1"
    Write-Output "Policy DLP criada: $($policy.Name)"
} catch {
    Write-Warning "Não foi possível criar DLP policy via cmdlet. Use o portal Compliance ou ajuste para seu ambiente."
}

# Criar regra dentro da policy (conceitual)
try {
    # Exemplo conceptual de criação de regra; cmdlet real pode ser New-DlpComplianceRule
    New-DlpComplianceRule -Name $ruleName -Policy $policyName -BlockAccess -ContentContainsSensitiveInformation @{Name="Brazilian CPF";MinCount=1} -ApplyToTeamsChat $true
    Write-Output "Regra DLP criada: $ruleName"
} catch {
    Write-Warning "Falha ao criar regra DLP via cmdlet. Recomendo criar regra via portal Microsoft Purview e depois exportar com PowerShell."
}

# Finalizar sessão
Disconnect-ExchangeOnline -Confirm:$false
Ressalto: o universo DLP tem cmdlets com variação dependendo da sua versão do módulo; se os cmdlets acima não existirem na sua sessão, crie a política no portal do Microsoft Purview e eu te ajudo a exportar/automatizar via Graph.

Restringir compartilhamento externo no Teams (Teams PowerShell)

# Conectar ao Teams (já conectado anteriormente)
# Bloquear external access (federation) e console de guest
# Ajuste para true/false conforme sua política

# Desabilitar federated external access (impede comunicação com domínios federados)
Set-CsExternalAccessPolicy -Identity Global -EnableFederation $false -EnablePublicCloudAccess $false

# Restringir Guest access (via Teams admin)
Set-CsTeamsClientConfiguration -Identity Global -AllowGuestUser $false

# No nível de organização (Teams Admin Center) também existe configuração que pode bloquear upload de arquivos por guests:
# Usando Graph para atualizar org-wide settings (exemplo conceptual)
$orgSettingsPayload = @{
    resource = "teamsSettings"
    allowGuestUser = $false
}
# Exemplo de chamada (verificar schema real)
Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/teams/settings" -Body ($orgSettingsPayload| ConvertTo-Json -Depth 5)
Criar alerta (subscription) para eventos críticos (ex.: várias detecções de Safe Attachments)
Você pode criar alertas via Microsoft 365 Defender Alert policies ou via Microsoft Graph Security Alerts API. Abaixo um exemplo de criação de uma regra de alerta conceitual via Graph Security (beta).

# Exemplo conceptual: criar uma policy de alerta via Graph
$alertPolicy = @{
    displayName = "Alert-SafeAttachment-ManyDetections"
    description = "Alerta quando > X arquivos maliciosos detectados no Teams em 1 hora"
    severity = "high"
    query = "products='Defender' AND activity='malwareDetected' AND location='Teams'"
    threshold = 5
    timeWindow = "PT1H"
    recipients = @("secops@dominio.com")
}

$json = $alertPolicy | ConvertTo-Json -Depth 10
$resp = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/beta/security/alertPolicies" -Body $json
Write-Output "Resposta criação alerta: $($resp | ConvertTo-Json -Depth 5)"
Para alertas e automações mais maduras, recomendo criar um playbook no Microsoft Sentinel ou uma Alert Policy no portal Defender e depois usar Logic Apps para notificação/ação automática.

3. Auditoria: script para inventariar arquivos compartilhados e links no Teams (logs via Graph / AuditLogs)

# Exemplo: buscar audit logs do Teams via Graph (exemplo conceptual)
# Requer a permissão AuditLog.Read.All
$from = (Get-Date).AddDays(-7).ToString("o")
$to = (Get-Date).ToString("o")
$uri = "https://graph.microsoft.com/v1.0/auditLogs/signIns"  # exemplo: signIns; para Teams use /auditLogs/directoryAudits ou activityReports
$resp = Invoke-MgGraphRequest -Method GET -Uri $uri
$resp.value | Where-Object { $_.activityDisplayName -like "*Teams*" } | Select-Object createdDateTime, activityDisplayName, initiatedBy | Format-Table -AutoSize
