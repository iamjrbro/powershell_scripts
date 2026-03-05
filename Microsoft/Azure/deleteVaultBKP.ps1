# Excluir backup e remover dados imediatamente, item por item

Connect-AzAccount
Select-AzSubscription -SubscriptionId "SUBSCRIPTION-ID"

# 1. Definir variáveis
$vaultName = "VAULT-NAME"
$resourceGroupName = "RESOURCE-GROUP-NAME"
$backupItemName = "BACKUP-ITEM-NAME" # Nome do item de backup (ex: nome da VM)

# 2. Obter o Cofre e o Item de Backup
$vault = Get-AzRecoveryServicesVault -Name $vaultName -ResourceGroupName $resourceGroupName
$item = Get-AzRecoveryServicesBackupItem -VaultId $vault.ID -BackupManagementType AzureVM -WorkloadType AzureVM -Name $backupItemName

# 3. Interromper proteção e remover dados imediatamente
Disable-AzRecoveryServicesBackupProtection -Item $item -RemoveRecoveryPoints -Force -VaultId $vault.ID

------------------------------------------------------------------------------------------------------------------------


# Excluir todos backups em Soft Delete (Purge)

Connect-AzAccount
Select-AzSubscription -SubscriptionId "SUBSCRIPTION-ID"

# Variáveis
$vaultName = "VAULT-NAME"
$resourceGroupName = "RESOURCE-GROUP-NAME"

# Obter o Vault
$vault = Get-AzRecoveryServicesVault -Name $vaultName -ResourceGroupName $resourceGroupName

# Definir contexto do Vault
Set-AzRecoveryServicesVaultContext -Vault $vault

# Buscar todos os itens de VM em Soft Delete
$items = Get-AzRecoveryServicesBackupItem `
    -BackupManagementType AzureVM `
    -WorkloadType AzureVM `
    -DeleteState ToBeDeleted

# Loop para purge definitivo
foreach ($item in $items) {

    Write-Host "Removendo definitivamente backup de:" $item.Name

    Disable-AzRecoveryServicesBackupProtection `
        -Item $item `
        -RemoveRecoveryPoints `
        -Force
}

Write-Host "Purge concluído para todos os backups em Soft Delete."