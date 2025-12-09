# Variáveis principais
$subscriptionId = "<sua-subscription>"
$resourceGroup  = "<seu-resource-group>"
$location       = "eastus"
$vmNames        = @("vm01","vm02","vm03")  # até 100 VMs por chamada
$scheduledTime  = "2025-01-20T23:00:00Z"   # horário do agendamento

# Login e seleção da subscription
Connect-AzAccount
Set-AzContext -Subscription $subscriptionId

# Criação do corpo da ação agendada
$body = @{
    properties = @{
        actionType   = "Stop"                 # valores possíveis: Start, Stop, Hibernate
        scheduleType = "Scheduled"
        schedule     = $scheduledTime
        resources    = $vmNames | ForEach-Object {
            @{
                id = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.Compute/virtualMachines/$_"
            }
        }
    }
}

# Conversão para JSON
$bodyJson = $body | ConvertTo-Json -Depth 10

# Criação da ação agendada
$actionName = "agendamento-stop-" + (Get-Random)
New-AzResource -ResourceType "Microsoft.ScheduledActions/scheduledActions" `
               -ApiVersion "2024-10-01" `
               -ResourceGroupName $resourceGroup `
               -Location $location `
               -Name $actionName `
               -Properties $body.properties

Write-Host "Ação criada: $actionName"
