<#
.SYNOPSIS
Inventaria atribuições de funções administrativas do Microsoft Entra ID.

.DESCRIPTION
Consulta definições de funções e atribuições no Microsoft Graph e identifica o tipo de principal associado, como usuário, grupo, service principal ou dispositivo.

.PREREQUISITES
Requer Microsoft Graph PowerShell SDK e permissões RoleManagement.Read.Directory e Directory.Read.All.
#>

# Instala o Microsoft.Graph caso ainda não esteja disponível.
Install-Module Microsoft.Graph -Scope CurrentUser -Force

# Importa os módulos necessários.
Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Identity.Governance
Import-Module Microsoft.Graph.Users
Import-Module Microsoft.Graph.Groups
Import-Module Microsoft.Graph.Applications
Import-Module Microsoft.Graph.Identity.DirectoryManagement

# Conecta ao Microsoft Graph.
Connect-MgGraph -Scopes "RoleManagement.Read.Directory","Directory.Read.All"

# Obtém as definições de funções e as respectivas atribuições.
$roles = Get-MgRoleManagementDirectoryRoleDefinition -All
$roleAssignments = Get-MgRoleManagementDirectoryRoleAssignment -All

$result = foreach ($assignment in $roleAssignments) {

    $role = $roles | Where-Object { $_.Id -eq $assignment.RoleDefinitionId }

    $name = $null
    $type = "Unknown"
    $upn = "-"

    # Tenta identificar o principal como usuário.
    try {
        $obj = Get-MgUser -UserId $assignment.PrincipalId -ErrorAction Stop
        $name = $obj.DisplayName
        $upn = $obj.UserPrincipalName
        $type = "User"
    }
    catch {

        # Se não for usuário, tenta identificar como grupo.
        try {
            $obj = Get-MgGroup -GroupId $assignment.PrincipalId -ErrorAction Stop
            $name = $obj.DisplayName
            $type = "Group"
        }
        catch {

            # Se não for grupo, tenta identificar como service principal.
            try {
                $obj = Get-MgServicePrincipal -ServicePrincipalId $assignment.PrincipalId -ErrorAction Stop
                $name = $obj.DisplayName
                $type = "Service Principal"
            }
            catch {

                # Se não for service principal, tenta identificar como dispositivo.
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

# Exibe o resultado ordenado por função e principal.
$result |
    Sort-Object RoleName, PrincipalName |
    Format-Table RoleName, PrincipalName, PrincipalType, UserPrincipalName, Scope -AutoSize
