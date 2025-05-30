$drive = "C:"
$minFreeGB = 10

$freeSpaceGB = (Get-PSDrive $drive).Free / 1GB

if ($freeSpaceGB -lt $minFreeGB) {
    Write-Output "Espaço em disco insuficiente: $([math]::Round($freeSpaceGB,2)) GB livre em $drive"
    exit 1
} else {
    Write-Output "Espaço em disco OK: $([math]::Round($freeSpaceGB,2)) GB livre em $drive"
    exit 0
}
