# Azure Front Door — Correção de Referência da Azure DNS Zone

## Contexto

Após a migração de recursos do Azure Front Door entre subscriptions e Resource Groups, um Custom Domain passou a apresentar problemas durante a validação de ownership e renovação do certificado gerenciado.

A arquitetura foi mantida com o **Azure Front Door e a Azure DNS Zone em subscriptions diferentes**.

O problema ocorreu porque o Custom Domain do Azure Front Door continuava referenciando o **Resource ID antigo da Azure DNS Zone**.

 

## Problema

Ao tentar utilizar a opção **Add** para criar automaticamente o registro TXT de validação, o Azure Front Door retornava um erro indicando que a DNS Zone não poderia ser encontrada.

Isso acontecia porque a referência armazenada no Custom Domain apontava para uma subscription/resource group onde a DNS Zone não existia mais.

Exemplo conceitual:

```text
Azure Front Door
       │
       └── Custom Domain
                │
                └── Azure DNS Zone
                     │
                     └── ❌ Resource ID antigo
```

Enquanto a DNS Zone atualmente estava localizada em outro escopo:

```text
Azure Front Door
       │
       └── Custom Domain
                │
                └── Azure DNS Zone
                     │
                     └── ✅ Resource ID atual
```

 

## Diagnóstico

O Custom Domain possui uma propriedade chamada:

```text
azureDnsZone
```

Essa propriedade contém o Resource ID da Azure DNS Zone associada ao domínio.

Após a migração, essa referência continuava apontando para o Resource ID anterior.

Para verificar a configuração atual:

```powershell
az afd custom-domain show `
    --subscription "<FRONTDOOR-SUBSCRIPTION-ID>" `
    --resource-group "<FRONTDOOR-RESOURCE-GROUP>" `
    --profile-name "<FRONTDOOR-PROFILE>" `
    --custom-domain-name "<CUSTOM-DOMAIN-RESOURCE-NAME>"
```

A propriedade `azureDnsZone` deve ser verificada no resultado.

 

## Solução

A solução foi atualizar a propriedade `azureDnsZone` do Custom Domain para apontar para o **Resource ID atual da Azure DNS Zone**.


## Validação

Após executar o update, o comando de validação deve retornar o Resource ID correspondente à **Azure DNS Zone atual**.

```powershell
az afd custom-domain show `
    --subscription "<FRONTDOOR-SUBSCRIPTION-ID>" `
    --resource-group "<FRONTDOOR-RESOURCE-GROUP>" `
    --profile-name "<FRONTDOOR-PROFILE-NAME>" `
    --custom-domain-name "<CUSTOM-DOMAIN-RESOURCE-NAME>" `
    --query "azureDnsZone"
```

Depois da correção, o Azure Front Door poderá utilizar a referência correta da DNS Zone para realizar a validação do domínio e a renovação do certificado.

 

## Resultado

A configuração final fica conceitualmente:

```text
Subscription A
│
└── Resource Group
    │
    └── Azure Front Door Profile
        │
        └── Custom Domain
            │
            └── azureDnsZone
                    │
                    ▼
Subscription B
│
└── Resource Group
    │
    └── Azure DNS Zone
        │
        └── DNS Records
```

A separação entre as subscriptions é mantida.



## O que não foi necessário fazer

* Não foi necessário mover novamente o Azure Front Door.
* Não foi necessário mover a Azure DNS Zone.
* Não foi necessário excluir o Custom Domain.
* Não foi necessário recriar o domínio.
* Não foi necessário alterar o CNAME de produção.
* Não foi necessário recriar a DNS Zone.

A correção consistiu apenas em **atualizar a referência `azureDnsZone` do Custom Domain para o Resource ID atual da Azure DNS Zone**.





 

# verificar a configuração atual do custom domain:

az afd custom-domain show `
    --subscription "<FRONTDOOR-SUBSCRIPTION-ID>" `
    --resource-group "<FRONTDOOR-RESOURCE-GROUP>" `
    --profile-name "<FRONTDOOR-PROFILE>" `
    --custom-domain-name "<CUSTOM-DOMAIN-RESOURCE-NAME>"


# validar a propriedade azureDnsZone do custom domain:


az afd custom-domain show `
    --subscription "<FRONTDOOR-SUBSCRIPTION-ID>" `
    --resource-group "<FRONTDOOR-RESOURCE-GROUP>" `
    --profile-name "<FRONTDOOR-PROFILE-NAME>" `
    --custom-domain-name "<CUSTOM-DOMAIN-RESOURCE-NAME>" `
    --query "azureDnsZone"



# Azure Front Door: verificar a referência da Azure DNS Zone e atualizar para o Resource ID correto
$FrontDoorSubscription = "<FRONTDOOR-SUBSCRIPTION-ID>"
$FrontDoorResourceGroup = "<FRONTDOOR-RESOURCE-GROUP>"
$FrontDoorProfile = "<FRONTDOOR-PROFILE-NAME>"
$CustomDomainName = "<CUSTOM-DOMAIN-RESOURCE-NAME>"

# Azure DNS Zone: verficar o Resource ID correto
$DnsSubscription = "<DNS-SUBSCRIPTION-ID>"
$DnsResourceGroup = "<DNS-RESOURCE-GROUP>"
$DnsZoneName = "<DNS-ZONE-NAME>"

# Build Azure DNS Zone Resource ID: alterar para o Resource ID correto da Azure DNS Zone
$AzureDnsZoneId = "/subscriptions/$DnsSubscription/resourceGroups/$DnsResourceGroup/providers/Microsoft.Network/dnszones/$DnsZoneName"

# Update Custom Domain: realizar a atualização da referência da Azure DNS Zone no Custom Domain do Azure Front Door
az afd custom-domain update `
    --subscription $FrontDoorSubscription `
    --resource-group $FrontDoorResourceGroup `
    --profile-name $FrontDoorProfile `
    --custom-domain-name $CustomDomainName `
    --azure-dns-zone $AzureDnsZoneId

# Validate the updated reference: validar a propriedade azureDnsZone do custom domain após a atualização
az afd custom-domain show `
    --subscription $FrontDoorSubscription `
    --resource-group $FrontDoorResourceGroup `
    --profile-name $FrontDoorProfile `
    --custom-domain-name $CustomDomainName `
    --query "azureDnsZone"
