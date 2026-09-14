<#
.SYNOPSIS
Concede permissões de acesso ao calendário de uma caixa de correio no Exchange Online.

.DESCRIPTION
Instala o módulo ExchangeOnlineManagement, conecta ao Exchange Online, adiciona a permissão informada ao calendário e consulta a configuração resultante.

.NOTES
AccessRights possíveis incluem Reviewer, Editor e Owner. Ajuste o nome da pasta conforme o idioma da mailbox.
#>

# Instala o módulo ExchangeOnlineManagement, caso necessário.
Install-Module ExchangeOnlineManagement -Scope CurrentUser

# Conecta ao Exchange Online.
Connect-ExchangeOnline

# Concede a permissão desejada ao calendário.
Add-MailboxFolderPermission -Identity user@domain.com:\Calendar -User other.user@domain.com -AccessRights Reviewer

# Consulta as permissões atuais do calendário.
Get-MailboxFolderPermission -Identity user@domain.com.br:\Calendar

# Se a pasta do calendário estiver em outro idioma, utilize o nome correspondente.
# Exemplo para português: Calendário.
