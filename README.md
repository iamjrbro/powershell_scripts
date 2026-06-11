# PowerShell Scripts

Repositório pessoal contendo scripts PowerShell voltados para administração, automação e governança de ambientes Microsoft. Os scripts disponíveis auxiliam atividades operacionais relacionadas a Microsoft 365, Exchange Online, Microsoft Entra ID (Azure AD), Intune, Microsoft Graph e outras soluções do ecossistema Microsoft.

## Objetivo

Este repositório foi criado para centralizar scripts utilizados em ambientes corporativos, facilitando tarefas administrativas, geração de relatórios, auditorias, automações e operações recorrentes executadas por equipes de infraestrutura e cloud.

# Principais Categorias

## Microsoft 365

Scripts para administração e automação de workloads do Microsoft 365, incluindo:

Exchange Online
Microsoft Teams
SharePoint Online
Microsoft Graph
Microsoft Places
Gestão de usuários e licenciamento
Microsoft Entra ID

Automações relacionadas a:

Enterprise Applications
App Registrations
Service Principals
Governança de identidade
Auditoria e relatórios
Microsoft Intune

Scripts para:

Inventário de dispositivos
Relatórios de conformidade
Monitoramento de endpoints
Administração de políticas
Exchange Online

Scripts voltados para:

Gerenciamento de caixas postais
Assinaturas corporativas
Configurações de transporte
Auditoria e governança
KQL

Consultas Kusto Query Language utilizadas em:

Log Analytics
Microsoft Sentinel
Azure Monitor
Workbooks e dashboards
Requisitos

Dependendo do script utilizado, pode ser necessário instalar alguns módulos PowerShell:

Install-Module Microsoft.Graph -Scope CurrentUser
Install-Module ExchangeOnlineManagement -Scope CurrentUser
Install-Module Az -Scope CurrentUser
Install-Module MicrosoftTeams -Scope CurrentUser
Como Utilizar

Clone o repositório:

git clone https://github.com/iamjrbro/powershell_scripts.git

Acesse a pasta:

cd powershell_scripts

Execute o script desejado:

.\script.ps1
Boas Práticas

Antes de executar qualquer script:

Revise o código e adapte ao seu ambiente.
Teste inicialmente em ambiente de homologação.
Verifique permissões e roles necessárias.
Utilize contas com privilégios mínimos necessários.
Mantenha os módulos PowerShell atualizados.
Contribuições

Contribuições são bem-vindas. Caso encontre melhorias, correções ou novas automações úteis, fique à vontade para abrir um Pull Request.

Aviso

Os scripts são fornecidos "como estão", sem garantias. Utilize por sua conta e risco, validando sempre os impactos antes da execução em ambientes produtivos.


## Estrutura do Repositório

```text
powershell_scripts
│
├── General_Install
│   └── Scripts de instalação e configuração inicial
│
├── KQL
│   └── Consultas Kusto Query Language (KQL)
│
├── Microsoft
│   ├── 365
│   ├── Exchange
│   ├── Entra ID
│   ├── Intune
│   └── Outros serviços Microsoft
│
├── intune_Report.ps1
├── microsoft_places.ps1
├── emptyfileforinputscript.ps1
└── README.md


