<#
.SYNOPSIS
Lista App Registrations do Microsoft Entra ID e seus últimos sign-ins.

.DESCRIPTION
Consulta todos os App Registrations e identifica o último Interactive User Sign-In e Non-Interactive User Sign-In de cada aplicação. O resultado é exibido e exportado para CSV.

.PREREQUISITES
Requer Microsoft Graph PowerShell SDK e permissões Application.Read.All, AuditLog.Read.All e Directory.Read.All.
#>

# Conecta ao Microsoft Graph.
Connect-MgGraph -Scopes `
    "Application.Read.All",
    "AuditLog.Read.All",
    "Directory.Read.All"

Write-Host "`nColetando aplicações..." -ForegroundColor Cyan

# Obtém todos os App Registrations.
$applications = Get-MgApplication -All

$resultados = @()

foreach ($app in $applications) {
    Write-Host "Processando: $($app.DisplayName)" -ForegroundColor Yellow

    # Consulta o último Interactive User Sign-In.
    $interactive = Get-MgAuditLogSignIn -Filter "
        appId eq '$($app.AppId)'
        and signInEventTypes/any(t:t eq 'interactiveUser')
    " -Top 1 -Sort "createdDateTime DESC" `
    -ErrorAction SilentlyContinue

    # Consulta o último Non-Interactive User Sign-In.
    $nonInteractive = Get-MgAuditLogSignIn -Filter "
        appId eq '$($app.AppId)'
        and signInEventTypes/any(t:t eq 'nonInteractiveUser')
    " -Top 1 -Sort "createdDateTime DESC" `
    -ErrorAction SilentlyContinue

    # Define os últimos dados encontrados para cada tipo de sign-in.
    $ultimoInteractive = if ($interactive) { $interactive[0].CreatedDateTime } else { "Nunca" }
    $ultimoInteractiveUser = if ($interactive) { $interactive[0].UserDisplayName } else { "-" }
    $ultimoNonInteractive = if ($nonInteractive) { $nonInteractive[0].CreatedDateTime } else { "Nunca" }
    $ultimoNonInteractiveUser = if ($nonInteractive) { $nonInteractive[0].UserDisplayName } else { "-" }

    # Monta o resultado final da aplicação.
    $resultados += [PSCustomObject]@{
        AppName = $app.DisplayName
        AppId = $app.AppId
        InteractiveLastSignIn = $ultimoInteractive
        InteractiveLastUser = $ultimoInteractiveUser
        NonInteractiveLastSignIn = $ultimoNonInteractive
        NonInteractiveLastUser = $ultimoNonInteractiveUser
    }
}

# Exibe o resultado na tela.
$resultados | Format-Table -AutoSize

# Exporta o resultado para CSV.
$path = ".\AppRegistrations_LastSignIns.csv"
$resultados | Export-Csv -Path $path -NoTypeInformation -Encoding UTF8

Write-Host "`nRelatório exportado para: $path" -ForegroundColor Green
