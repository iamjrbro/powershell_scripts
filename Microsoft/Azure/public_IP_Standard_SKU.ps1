# creating new public IP address (Standard SKU)

New-AzPublicIpAddress -Name "novo-ip-standard" `
  -ResourceGroupName "meu-rg" `
  -Location "brazilsouth" `
  -AllocationMethod Static `
  -Sku Standard

# updating gateway with the new IP

Set-AzVirtualNetworkGateway -Name "meu-gateway-vpn" `
  -ResourceGroupName "meu-rg" `
  -PublicIpAddressId "/subscriptions/<ID>/resourceGroups/meu-rg/providers/Microsoft.Network/publicIPAddresses/novo-ip-standard"

