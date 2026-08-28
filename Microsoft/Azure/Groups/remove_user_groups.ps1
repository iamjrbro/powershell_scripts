# Script para remover usuários de grupos no Microsoft Entra ID
# utilizando Microsoft Graph PowerShell SDK

Connect-MgGraph -Scopes "User.Read.All", "Group.ReadWrite.All"

$usuarios = @(
    "user.upn@domain.com"
)

# Grupos dos quais todos os usuários serão removidos
$grupos = @(
    "G1",
    "G2"
)

foreach ($usuarioUPN in $usuarios) {

    Write-Host "`n=====================================" -ForegroundColor Cyan
    Write-Host "Usuário: $usuarioUPN" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan

    try {
        $usuario = Get-MgUser `
            -UserId $usuarioUPN `
            -ErrorAction Stop
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

            # Verifica se o usuário é membro
            $membro = Get-MgGroupMember `
                -GroupId $grupo.Id `
                -All |
                Where-Object { $_.Id -eq $usuario.Id }

            if (-not $membro) {
                Write-Host "$nomeGrupo -> usuário não é membro" -ForegroundColor Yellow
                continue
            }

            # Remove o usuário do grupo
            Remove-MgGroupMemberByRef `
                -GroupId $grupo.Id `
                -DirectoryObjectId $usuario.Id

            Write-Host "$nomeGrupo -> REMOVIDO" -ForegroundColor Green
        }
        catch {
            Write-Host "$nomeGrupo -> ERRO: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}