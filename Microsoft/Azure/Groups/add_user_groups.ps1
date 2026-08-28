
# Script para adicionar usuários a grupos no Microsoft Entra ID (Azure AD) usando Microsoft Graph PowerShell SDK

Connect-MgGraph -Scopes "User.Read.All", "Group.ReadWrite.All"

$usuarios = @(
    "user.upn@domain.com"
)

# Grupos que todos os usuários receberão
$grupos = @(
    "G1",
    "G2"
)

foreach ($usuarioUPN in $usuarios) {

    Write-Host "`n=====================================" -ForegroundColor Cyan
    Write-Host "Usuário: $usuarioUPN" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan

    try {
        $usuario = Get-MgUser -UserId $usuarioUPN -ErrorAction Stop
    }
    catch {
        Write-Host "Usuário não encontrado: $usuarioUPN" -ForegroundColor Red
        continue
    }

    foreach ($nomeGrupo in $grupos) {

        try {
            $grupo = Get-MgGroup `
                -Filter "displayName eq '$nomeGrupo'" `
                -ConsistencyLevel eventual `
                -ErrorAction Stop

            if (-not $grupo) {
                Write-Host "$nomeGrupo -> GRUPO NÃO ENCONTRADO" -ForegroundColor Red
                continue
            }

            if ($grupo.Count -gt 1) {
                Write-Host "$nomeGrupo -> MAIS DE UM GRUPO ENCONTRADO" -ForegroundColor Red
                continue
            }

            # Verifica se já é membro
            $membro = Get-MgGroupMember `
                -GroupId $grupo.Id `
                -All |
                Where-Object { $_.Id -eq $usuario.Id }

            if ($membro) {
                Write-Host "$nomeGrupo -> já é membro" -ForegroundColor Yellow
                continue
            }

            # Adiciona
            New-MgGroupMemberByRef `
                -GroupId $grupo.Id `
                -OdataId "https://graph.microsoft.com/v1.0/directoryObjects/$($usuario.Id)"

            Write-Host "$nomeGrupo -> ADICIONADO" -ForegroundColor Green
        }
        catch {
            Write-Host "$nomeGrupo -> ERRO: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

