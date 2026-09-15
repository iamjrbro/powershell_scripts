<#
.SYNOPSIS
Cria uma Claims Mapping Policy no Microsoft Entra ID e a associa a um Service Principal.

.DESCRIPTION
Define um claim baseado em um atributo de extensão do usuário, cria a política no Microsoft Graph e aplica a política ao Service Principal da aplicação.

.NOTES
Substitua o identificador da extensão e o App ID pelos valores reais do ambiente.
#>

# Define a Claims Mapping Policy com o claim SponsorID.
$policy = '{

  "ClaimsMappingPolicy": {

    "ClaimsSchema": [

      {

        "Source": "user",

        "ID": "extension_<AppClientID>_sponsorid1",

        "SamlClaimType": "SponsorID"

      }

    ]

  }

}'

# Cria a Claims Mapping Policy.
New-MgPolicyClaimsMappingPolicy -DisplayName "PolicySponsorID" -Definition @($policy)

# Localiza o Service Principal da aplicação.
$sp = Get-MgServicePrincipal -Filter "AppId eq 'APP_ID_DA_APLICACAO'"

# Associa a política ao Service Principal.
Add-MgServicePrincipalPolicy -ServicePrincipalId $sp.Id -PolicyId (Get-MgPolicyClaimsMappingPolicy -Filter "DisplayName eq 'PolicySponsorID'").Id
