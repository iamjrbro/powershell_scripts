# Lista de IPs das impressoras a remover
$ipsParaRemover = @(
    "coloque o ip das impressoras entre parenteses"
)

$logPath = "$env:ProgramData\IntuneLogs\RemocaoImpressoras.log"
if (!(Test-Path (Split-Path $logPath))) {
    New-Item -ItemType Directory -Path (Split-Path $logPath) -Force
}

function Write-Log {
    param([string]$mensagem)
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Add-Content -Path $logPath -Value "$timestamp - $mensagem"
}

foreach ($ip in $ipsParaRemover) {
    $filas = Get-Printer | Where-Object { $_.PortName -like "*$ip*" }
    foreach ($fila in $filas) {
        try {
            Remove-Printer -Name $fila.Name -ErrorAction Stop
            Write-Log "Removida: $($fila.Name)"
        } catch {
            Write-Log "Erro ao remover $($fila.Name): $_"
        }
    }
}
