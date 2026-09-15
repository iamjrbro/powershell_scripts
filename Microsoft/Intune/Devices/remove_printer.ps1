<#
.SYNOPSIS
Remove filas de impressão associadas aos IPs informados.

.DESCRIPTION
Percorre os IPs configurados, localiza filas de impressão pela porta e remove as filas encontradas. As operações são registradas em arquivo de log.

.NOTES
Preencha $ipsParaRemover antes da execução.
#>

# Lista de IPs das impressoras cujas filas devem ser removidas.
$ipsParaRemover = @(
   # Informe os IPs das impressoras, por exemplo: "10.98.0.2"
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
