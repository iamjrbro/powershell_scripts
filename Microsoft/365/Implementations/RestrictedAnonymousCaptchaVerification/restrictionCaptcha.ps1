# Para ativar o uso de Captcha no Teams admin usando script, siga os passos

 https://www.cloud-ing.blog/2025/01/verificacao-de-identidade-ao-entrar-em.html
 
 
# Posteriormente, não se esqueça de instalar os módulos do Teams (sempre mantendo a versão mais recente), importá-los e conecta-los.
 
Install-Module -Name MicrosoftTeams -Force -AllowClobber (instala o modulo)
Import-Module MicrosoftTeamsftTeams -Force -AllowClobber (importa o modulo)

 Connect-MicrosoftTeams (conecta ao Teams)

 Get-Help Grant-CsTeamsMeetingPolicy -Full (libera full para o modulo)

 New-CsGroupPolicyAssignment -GroupId "ID_DO_GRUPO" -PolicyType TeamsMeetingPolicy -PolicyName "NOME_DA_POLITICA"


New-CsGroupPolicyAssignment -GroupId "GROUP_ID" -PolicyType TeamsMeetingPolicy -PolicyName "RestrictedAnonymousCaptchaVerification"


 
Para deletar a política "RestrictedAnonymousCaptchaVerification", use o cmdlet correto:

 Remove-CsTeamsMeetingPolicy -Identity "RestrictedAnonymousCaptchaVerification"

 Para remover de um grupo:

 Remove-CsGroupPolicyAssignment -GroupId "GROUP_ID" -PolicyType TeamsMeetingPolicy -PolicyName "NOME_DA_POLITICA"

— NÃO crie uma politica de acesso condicional tambem


Revoke-AzureADUserAllRefreshToken -ObjectId "OBJECT_ID_DO_USUARIO" (revoga o token do usuario)



EXCESSÃO

> se um usuário estiver em dois grupos com políticas diferentes atribuídas via New-CsGroupPolicyAssignment. Nesse caso, o Teams vai aplicar a política com a maior prioridade.

Como o Teams resolve conflitos:
Quando um usuário pertence a mais de um grupo com políticas atribuídas, o Teams aplica a política com:
Rank mais baixo → mais alta prioridade


Exemplo:
Grupo
Política aplicada
Rank (prioridade)
Grupo A (geral)
RestrictedPolicy
2
Grupo B (exceção)
RelaxedPolicy (mais flexível)
1 ← mais prioritário

  Resultado: O usuário vai receber a RelaxedPolicy, pois o Rank 1 tem prioridade sobre Rank 2.

Se o Rank for igual:
Se você por acaso colocar o mesmo Rank para dois grupos, o resultado é indeterminado — o sistema pode aplicar qualquer uma das políticas. Por isso é importante definir a ordem com clareza.

Verificar atribuições e prioridades:
Você pode listar os grupos com políticas atribuídas e suas prioridades com:
Get-CsGroupPolicyAssignment -PolicyType TeamsMeetingPolicy


Dica:
Coloque o grupo de exceção com -Rank 1.
Coloque o grupo geral com -Rank 2 ou maior.
Assim, qualquer pessoa no grupo de exceção sempre terá prioridade.