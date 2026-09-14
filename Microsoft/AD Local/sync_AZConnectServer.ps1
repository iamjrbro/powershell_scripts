<#
.SYNOPSIS
Executa ciclos de sincronização do Microsoft Entra Connect Sync.

.DESCRIPTION
Importa o módulo ADSync e inicia um ciclo Initial seguido de um ciclo Delta, útil para testes e troubleshooting de sincronização.

.NOTES
Execute no servidor que possui o Microsoft Entra Connect Sync instalado.
#>

# Importa o módulo de gerenciamento do Entra Connect Sync.
Import-Module ADSync

# Inicia uma sincronização Initial, útil para testes e troubleshooting.
Start-ADSyncSyncCycle -PolicyType Initial

# Inicia uma sincronização Delta, útil para testes e troubleshooting.
Start-ADSyncSyncCycle Delta
