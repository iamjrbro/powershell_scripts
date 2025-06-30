# Path to the CSV file
$csvPath = "C:\Path\To\computers.csv"

# Import computer names from CSV
$computers = Import-Csv -Path $csvPath | Select-Object -ExpandProperty ComputerName

# Array to store connected machines
$connectedMachines = @()

foreach ($computer in $computers) {
    Write-Host "Checking $computer..." -ForegroundColor Cyan

    try {
        # Check HIMDS service
        $himdsService = Get-Service -ComputerName $computer -Name "himds" -ErrorAction Stop
        $himdsStatus = $himdsService.Status

        # Run azcmagent show remotely and parse output
        $azcmOutput = Invoke-Command -ComputerName $computer -ScriptBlock {
            try {
                $output = azcmagent show | Out-String
                return $output
            } catch {
                Write-Error "Failed to run azcmagent: $_"
                return $null
            }
        }

        if ($azcmOutput -ne $null) {
            $statusLine = $azcmOutput -split "`n" | Where-Object { $_ -match "Agent Status\s*:\s*Connected" }

            if ($statusLine) {
                Write-Host "[$computer] HIMDS Service: $himdsStatus, Azure Arc Status: Connected" -ForegroundColor Green
                $connectedMachines += $computer
            } else {
                Write-Host "[$computer] HIMDS Service: $himdsStatus, Azure Arc Status: Not Connected" -ForegroundColor Yellow
            }
        } else {
            Write-Host "[$computer] HIMDS Service: $himdsStatus, Azure Arc Status: Unknown (command failed)" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "[$computer] Error: $_" -ForegroundColor Red
    }
}

# Output connected machines
Write-Host "`nConnected Machines:" -ForegroundColor Cyan
$connectedMachines | ForEach-Object { Write-Host $_ -ForegroundColor Green }