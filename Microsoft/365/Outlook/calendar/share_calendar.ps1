# install ps module
Install-Module ExchangeOnlineManagement -Scope CurrentUser

# connect to Exchange Online
Connect-ExchangeOnline

# conceive the wanted permission on the calendar 
Add-MailboxFolderPermission -Identity user@domain.com:\Calendar -User other.user@domain.com -AccessRights Reviewer

  > permissions: Reviewer, Editor, Owner

# check if the the permission was setted
Get-MailboxFolderPermission -Identity user@domain.com.br:\Calendar


-- if the calendar is on other language, change to the right language (if it is in Portuguese, change to Calendário)
