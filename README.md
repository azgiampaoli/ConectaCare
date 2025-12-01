🚀 Salesforce – Módulo de Busca e Atualização de Cases

Sistema desenvolvido em Apex + LWC, com foco em consulta unificada de registros (Account, Contact, Case) e atualização automatizada de Cases via Flow e Apex Controller.

📌 Sumário

Descrição Geral

Arquitetura da Solução

Tecnologias Utilizadas

Componentes do Projeto

Apex Controllers

LWC

Triggers & Handlers

Classes de Teste

Fluxo de Execução

Endpoints

Instalação e Deploy

Boas Práticas Implementadas

Licença

🧾 Descrição Geral

Este projeto implementa uma solução Salesforce composta por:

🔍 Busca dinâmica de clientes via LWC consumindo Apex

🧩 Agrupamento de múltiplas entidades (Account, Contact, Case) com retorno padronizado

📨 Controller de atualização de Cases exposto para Flow

⚙️ Trigger com Handler seguindo padrões Salesforce recomendados

🧪 Classes de teste completas garantindo cobertura e assertividade

🔗 Mock Server no Postman para simular integrações externas sem depender de API real

🏛 Arquitetura da Solução
flowchart TD
    A[LWC BuscaClientes] --> B[Apex: BuscaClienteController]
    B --> C[Retorno consolidado (Map)]
    A -->|Selecionar registro| D[Redirect para registro]

    F[Flow] --> G[AtualizarCaseController]
    G --> H[Atualização granular do Case]

🧰 Tecnologias Utilizadas
Backend (Salesforce Apex)

Apex Controllers

Trigger Handler Pattern

SOQL otimizado

@AuraEnabled para LWC

@Test, TestSetup

Frontend (LWC)

Lightning Web Components

JavaScript ES6

@track para gerenciamento de estado

DevOps & Ferramentas

Git + GitHub

VS Code + Salesforce Extensions

SFDX CLI

Mock Server – Postman (para simular APIs externas)

Mock Server

Utilizado para simular API de planos de saúde durante desenvolvimento.

Exemplo de endpoint:
https://5480913e-2cab-4216-8452-c04f138bf88b.mock.pstmn.io/planos

📦 Componentes do Projeto
🧩 Apex Controllers
BuscaClienteController

Responsável por:

Consultar:

Account

Contact

Case

Consolidar o retorno no formato List<Map<String, Object>>

Normalizar dados e identificar o tipo do registro

Buscar por termo parcial via LIKE

AtualizarCaseController

Usado para Flow.

Funções:

Atualizar Status

Atualizar Owner

Atualizar SLA / datas

Atualizar descrição

Garantir atomicidade do update

💡 LWC
buscaClientes

Responsável por:

Executar busca dinâmica enquanto o usuário digita

Exibir tabelas em lightning-datatable

Redirecionar o usuário ao registro selecionado

Abrir modal com detalhes do Case

Atualizar Case via Apex

⚙️ Triggers & Handlers
CaseTriggerHandler

Executa:

before insert / before update

Associação automática de Entitlement baseado no SLA

Lógica condicional centralizada em Handler

🧪 Classes de Teste

Cobertura inclui:

Busca unificada

Atualização de Cases

Trigger de Cases

Criação de dados com @TestSetup

Boas práticas:

Cobertura > 75%

Assertivas reais

Dados mínimos e relevantes

🔄 Fluxo de Execução

Usuário digita termo no LWC

Se length >= 2 → consulta Apex

Apex retorna mapa consolidado

Usuário seleciona registro

UI redireciona para o registro Salesforce

Flow atualiza o Case

Usa AtualizarCaseController

🔗 Endpoints
1. ViaCEP 

Usado para buscar endereços reais.

Endpoint
GET https://viacep.com.br/ws/{cep}/json/

Exemplo Request
GET https://viacep.com.br/ws/01001000/json/

Exemplo Response
{
  "cep": "01001-000",
  "logradouro": "Praça da Sé",
  "complemento": "lado ímpar",
  "bairro": "Sé",
  "localidade": "São Paulo",
  "uf": "SP",
  "ibge": "3550308",
  "gia": "1004",
  "ddd": "11",
  "siafi": "7107"
}

2. Mock Server – Postman (Planos de Saúde)

Base URL:
https://5480913e-2cab-4216-8452-c04f138bf88b.mock.pstmn.io

Endpoint
| Finalidade                     | Método | Endpoint  | Descrição               |
| ------------------------------ | ------ | --------- | ----------------------- |
| Listar tipos de plano de saúde | GET    | `/planos` | Lista mockada de planos |

Response
[
  {
    "tipoPlano": "Basico",
    "valorMensalidade": "250.00",
    "cobertura": "Ambulatorial e Hospitalar com coparticipação",
    "carencia": "180"
  },
  {
    "tipoPlano": "Gold",
    "valorMensalidade": "450.00",
    "cobertura": "Ambulatorial, Hospitalar e Odontológico",
    "carencia": "90"
  },
  {
    "tipoPlano": "Premium",
    "valorMensalidade": "750.00",
    "cobertura": "Ambulatorial, Hospitalar, Odontológico e Estético",
    "carencia": "30"
  }
]

🛠 Instalação e Deploy
1. Clone o repositório
git clone <URL-do-repo>

2. Autentique no Salesforce
sf org login web -a Prod

3. Deploy do código
sf project deploy start

4. Rodar testes
sf apex run test -c -r human --synchronous

📘 Boas Práticas Implementadas

Trigger Handler Pattern
DDD (parcial)
SOQL seletivo
LWC com async/await
Mock Server para independência de APIs
Testes com TestSetup
Retornos padronizados em Maps

📄 Licença

MIT License.