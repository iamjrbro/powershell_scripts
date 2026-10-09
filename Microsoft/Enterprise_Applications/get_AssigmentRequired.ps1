#Requires -Version 5.1

<#
.SYNOPSIS
    Lista Enterprise Applications que NÃO exigem assignment
    e exporta os resultados para um arquivo Excel (.xlsx).

.DESCRIPTION
    Conecta ao Microsoft Graph, consulta todos os Service Principals
    (Enterprise Applications), identifica aqueles com
    appRoleAssignmentRequired = false e gera um Excel usando
    Excel COM.

.NOTES
    Requer:
      - PowerShell 5.1+
      - Microsoft Graph PowerShell
      - Microsoft Excel instalado
#>

# INSTALAÇÃO DO MÓDULO

Install-Module Microsoft.Graph -Scope AllUsers -Repository PSGallery -Force

#Requires -Version 5.1

<#
.SYNOPSIS
    Exporta todas as Enterprise Applications com
    Assignment Required = No para Excel.

.DESCRIPTION
    - Microsoft Graph PowerShell
    - Autenticação interativa via navegador
    - WAM desabilitado
    - Não utiliza Device Code
    - Busca todos os Service Principals
    - Filtra appRoleAssignmentRequired = false
    - Gera XLSX através do Excel COM
    - Não utiliza ImportExcel
    - Mantém a janela aberta em caso de erro

.REQUIREMENTS
    - PowerShell 5.1+
    - Microsoft Graph PowerShell
    - Microsoft Excel instalado
    - Permissão Microsoft Graph:
        Application.Read.All
#>


# ============================================================
# CONFIGURAÇÕES
# ============================================================

$OutputPath = Join-Path `
    $env:USERPROFILE `
    "Desktop\EnterpriseApps_AssignmentRequired_No.xlsx"


# ============================================================
# FUNÇÃO PARA PAUSAR O SCRIPT
# ============================================================

function Pause-Script {

    Write-Host ""
    Write-Host "Pressione ENTER para fechar..." -ForegroundColor Cyan

    Read-Host | Out-Null
}


# ============================================================
# INÍCIO
# ============================================================

Clear-Host

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "     ENTERPRISE APPLICATIONS - ASSIGNMENT REQUIRED = NO" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""


try {

    # ========================================================
    # 1 - VERIFICAR POWERSHELL
    # ========================================================

    Write-Host "[1/7] Verificando PowerShell..." -ForegroundColor Yellow

    Write-Host "Versão: $($PSVersionTable.PSVersion)" -ForegroundColor Gray

    if ($PSVersionTable.PSVersion.Major -lt 5) {

        throw "Este script requer PowerShell 5.1 ou superior."
    }


    # ========================================================
    # 2 - VERIFICAR MICROSOFT GRAPH
    # ========================================================

    Write-Host ""
    Write-Host "[2/7] Verificando Microsoft Graph..." -ForegroundColor Yellow

    $GraphAuth = Get-Module `
        -ListAvailable `
        -Name Microsoft.Graph.Authentication


    if (-not $GraphAuth) {

        Write-Host ""
        Write-Host "Microsoft Graph não encontrado." -ForegroundColor Yellow

        Write-Host "Instalando Microsoft.Graph..." -ForegroundColor Yellow

        Install-Module `
            Microsoft.Graph `
            -Scope CurrentUser `
            -Force `
            -AllowClobber `
            -ErrorAction Stop

        Write-Host ""
        Write-Host "Microsoft Graph instalado com sucesso." -ForegroundColor Green
    }
    else {

        Write-Host "Microsoft Graph encontrado." -ForegroundColor Green
    }


    # ========================================================
    # 3 - IMPORTAR MÓDULOS
    # ========================================================

    Write-Host ""
    Write-Host "[3/7] Importando módulos..." -ForegroundColor Yellow

    Import-Module `
        Microsoft.Graph.Authentication `
        -ErrorAction Stop

    Import-Module `
        Microsoft.Graph.Applications `
        -ErrorAction Stop

    Write-Host "Módulos carregados com sucesso." -ForegroundColor Green


    # ========================================================
    # 4 - AUTENTICAÇÃO MICROSOFT GRAPH
    # ========================================================

    Write-Host ""
    Write-Host "[4/7] Configurando autenticação..." -ForegroundColor Yellow

    # --------------------------------------------------------
    # IMPORTANTE:
    #
    # O computador está ingressado no Intune/Entra e o WAM
    # estava causando:
    #
    # InteractiveBrowserCredential authentication failed
    #
    # Portanto, desabilitamos o WAM e usamos autenticação
    # interativa através do navegador.
    # --------------------------------------------------------

    Set-MgGraphOption `
        -DisableLoginByWAM $true `
        -ErrorAction Stop

    Write-Host ""
    Write-Host "WAM desabilitado para esta sessão." -ForegroundColor Gray

    Write-Host ""
    Write-Host "Abrindo autenticação do Microsoft Graph..." -ForegroundColor Yellow
    Write-Host ""

    Connect-MgGraph `
        -Scopes "Application.Read.All" `
        -NoWelcome `
        -ErrorAction Stop


    # ========================================================
    # VALIDAR CONEXÃO
    # ========================================================

    $Context = Get-MgContext

    if (-not $Context) {

        throw "Não foi possível obter o contexto do Microsoft Graph."
    }


    Write-Host ""
    Write-Host "Conexão realizada com sucesso!" -ForegroundColor Green

    Write-Host ""
    Write-Host "Conta :" -NoNewline
    Write-Host " $($Context.Account)" -ForegroundColor Green

    Write-Host "Tenant:" -NoNewline
    Write-Host " $($Context.TenantId)" -ForegroundColor Green

    Write-Host "Auth  :" -NoNewline
    Write-Host " $($Context.AuthType)" -ForegroundColor Green

    Write-Host ""


    # ========================================================
    # 5 - BUSCAR ENTERPRISE APPLICATIONS
    # ========================================================

    Write-Host "[5/7] Buscando Enterprise Applications..." -ForegroundColor Yellow

    Write-Host ""
    Write-Host "Aguarde. O tempo depende da quantidade de aplicações"
    Write-Host "existentes no tenant."
    Write-Host ""


    $EnterpriseApps = Get-MgServicePrincipal `
        -All `
        -Property @(
            "id",
            "appId",
            "displayName",
            "appRoleAssignmentRequired",
            "accountEnabled",
            "servicePrincipalType",
            "homepage",
            "publisherName",
            "createdDateTime",
            "loginUrl",
            "preferredSingleSignOnMode",
            "tags"
        ) `
        -ErrorAction Stop


    if (-not $EnterpriseApps) {

        throw "Nenhuma Enterprise Application foi retornada pelo Microsoft Graph."
    }


    Write-Host ""
    Write-Host "Total de Enterprise Applications encontradas:" -NoNewline
    Write-Host " $($EnterpriseApps.Count)" -ForegroundColor Green


    # ========================================================
    # FILTRAR ASSIGNMENT REQUIRED = NO
    # ========================================================

    Write-Host ""
    Write-Host "Filtrando Assignment Required = No..." -ForegroundColor Yellow


    $AppsWithoutAssignmentRequired = @(
        $EnterpriseApps |
            Where-Object {
                $_.AppRoleAssignmentRequired -eq $false
            }
    )


    Write-Host ""
    Write-Host "Enterprise Applications com Assignment Required = NO:" -ForegroundColor Green
    Write-Host $AppsWithoutAssignmentRequired.Count -ForegroundColor Green


    # ========================================================
    # 6 - PREPARAR DADOS
    # ========================================================

    Write-Host ""
    Write-Host "[6/7] Preparando dados para o Excel..." -ForegroundColor Yellow


    $ExcelData = foreach ($App in $AppsWithoutAssignmentRequired) {

        $CreatedDate = ""

        if ($App.CreatedDateTime) {

            $CreatedDate = (
                [datetime]$App.CreatedDateTime
            ).ToString("yyyy-MM-dd HH:mm:ss")
        }


        [PSCustomObject]@{

            "Display Name" =
                $App.DisplayName

            "Application ID" =
                $App.AppId

            "Object ID" =
                $App.Id

            "Assignment Required" =
                "No"

            "Account Enabled" =
                $App.AccountEnabled

            "Service Principal Type" =
                $App.ServicePrincipalType

            "Publisher" =
                $App.PublisherName

            "Homepage" =
                $App.Homepage

            "Login URL" =
                $App.LoginUrl

            "SSO Mode" =
                $App.PreferredSingleSignOnMode

            "Created Date" =
                $CreatedDate
        }
    }


    # ========================================================
    # VERIFICAR EXCEL
    # ========================================================

    Write-Host ""
    Write-Host "Verificando Microsoft Excel..." -ForegroundColor Yellow


    try {

        $Excel = New-Object `
            -ComObject Excel.Application `
            -ErrorAction Stop

    }
    catch {

        throw @"
Não foi possível iniciar o Microsoft Excel através do COM.

Verifique se o Microsoft Excel está instalado nesta máquina.

Erro original:
$($_.Exception.Message)
"@
    }


    $Excel.Visible = $false
    $Excel.DisplayAlerts = $false


    Write-Host "Excel iniciado." -ForegroundColor Green


    # ========================================================
    # VARIÁVEIS COM
    # ========================================================

    $Workbook = $null
    $Worksheet = $null
    $UsedRange = $null
    $HeaderRange = $null
    $Table = $null


    try {

        # ====================================================
        # CRIAR WORKBOOK
        # ====================================================

        $Workbook = $Excel.Workbooks.Add()

        $Worksheet = $Workbook.Worksheets.Item(1)

        $Worksheet.Name = "Enterprise Apps"


        # ====================================================
        # CABEÇALHOS
        # ====================================================

        $Headers = @(
            "Display Name",
            "Application ID",
            "Object ID",
            "Assignment Required",
            "Account Enabled",
            "Service Principal Type",
            "Publisher",
            "Homepage",
            "Login URL",
            "SSO Mode",
            "Created Date"
        )


        for (
            $Column = 0;
            $Column -lt $Headers.Count;
            $Column++
        ) {

            $Cell = $Worksheet.Cells.Item(
                1,
                $Column + 1
            )

            $Cell.Value2 = $Headers[$Column]

            $Cell.Font.Bold = $true
        }


        # ====================================================
        # INSERIR DADOS
        # ====================================================

        $Row = 2


        foreach ($Item in $ExcelData) {

            $Worksheet.Cells.Item(
                $Row,
                1
            ).Value2 = $Item."Display Name"


            $Worksheet.Cells.Item(
                $Row,
                2
            ).Value2 = $Item."Application ID"


            $Worksheet.Cells.Item(
                $Row,
                3
            ).Value2 = $Item."Object ID"


            $Worksheet.Cells.Item(
                $Row,
                4
            ).Value2 = $Item."Assignment Required"


            $Worksheet.Cells.Item(
                $Row,
                5
            ).Value2 = $Item."Account Enabled"


            $Worksheet.Cells.Item(
                $Row,
                6
            ).Value2 = $Item."Service Principal Type"


            $Worksheet.Cells.Item(
                $Row,
                7
            ).Value2 = $Item."Publisher"


            $Worksheet.Cells.Item(
                $Row,
                8
            ).Value2 = $Item."Homepage"


            $Worksheet.Cells.Item(
                $Row,
                9
            ).Value2 = $Item."Login URL"


            $Worksheet.Cells.Item(
                $Row,
                10
            ).Value2 = $Item."SSO Mode"


            $Worksheet.Cells.Item(
                $Row,
                11
            ).Value2 = $Item."Created Date"


            $Row++
        }


        # ====================================================
        # FORMATAÇÃO
        # ====================================================

        $LastColumn = $Headers.Count

        $LastRow = [Math]::Max(
            $Row - 1,
            1
        )


        $UsedRange = $Worksheet.Range(
            $Worksheet.Cells.Item(1, 1),
            $Worksheet.Cells.Item(
                $LastRow,
                $LastColumn
            )
        )


        # AutoFit
        $UsedRange.EntireColumn.AutoFit()


        # Larguras específicas
        $Worksheet.Columns.Item(1).ColumnWidth = 40
        $Worksheet.Columns.Item(2).ColumnWidth = 38
        $Worksheet.Columns.Item(3).ColumnWidth = 38
        $Worksheet.Columns.Item(7).ColumnWidth = 30
        $Worksheet.Columns.Item(8).ColumnWidth = 45
        $Worksheet.Columns.Item(9).ColumnWidth = 45


        # ====================================================
        # FILTRO
        # ====================================================

        $HeaderRange = $Worksheet.Range(
            $Worksheet.Cells.Item(1, 1),
            $Worksheet.Cells.Item(
                1,
                $LastColumn
            )
        )


        $HeaderRange.AutoFilter()


        # ====================================================
        # CONGELAR PRIMEIRA LINHA
        # ====================================================

        $Worksheet.Activate()

        $Excel.ActiveWindow.SplitRow = 1
        $Excel.ActiveWindow.FreezePanes = $true


        # ====================================================
        # CRIAR TABELA
        # ====================================================

        if ($LastRow -ge 2) {

            $TableRange = $Worksheet.Range(
                $Worksheet.Cells.Item(1, 1),
                $Worksheet.Cells.Item(
                    $LastRow,
                    $LastColumn
                )
            )


            $Table = $Worksheet.ListObjects.Add(
                1,
                $TableRange,
                $null,
                1
            )


            $Table.Name = "EnterpriseAppsAssignmentNo"

            $Table.TableStyle = "TableStyleMedium2"
        }


        # ====================================================
        # SALVAR
        # ====================================================

        Write-Host ""
        Write-Host "[7/7] Salvando Excel..." -ForegroundColor Yellow


        # 51 = xlOpenXMLWorkbook (.xlsx)

        $Workbook.SaveAs(
            $OutputPath,
            51
        )


        Write-Host ""
        Write-Host "Excel salvo com sucesso!" -ForegroundColor Green


        # ====================================================
        # FECHAR WORKBOOK
        # ====================================================

        $Workbook.Close($true)
    }
    finally {

        # ====================================================
        # LIMPAR OBJETOS COM
        # ====================================================

        if ($Table) {

            try {
                [System.Runtime.InteropServices.Marshal]::ReleaseComObject(
                    $Table
                ) | Out-Null
            }
            catch {}
        }


        if ($HeaderRange) {

            try {
                [System.Runtime.InteropServices.Marshal]::ReleaseComObject(
                    $HeaderRange
                ) | Out-Null
            }
            catch {}
        }


        if ($UsedRange) {

            try {
                [System.Runtime.InteropServices.Marshal]::ReleaseComObject(
                    $UsedRange
                ) | Out-Null
            }
            catch {}
        }


        if ($Worksheet) {

            try {
                [System.Runtime.InteropServices.Marshal]::ReleaseComObject(
                    $Worksheet
                ) | Out-Null
            }
            catch {}
        }


        if ($Workbook) {

            try {
                [System.Runtime.InteropServices.Marshal]::ReleaseComObject(
                    $Workbook
                ) | Out-Null
            }
            catch {}
        }


        if ($Excel) {

            try {
                $Excel.Quit()
            }
            catch {}


            try {
                [System.Runtime.InteropServices.Marshal]::ReleaseComObject(
                    $Excel
                ) | Out-Null
            }
            catch {}
        }


        [GC]::Collect()
        [GC]::WaitForPendingFinalizers()
    }


    # ========================================================
    # RESULTADO
    # ========================================================

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host "                 EXPORTAÇÃO CONCLUÍDA" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host ""

    Write-Host "Total de Enterprise Applications :" -NoNewline
    Write-Host " $($EnterpriseApps.Count)" -ForegroundColor White

    Write-Host "Assignment Required = NO         :" -NoNewline
    Write-Host " $($AppsWithoutAssignmentRequired.Count)" -ForegroundColor Yellow

    Write-Host ""
    Write-Host "Arquivo gerado:" -ForegroundColor White

    Write-Host $OutputPath -ForegroundColor Cyan

    Write-Host ""


    # ========================================================
    # PERGUNTAR SE QUER ABRIR
    # ========================================================

    $OpenFile = Read-Host "Deseja abrir o Excel agora? (S/N)"


    if ($OpenFile -match "^[Ss]$") {

        Start-Process `
            -FilePath $OutputPath
    }

}
catch {

    # ========================================================
    # ERRO GLOBAL
    # ========================================================

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host "                         ERRO" -ForegroundColor Red
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host ""

    Write-Host "Mensagem:" -ForegroundColor Yellow

    Write-Host $_.Exception.Message -ForegroundColor Red

    Write-Host ""

    Write-Host "Tipo do erro:" -ForegroundColor Yellow

    Write-Host $_.Exception.GetType().FullName -ForegroundColor DarkRed

    Write-Host ""

    Write-Host "O script não será fechado automaticamente." -ForegroundColor Yellow
}

finally {

    Pause-Script
}