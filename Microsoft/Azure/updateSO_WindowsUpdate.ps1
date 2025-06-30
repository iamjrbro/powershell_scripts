# Executar com privilégios de administrador
Write-Host "Iniciando verificação e instalação de atualizações do sistema operacional..." -ForegroundColor Cyan

# Habilitar script policy (se necessário)
Set-ExecutionPolicy RemoteSigned -Scope Process -Force

# Importar módulo Windows Update (se não instalado)
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Install-Module -Name PSWindowsUpdate -Force
}

# Importar o módulo
Import-Module PSWindowsUpdate

# Mostrar atualizações disponíveis
Write-Host "Verificando atualizações disponíveis..." -ForegroundColor Yellow
Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot

# Forçar instalação de todas as atualizações pendentes
Write-Host "Iniciando instalação das atualizações..." -ForegroundColor Green
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot -AutoReboot

# Após reboot, confirmar versão
Start-Sleep -Seconds 5
$version = (Get-ComputerInfo).WindowsVersion
Write-Host "Versão atual do Windows: $version" -ForegroundColor Cyan

