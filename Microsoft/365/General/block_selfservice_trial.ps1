<#
.SYNOPSIS
Desabilita a compra de produtos Microsoft por autoatendimento.

.DESCRIPTION
Consulta as políticas AllowSelfServicePurchase habilitadas no Microsoft 365 e desabilita a compra por autoatendimento para cada produto encontrado.

.PREREQUISITES
Requer o módulo MSCommerce e uma conta com permissões administrativas para alterar as políticas de compra.
#>

# Instala e importa o módulo MSCommerce.
Install-Module -Name MSCommerce -Scope CurrentUser
Import-Module -Name MSCommerce

# Conecta ao serviço Microsoft Commerce.
Connect-MSCommerce

# Obtém os produtos que permitem compra por autoatendimento.
$products = Get-MSCommerceProductPolicies -PolicyId AllowSelfServicePurchase | Where { $_.PolicyValue -eq "Enabled"}

# Desabilita a compra por autoatendimento para os produtos encontrados.
foreach ($p in $products)
{
    Update-MSCommerceProductPolicy -PolicyId AllowSelfServicePurchase -ProductId $p.ProductId -Enabled $False
}
