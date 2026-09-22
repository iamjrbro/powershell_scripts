# Auditoria de usuários internos ativos no Microsoft Entra ID.
#
# O script:
# - lista usuários do tipo Member com a conta habilitada;
# - identifica usuários com e sem gestor;
# - identifica gestores com subordinados diretos;
# - coleta departamento, status da conta e status de licença;
# - gera um arquivo Excel local com abas separadas para análise.
#
# O script realiza apenas consultas e não altera usuários, grupos ou licenças.
#
# Requisitos:
# - Microsoft.Graph.Users
# - ImportExcel
# - Permissões Microsoft Graph compatíveis com leitura de usuários, gestores,
#   subordinados e informações de licença, como User.Read.All e Directory.Read.All.

Import-Module Microsoft.Graph.Users -ErrorAction Stop
Import-Module ImportExcel -ErrorAction Stop

Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All"

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$excelPath = Join-Path -Path (Get-Location) -ChildPath "AuditoriaUsuarios_$timestamp.xlsx"

# Arrays para armazenar os resultados.
$comManager = @()
$semManager = @()
$managersComSubordinados = @()

$usuarios = Get-MgUser -All -Property Id,DisplayName,UserPrincipalName,Department,UserType,AccountEnabled |
    Where-Object {
        $_.UserType -eq "Member" -and
        $_.AccountEnabled -eq $true -and
        $_.UserPrincipalName -notlike "*#EXT#*"
    }

foreach ($user in $usuarios) {
    try {
        $manager = $null
        $manager = Get-MgUserManager -UserId $user.Id -ErrorAction Stop

        if ($manager -and $manager.Id) {
            $managerDetails = Get-MgUser -UserId $manager.Id -Property DisplayName,UserPrincipalName -ErrorAction Stop
        }
    }
    catch {
        $managerDetails = $null
    }

    try {
        $licenseDetails = Get-MgUserLicenseDetail -UserId $user.Id -All -ErrorAction Stop
        $licenciado = @($licenseDetails).Count -gt 0
    }
    catch {
        $licenciado = $false
    }

    $statusLicenca = if ($licenciado) { "Licensed" } else { "Unlicensed" }
    $statusConta = if ($user.AccountEnabled) { "Active" } else { "Disabled" }

    if ($managerDetails) {
        $comManager += [PSCustomObject]@{
            Nome             = $user.DisplayName
            UPN              = $user.UserPrincipalName
            Departamento     = $user.Department
            "Manager Nome"   = $managerDetails.DisplayName
            "Manager UPN"    = $managerDetails.UserPrincipalName
            "Status Conta"   = $statusConta
            "Status Licença" = $statusLicenca
        }
    }
    else {
        $semManager += [PSCustomObject]@{
            Nome             = $user.DisplayName
            UPN              = $user.UserPrincipalName
            Departamento     = $user.Department
            "Manager Nome"   = "N/A"
            "Manager UPN"    = "N/A"
            "Status Conta"   = $statusConta
            "Status Licença" = $statusLicenca
        }
    }

    try {
        $subordinados = @(Get-MgUserDirectReport -UserId $user.Id -All -ErrorAction Stop)

        $subordinadosDetalhes = foreach ($subordinado in $subordinados) {
            if ($subordinado.Id) {
                Get-MgUser -UserId $subordinado.Id -Property DisplayName,UserPrincipalName -ErrorAction SilentlyContinue
            }
        }

        if (@($subordinadosDetalhes).Count -gt 0) {
            $managersComSubordinados += [PSCustomObject]@{
                NomeManager          = $user.DisplayName
                UPNManager           = $user.UserPrincipalName
                Departamento         = $user.Department
                StatusConta          = $statusConta
                StatusLicenca        = $statusLicenca
                QtdSubordinados      = @($subordinadosDetalhes).Count
                "Nomes Subordinados" = (@($subordinadosDetalhes | Select-Object -ExpandProperty DisplayName) -join ", ")
                "UPNs Subordinados"  = (@($subordinadosDetalhes | Select-Object -ExpandProperty UserPrincipalName) -join ", ")
            }
        }
    }
    catch {
        Write-Warning "Não foi possível consultar os subordinados de '$($user.UserPrincipalName)': $($_.Exception.Message)"
    }
}

$resumo = @(
    [PSCustomObject]@{ Indicador = "Usuários ativos"; Quantidade = @($usuarios).Count }
    [PSCustomObject]@{ Indicador = "Usuários com manager"; Quantidade = @($comManager).Count }
    [PSCustomObject]@{ Indicador = "Usuários sem manager"; Quantidade = @($semManager).Count }
    [PSCustomObject]@{ Indicador = "Managers com subordinados"; Quantidade = @($managersComSubordinados).Count }
)

$resumo | Export-Excel -Path $excelPath -WorksheetName "Resumo" -AutoSize -AutoFilter
$comManager | Export-Excel -Path $excelPath -WorksheetName "Com Manager" -AutoSize -AutoFilter
$semManager | Export-Excel -Path $excelPath -WorksheetName "Sem Manager" -AutoSize -AutoFilter
$managersComSubordinados | Export-Excel -Path $excelPath -WorksheetName "Managers" -AutoSize -AutoFilter

Write-Host "Auditoria concluída. Relatório gerado em: $excelPath"
