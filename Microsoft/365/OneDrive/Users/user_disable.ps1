<#
.SYNOPSIS
Concede acesso administrativo ao OneDrive de um usuário desligado.

.DESCRIPTION
Conecta ao Microsoft Graph e ao SharePoint Online, localiza o OneDrive do usuário informado e concede ao gestor acesso como administrador da coleção de sites.

.NOTES
Substitua os valores de usuário, gestor e tenant pelos dados do ambiente antes da execução. A concessão de Site Collection Administrator deve ser utilizada conforme a política de acesso da organização.
#>

# Instala os módulos necessários no ambiente administrativo.
Install-Module Microsoft.Graph -Scope AllUsers -Force
Install-Module Microsoft.Online.SharePoint.PowerShell -Scope AllUsers -Force

# Conecta ao Microsoft Graph e ao SharePoint Online.
Connect-MgGraph -Scopes "User.Read.All","Directory.Read.All"
Connect-SPOService -Url https://seutenant-admin.sharepoint.com

# Define o usuário desligado e o gestor que receberá acesso ao OneDrive.
$UsuarioDesligado = "usuario@dominio.com"
$Gestor = "gestor@dominio.com"

# Localiza o OneDrive do usuário desligado.
# O OneDrive é um site pessoal do SharePoint Online.
$OneDriveUrl = (Get-SPOSite -IncludePersonalSite $true -Limit All | Where-Object { $_.Owner -eq $UsuarioDesligado }).Url

# Concede ao gestor permissão de administrador da coleção de sites do OneDrive.
Set-SPOUser -Site $OneDriveUrl -LoginName $Gestor -IsSiteCollectionAdmin $true
