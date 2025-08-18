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

New-MgPolicyClaimsMappingPolicy -DisplayName "PolicySponsorID" -Definition @($policy)

# depois, aplique a política ao Service Principal da aplicação

$sp = Get-MgServicePrincipal -Filter "AppId eq 'APP_ID_DA_APLICACAO'"

Add-MgServicePrincipalPolicy -ServicePrincipalId $sp.Id -PolicyId (Get-MgPolicyClaimsMappingPolicy -Filter "DisplayName eq 'PolicySponsorID'").Id

