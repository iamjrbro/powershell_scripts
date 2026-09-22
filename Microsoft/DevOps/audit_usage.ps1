Se você gerencia várias organizações e projetos no Azure DevOps, pode ser um desafio saber quais deles estão realmente ativos — seja com Boards (work items), commits em repositórios ou pipelines de CI/CD em uso.

Neste artigo, vou mostrar um método simples usando PowerShell para gerar um relatório CSV que ajuda a entender o uso real dos seus projetos, sem alterar nada no ambiente — só leitura.

O que vamos auditar?
Projetos existentes em várias organizações (organizações = assinaturas dentro do Azure DevOps).

Se os projetos têm Boards (work items) ativos.

Data do último commit nos repositórios.

Se existem pipelines com execuções recentes.

Uma aproximação da data de criação do projeto, baseada no primeiro commit encontrado.

Pré-requisitos
Permissão de acesso às organizações do Azure DevOps.

Um Personal Access Token (PAT) com permissões de leitura para:

Projetos e times

Work Items

Repositórios Git

Pipelines

PowerShell 7+ instalado na sua máquina.

Como gerar seu PAT
Entre no Azure DevOps.

Clique no seu avatar > Security > Personal Access Tokens > New Token.

Configure com as permissões de leitura e validade desejadas.

Copie o token gerado — ele aparecerá só uma vez.

Script PowerShell para auditoria
O script abaixo conecta nas suas organizações, lista os projetos e coleta as informações de uso, exportando para um arquivo CSV:



# Configurar suas organizações aqui

$organizations = @("sua-org-1", "sua-org-2")



# Solicita o PAT para autenticação segura

$pat = Read-Host -Prompt "Informe seu PAT do Azure DevOps" -AsSecureString

$ptraw = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pat))

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$ptraw"))

$headers = @{Authorization = "Basic $base64AuthInfo"}



$resultados = @()



foreach ($org in $organizations) {

    Write-Host "Organização: $org"

    $projectsUrl = "https://dev.azure.com/$org/_apis/projects?api-version=7.0"

    $projects = (Invoke-RestMethod -Uri $projectsUrl -Headers $headers).value



    foreach ($project in $projects) {

        $projectName = $project.name

        Write-Host "Projeto: $projectName"



        # Verifica uso de Boards

        $wiql = @{ query = "SELECT [System.Id] FROM WorkItems WHERE [System.TeamProject] = '$projectName'" } | ConvertTo-Json -Depth 3

        $workItemsUrl = "https://dev.azure.com/$org/$projectName/_apis/wit/wiql?api-version=7.0"

        $workItems = Invoke-RestMethod -Method Post -Uri $workItemsUrl -Headers $headers -Body $wiql -ContentType "application/json"

        $temBoards = if ($workItems.workItems.Count -gt 0) { "Sim" } else { "Não" }



        # Último commit (mais recente) em todos os repositórios do projeto

        $reposUrl = "https://dev.azure.com/$org/$projectName/_apis/git/repositories?api-version=7.0"

        $repos = (Invoke-RestMethod -Uri $reposUrl -Headers $headers).value

        $ultimoCommit = $null

        $primeiroCommit = $null



        foreach ($repo in $repos) {

            # Commit mais recente

            $commitsRecentesUrl = "https://dev.azure.com/$org/$projectName/_apis/git/repositories/$($repo.id)/commits?`$top=1"

            $commitsRecentes = (Invoke-RestMethod -Uri $commitsRecentesUrl -Headers $headers).value

            if ($commitsRecentes.Count -gt 0) {

                $dataRecente = $commitsRecentes[0].committer.date

                if (-not $ultimoCommit -or [datetime]$dataRecente -gt [datetime]$ultimoCommit) {

                    $ultimoCommit = $dataRecente

                }

            }



            # Commit mais antigo (para data aproximada da criação)

            $commitsAntigosUrl = "https://dev.azure.com/$org/$projectName/_apis/git/repositories/$($repo.id)/commits?`$top=1&`$orderby=authorDate asc"

            $commitsAntigos = (Invoke-RestMethod -Uri $commitsAntigosUrl -Headers $headers).value

            if ($commitsAntigos.Count -gt 0) {

                $dataAntiga = $commitsAntigos[0].committer.date

                if (-not $primeiroCommit -or [datetime]$dataAntiga -lt [datetime]$primeiroCommit) {

                    $primeiroCommit = $dataAntiga

                }

            }

        }



        if (-not $ultimoCommit) { $ultimoCommit = "Sem commit" }

        if (-not $primeiroCommit) { $primeiroCommit = "Indisponível" }



        # Verifica uso de pipelines

        $pipelinesUrl = "https://dev.azure.com/$org/$projectName/_apis/pipelines?api-version=7.0"

        $pipelines = (Invoke-RestMethod -Uri $pipelinesUrl -Headers $headers).value

        $usouPipeline = "Não"

        foreach ($pipeline in $pipelines) {

            $runsUrl = "https://dev.azure.com/$org/$projectName/_apis/pipelines/$($pipeline.id)/runs?`$top=1"

            $runs = (Invoke-RestMethod -Uri $runsUrl -Headers $headers).value

            if ($runs.Count -gt 0) {

                $usouPipeline = "Sim"

                break

            }

        }



        # Monta o objeto resultado

        $resultados += [PSCustomObject]@{

            Organizacao     = $org

            Projeto         = $projectName

            CriadoEm        = $primeiroCommit

            BoardsUsado     = $temBoards

            UltimoCommit    = $ultimoCommit

            PipelinesUsado  = $usouPipeline

        }

    }

}



# Exporta para CSV

$csvPath = ".\\auditoria-devops-multiorgs.csv"

$resultados | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8



Write-Host "Auditoria concluída! Arquivo salvo em $csvPath"

=====================================================================
Como usar
Copie o script acima para um arquivo .ps1 (exemplo: auditoria-devops.ps1).

Altere a variável $organizations para as suas organizações do Azure DevOps.

Abra o PowerShell e execute o script.

Informe seu PAT quando solicitado.

Aguarde o término da execução e confira o arquivo .csv gerado.

Resultado esperado

O arquivo CSV terá as seguintes informações:



Por que vale a pena usar esse script de auditoria no Azure DevOps?
Você ganha visibilidade real do ambiente
Saber exatamente quais projetos estão ativos, abandonados ou apenas parcialmente utilizados evita desperdício de recursos e ajuda na organização.

Ajuda no planejamento de governança
Você pode identificar padrões: quais equipes usam mais Boards? Quais usam só o repositório? Isso ajuda a definir diretrizes e boas práticas internas.

É ideal para ambientes com muitas organizações e projetos
Em vez de fazer tudo manualmente, o script percorre todas as organizações de forma automatizada.

Garante segurança e tranquilidade
Como o script é somente leitura, ele não modifica nada — ou seja, você pode rodar sem medo em produção.

Facilita relatórios e auditorias oficiais
O CSV gerado pode ser facilmente enviado para times de governança, compliance, segurança ou gestão.

É base para automações futuras
Você pode adaptar esse script para criar painéis no Power BI, gerar alertas, ou até sugerir arquivamento automático no futuro (com cuidado, claro).

Se você trabalha com DevOps em uma organização que tem múltiplos times, projetos legados e ambientes complexos, esse script é uma mão na roda para iniciar uma auditoria eficiente, sem riscos e com dados valiosos.


