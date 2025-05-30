
1. execute o script no PowerShell como administrador 
2. após a execução, você terá um arquivo CSV com as informações sobre os App Registrations, pronto para análise

# Conectando com o Azure
if (-not (Get-AzContext)) {
    Write-Host "Conectando ao Azure..." -ForegroundColor Yellow
    Connect-AzAccount
}
# Verificando a conexão foi bem-sucedida
if (-not (Get-AzContext)) {
    Write-Host "Falha ao conectar ao Azure. Verifique suas credenciais." -ForegroundColor Red
    exit
}
# Conectando ao Microsoft Graph para obter os logs de autenticação
try {
    Write-Host "Conectando ao Microsoft Graph..." -ForegroundColor Yellow
    Connect-MgGraph -Scopes "AuditLog.Read.All"
} catch {
    Write-Host "Falha ao conectar ao Microsoft Graph. Verifique permissões." -ForegroundColor Red
    exit
}
# Obtendo os aplicativos no Azure AD
try {
    Write-Host "Obtendo lista de aplicativos do Azure AD..." -ForegroundColor Yellow
    $applications = Get-AzADApplication

    if ($null -eq $applications -or $applications.Count -eq 0) {
        Write-Host "Nenhum aplicativo encontrado no Azure AD." -ForegroundColor Yellow
        exit
    }

    # Criando as listas para armazenar os dados
    $appDetails = @()
    # Obtendo data de corte para os últimos 90 dias
    $cutoffDate = (Get-Date).AddDays(-90).ToString("yyyy-MM-ddTHH:mm:ssZ")
    # Obtendo logs de autenticação dos últimos 90 dias
    Write-Host "Obtendo logs de autenticação..." -ForegroundColor Yellow
    $authLogs = Get-MgAuditLogSignIn -Filter "createdDateTime ge $cutoffDate"
    foreach ($app in $applications) {
        # Obtendo Secrets (credenciais) do aplicativo
        $secrets = Get-AzADAppCredential -ApplicationId $app.AppId

        # Verificando se a Secret foi utilizada nos últimos 90 dias
        $secretsUsed = $false
        foreach ($secret in $secrets) {
            if ($secret.StartDateTime -ge (Get-Date).AddDays(-90)) {
                $secretsUsed = $true
                break
            }
        }

        # Caso a Secret não tenha sido utilizada nos últimos 90 dias, anotar como "Não utilizada nos últimos 90 dias"
        $secretUsage = if ($secretsUsed) { "Em uso" } else { "Não utilizada nos últimos 90 dias" }

        # Verificando se o aplicativo teve logins recentes
        $authUsed = $authLogs | Where-Object { $_.AppId -eq $app.AppId }

        # Definindo status de uso do aplicativo
        $authUsage = if ($authUsed) { "Autenticado recentemente" } else { "Sem autenticações nos últimos 90 dias" }
        # Adicionando detalhes do aplicativo à lista
        $appDetails += [PSCustomObject]@{
            'DisplayName'   = $app.DisplayName
            'ClientId'      = $app.AppId
            'SecretUsage'   = $secretUsage
            'SecretExpiry'  = ($secrets | Select-Object -First 1 -ExpandProperty EndDateTime) 
            'AuthUsage'     = $authUsage
        }
    }

    # Definindo o caminho do arquivo CSV
    $csvPath = "$env:USERPROFILE\Documents\AzureAplications.csv"

    # Exportando para CSV
    $appDetails | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

    # Confirmando a exportação
    if (Test-Path $csvPath) {
        Write-Host "Arquivo exportado com sucesso: $csvPath" -ForegroundColor Green
    } else {
        Write-Host "Falha ao salvar o arquivo. Verifique permissões na pasta." -ForegroundColor Red
    }
} catch {
    Write-Host "Erro ao obter aplicativos do Azure AD: $_" -ForegroundColor Red
}

