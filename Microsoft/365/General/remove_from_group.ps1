#USING CSV

$usuarios = Import-Csv -Path "c:\scripts\logins_desativados.csv

 foreach ($usuario in $usuarios) {
    $user = Get-AzureADUser -Filter "UserPrincipalName eq '$($usuario.Login)'"
 
    if ($user) {
        # Obtenha todos os grupos dos quais o usuário é membro
        $grupos = Get-AzureADUserMembership -ObjectId $user.ObjectId
 
        if ($grupos) {
            # Remova o usuário de cada grupo
            foreach ($grupo in $grupos) {
                Remove-AzureADGroupMember -ObjectId $grupo.ObjectId -MemberId $user.ObjectId
            }
        }
        else {
            Write-Host "Nenhum grupo encontrado para o usuário $($usuario.Login)."
        }
    }
    else {
        Write-Host "Usuário $($usuario.Login) não encontrado no Azure AD."
    }
}




#USING FUNCTION APP

# Conectar ao Azure AD
Connect-AzureAD -TenantId "<TenantID>"

# Obter todos os usuários desabilitados no Azure AD
$disabledUsers = Get-AzureADUser -All $true | Where-Object { $_.AccountEnabled -eq $false }

# Loop através de cada usuário desabilitado
foreach ($user in $disabledUsers) {
    # Obter os grupos do usuário
    $groups = Get-AzureADUserMembership -ObjectId $user.ObjectId | Where-Object { $_.ObjectType -eq "Group" }

    # Remover o usuário desabilitado de cada grupo
    foreach ($group in $groups) {
        Remove-AzureADGroupMember -ObjectId $group.ObjectId -MemberId $user.ObjectId
        Write-Output "Usuário $($user.UserPrincipalName) removido do grupo $($group.DisplayName)"
    }
}

# Desconectar do Azure AD
Disconnect-AzureAD





######USING MANAGED ID
# Obter o token da Identidade Gerenciada para acessar o Azure AD
$response = Invoke-RestMethod -Uri "http://169.254.169.254/metadata/identity/oauth2/token?resource=https://graph.microsoft.com&api-version=2019-08-01" -Method GET -Headers @{Metadata="true"}

$token = $response.access_token

# Conectar ao Microsoft Graph (Azure AD) usando o token da identidade gerenciada
Connect-AzureAD -AadAccessToken $token -AccountId <AccountId> # Use o AccountId da função

# Obter todos os usuários desabilitados no Azure AD
$disabledUsers = Get-AzureADUser -All $true | Where-Object { $_.AccountEnabled -eq $false }

# Loop através de cada usuário desabilitado
foreach ($user in $disabledUsers) {
    # Obter os grupos do usuário
    $groups = Get-AzureADUserMembership -ObjectId $user.ObjectId | Where-Object { $_.ObjectType -eq "Group" }

    # Remover o usuário desabilitado de cada grupo
    foreach ($group in $groups) {
        Remove-AzureADGroupMember -ObjectId $group.ObjectId -MemberId $user.ObjectId
        Write-Output "Usuário $($user.UserPrincipalName) removido do grupo $($group.DisplayName)"
    }
}

# Desconectar do Azure AD
Disconnect-AzureAD

