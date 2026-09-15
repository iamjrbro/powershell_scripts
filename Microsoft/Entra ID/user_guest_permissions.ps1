<#
.SYNOPSIS
Audita permissões de usuários Guest no Microsoft Entra ID.

.DESCRIPTION
Consulta usuários Guest, funções administrativas, atribuições RBAC e App Role Assignments para identificar acessos privilegiados ou delegados. Exporta os resultados de funções administrativas para CSV.

.PREREQUISITES
Requer módulos AzureAD, Microsoft.Graph e Az, além das permissões necessárias para leitura de diretório, funções e recursos Azure.
#>

# Os módulos Az.Accounts e Az.Resources devem estar atualizados para as consultas de RBAC.
# Conecta ao Microsoft Entra ID usando o módulo AzureAD.
Connect-AzureAD

# Lista os usuários Guest do tenant.
Get-AzureADUser -All $true | Where-Object { $_.UserType -eq "Guest" } | Select DisplayName, UserPrincipalName

# Conecta ao Microsoft Graph para consultar funções e membros.
Connect-MgGraph -Scopes "RoleManagement.Read.Directory", "Directory.Read.All", "User.Read.All"

# Obtém todos os usuários Guest.
$guests = Get-MgUser -Filter "UserType eq 'Guest'" -All

# Obtém as funções administrativas e seus membros.
$roleAssignments = Get-MgDirectoryRole | ForEach-Object {
    $role = $_
    Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id | ForEach-Object {
        [PSCustomObject]@{
            RoleName = $role.DisplayName
            UserId = $_.Id
        }
    }
}

# Associa usuários Guest às funções administrativas encontradas.
$results = foreach ($guest in $guests) {
    $roles = $roleAssignments | Where-Object { $_.UserId -eq $guest.Id }
    if ($roles) {
        [PSCustomObject]@{
            DisplayName = $guest.DisplayName
            UserPrincipalName = $guest.UserPrincipalName
            Roles = ($roles.RoleName -join ', ')
        }
    }
}

# Verifica atribuições RBAC de cada usuário Guest no Azure.
$guestsWithRBAC = foreach ($guest in $guests) {
    $roles = Get-AzRoleAssignment -ObjectId $guest.Id -ErrorAction SilentlyContinue
    if ($roles) {
        [PSCustomObject]@{
            DisplayName = $guest.DisplayName
            UserPrincipalName = $guest.UserPrincipalName
            RBACRoles = ($roles.RoleDefinitionName -join ', ')
            Scope = ($roles.Scope -join ', ')
        }
    }
}

# Verifica se o Guest pertence a grupos com possíveis permissões.
foreach ($guest in $guests) {
    $groups = Get-MgUserMemberOf -UserId $guest.Id
    foreach ($group in $groups) {
        # Adicione aqui verificações específicas de permissões de grupos, se necessário.
    }
}

# Consulta App Role Assignments dos usuários Guest.
$guestsWithApps = foreach ($guest in $guests) {
    $assignments = Get-MgUserAppRoleAssignment -UserId $guest.Id -ErrorAction SilentlyContinue
    if ($assignments) {
        foreach ($assignment in $assignments) {
            $app = Get-MgServicePrincipal -ServicePrincipalId $assignment.ResourceId
            [PSCustomObject]@{
                DisplayName = $guest.DisplayName
                UserPrincipalName = $guest.UserPrincipalName
                AppName = $app.DisplayName
                AppRoleId = $assignment.AppRoleId
            }
        }
    }
}

# Exporta o relatório caso existam usuários Guest com funções administrativas.
if ($results) {
    $filePath = "$env:USERPROFILE\Downloads\GuestsWithRoles.csv"
    $results | Export-Csv -Path $filePath -NoTypeInformation -Encoding UTF8
    Write-Host "Arquivo CSV exportado para: $filePath"
} else {
    Write-Host "Nenhum usuário Guest com roles foi encontrado."
}
