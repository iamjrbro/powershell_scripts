subscriptionId="<sua-subscription>"
resourceGroup="<seu-resource-group>"
location="eastus"
actionName="start-agendado-$RANDOM"
vm1="/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.Compute/virtualMachines/vm01"
vm2="/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.Compute/virtualMachines/vm02"
schedule="2025-01-21T08:00:00Z"

az login
az account set --subscription $subscriptionId

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

az resource create \
  --resource-type Microsoft.ScheduledActions/scheduledActions \
  --api-version 2024-10-01 \
  --name $actionName \
  --resource-group $resourceGroup \
  --location $location \
  --properties @body.json

# Checar status

az resource show \
  --resource-type Microsoft.ScheduledActions/scheduledActions \
  --api-version 2024-10-01 \
  --name $actionName \
  --resource-group $resourceGroup

# Cancelar ação

az resource delete \
  --resource-type Microsoft.ScheduledActions/scheduledActions \
  --api-version 2024-10-01 \
  --name $actionName \
  --resource-group $resourceGroup
