<#
.SYNOPSIS
Remove backups de VMs de um Recovery Services Vault, incluindo itens em Soft Delete.

.DESCRIPTION
Contém exemplos para interromper a proteção, remover recovery points, identificar itens em Soft Delete, executar purge e reativar o Soft Delete.

.WARNING
As operações de remoção de recovery points e purge são destrutivas e podem impedir a recuperação dos dados. Revise o vault, a subscription e os itens antes da execução.
#>

# Desabilita temporariamente o Soft Delete no ambiente.
Set-AzRecoveryServicesVaultProperty -VaultId $vault.ID -SoftDeleteFeatureState Disable

# Exclui o backup de uma VM e remove os recovery points imediatamente.
Connect-AzAccount
Select-AzSubscription -SubscriptionId "SUBSCRIPTION-ID"

# Define as variáveis do vault e do item de backup.
$vaultName = "VAULT-NAME"
$resourceGroupName = "RESOURCE-GROUP-NAME"
$backupItemName = "BACKUP-ITEM-NAME" # Nome do item de backup, por exemplo, o nome da VM.

# Obtém o Recovery Services Vault e o item de backup.
$vault = Get-AzRecoveryServicesVault -Name $vaultName -ResourceGroupName $resourceGroupName
$item = Get-AzRecoveryServicesBackupItem -VaultId $vault.ID -BackupManagementType AzureVM -WorkloadType AzureVM -Name $backupItemName

# Interrompe a proteção e remove os recovery points.
Disable-AzRecoveryServicesBackupProtection -Item $item -RemoveRecoveryPoints -Force -VaultId $vault.ID

# ============================================================================
# PURGE DE BACKUPS EM SOFT DELETE
# ============================================================================

Connect-AzAccount
Select-AzSubscription -SubscriptionId "SUBSCRIPTION-ID"

# Define as variáveis do vault.
$vaultName = "VAULT-NAME"
$resourceGroupName = "RESOURCE-GROUP-NAME"

# Obtém o vault.
$vault = Get-AzRecoveryServicesVault -Name $vaultName -ResourceGroupName $resourceGroupName

# Define o contexto do Recovery Services Vault.
Set-AzRecoveryServicesVaultContext -Vault $vault

# Busca todos os itens de VM em Soft Delete.
$items = Get-AzRecoveryServicesBackupItem `
    -BackupManagementType AzureVM `
    -WorkloadType AzureVM `
    -DeleteState ToBeDeleted

# Executa o purge definitivo dos itens encontrados.
foreach ($item in $items) {
    Write-Host "Removendo definitivamente o backup de: $($item.Name)"

    Disable-AzRecoveryServicesBackupProtection `
        -Item $item `
        -RemoveRecoveryPoints `
        -Force
}

Write-Host "Purge concluído para todos os backups em Soft Delete."

# ============================================================================
# CONSULTA DE BACKUPS
# ============================================================================

# Lista as VMs registradas no backup do vault e seus respectivos estados.
Get-AzRecoveryServicesBackupItem -BackupManagementType AzureVM -WorkloadType AzureVM |
Select-Object Name, ProtectionStatus, DeleteState, HealthStatus

# Lista somente os itens que estão em Soft Delete.
Get-AzRecoveryServicesBackupItem -BackupManagementType AzureVM -WorkloadType AzureVM |
Where-Object {$_.DeleteState -eq "ToBeDeleted"} |
Select-Object Name, ProtectionStatus, DeleteState

# Reativa o Soft Delete no ambiente, caso necessário.
Set-AzRecoveryServicesVaultProperty -VaultId $vault.ID -SoftDeleteFeatureState Enable
