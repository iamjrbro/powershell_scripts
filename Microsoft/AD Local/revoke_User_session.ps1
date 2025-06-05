Connect-AzureAD 
Revoke-AzureADUserAllRefreshToken -ObjectId username@domain.com.br

# revoking the session in loop

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
