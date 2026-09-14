<#
.SYNOPSIS
Cria, consulta e remove uma Scheduled Action para VMs do Azure.

.DESCRIPTION
Define as VMs alvo, monta a configuração da ação agendada, cria o recurso, consulta seu status e demonstra como removê-lo.

.NOTES
Substitua subscription, Resource Group, localização, VMs e horário pelos valores do ambiente.
#>

# Define os parâmetros principais da ação agendada.
$subscriptionId = "<sua-subscription>"
$resourceGroup  = "<seu-resource-group>"
$location       = "eastus"
$vmNames        = @("vm01","vm02","vm03")  # Até 100 VMs por chamada.
$scheduledTime  = "2025-01-20T23:00:00Z"   # Horário do agendamento.

# Autentica e seleciona a subscription.
Connect-AzAccount
Set-AzContext -Subscription $subscriptionId

# Cria o corpo da Scheduled Action.
$body = @{
    properties = @{
        actionType   = "Stop"                 # Valores possíveis: Start, Stop, Hibernate.
        scheduleType = "Scheduled"
        schedule     = $scheduledTime
        resources    = $vmNames | ForEach-Object {
            @{
                id = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.Compute/virtualMachines/$_"
            }
        }
    }
}

# Converte o corpo para JSON.
$bodyJson = $body | ConvertTo-Json -Depth 10

# Cria a ação agendada.
$actionName = "agendamento-stop-" + (Get-Random)
New-AzResource -ResourceType "Microsoft.ScheduledActions/scheduledActions" `
               -ApiVersion "2024-10-01" `
               -ResourceGroupName $resourceGroup `
               -Location $location `
               -Name $actionName `
               -Properties $body.properties

Write-Host "Ação criada: $actionName"

# Consulta o status da ação criada.
Get-AzResource -ResourceType "Microsoft.ScheduledActions/scheduledActions" `
               -ResourceGroupName $resourceGroup `
               -Name $actionName

# Remove a ação agendada.
Remove-AzResource -ResourceType "Microsoft.ScheduledActions/scheduledActions" `
                  -ResourceGroupName $resourceGroup `
                  -Name $actionName -Force
