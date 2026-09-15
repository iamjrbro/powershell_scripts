<#
.SYNOPSIS
Identifica grupos sem membros usando AzureAD ou Microsoft Graph.

.DESCRIPTION
Apresenta duas abordagens equivalentes para localizar grupos vazios: uma utilizando o módulo AzureAD e outra utilizando Microsoft Graph.

.NOTES
O módulo AzureAD é legado. Para novos desenvolvimentos, prefira Microsoft Graph.
#>

# ============================================================================
# ABORDAGEM COM AZUREAD
# ============================================================================

# Instala o módulo, se necessário.
# Install-Module AzureAD -Scope CurrentUser

# Conecta ao Azure AD.
Connect-AzureAD

# Obtém todos os grupos.
$groups = Get-AzureADGroup -All $true

# Inicializa a lista de grupos vazios.
$emptyGroups = @()

foreach ($group in $groups) {
    $members = Get-AzureADGroupMember -ObjectId $group.ObjectId -All $true
    if (!$members) {
        $emptyGroups += [PSCustomObject]@{
            DisplayName = $group.DisplayName
            ObjectId    = $group.ObjectId
            Mail        = $group.Mail
        }
    }
}

# Exibe os grupos vazios.
$emptyGroups | Format-Table -AutoSize

# ============================================================================
# ABORDAGEM COM MICROSOFT GRAPH
# ============================================================================

# Instala o módulo, se necessário.
# Install-Module Microsoft.Graph -Scope CurrentUser

# Conecta ao Microsoft Graph.
Connect-MgGraph -Scopes "Group.Read.All"

# Obtém todos os grupos.
$allGroups = Get-MgGroup -All

# Inicializa a lista de grupos vazios.
$emptyGroups = @()

# Verifica os membros de cada grupo.
foreach ($group in $allGroups) {
    $members = Get-MgGroupMember -GroupId $group.Id -ErrorAction SilentlyContinue
    if (!$members) {
        $emptyGroups += [PSCustomObject]@{
            DisplayName = $group.DisplayName
            Id          = $group.Id
            Mail        = $group.Mail
            GroupType   = $group.GroupTypes -join ', '
        }
    }
}

# Exibe os grupos vazios.
$emptyGroups | Format-Table -AutoSize
