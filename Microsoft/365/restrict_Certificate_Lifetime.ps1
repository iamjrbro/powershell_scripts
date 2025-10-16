# Ativando o X509Certificate

Update-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration `
  -AuthenticationMethodConfigurationId "X509Certificate" `
  -BodyParameter @{ state = "enabled" }

# Definindo o limite

Update-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration `
  -AuthenticationMethodConfigurationId "X509Certificate" `
  -BodyParameter @{ restrictMaximumCertificateLifetime = "P90D" }


# Verificando se a police foi implementada

# Instale o módulo Microsoft Graph

Install-Module Microsoft.Graph -Scope CurrentUser

# Conecte-se
Connect-MgGraph -Scopes "Policy.Read.All","Directory.Read.All"

# Comando para listar a política
Get-MgPolicyAuthenticationMethodPolicy | Select-Object -ExpandProperty AuthenticationMethodConfigurations

# Procure pela seção de X509Certificate

