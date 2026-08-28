#Primeiro, instale os módulos necessários no ambiente administrativo.

Install-Module Microsoft.Graph -Scope AllUsers -Force
Install-Module Microsoft.Online.SharePoint.PowerShell -Scope AllUsers -Force
Em seguida, conecte-se ao Microsoft Graph e ao SharePoint Online.

Connect-MgGraph -Scopes "User.Read.All","Directory.Read.All"
Connect-SPOService -Url https://seutenant-admin.sharepoint.com

#Defina as variáveis do usuário desligado e do gestor que receberá acesso ao OneDrive.

$UsuarioDesligado = "usuario@dominio.com"
$Gestor = "gestor@dominio.com"

#Agora, recupere o OneDrive do usuário desligado. O OneDrive é um site pessoal do SharePoint Online.

$OneDriveUrl = (Get-SPOSite -IncludePersonalSite $true -Limit All | Where-Object { $_.Owner -eq $UsuarioDesligado }).Url
Conceda permissão de administrador do site ao gestor.

Set-SPOUser -Site $OneDriveUrl -LoginName $Gestor -IsSiteCollectionAdmin $true