# Auditoria de e-mails excluídos no Exchange Online.
#
# Consulta, em modo somente leitura:
# - configurações de retenção e recuperação da mailbox;
# - estatísticas da pasta Recoverable Items;
# - regras da Caixa de Entrada;
# - registros de auditoria relacionados a SoftDelete e HardDelete.
#
# O script não realiza alterações na mailbox ou no ambiente.
#
# Requisitos:
# - ExchangeOnlineManagement
# - Permissões compatíveis com as cmdlets utilizadas e com a consulta do Unified Audit Log.

Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber

Connect-ExchangeOnline

# UPN da mailbox que será auditada.
$UserMailbox = "USER_UPN"

Get-EXOMailbox -Identity $UserMailbox |
    Select-Object DisplayName,
                  PrimarySmtpAddress,
                  SingleItemRecoveryEnabled,
                  RetainDeletedItemsFor,
                  LitigationHoldEnabled

# Consulta as pastas de recuperação e a quantidade de itens armazenados.
Get-EXOMailboxFolderStatistics `
    -Identity $UserMailbox `
    -FolderScope RecoverableItems |
    Select-Object Name,
                  FolderPath,
                  ItemsInFolder,
                  FolderAndSubfolderSize

# Consulta as regras configuradas na Caixa de Entrada.
Get-InboxRule -Mailbox $UserMailbox |
    Select-Object Name,
                  Enabled,
                  Priority,
                  Description

# Consulta eventos de exclusão registrados no Unified Audit Log.
Search-UnifiedAuditLog `
    -StartDate "2026-09-01" `
    -EndDate "2026-09-18" `
    -UserIds $UserMailbox `
    -Operations SoftDelete,HardDelete `
    -ResultSize 100 |
    Select-Object CreationDate,UserIds,Operations,AuditData
