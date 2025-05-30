Antes, gerar um csv com os logins dos usuarios desativados dos ultimos 90 dias (ou prazo no qual vc executou a ultima vez o script)


Script para remover usuários dos grupos do office 365:
# Instale o módulo AzureAD se ainda não estiver instalado
Install-Module -Name AzureAD
 
# Conecte-se ao Azure AD com credenciais administrativas
Connect-AzureAD
 
# Leia o arquivo CSV com os logins. Certifique-se de que o CSV tem uma coluna "User", "Login" ou "Name" com os UPNs dos usuários.
$usuarios = Import-Csv -Path "c:\scripts\logins_desativados.csv"

foreach ($usuario in $usuarios) {
    $user = Get-AzureADUser -Filter "UserPrincipalName eq '$($usuario.UserLoginName)'"

    if ($user) {
        $grupos = Get-AzureADUserMembership -ObjectId $user.ObjectId

        if ($grupos) {
            foreach ($grupo in $grupos) {
                Remove-AzureADGroupMember -ObjectId $grupo.ObjectId -MemberId $user.ObjectId
            }
        } else {
            Write-Host "Nenhum grupo encontrado para o usuário $($usuario.UserLoginName)."
        }
    } else {
        Write-Host "Usuário $($usuario.UserLoginName) não encontrado."
    }
}
