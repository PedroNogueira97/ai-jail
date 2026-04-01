# ai-jail

Ambiente de desenvolvimento em **Docker** pensado para rodar o [**Gemini CLI**](https://www.npmjs.com/package/@google/gemini-cli) da Google e o [**basic-memory**](https://pypi.org/project/basic-memory/) (ferramenta local de conhecimento / MCP) com um filesystem persistente no host.

## O que inclui

| Componente | Função |
|------------|--------|
| **Ubuntu 24.04** | Base com Python **3.12+** (requisito do `basic-memory`). |
| **Node.js 20** | Runtime para o Gemini CLI (instalado globalmente). |
| **`@google/gemini-cli`** | Assistente de linha de comando no container. |
| **`basic-memory`** | Instalado via `pip` no Python do sistema; dados persistentes em `./memory` (ver secção abaixo). |
| **Ferramentas** | `git`, `curl`, `build-essential`, `vim`, `nano`, `sudo` (usuário `dev` com sudo). |

Dentro do repositório, a pasta **`workspace/`** contém convenções para projetos e instruções para agentes (por exemplo `GEMINI.md`, `AGENT_WORKFLOW.md`, `GIT_WORKFLOW.md`, `PROJECT.md`, `MEMORY.md`). O código dos seus projetos fica em subpastas de `workspace/` conforme essas regras.

### Memória (basic-memory)

O **`basic-memory`** guarda o grafo de conhecimento e ficheiros associados no volume montado em **`MEMORY_PATH`**, por defeito **`/home/dev/.memory`** no contentor (pasta **`./memory`** no host). A variável **`MEMORY_PATH`** é definida no `docker-compose.yml`.

A documentação em **`workspace/MEMORY.md`** descreve como a memória deve ser usada pelos agentes: é **contexto auxiliar**, nunca a fonte de verdade face ao código e à documentação do projeto. O **`GEMINI.md`** detalha quando ler ou escrever na memória em sessões com o Gemini CLI.

## Pré-requisitos

- Docker e Docker Compose (plugin `docker compose`)
- Uma **Google API key** com acesso às APIs usadas pelo Gemini (variável `GOOGLE_API_KEY`)

## Configuração

1. Copie o exemplo de ambiente (se existir) ou crie um ficheiro **`.env`** na raiz do projeto:

   ```env
   GOOGLE_API_KEY=sua_chave_aqui
   ```

2. O Compose injeta `GOOGLE_API_KEY` e `MEMORY_PATH=/home/dev/.memory` no serviço.

## Build e execução

Na raiz do repositório:

```bash
docker compose build
docker compose run --rm ai-jail bash
```

Para um serviço em segundo plano (como no `docker-compose.yml`):

```bash
docker compose up -d
docker exec -it ai-jail bash
```

O comando padrão do contentor é `bash`; `stdin_open` e `tty` estão ativos para sessões interativas.

## Volumes

| Caminho no host | Caminho no container | Uso |
|-----------------|----------------------|-----|
| `./workspace` | `/workspace` | Projetos e documentação de trabalho (ponto de montagem principal). |
| `./config` | `/home/dev/.config` | Configuração persistente da aplicação / ferramentas. |
| `./memory` | `/home/dev/.memory` | Dados do **basic-memory** (grafo de notas, índices, etc.; `MEMORY_PATH`). |

Crie as pastas `config` e `memory` no host se ainda não existirem; o Compose monta-as mesmo vazias. O conteúdo de `./memory` é gerido pelo **basic-memory**; não edite manualmente salvo saber o que está a fazer.

## Permissões (host Linux / WSL)

O utilizador no contentor é **`dev`** (UID típico **1001**). Ficheiros criados dentro dos volumes podem ficar com esse dono no host. Se o seu utilizador no host for outro UID (por exemplo **1000**), o editor pode não conseguir gravar até corrigir o dono, por exemplo:

```bash
docker run --rm -v "$(pwd)/workspace:/w" alpine chown -R "$(id -u):$(id -g)" /w
```

(Ajuste o caminho do volume se necessário.)

## Estrutura do repositório

```
ai-jail/
├── Dockerfile              # Imagem: Ubuntu 24.04 + Node + pip tools
├── docker-compose.yml      # Serviço ai-jail, volumes e env
├── .env                    # Não versionar: GOOGLE_API_KEY (ver .gitignore)
├── workspace/              # Montado em /workspace — projetos e docs do agente
│   ├── GEMINI.md           # Regras gerais para o Gemini no ambiente
│   ├── AGENT_WORKFLOW.md   # Fluxo de trabalho (entender → planear → testes → …)
│   ├── GIT_WORKFLOW.md     # Convenções de branches e commits
│   ├── PROJECT.md          # Como estruturar e ler projetos em subpastas
│   └── MEMORY.md           # Uso da memória (basic-memory) pelos agentes
├── config/                 # (opcional no host) config persistente
└── memory/                 # (opcional no host) dados basic-memory
```

## Documentação em `workspace/`

- **`PROJECT.md`** — Como organizar cada projeto (ficheiros como `PRD.md`, `ARCHITECTURE.md`, `GEMINI.local.md`, etc.).
- **`GEMINI.md`** — Prioridade de instruções, âmbito, testes e segurança para o assistente.
- **`AGENT_WORKFLOW.md`** e **`GIT_WORKFLOW.md`** — Fluxo de execução e Git por defeito (podem ser sobrepostos por regras por projeto); no passo *Understand* pode incluir-se consulta à memória.
- **`MEMORY.md`** — Princípios para entradas de memória (o que gravar, o que evitar; complementa a secção de memória no `GEMINI.md`).

## Licença e upstream

- **Gemini CLI** e **basic-memory** têm as respetivas licenças nos respetivos repositórios/PyPI.
- Este repositório agrupa apenas Docker e documentação de ambiente; não inclui o código-fonte dessas ferramentas.
