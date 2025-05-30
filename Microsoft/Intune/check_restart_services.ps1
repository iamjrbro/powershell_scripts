# Parâmetro: nome do serviço a verificar
param (
    [string]$ServiceName = "wuauserv"  # Serviço Windows Update como exemplo
)

$service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue

if ($null -eq $service) {
    Write-Output "Serviço '$ServiceName' não encontrado."
    exit 1
}

if ($service.Status -ne "Running") {
    Write-Output "Serviço '$ServiceName' não está rodando. Tentando iniciar..."
    Start-Service -Name $ServiceName
    Start-Sleep -Seconds 5
    $service.Refresh()
    if ($service.Status -eq "Running") {
        Write-Output "Serviço '$ServiceName' iniciado com sucesso."
        exit 0
    } else {
        Write-Output "Falha ao iniciar o serviço '$ServiceName'."
        exit 1
    }
} else {
    Write-Output "Serviço '$ServiceName' está rodando normalmente."
    exit 0
}
