# Conecte ao Microsoft Graph com permissões adequadas

Connect-MgGraph -Scopes "Application.ReadWrite.All"

# subistitua o <ObjectId> pelo Object ID da aplicação:

Update-MgApplication -ApplicationId <ObjectId> -BodyParameter @{ isDisabled = $true }

# após a execução, o atributo isDisabled será definido como verdadeiro, bloqueando novas autenticações.


# DESATIVAR MULTIPLOS APPS

# processo consiste em: listar aplicações com base em critérios específicos (por exemplo, apps sem uso recente ou sem owners válidos), iterar sobre cada ObjectId e aplicar o comando definindo isDisabled = $true:

Update-MgApplication  isDisabled = $true
