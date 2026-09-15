<#!
.SYNOPSIS
Remove todos os perfis Wi-Fi configurados no computador.

.DESCRIPTION
Consulta os perfis Wi-Fi usando netsh, extrai os nomes de forma independente
do idioma do Windows e remove cada perfil encontrado.

.NOTES
A operação é destrutiva. Use apenas quando a remoção de todos os perfis for
intencional, por exemplo durante uma rotina de reprovisionamento do dispositivo.
#>

$profilesOutput = netsh wlan show profiles 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "Não foi possível consultar os perfis Wi-Fi."
    exit 1
}

# O nome do perfil aparece após o primeiro caractere ':' na saída do netsh.
# O filtro usa as linhas que contêm um separador ':' e ignora o cabeçalho do comando.
$profiles = foreach ($line in $profilesOutput) {
    if ($line -match '^\s*[^:]+\s*:\s*(.+?)\s*$') {
        $name = $Matches[1].Trim()
        if ($name -and $name -notmatch '^(Perfil|Profiles?)\s*$') {
            $name
        }
    }
}

if (-not $profiles) {
    Write-Output "Nenhum perfil Wi-Fi encontrado."
    exit 0
}

$failed = $false

foreach ($profileName in ($profiles | Select-Object -Unique)) {
    Write-Output "Removendo perfil Wi-Fi: $profileName"
    netsh wlan delete profile name="$profileName"

    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Falha ao remover o perfil Wi-Fi: $profileName"
        $failed = $true
    }
}

if ($failed) {
    Write-Error "Um ou mais perfis Wi-Fi não puderam ser removidos."
    exit 1
}

Write-Output "Todos os perfis Wi-Fi encontrados foram removidos."
exit 0
