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