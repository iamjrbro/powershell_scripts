 
# INVESTIGAÇÃO DE E-MAILS DESAPARECIDOS - EXCHANGE ONLINE
 
Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber

Connect-ExchangeOnline 

# teste de mailbox 
$UserMailbox = "USER_UPN"

Get-EXOMailbox -Identity $UserMailbox |
    Select-Object DisplayName,
                  PrimarySmtpAddress,
                  SingleItemRecoveryEnabled,
                  RetainDeletedItemsFor,
                  LitigationHoldEnabled

                  # checar recoverable itens
Get-EXOMailboxFolderStatistics `
    -Identity $UserMailbox `
    -FolderScope RecoverableItems |
    Select-Object Name,
                  FolderPath,
                  ItemsInFolder,
                  FolderAndSubfolderSize

# verificar se há regras

Get-InboxRule -Mailbox $UserMailbox |
    Select-Object Name,
                  Enabled,
                  Priority,
                  Description

# audit da mailbox para verificar se houve deleção de e-mails

Search-UnifiedAuditLog `
    -StartDate "2026-09-01" `
    -EndDate "2026-09-18" `
    -UserIds $UserMailbox `
    -Operations SoftDelete,HardDelete `
    -ResultSize 100 |
    Select-Object CreationDate,UserIds,Operations,AuditData