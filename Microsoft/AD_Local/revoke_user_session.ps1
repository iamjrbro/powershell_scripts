<#
.SYNOPSIS
Revoga as sessões e tokens de atualização dos usuários informados.

.DESCRIPTION
Utiliza o módulo AzureAD para revogar todos os refresh tokens de um usuário individualmente ou em lote.

.NOTES
Substitua os UPNs de exemplo pelos usuários que devem ter as sessões revogadas.
#>

# Revoga as sessões do usuário informado individualmente.
Connect-AzureAD
Revoke-AzureADUserAllRefreshToken -ObjectId username@domain.com.br

# Revoga as sessões dos usuários informados em lote.
Connect-AzureAD

$users = @(
'username@domain.com.br',
'username@domain.com.br',
'username@domain.com.br',
'username@domain.com.br'
)

foreach ($user in $users) {
    Revoke-AzureADUserAllRefreshToken -ObjectId $user
}
