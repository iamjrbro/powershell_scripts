<#!
.SYNOPSIS
Remove usuários desativados dos grupos de segurança do Microsoft Entra ID.

.DESCRIPTION
Lê um CSV contendo a coluna UserLoginName, localiza cada usuário no Microsoft
Entra ID e remove o usuário dos grupos dos quais ele é membro.

.NOTES
Requer Microsoft Graph PowerShell SDK e as permissões User.Read.All e
Group.ReadWrite.All. Revise o CSV e teste em homologação antes da execução.
Grupos dinâmicos não podem ser gerenciados por remoção direta de membros.
#>

$CsvPath = "C:\scripts\logins_desativados.csv"

if (-not (Test-Path -LiteralPath $CsvPath)) {
    Write-Error "Arquivo CSV não encontrado: $CsvPath"
    exit 1
}

Connect-MgGraph -Scopes "User.Read.All", "Group.ReadWrite.All"

$usuarios = Import-Csv -LiteralPath $CsvPath

foreach ($usuario in $usuarios) {
    $upn = $usuario.UserLoginName

    if ([string]::IsNullOrWhiteSpace($upn)) {
        Write-Warning "Linha do CSV sem UserLoginName. Ignorando."
        continue
    }

    try {
        $user = Get-MgUser -UserId $upn -ErrorAction Stop
        $membros = Get-MgUserMemberOf -UserId $user.Id -All -ErrorAction Stop

        $grupos = $membros | Where-Object {
            $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.group'
        }

        if (-not $grupos) {
            Write-Host "Nenhum grupo encontrado para $upn." -ForegroundColor Yellow
            continue
        }

        foreach ($grupo in $grupos) {
            try {
                Remove-MgGroupMemberByRef `
                    -GroupId $grupo.Id `
                    -DirectoryObjectId $user.Id `
                    -ErrorAction Stop

                Write-Host "$upn -> removido do grupo $($grupo.Id)" -ForegroundColor Green
            }
            catch {
                Write-Warning "$upn -> não foi possível remover do grupo $($grupo.Id): $($_.Exception.Message)"
            }
        }
    }
    catch {
        Write-Warning "Não foi possível processar $upn: $($_.Exception.Message)"
    }
}
