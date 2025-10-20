# Execute o PowerSheel como admin

# Ativando o X509Certificate

Update-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration `
  -AuthenticationMethodConfigurationId "X509Certificate" `
  -BodyParameter @{ state = "enabled" }

# Definindo o limite (esse código está definido para 180 dias, altere conforme necessidade no campo BodyParameter)

Update-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration `
  -AuthenticationMethodConfigurationId "X509Certificate" `
  -BodyParameter @{ restrictMaximumCertificateLifetime = "P180D" }


# Instale o módulo Microsoft Graph

Install-Module Microsoft.Graph -Scope CurrentUser

# Conecte-se
Connect-MgGraph -Scopes "Policy.Read.All","Directory.Read.All"

# Comando para listar a política
Get-MgPolicyAuthenticationMethodPolicy | Select-Object -ExpandProperty AuthenticationMethodConfigurations






