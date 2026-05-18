# =========================================================
# Microsoft Entra ID / Azure AD
# Lista todos os App Registrations e últimos sign-ins:
# - Interactive User Sign-In
# - Non-Interactive User Sign-In
# Requisitos:
# Install-Module Microsoft.Graph -Scope CurrentUser
# Permissões necessárias no Graph:
# - AuditLog.Read.All
# - Application.Read.All
# - Directory.Read.All
# =========================================================

# Conecta no Microsoft Graph
Connect-MgGraph -Scopes `
    "Application.Read.All",
    "AuditLog.Read.All",
    "Directory.Read.All"

Write-Host "`nColetando aplicações..." -ForegroundColor Cyan

# Busca todos os App Registrations
$applications = Get-MgApplication -All

$resultados = @()

foreach ($app in $applications) {

    Write-Host "Processando: $($app.DisplayName)" -ForegroundColor Yellow

    # =========================
    # Interactive Sign-In
    # =========================
    $interactive = Get-MgAuditLogSignIn -Filter "
        appId eq '$($app.AppId)'
        and signInEventTypes/any(t:t eq 'interactiveUser')
    " -Top 1 -Sort "createdDateTime DESC" `
    -ErrorAction SilentlyContinue

    # =========================
    # Non-Interactive Sign-In
    # =========================
    $nonInteractive = Get-MgAuditLogSignIn -Filter "
        appId eq '$($app.AppId)'
        and signInEventTypes/any(t:t eq 'nonInteractiveUser')
    " -Top 1 -Sort "createdDateTime DESC" `
    -ErrorAction SilentlyContinue

    # =========================
    # Últimos dados
    # =========================
    $ultimoInteractive = if ($interactive) {
        $interactive[0].CreatedDateTime
    } else {
        "Nunca"
    }

    $ultimoInteractiveUser = if ($interactive) {
        $interactive[0].UserDisplayName
    } else {
        "-"
    }

    $ultimoNonInteractive = if ($nonInteractive) {
        $nonInteractive[0].CreatedDateTime
    } else {
        "Nunca"
    }

    $ultimoNonInteractiveUser = if ($nonInteractive) {
        $nonInteractive[0].UserDisplayName
    } else {
        "-"
    }

    # =========================
    # Resultado final
    # =========================
    $resultados += [PSCustomObject]@{
        AppName                    = $app.DisplayName
        AppId                      = $app.AppId
        InteractiveLastSignIn      = $ultimoInteractive
        InteractiveLastUser        = $ultimoInteractiveUser
        NonInteractiveLastSignIn   = $ultimoNonInteractive
        NonInteractiveLastUser     = $ultimoNonInteractiveUser
    }
}

# Exibe na tela
$resultados | Format-Table -AutoSize

# Exporta CSV
$path = ".\AppRegistrations_LastSignIns.csv"

$resultados | Export-Csv -Path $path -NoTypeInformation -Encoding UTF8

Write-Host "`nRelatório exportado para: $path" -ForegroundColor Green