param (
    [string]$SoftwareDisplayName = "Google Chrome"
)

$installed = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" , "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" `
    | Where-Object { $_.DisplayName -like "*$SoftwareDisplayName*" }

if ($installed) {
    Write-Output "Software '$SoftwareDisplayName' está instalado."
    exit 0
} else {
    Write-Output "Software '$SoftwareDisplayName' NÃO está instalado."
    exit 1
}
