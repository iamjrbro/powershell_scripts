USANDO MODULO AZURE AD

# Instalar o módulo, se necessário
# Install-Module AzureAD -Scope CurrentUser

# Conectar ao Azure AD
Connect-AzureAD

# Obter todos os grupos
$groups = Get-AzureADGroup -All $true

# Inicializar lista de grupos vazios
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

# Exibir os grupos vazios
$emptyGroups | Format-Table -AutoSize


USANDO GRAPH

# Instalar o módulo, se necessário
# Install-Module Microsoft.Graph -Scope CurrentUser

# Conectar ao Microsoft Graph
Connect-MgGraph -Scopes "Group.Read.All"

# Obter todos os grupos
$allGroups = Get-MgGroup -All

# Inicializar lista de grupos vazios
$emptyGroups = @()

# Verificar membros de cada grupo
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

# Exibir os grupos vazios
$emptyGroups | Format-Table -AutoSize