<#
.SYNOPSIS
Remove perfis locais de usuários que estão inativos há mais de 30 dias.

.DESCRIPTION
Identifica perfis locais não especiais cujo último uso ocorreu antes da data de corte e remove esses perfis. O arquivo também documenta como agendar a execução pelo Task Scheduler.

.WARNING
A remoção de perfis locais é destrutiva. Valide o período de inatividade e os perfis encontrados antes de automatizar a execução.
#>

# Define o período de inatividade em dias.
$daysInactive = 30

# Calcula a data de corte com base no período de inatividade.
$cutoffDate = (Get-Date).AddDays(-$daysInactive)

# Obtém perfis de usuário não especiais que não são utilizados desde a data de corte.
$profiles = Get-CimInstance -ClassName Win32_UserProfile | Where-Object {
    $_.Special -eq $false -and $_.LastUseTime -lt $cutoffDate
}

# Remove os perfis inativos encontrados.
foreach ($profile in $profiles) {
    try {
        Remove-WmiObject -InputObject $profile
        Write-Host "Perfil removido: $($profile.LocalPath)" -ForegroundColor Green
    } catch {
        Write-Host "Erro ao remover o perfil: $($profile.LocalPath)" -ForegroundColor Red
    }
}

# ============================================================================
# AGENDAMENTO PELO TASK SCHEDULER
# ============================================================================
# Salve o script em um arquivo .ps1, por exemplo: CleanProfiles.ps1.
# Para agendar a execução:
# 1. Pressione Win+R, digite taskschd.msc e pressione Enter.
# 2. No painel direito, selecione Create Task.
# 3. Na aba General, informe um nome e habilite Run with highest privileges.
# 4. Na aba Triggers, crie um gatilho diário no horário desejado.
# 5. Na aba Actions, selecione Start a program e informe powershell.exe.
# 6. Em Add arguments, utilize:
#    -ExecutionPolicy Bypass -File "C:\scripts\CleanProfiles.ps1"
