<#
.SYNOPSIS
Adiciona usuários aos grupos do Microsoft Entra ID informados.

.DESCRIPTION
Consulta cada usuário, localiza os grupos pelo displayName, verifica se o usuário já é membro e adiciona a associação quando necessário.

.PREREQUISITES
Requer Microsoft Graph PowerShell SDK e permissões User.Read.All e Group.ReadWrite.All.
#>

# Conecta ao Microsoft Graph.
Connect-MgGraph -Scopes "User.Read.All", "Group.ReadWrite.All"

# Usuários que receberão os grupos.
$usuarios = @(
    "user.upn@domain.com"
)

# Grupos que serão atribuídos a todos os usuários.
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
            # Localiza o grupo pelo displayName.
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

            # Verifica se o usuário já é membro do grupo.
            $membro = Get-MgGroupMember `
                -GroupId $grupo.Id `
                -All |
                Where-Object { $_.Id -eq $usuario.Id }

            if ($membro) {
                Write-Host "$nomeGrupo -> já é membro" -ForegroundColor Yellow
                continue
            }

            # Adiciona o usuário ao grupo.
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
