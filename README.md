# PowerShell Scripts

Repositório pessoal de scripts, consultas e automações voltados para administração, auditoria, governança e operação de ambientes Microsoft.

O conteúdo reúne exemplos práticos para Microsoft 365, Azure, Microsoft Entra ID, Intune, Microsoft Graph, SharePoint Online, Exchange Online, Azure DevOps e ferramentas de monitoramento e segurança.

## Objetivo

Centralizar scripts reutilizáveis para atividades de infraestrutura, cloud e identidade, incluindo:

- Administração de serviços Microsoft.
- Auditoria e inventário de ambientes.
- Gestão de usuários, grupos, aplicações e permissões.
- Automação de tarefas operacionais.
- Geração de relatórios.
- Administração e troubleshooting de endpoints.
- Operações relacionadas a Azure, Microsoft 365 e Entra ID.
- Consultas e análises com KQL.

Os scripts são organizados por tecnologia, serviço e finalidade para facilitar localização, manutenção e reutilização.

## Estrutura do Repositório

```text
powershell_scripts/
│
├── KQL/
│   └── Consultas Kusto Query Language
│
├── Microsoft/
│   ├── 365/
│   │   ├── Defender/
│   │   ├── Exchange/
│   │   ├── General/
│   │   ├── Implementations/
│   │   ├── OneDrive/
│   │   ├── Outlook/
│   │   └── Teams/
│   │
│   ├── AD_Local/
│   │   └── Administração e operações de Active Directory
│   │
│   ├── Azure/
│   │   ├── App_Registrations/
│   │   ├── Front_Door/
│   │   ├── General/
│   │   ├── Key_Vault/
│   │   ├── Networking/
│   │   └── Resource_Governance/
│   │
│   ├── DevOps/
│   │   └── PAT/
│   │
│   ├── Entra_ID/
│   │   ├── Applications/
│   │   ├── Authentication/
│   │   ├── Groups/
│   │   ├── Guests/
│   │   ├── Reports/
│   │   └── Roles/
│   │
│   ├── Graph/
│   │   ├── Applications/
│   │   ├── Groups/
│   │   ├── Guests/
│   │   └── Users/
│   │
│   ├── Intune/
│   │   ├── Configuration/
│   │   ├── Devices/
│   │   ├── Reports/
│   │   └── Security/
│   │
│   └── Sharepoint/
│       └── Auditoria e administração do SharePoint Online
│
└── README.md
```

A estrutura pode evoluir conforme novos scripts forem adicionados. A nomenclatura dos arquivos segue, sempre que possível, o padrão `snake_case`, e os diretórios são organizados por tecnologia e contexto.

## Principais Categorias

### Microsoft 365

Scripts para administração e automação de workloads do Microsoft 365, incluindo Exchange Online, Teams, OneDrive, Outlook, Defender e tarefas administrativas gerais.

Entre os exemplos estão gerenciamento de usuários, grupos, licenciamento, configurações, recuperação de dados e automações operacionais.

### Microsoft Entra ID

Scripts relacionados a identidade e controle de acesso, incluindo:

- Enterprise Applications.
- App Registrations.
- Service Principals.
- Grupos e associação de usuários.
- Roles e permissões.
- Autenticação.
- Relatórios de acesso e MFA.
- Contas guest.

### Microsoft Graph

Scripts que utilizam Microsoft Graph para consultar e administrar recursos de identidade e Microsoft 365, com foco em usuários, grupos, aplicações e convidados.

A utilização do Graph também faz parte da modernização de scripts que anteriormente dependiam de módulos legados.

### Azure

Scripts para tarefas de administração e governança do Azure, incluindo:

- App Registrations.
- Azure Front Door.
- Key Vault.
- Networking.
- Resource Governance.
- Scheduled Actions.
- Políticas e tags.

### Intune

Scripts para administração e suporte de endpoints, incluindo:

- Configuração de dispositivos.
- Inventário de software e hardware.
- Diagnóstico.
- Relatórios.
- Segurança do endpoint.
- Políticas e configurações.

### SharePoint Online

Scripts para auditoria e administração do SharePoint Online.

Inclui auditorias de grupos, membros, sites e subsites, com geração de relatórios para análise do ambiente.

### Azure DevOps

Scripts relacionados à administração e auditoria do Azure DevOps, incluindo inventário e controle de Personal Access Tokens (PATs) e informações de licenciamento.

### Active Directory local

Scripts para operações administrativas em ambientes Active Directory locais e cenários de integração com serviços de identidade Microsoft.

### KQL

Consultas Kusto Query Language utilizadas para investigação, auditoria e análise de dados em serviços como:

- Microsoft Sentinel.
- Log Analytics.
- Azure Monitor.
- Workbooks e dashboards.

## Autenticação e Permissões

Os requisitos variam de acordo com o script. Alguns utilizam autenticação interativa, enquanto outros dependem de permissões específicas em Microsoft Graph, Azure, SharePoint ou outros serviços.

Antes da execução:

1. Leia o conteúdo do script.
2. Identifique os módulos e permissões necessários.
3. Substitua valores de configuração e placeholders pelo ambiente de destino.
4. Utilize o princípio do menor privilégio.
5. Teste alterações em ambiente de homologação antes de executá-las em produção.

Scripts de auditoria somente leitura devem ser executados com permissões compatíveis com as consultas realizadas, evitando privilégios de escrita desnecessários.

## Requisitos

Dependendo do script, alguns módulos podem ser necessários:

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
Install-Module ExchangeOnlineManagement -Scope CurrentUser
Install-Module Az -Scope CurrentUser
Install-Module MicrosoftTeams -Scope CurrentUser
Install-Module PnP.PowerShell -Scope CurrentUser
```

Não é necessário instalar todos os módulos para utilizar o repositório. Instale somente as dependências exigidas pelo script que será executado.

Alguns scripts mais antigos ainda podem utilizar módulos ou cmdlets legados. A modernização para Microsoft Graph e APIs atuais é tratada gradualmente, preservando a finalidade original dos scripts.

## Como Utilizar

Clone o repositório:

```bash
git clone https://github.com/iamjrbro/powershell_scripts.git
cd powershell_scripts
```

Navegue até o diretório do script desejado e execute-o conforme seus parâmetros e requisitos de autenticação.

Exemplo:

```powershell
.\Microsoft\Entra_ID\Applications\enterprise_app_sign_in.ps1
```

Não execute scripts administrativos sem antes revisar o código e confirmar o impacto das operações realizadas.

## Segurança

Este repositório não deve armazenar credenciais reais, tokens, secrets ou outros dados sensíveis.

Os scripts utilizam placeholders ou entrada durante a execução quando uma credencial ou token é necessário. Nunca substitua esses placeholders por credenciais reais antes de publicar o código.

Exemplos de valores que não devem ser versionados:

- Client Secrets.
- Access Tokens.
- Personal Access Tokens.
- Senhas.
- Chaves privadas.
- Informações sensíveis do tenant.

## Boas Práticas

Antes de executar qualquer script:

- Revise o código e adapte-o ao ambiente de destino.
- Confirme as permissões e roles necessárias.
- Utilize contas com o menor privilégio possível.
- Teste inicialmente em ambiente de homologação.
- Faça backup quando a operação puder alterar ou remover recursos.
- Mantenha os módulos PowerShell atualizados.
- Valide os resultados dos scripts de auditoria e relatórios antes de tomar ações administrativas.

## Contribuições

Contribuições, correções e melhorias são bem-vindas. Pull Requests podem ser utilizados para propor novos scripts, correções ou melhorias na organização do repositório.

## Aviso

Os scripts são fornecidos "como estão", sem garantias. Eles foram desenvolvidos para fins de estudo, automação e administração de ambientes Microsoft.

Sempre valide o código, as permissões necessárias e os impactos antes de executar qualquer script em um ambiente produtivo.
