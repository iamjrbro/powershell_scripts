<#
.SYNOPSIS
Cria um endereço IP público Azure Standard SKU e associa o recurso a um Virtual Network Gateway.

.DESCRIPTION
Cria um Public IP com alocação estática e SKU Standard e utiliza seu Resource ID para atualizar o Virtual Network Gateway informado.

.NOTES
Substitua os nomes, Resource Group e subscription ID pelos valores do ambiente antes da execução.
#>

# Cria um novo endereço IP público com SKU Standard e alocação estática.
New-AzPublicIpAddress -Name "novo-ip-standard" `
  -ResourceGroupName "meu-rg" `
  -Location "brazilsouth" `
  -AllocationMethod Static `
  -Sku Standard

# Atualiza o Virtual Network Gateway para utilizar o novo endereço IP público.
Set-AzVirtualNetworkGateway -Name "meu-gateway-vpn" `
  -ResourceGroupName "meu-rg" `
  -PublicIpAddressId "/subscriptions/<ID>/resourceGroups/meu-rg/providers/Microsoft.Network/publicIPAddresses/novo-ip-standard"
