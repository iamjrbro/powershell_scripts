# Requer o módulo Az e permissão para listar recursos do Azure Arc
# Instale se necessário: Install-Module Az -Scope CurrentUser

# Login na conta Azure
Connect-AzAccount

# Parâmetros de auditoria
$resourceGroup = "<NOME_DO_RESOURCE_GROUP>"
$versaoEsperada = "26100"  # Versão mínima esperada do SO (ex: 26100 para 24H2)

# Obter todas as máquinas habilitadas para Azure Arc
$arcVMs = Get-AzConnectedMachine -ResourceGroupName $resourceGroup

# Inicializar relatório
$resultados = @()

foreach ($vm in $arcVMs) {
    $status = Get-AzConnectedMachineExtension -ResourceGroupName $vm.ResourceGroupName `
              -MachineName $vm.Name -Name "GuestConfiguration" -ErrorAction SilentlyContinue

    $osVersion = $vm.OSVersion

    # Comparação com a versão esperada
    $compliant = if ($osVersion -like "$versaoEsperada*") { "OK" } else { "Desatualizado" }

    $resultados += [PSCustomObject]@{
        Nome           = $vm.Name
        SistemaOperacional = $vm.OSName
        Versao         = $osVersion
        Compliance     = $compliant
    }
}

# Exibir resultado no console
$resultados | Format-Table -AutoSize

# Exportar para CSV
$resultados | Export-Csv -Path ".\\Relatorio_SO_AzureArc.csv" -NoTypeInformation -Encoding UTF8

Write-Host "`nRelatório gerado: Relatorio_SO_AzureArc.csv"