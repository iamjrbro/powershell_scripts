# Cria uma Scheduled Action do Azure para iniciar VMs em um horário definido.
# Este arquivo usa Azure CLI; execute os comandos em um shell compatível com a sintaxe utilizada.

# Define subscription, Resource Group, região, VMs e horário do agendamento.
subscriptionId="<sua-subscription>"
resourceGroup="<seu-resource-group>"
location="eastus"
actionName="start-agendado-$RANDOM"
vm1="/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.Compute/virtualMachines/vm01"
vm2="/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.Compute/virtualMachines/vm02"
schedule="2025-01-21T08:00:00Z"

# Autentica no Azure e seleciona a subscription.
az login
az account set --subscription $subscriptionId

# Monta o payload da Scheduled Action.
cat <<EOF > body.json
{
  "properties": {
    "actionType": "Start",
    "scheduleType": "Scheduled",
    "schedule": "$schedule",
    "resources": [
      { "id": "$vm1" },
      { "id": "$vm2" }
    ]
  }
}
EOF

# Cria a Scheduled Action.
az resource create \
  --resource-type Microsoft.ScheduledActions/scheduledActions \
  --api-version 2024-10-01 \
  --name $actionName \
  --resource-group $resourceGroup \
  --location $location \
  --properties @body.json

# Consulta o status da ação.
az resource show \
  --resource-type Microsoft.ScheduledActions/scheduledActions \
  --api-version 2024-10-01 \
  --name $actionName \
  --resource-group $resourceGroup

# Remove a ação agendada.
az resource delete \
  --resource-type Microsoft.ScheduledActions/scheduledActions \
  --api-version 2024-10-01 \
  --name $actionName \
  --resource-group $resourceGroup
