<#
.SYNOPSIS
Desabilita um App Registration no Microsoft Entra ID.

.DESCRIPTION
Conecta ao Microsoft Graph e define o atributo isDisabled da aplicação como true. O arquivo também documenta a abordagem para desabilitar múltiplas aplicações.

.WARNING
Desabilitar uma aplicação pode interromper autenticações e integrações. Valide o App Registration antes da alteração.
#>

# Conecta ao Microsoft Graph com permissão para alterar aplicações.
Connect-MgGraph -Scopes "Application.ReadWrite.All"

# Substitua <ObjectId> pelo Object ID da aplicação que será desabilitada.
Update-MgApplication -ApplicationId <ObjectId> -BodyParameter @{ isDisabled = $true }

# Após a execução, isDisabled será definido como true.

# ============================================================================
# DESABILITAR MÚLTIPLOS APPS
# ============================================================================

# A abordagem consiste em listar aplicações conforme critérios definidos,
# iterar pelos respectivos Object IDs e definir isDisabled = $true.
# Exemplo conceitual:
# Update-MgApplication -ApplicationId <ObjectId> -BodyParameter @{ isDisabled = $true }
