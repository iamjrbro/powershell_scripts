$profiles = netsh wlan show profiles | Select-String "Perfil todos os usuários"

foreach ($profile in $profiles) {
    $profileName = $profile.ToString().Split(":")[1].Trim()
    Write-Output "Removendo perfil Wi-Fi: $profileName"
    netsh wlan delete profile name="$profileName"
}

Write-Output "Perfis Wi-Fi removidos."
exit 0
