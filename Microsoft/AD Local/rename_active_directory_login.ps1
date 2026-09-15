# altere o nome do user no AD local | não executar o PS como admin

Install-Module Microsoft.Graph -Scope CurrentUser
Connect-MgGraph -Scopes "User.ReadWrite.All"
Update-MgUser -UserId user.upn@domain.com -UserPrincipalName user.upn@domain.com