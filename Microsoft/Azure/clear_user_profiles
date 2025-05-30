#sets the variable with the number of days of inactivity (30 days in this example)
$daysInactive = 30

#gets the current date minus the number of days of inactivity
$cutoffDate = (Get-Date).AddDays(-$daysInactive)

#gets the user profiles by deleting them from the system
$profiles = Get-CimInstance -ClassName Win32_UserProfile | Where-Object {
    $_.Special -eq $false -and $_.LastUseTime -lt $cutoffDate
}

#removes inactive user profiles
foreach ($profile in $profiles) {
    try {
        Remove-WmiObject -InputObject $profile
        Write-Host "Perfil removido: $($profile.LocalPath)" -ForegroundColor Green
    } catch {
        Write-Host "Erro ao remover o perfil: $($profile.LocalPath)" -ForegroundColor Red
    }
}


--Save the above script to a .ps1 file (e.g., CleanProfiles.ps1)

Schedule execution via Task Scheduler:
- press Win+R, type taskschd.msc, and press Enter to open Task Scheduler
- in the right pane, click Create Task

Basic task settings:
- on the General tab, give the task a name, such as "Cleaning User Profiles"
- check the Run with higher privileges option

Setting a Trigger:
- go to the Triggers tab and click New

Set to run Daily at the time you wish it to run:
- go to the Actions tab and click New.
- choose "Start a program"
- under Program/Script, look for powershell.exe
- under "Add arguments", enter the following argument:

-ExecutionPolicy Bypass -File "C:\scripts\CleanProfiles.ps1"
