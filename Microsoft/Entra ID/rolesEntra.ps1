# Instalar o módulo (caso ainda não tenha)
Install-Module Microsoft.Graph -Scope CurrentUser -Force

# Importar os módulos necessários
Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Identity.Governance
Import-Module Microsoft.Graph.Users
Import-Module Microsoft.Graph.Groups
Import-Module Microsoft.Graph.Applications
Import-Module Microsoft.Graph.Identity.DirectoryManagement

# Conectar ao Microsoft Graph
Connect-MgGraph -Scopes "RoleManagement.Read.Directory","Directory.Read.All"

# Buscar definições de funções e atribuições
$roles = Get-MgRoleManagementDirectoryRoleDefinition -All
$roleAssignments = Get-MgRoleManagementDirectoryRoleAssignment -All

$result = foreach ($assignment in $roleAssignments) {

    $role = $roles | Where-Object { $_.Id -eq $assignment.RoleDefinitionId }

    $name = $null
    $type = "Unknown"
    $upn = "-"

    # Usuário
    try {
        $obj = Get-MgUser -UserId $assignment.PrincipalId -ErrorAction Stop
        $name = $obj.DisplayName
        $upn = $obj.UserPrincipalName
        $type = "User"
    }
    catch {

        # Grupo
        try {
            $obj = Get-MgGroup -GroupId $assignment.PrincipalId -ErrorAction Stop
            $name = $obj.DisplayName
            $type = "Group"
        }
        catch {

            # Service Principal
            try {
                $obj = Get-MgServicePrincipal -ServicePrincipalId $assignment.PrincipalId -ErrorAction Stop
                $name = $obj.DisplayName
                $type = "Service Principal"
            }
            catch {

                # Device
                try {
                    $obj = Get-MgDevice -DeviceId $assignment.PrincipalId -ErrorAction Stop
                    $name = $obj.DisplayName
                    $type = "Device"
                }
                catch {
                    $name = "Objeto não encontrado"
                }
            }
        }
    }

    [PSCustomObject]@{
        RoleName          = $role.DisplayName
        PrincipalName     = $name
        PrincipalType     = $type
        UserPrincipalName = $upn
        Scope             = if ($assignment.DirectoryScopeId -eq "/") { "Tenant" } else { $assignment.DirectoryScopeId }
    }
}

$result |
    Sort-Object RoleName, PrincipalName |
    Format-Table RoleName, PrincipalName, PrincipalType, UserPrincipalName, Scope -AutoSize