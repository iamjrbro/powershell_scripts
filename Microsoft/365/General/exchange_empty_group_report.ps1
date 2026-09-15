
# Installing ExchangeOnlineManagement
Install-Module -Name ExchangeOnlineManagement -Scope AllUsers -Force -AllowClobber

# Charging ExchangeOnlineManagement's module
Import-Module ExchangeOnlineManagement

# Getting user's credencials 
$UserCredential = Get-Credential

# Connecting to Microsoft 365 with provided credentials 
Connect-ExchangeOnline -UserPrincipalName $UserCredential.UserName -Credential $UserCredential

# Getting a list of all user's mailboxes 
Get-Mailbox

# Disconnecting Microsoft 365's session
Disconnect-ExchangeOnline -Confirm:$false













# Verificar se o módulo AzureAD está instalado e instalar se necessário
if (-not (Get-Module -ListAvailable -Name Azure)) {
    Install-Module -Name AzureAD -Scope CurrentUser -Force -AllowClobber
}

# Carregar o módulo AzureAD
Import-Module AzureAD

# Solicitar as credenciais do usuário
$UserCredential = Get-Credential

# Conectar-se ao AzureAD com as credenciais fornecidas
Connect-AzureAD -Credential $UserCredential

# Obter a lista de todos os grupos
$groups = Get-AzureADGroup -All $true

# Criar uma lista para armazenar os grupos sem membros
$emptyGroups = @()

# Verificar cada grupo para membros
foreach ($group in $groups) {
    $members = Get-AzureADGroupMember -ObjectId $group.ObjectId -All $true -ErrorAction SilentlyContinue
    if (-not $members) {
        $emptyGroups += [PSCustomObject]@{
            DisplayName = $group.DisplayName
            ObjectId    = $group.ObjectId
        }
    }
}

# Exportar a lista de grupos sem membros para um arquivo CSV
$emptyGroups | Export-Csv -Path "C:\Caminho\Para\Seu\Arquivo\EmptyGroups.csv" -NoTypeInformation -Encoding UTF8
