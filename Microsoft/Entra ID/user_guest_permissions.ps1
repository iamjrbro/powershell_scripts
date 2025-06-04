# O modulo AZ Account deve estar atualizado https://www.powershellgallery.com/packages/Az.Accounts/5.0.1
# O modulo AZ Resources https://www.powershellgallery.com/packages/Az

# Conecte-se ao Azure AD (isso conecta apenas ao tenant, não à assinatura do Azure)
Connect-AzureAD

Get-AzureADUser -All $true | Where-Object { $_.UserType -eq "Guest" } | Select DisplayName, UserPrincipalName

# Conectar ao Microsoft Graph
Connect-MgGraph -Scopes "RoleManagement.Read.Directory", "Directory.Read.All", "User.Read.All"

# Obter todos os usuários Guest
$guests = Get-MgUser -Filter "UserType eq 'Guest'" -All

# Obter todas as roles e seus membros
$roleAssignments = Get-MgDirectoryRole | ForEach-Object {
    $role = $_
    Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id | ForEach-Object {
        [PSCustomObject]@{
            RoleName = $role.DisplayName
            UserId   = $_.Id
        }
    }
}

# Associar usuários Guest às roles
$results = foreach ($guest in $guests) {
    $roles = $roleAssignments | Where-Object { $_.UserId -eq $guest.Id }
    if ($roles) {
        [PSCustomObject]@{
            DisplayName       = $guest.DisplayName
            UserPrincipalName = $guest.UserPrincipalName
            Roles             = ($roles.RoleName -join ', ')
        }
    }
}


# Verificar role assignments de cada Guest
$guestsWithRBAC = foreach ($guest in $guests) {
    $roles = Get-AzRoleAssignment -ObjectId $guest.Id -ErrorAction SilentlyContinue
    if ($roles) {
        [PSCustomObject]@{
            DisplayName       = $guest.DisplayName
            UserPrincipalName = $guest.UserPrincipalName
            RBACRoles         = ($roles.RoleDefinitionName -join ', ')
            Scope             = ($roles.Scope -join ', ')
        }
    }
}

# Verificar se Guest pertence a grupos com permissões
foreach ($guest in $guests) {
    $groups = Get-MgUserMemberOf -UserId $guest.Id
    foreach ($group in $groups) {
        # Aqui você pode verificar se o grupo tem role assignment, se necessário
    }
}

# Para cada Guest, verificar AppRoleAssignments (atribuições de acesso a apps)
$guestsWithApps = foreach ($guest in $guests) {
    $assignments = Get-MgUserAppRoleAssignment -UserId $guest.Id -ErrorAction SilentlyContinue
    if ($assignments) {
        foreach ($assignment in $assignments) {
            $app = Get-MgServicePrincipal -ServicePrincipalId $assignment.ResourceId
            [PSCustomObject]@{
                DisplayName       = $guest.DisplayName
                UserPrincipalName = $guest.UserPrincipalName
                AppName           = $app.DisplayName
                AppRoleId         = $assignment.AppRoleId
            }
        }
    }
}


# Verifica se existem resultados antes de exportar
if ($results) {
    $filePath = "$env:USERPROFILE\Downloads\GuestsWithRoles.csv"
    $results | Export-Csv -Path $filePath -NoTypeInformation -Encoding UTF8
    Write-Host "Arquivo CSV exportado para: $filePath"
} else {
    Write-Host "Nenhum usuário Guest com roles foi encontrado."
}
