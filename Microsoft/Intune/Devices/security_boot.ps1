$secureBoot = Confirm-SecureBootUEFI -ErrorAction SilentlyContinue

if ($secureBoot -eq $true) {
    Write-Output "Secure Boot OK"
    exit 0
} else {
    Write-Output "Secure Boot NOT OK"
    exit 1
}