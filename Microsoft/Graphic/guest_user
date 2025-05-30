Install-Module Microsoft.Graph

 
 # 1. Conectar ao Microsoft Graph com autenticação interativa
Connect-MgGraph -Scopes "User.Read.All", "User.ReadWrite.All", "Group.ReadWrite.All" 

# Verifica se a conexão deu certo
if (-not (Get-MgContext)) {
    Write-Error "Erro ao conectar ao Microsoft Graph."
    exit
}

# 2. Buscar todos os usuários convidados com paginação
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

# 3. Buscar último login para cada usuário
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

# 4. Exportar relatório para CSV
$csvPath = "$env:USERPROFILE\Desktop\logins_guest.csv"
$report | Export-Csv $csvPath -NoTypeInformation -Encoding UTF8
Write-Host "Relatório exportado para: $csvPath"

# 5. Mostrar na tela (opcional)
$report | Sort-Object LastSignIn -Descending | Format-Table -AutoSize
