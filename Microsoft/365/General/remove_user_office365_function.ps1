THIS CODE RUNS ON A FUNTION APP AND IT REQUIRES THE FOLLOWING PERMISSIONS TO WORK:
  - Group.Read.All
  - User.Read.All
  - GroupMember.ReadWrite.All 


# Input bindings are passed in via param block.
param($Timer)
 
# Get the current universal time in the default string format.
$currentUTCtime = (Get-Date).ToUniversalTime()
 
# The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}
 
# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"
 
# Pega grupos e user desativados
$groups = Get-AzADGroup
$disabledUsers = Get-AzADUser -Filter "accountEnabled eq false" | Select-Object Id #Pega ID
 
# Filtragem dos grupos exceção
$excludedGroups = @("Domain Users", "Licenca_Office_365_Desabilitados", "Todos os Usuários (Desativados e Ativos)")
$excludedGroupIds = $groups | Where-Object { $excludedGroups -contains $_.DisplayName } | Select-Object -ExpandProperty Id #Pega ID
 
# Se isso funcionar é graças ao GPT (Pegar os user de cada grupo e armazena )
$groupMembers = @{}
foreach ($group in $groups) {
    if ($excludedGroupIds -contains $group.Id) { continue }
 
    $groupMembers[$group.Id] = Get-AzADGroupMember -GroupObjectId $group.Id | Select-Object Id #Pega ID
}
 
$groupMembership = @{} # Guarda os grupos dos user desativados
 
# verificar os user desativados de cada grp
foreach ($user in $disabledUsers) {
    foreach ($group in $groups) {
        if ($excludedGroupIds -contains $group.Id) { continue }
 
        # Verificar se o user ta no grupo
        $isMember = $groupMembers[$group.Id] | Where-Object { $_.Id -eq $user.Id }
        if ($isMember) {
            if (-not $groupMembership[$user.Id]) {
                $groupMembership[$user.Id] = @()
            }
            $groupMembership[$user.Id] += $group.Id
        }
    }
}
 
# excloi
foreach ($user in $groupMembership.Keys) {
    foreach ($groupId in $groupMembership[$user]) {
        Remove-AzADGroupMember -GroupObjectId $groupId -MemberObjectId $user
    }
}
