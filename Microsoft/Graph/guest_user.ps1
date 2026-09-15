<#
.SYNOPSIS
Gera um relatório dos usuários convidados do Microsoft Entra ID e de seus últimos sign-ins.

.DESCRIPTION
Conecta ao Microsoft Graph, lista usuários do tipo Guest com paginação, consulta o último sign-in de cada usuário e exporta os dados para CSV.

.PREREQUISITES
Requer o módulo Microsoft.Graph e permissões User.Read.All, User.ReadWrite.All e Group.ReadWrite.All.
#>

Install-Module Microsoft.Graph

# Conecta ao Microsoft Graph com autenticação interativa.
Connect-MgGraph -Scopes "User.Read.All", "User.ReadWrite.All", "Group.ReadWrite.All"

# Verifica se a conexão foi estabelecida.
if (-not (Get-MgContext)) {
    Write-Error "Erro ao conectar ao Microsoft Graph."
    exit
}

# Obtém todos os usuários convidados com paginação.
$guestUsers = @()
$uri = "https://graph.microsoft.com/v1.0/users?\$filter=userType eq 'Guest'&\$top=100"

do {
    try {
        $response = Invoke-MgGraphRequest -Uri $uri -Method GET
        $guestUsers += $response.value
        $uri = $response.'@odata.nextLink'
    }
    catch {
        Write-Warning "Erro ao buscar usuários convidados: $_"
        break
    }
} while ($uri)

Write-Host "Total de convidados encontrados: $($guestUsers.Count)"

# Consulta o último sign-in de cada usuário convidado.
$report = @()

foreach ($user in $guestUsers) {
    try {
        $signInLog = Invoke-MgGraphRequest -Method GET `
            -Uri "https://graph.microsoft.com/v1.0/auditLogs/signIns?\$filter=userId eq '$($user.id)'&\$orderby=createdDateTime desc&\$top=1"

        if ($signInLog.value.Count -gt 0) {
            $log = $signInLog.value[0]
            $report += [PSCustomObject]@{
                DisplayName        = $user.displayName
                UserPrincipalName  = $user.userPrincipalName
                LastSignIn         = $log.createdDateTime
                IPAddress          = $log.ipAddress
                Status             = if ($log.status.errorCode -eq 0) { "Success" } else { "Failed" }
            }
        } else {
            $report += [PSCustomObject]@{
                DisplayName        = $user.displayName
                UserPrincipalName  = $user.userPrincipalName
                LastSignIn         = "Nunca logou"
                IPAddress          = "-"
                Status             = "-"
            }
        }
    }
    catch {
        Write-Warning "Erro ao buscar logins de $($user.userPrincipalName): $_"
    }
}

# Exporta o relatório para CSV.
$csvPath = "$env:USERPROFILE\Desktop\logins_guest.csv"
$report | Export-Csv $csvPath -NoTypeInformation -Encoding UTF8
Write-Host "Relatório exportado para: $csvPath"

# Exibe o relatório na tela.
$report | Sort-Object LastSignIn -Descending | Format-Table -AutoSize
