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