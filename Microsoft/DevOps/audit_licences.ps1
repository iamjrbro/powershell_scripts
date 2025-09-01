# Connect your Azure Account

Connect-AzAccount

# Run the first block
# On DevOps, get your Personal Access Token and fill the informations on it - Name, organization and scopes (set it as full access)

$organizations = @("org1", "org2")  # change it to the name of your organizations
$pat = "YOUR_PAT_HERE"
$authHeader = @{

    Authorization = ("Basic {0}" -f [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$pat")))

}


# Run the second block

$cutoff = (Get-Date).AddDays(-30)
function Invoke-AzDo {

    param($Uri)

    try {

        return Invoke-RestMethod -Uri $Uri -Headers $authHeader -ErrorAction Stop

    } catch {

        return $null

    }

}

$report = @()

foreach ($org in $organizations) {

    Write-Host "n Checando organização: $org" -ForegroundColor Cyan

    # Get user with Basic licence

    $uriUsers = "https://vsaex.dev.azure.com/$org/_apis/userentitlements?top=1000&api-version=7.1-preview.1"

    $resUsers = Invoke-AzDo $uriUsers

    if (-not $resUsers) { Write-Warning "Failed to get user on organization $org"; continue }

    $basicUsers = $resUsers.value | Where-Object { $_.accessLevel.licenseDisplayName -eq "Basic" }


    foreach ($u in $basicUsers) {

        $email = $u.user.mailAddress

        $name = $u.user.displayName

        Write-Host "→ User: $name"

        $active = $false



        # 1. Check commits

        $uriRepos = "https://dev.azure.com/$org/_apis/projects?api-version=7.1"

        $projects = Invoke-AzDo $uriRepos

        foreach ($p in $projects.value) {

            $uriGit = "https://dev.azure.com/$org/$($p.name)/_apis/git/repositories?api-version=7.1"

            $repos = Invoke-AzDo $uriGit

            foreach ($r in $repos.value) {

                $uriCommits = "https://dev.azure.com/$org/$($p.name)/_apis/git/repositories/$($r.id)/commits?searchCriteria.author=$email&$top=1&api-version=7.1"

                $comm = Invoke-AzDo $uriCommits

                if ($comm.value -and [datetime]$comm.value[0].author.date -ge $cutoff) { $active = $true }

                if ($active) { break }

            }

            if ($active) { break }

        }



        # 2. Check builds

        if (-not $active) {

            foreach ($p in $projects.value) {

                $uriBuilds = "https://dev.azure.com/$org/$($p.name)/_apis/build/builds?requestedFor=$email&$top=1&api-version=7.1"

                $b = Invoke-AzDo $uriBuilds

                if ($b.value -and [datetime]$b.value[0].queueTime -ge $cutoff) {

                    $active = $true; break

                }

            }

        }



        # 3. Check boards (work items modifications)

        if (-not $active) {

            foreach ($p in $projects.value) {

                $uriWork = "https://dev.azure.com/$org/$($p.name)/_apis/wit/activitylogs?user=$email&$top=1&startDateTime=$($cutoff.ToString("o"))&api-version=7.1"

                $w = Invoke-AzDo $uriWork

                if ($w.value) {

                    $active = $true; break

                }

            }

        }



        # Action sugestion

        $action = if ($active) { "Keep Basic" } else { "Change it to Stakeholder" }



        $report += [PSCustomObject]@{

            Organization       = $org

            Name              = $name

            Email             = $email

            Licence           = "Basic"

            ActiveLast30d   = $active

            ActionSugestion    = $action

        }

    }

}

# Export results

$out = Join-Path (Get-Location).Path "Audit_Basic_Licence.csv"

# Converte o objeto para CSV e depois salva no arquivo
$report | Sort-Object Organization, Name | ConvertTo-Csv -NoTypeInformation -Delimiter ';' | Out-File -FilePath $out -Encoding UTF8

Write-Host "`nReport generated: $out" -ForegroundColor Green