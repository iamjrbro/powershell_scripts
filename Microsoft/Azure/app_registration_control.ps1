<#
.SYNOPSIS
Gera um inventário de App Registrations, credenciais e autenticações recentes.

.DESCRIPTION
Conecta ao Azure e ao Microsoft Graph, coleta App Registrations, verifica a data das credenciais e consulta logs de autenticação dos últimos 90 dias. Ao final, exporta os dados para CSV.

.PREREQUISITES
Execute o script com permissões adequadas no Azure e no Microsoft Graph.

.NOTES
A informação de SecretUsage é baseada na data de início da credencial e não representa, por si só, evidência de utilização da Secret.
#>

# Execute o script no PowerShell como administrador.
# Após a execução, o CSV estará disponível na pasta Documents do usuário.

# Conecta ao Azure.
if (-not (Get-AzContext)) {
    Write-Host "Conectando ao Azure..." -ForegroundColor Yellow
    Connect-AzAccount
}

# Verifica se a conexão com o Azure foi estabelecida.
if (-not (Get-AzContext)) {
    Write-Host "Falha ao conectar ao Azure. Verifique suas credenciais." -ForegroundColor Red
    exit
}

# Conecta ao Microsoft Graph para consultar os logs de autenticação.
try {
    Write-Host "Conectando ao Microsoft Graph..." -ForegroundColor Yellow
    Connect-MgGraph -Scopes "AuditLog.Read.All"
} catch {
    Write-Host "Falha ao conectar ao Microsoft Graph. Verifique permissões." -ForegroundColor Red
    exit
}

# Obtém os aplicativos registrados no Microsoft Entra ID.
try {
    Write-Host "Obtendo lista de aplicativos do Azure AD..." -ForegroundColor Yellow
    $applications = Get-AzADApplication

    if ($null -eq $applications -or $applications.Count -eq 0) {
        Write-Host "Nenhum aplicativo encontrado no Azure AD." -ForegroundColor Yellow
        exit
    }

    # Cria as listas para armazenar os dados.
    $appDetails = @()
    # Define a data de corte para os últimos 90 dias.
    $cutoffDate = (Get-Date).AddDays(-90).ToString("yyyy-MM-ddTHH:mm:ssZ")
    # Obtém os logs de autenticação dos últimos 90 dias.
    Write-Host "Obtendo logs de autenticação..." -ForegroundColor Yellow
    $authLogs = Get-MgAuditLogSignIn -Filter "createdDateTime ge $cutoffDate"
    foreach ($app in $applications) {
        # Obtém as credenciais do aplicativo.
        $secrets = Get-AzADAppCredential -ApplicationId $app.AppId

        # Verifica se existe uma credencial com início nos últimos 90 dias.
        $secretsUsed = $false
        foreach ($secret in $secrets) {
            if ($secret.StartDateTime -ge (Get-Date).AddDays(-90)) {
                $secretsUsed = $true
                break
            }
        }

        # Classifica a existência de credencial iniciada nos últimos 90 dias.
        $secretUsage = if ($secretsUsed) { "Em uso" } else { "Não utilizada nos últimos 90 dias" }

        # Verifica se o aplicativo teve autenticações recentes.
        $authUsed = $authLogs | Where-Object { $_.AppId -eq $app.AppId }

        # Define o status de autenticação do aplicativo.
        $authUsage = if ($authUsed) { "Autenticado recentemente" } else { "Sem autenticações nos últimos 90 dias" }
        # Adiciona os detalhes do aplicativo à lista.
        $appDetails += [PSCustomObject]@{
            'DisplayName'   = $app.DisplayName
            'ClientId'      = $app.AppId
            'SecretUsage'   = $secretUsage
            'SecretExpiry'  = ($secrets | Select-Object -First 1 -ExpandProperty EndDateTime) 
            'AuthUsage'     = $authUsage
        }
    }

    # Define o caminho do arquivo CSV.
    $csvPath = "$env:USERPROFILE\Documents\AzureAplications.csv"

    # Exporta os dados para CSV.
    $appDetails | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

    # Confirma se a exportação foi concluída.
    if (Test-Path $csvPath) {
        Write-Host "Arquivo exportado com sucesso: $csvPath" -ForegroundColor Green
    } else {
        Write-Host "Falha ao salvar o arquivo. Verifique permissões na pasta." -ForegroundColor Red
    }
} catch {
    Write-Host "Erro ao obter aplicativos do Azure AD: $_" -ForegroundColor Red
}
