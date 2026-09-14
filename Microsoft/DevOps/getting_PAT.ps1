<#
.SYNOPSIS
Audita Personal Access Tokens (PATs) do Azure DevOps por organização.

.DESCRIPTION
Consulta usuários e PATs do Azure DevOps, identifica escopos considerados de alto risco, calcula status e proximidade de expiração e exporta o inventário para CSV.

.PREREQUISITES
O Access Token OAuth informado durante a execução deve possuir vso.tokenadministration e a identidade deve ter as permissões administrativas necessárias na organização.

.NOTES
O token é solicitado em tempo de execução e não é armazenado no script.
#>

# Organizações do Azure DevOps que serão auditadas.
$Organizations = @(
    "ORG-01",
    "ORG-02",
    "ORG-03",
    "ORG-04",
    "ORG-05"
)

$OutputFile = ".\AzureDevOps-PAT-Inventory.csv"

# Solicita o Access Token OAuth em tempo de execução.
$AccessToken = Read-Host "Cole o Access Token OAuth do Azure DevOps"

$Headers = @{
    Authorization = "Bearer $AccessToken"
    Accept        = "application/json"
}

# Escopos considerados de alto risco.
# A lista pode ser ajustada conforme a política de segurança da organização.
# A comparação procura qualquer um desses termos dentro dos scopes do PAT.
$HighRiskScopes = @(
    # Administração
    "vso.admin"
    "vso.memberentitlementmanagement"

    # Segurança e políticas
    "vso.security_manage"
    "vso.policy_manage"

    # Release e Build
    "vso.release_manage"
    "vso.build_execute"
    "vso.build_manage"

    # Código com permissão de escrita
    "vso.code_write"

    # Work Items com permissão de escrita
    "vso.work_write"

    # Service Hooks
    "vso.hooks_write"

    # Variable Groups
    "vso.variablegroups_manage"

    # Agent Pools
    "vso.agentpools_manage"

    # Deployment
    "vso.deploy_manage"

    # Projetos e times
    "vso.project_manage"
)

# Identifica se um escopo está classificado como de alto risco.
function Test-HighRiskScope {
    param (
        [string]$Scope
    )

    if ([string]::IsNullOrWhiteSpace($Scope)) {
        return $false
    }

    foreach ($RiskScope in $HighRiskScopes) {
        if ($Scope -match [regex]::Escape($RiskScope)) {
            return $true
        }
    }

    return $false
}

# Obtém os usuários de uma organização do Azure DevOps.
function Get-AzureDevOpsUsers {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Organization
    )

    $Users = @()
    $ContinuationToken = $null

    Write-Host ""
    Write-Host "Obtendo usuários: $Organization" `
        -ForegroundColor Cyan

    do {
        $Uri = "https://vssps.dev.azure.com/$Organization/_apis/graph/users?api-version=7.1-preview.1"

        if ($ContinuationToken) {
            $Uri += "&continuationToken=$(
                [uri]::EscapeDataString($ContinuationToken)
            )"
        }

        try {
            $Response = Invoke-RestMethod `
                -Uri $Uri `
                -Method Get `
                -Headers $Headers `
                -ErrorAction Stop
        }
        catch {
            Write-Host ""
            Write-Host "ERRO ao consultar usuários de $Organization" `
                -ForegroundColor Red
            Write-Host $_.Exception.Message `
                -ForegroundColor Red
            break
        }

        if ($Response.value) {
            foreach ($User in $Response.value) {
                if ($User.subjectKind -eq "user") {
                    $Users += [PSCustomObject]@{
                        Descriptor = $User.descriptor
                        UserId = $User.originId
                        Dev = $User.displayName
                        Email = $User.mailAddress
                        PrincipalName = $User.principalName
                    }
                }
            }
        }

        $ContinuationToken = $Response.continuationToken
    }
    while ($ContinuationToken)

    Write-Host "Usuários encontrados: $($Users.Count)" `
        -ForegroundColor Green

    return $Users
}

# Obtém os PATs associados a um usuário.
function Get-UserPATs {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Organization,

        [Parameter(Mandatory = $true)]
        [string]$SubjectDescriptor
    )

    $PATs = @()
    $ContinuationToken = $null

    do {
        $Uri = "https://vssps.dev.azure.com/$Organization/_apis/tokenadmin/personalaccesstokens/$SubjectDescriptor"

        $Query = @(
            "pageSize=100"
            "api-version=7.1"
        )

        if ($ContinuationToken) {
            $Query += "continuationToken=$(
                [uri]::EscapeDataString($ContinuationToken)
            )"
        }

        $RequestUri = "$Uri?" + ($Query -join "&")

        try {
            $Response = Invoke-RestMethod `
                -Uri $RequestUri `
                -Method Get `
                -Headers $Headers `
                -ErrorAction Stop
        }
        catch {
            $StatusCode = $null

            if ($_.Exception.Response) {
                try {
                    $StatusCode = [int]$_.Exception.Response.StatusCode
                }
                catch {}
            }

            if ($StatusCode -eq 404) {
                return @()
            }

            if ($StatusCode -eq 401 -or $StatusCode -eq 403) {
                Write-Host ""
                Write-Host "SEM PERMISSÃO para consultar PATs de $SubjectDescriptor" `
                    -ForegroundColor Red
                Write-Host "Verifique vso.tokenadministration e as permissões administrativas." `
                    -ForegroundColor Yellow
                return @()
            }

            Write-Host ""
            Write-Host "Erro consultando PAT:" `
                -ForegroundColor Red
            Write-Host $_.Exception.Message `
                -ForegroundColor Red
            return @()
        }

        if ($Response.value) {
            foreach ($PAT in $Response.value) {
                $PATs += $PAT
            }
        }

        $ContinuationToken = $Response.continuationToken
    }
    while ($ContinuationToken)

    return $PATs
}

# Retorna o status atual do PAT.
function Get-PATStatus {
    param (
        $PAT
    )

    if ($PAT.isValid -eq $false) {
        return "Revoked"
    }

    if ($PAT.validTo) {
        $Expiration = ([DateTime]$PAT.validTo).ToUniversalTime()

        if ($Expiration -lt [DateTime]::UtcNow) {
            return "Expired"
        }
    }

    return "Active"
}

# Calcula a quantidade de dias restantes até a expiração do PAT.
function Get-DaysToExpire {
    param (
        $ExpirationDate
    )

    if (-not $ExpirationDate) {
        return $null
    }

    $Expiration = ([DateTime]$ExpirationDate).ToUniversalTime()
    $Now = [DateTime]::UtcNow

    return [math]::Floor(
        ($Expiration - $Now).TotalDays
    )
}

# Inicia o inventário de PATs.
$Inventory = @()

foreach ($Organization in $Organizations) {
    Write-Host ""
    Write-Host "========================================================" `
        -ForegroundColor Cyan
    Write-Host "ORGANIZAÇÃO: $Organization" `
        -ForegroundColor Cyan
    Write-Host "========================================================" `
        -ForegroundColor Cyan

    # Obtém os usuários da organização.
    $Users = Get-AzureDevOpsUsers `
        -Organization $Organization

    if (-not $Users) {
        Write-Host "Nenhum usuário encontrado." `
            -ForegroundColor Yellow
        continue
    }

    # Consulta os PATs de cada usuário.
    foreach ($User in $Users) {
        Write-Host ""
        Write-Host "Dev: $($User.Dev)" `
            -ForegroundColor White

        $PATs = Get-UserPATs `
            -Organization $Organization `
            -SubjectDescriptor $User.Descriptor

        if (-not $PATs) {
            Write-Host "Nenhum PAT encontrado." `
                -ForegroundColor DarkGray
            continue
        }

        Write-Host "PATs encontrados: $($PATs.Count)" `
            -ForegroundColor Green

        foreach ($PAT in $PATs) {
            # Calcula o status do PAT.
            $Status = Get-PATStatus $PAT

            # Calcula os dias restantes até a expiração.
            $DaysToExpire = Get-DaysToExpire `
                -ExpirationDate $PAT.validTo

            # Identifica PATs com expiração prevista para até 30 ou 60 dias.
            $ExpiresIn30Days = $false
            $ExpiresIn60Days = $false

            if ($null -ne $DaysToExpire) {
                if (
                    $DaysToExpire -ge 0 -and
                    $DaysToExpire -le 30
                ) {
                    $ExpiresIn30Days = $true
                }

                if (
                    $DaysToExpire -ge 0 -and
                    $DaysToExpire -le 60
                ) {
                    $ExpiresIn60Days = $true
                }
            }

            # Obtém o escopo do PAT.
            $Scope = $PAT.scope

            # Verifica se o escopo está classificado como de alto risco.
            $HighRisk = Test-HighRiskScope `
                -Scope $Scope

            if ($HighRisk) {
                $HighRiskValue = "SIM"
            }
            else {
                $HighRiskValue = "NÃO"
            }

            # Obtém as organizações alvo do PAT.
            if ($PAT.targetAccounts) {
                $TargetOrganizations = (
                    $PAT.targetAccounts -join "; "
                )
            }
            else {
                $TargetOrganizations = `
                    "Todas as organizações acessíveis"
            }

            # Adiciona o PAT ao inventário.
            $Inventory += [PSCustomObject]@{
                Organização = $Organization
                Dev = $User.Dev
                "E-mail" = $User.Email
                PAT = $PAT.displayName
                Escopo = $Scope
                Criado = $PAT.validFrom
                Expira = $PAT.validTo
                Status = $Status
                DiasParaExpirar = $DaysToExpire
                ExpiraEm30Dias = $ExpiresIn30Days
                ExpiraEm60Dias = $ExpiresIn60Days
                EscopoDeAltoRisco = $HighRiskValue
                OrganizaçõesAlvo = $TargetOrganizations
                AuthorizationId = $PAT.authorizationId
            }
        }
    }
}

# Exporta o inventário para CSV.
if ($Inventory.Count -eq 0) {
    Write-Host ""
    Write-Host "Nenhum PAT encontrado." `
        -ForegroundColor Yellow
    return
}

$Inventory |
    Sort-Object `
        Organização,
        Status,
        DiasParaExpirar |
    Export-Csv `
        -Path $OutputFile `
        -NoTypeInformation `
        -Encoding UTF8

# Calcula o resumo do inventário.
$Total = $Inventory.Count
$Active = @(
    $Inventory |
    Where-Object Status -eq "Active"
).Count
$Expired = @(
    $Inventory |
    Where-Object Status -eq "Expired"
).Count
$Revoked = @(
    $Inventory |
    Where-Object Status -eq "Revoked"
).Count
$Expiring30 = @(
    $Inventory |
    Where-Object ExpiraEm30Dias -eq $true
).Count
$Expiring60 = @(
    $Inventory |
    Where-Object ExpiraEm60Dias -eq $true
).Count
$HighRisk = @(
    $Inventory |
    Where-Object EscopoDeAltoRisco -eq "SIM"
).Count

# Exibe o resultado da auditoria.
Write-Host ""
Write-Host "========================================================" `
    -ForegroundColor Green
Write-Host "AUDITORIA DE PATs CONCLUÍDA" `
    -ForegroundColor Green
Write-Host "========================================================" `
    -ForegroundColor Green
Write-Host ""
Write-Host "Total de PATs       : $Total"
Write-Host "Ativos              : $Active"
Write-Host "Expirados           : $Expired"
Write-Host "Revogados           : $Revoked"
Write-Host "Expiram em 30 dias  : $Expiring30"
Write-Host "Expiram em 60 dias  : $Expiring60"
Write-Host "Alto risco          : $HighRisk"
Write-Host ""
Write-Host "CSV:"
Write-Host (Resolve-Path $OutputFile)
Write-Host ""
