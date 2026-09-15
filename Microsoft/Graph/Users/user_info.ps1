Connect-MgGraph -Scopes "User.ReadWrite.All"

$UserId = (Get-MgUser -UserPrincipalName "usuario@dominio.com").Id

Update-MgUser -UserId $UserId -AdditionalProperties @{

  "extension_<AppClientID>_sponsorid1" = "ValorPersonalizado123"

}