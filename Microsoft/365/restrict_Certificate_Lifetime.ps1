# Execute o PowerSheel como admin

# Ativando o X509Certificate

Update-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration `
  -AuthenticationMethodConfigurationId "X509Certificate" `
  -BodyParameter @{ state = "enabled" }

# Definindo o limite (esse código está definido para 180 dias, altere conforme necessidade no campo BodyParameter)

Update-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration `
  -AuthenticationMethodConfigurationId "X509Certificate" `
  -BodyParameter @{ restrictMaximumCertificateLifetime = "P180D" }


# Verificando se a police foi implementada

# Instale o módulo Microsoft Graph

Install-Module Microsoft.Graph -Scope CurrentUser

# Conecte-se
Connect-MgGraph -Scopes "Policy.Read.All","Directory.Read.All"

# Comando para listar a política
Get-MgPolicyAuthenticationMethodPolicy | Select-Object -ExpandProperty AuthenticationMethodConfigurations

# Desativar  X509Certificate

Update-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration `
  -AuthenticationMethodConfigurationId "X509Certificate" `
  -BodyParameter @{ state = "disabled" }

# Mantendo ativo, mas escopado

Update-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration `
  -AuthenticationMethodConfigurationId "X509Certificate" `
  -BodyParameter @{
    state = "enabled";
    includeTargets = @(
      @{
        id = "<ObjectID-do-grupo>";
        targetType = "group";
        targetedAuthenticationMethod = "x509Certificate"
      }
    )
  }


# Vinculando a policy 

Update-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration `
  -AuthenticationMethodConfigurationId "X509Certificate" `
  -BodyParameter @{
    state = "enabled";
    includeTargets = @(
      @{
        id = "<ObjectId do grupo>";
        targetType = "group";
        targetedAuthenticationMethod = "x509Certificate"
      }
    )
  }




# baixando app

# Conectar ao Microsoft Graph
Connect-MgGraph -Scopes "Application.Read.All"

# Buscar todas as App Registrations
$apps = Get-MgApplication -All

# Exibir nome e ID no console
$apps | Select-Object DisplayName, AppId, Id, PublisherDomain, CreatedDateTime | Format-Table

# (Opcional) Exportar para CSV
$apps | Select-Object DisplayName, AppId, Id, PublisherDomain, CreatedDateTime `
| Export-Csv -Path "C:\AppRegistrations.csv" -NoTypeInformation -Encoding UTF8

Se quiser ver apenas os apps que usam certificados, você pode filtrar assim:

$apps | Where-Object { $_.KeyCredentials.Count -gt 0 } | 
Select-Object DisplayName, AppId, @{Name='CertCount';Expression={$_.KeyCredentials.Count}}


