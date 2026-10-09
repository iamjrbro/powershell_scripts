Connect-AzAccount

# Pesquise em todas as subscriptions acessíveis
# Execute este script completo. Ele percorre as subscriptions às quais sua conta tem acesso e mostra qualquer assignment que referencie a role, sem excluir nada

$RoleId = "YOUR_ROLE_DEFINITION_ID" # Substitua pelo ID da role definition que deseja remover

$Subscriptions = Get-AzSubscription
$Found = @()

foreach ($Sub in $Subscriptions) {
    Write-Host "`nConsultando: $($Sub.Name) [$($Sub.Id)]" -ForegroundColor Cyan

    $Uri = "https://management.azure.com/subscriptions/$($Sub.Id)/providers/Microsoft.Authorization/roleAssignments?api-version=2022-04-01"

    try {
        do {
            $Response = Invoke-AzRestMethod -Method GET -Uri $Uri
            $Data = $Response.Content | ConvertFrom-Json

            $Matches = @(
                $Data.value | Where-Object {
                    $_.properties.roleDefinitionId -match [regex]::Escape($RoleId)
                }
            )

            foreach ($Item in $Matches) {
                $Found += [PSCustomObject]@{
                    Subscription = $Sub.Name
                    AssignmentId = $Item.id
                    PrincipalId  = $Item.properties.principalId
                    Scope        = $Item.properties.scope
                    RoleId       = $Item.properties.roleDefinitionId
                }
            }

            $Uri = $Data.nextLink
        } while ($Uri)
    }
    catch {
        Write-Warning "Falha na consulta: $($_.Exception.Message)"
    }
}

if ($Found.Count -gt 0) {
    $Found | Format-List *
} else {
    Write-Host "`nNenhum assignment encontrado nas subscriptions consultadas." -ForegroundColor Yellow
}

# confira os assignments antes de removê-los
$Found | Format-Table Subscription, PrincipalId, Scope, AssignmentId -AutoSize

# verifique

foreach ($Item in $Found) {
    Write-Host "Removendo assignment de $($Item.Subscription)..." -ForegroundColor Yellow

    try {
        $Uri = "https://management.azure.com$($Item.AssignmentId)?api-version=2022-04-01"

        $Result = Invoke-AzRestMethod -Method DELETE -Uri $Uri -ErrorAction Stop

        Write-Host "Solicitação enviada: $($Item.Subscription)" -ForegroundColor Green
    }
    catch {
        Write-Warning "Falha em $($Item.Subscription): $($_.Exception.Message)"
    }
}

# execute a remoção da role definition após garantir que não há assignments restantes

Remove-AzRoleDefinition -Id "YOUR_ROLE_DEFINITION_ID" -Force