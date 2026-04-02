# ai-jail

Ambiente de desenvolvimento em **Docker** pensado para rodar o [**Gemini CLI**](https://www.npmjs.com/package/@google/gemini-cli) da Google, o [**basic-memory**](https://pypi.org/project/basic-memory/) (conhecimento local / MCP) e o [**GitHub CLI**](https://cli.github.com/) (`gh`) para automatizar a criação de repositórios a partir de `workspace/new-project.sh`.

## O que inclui

| Componente | Função |
|------------|--------|
| **Ubuntu 24.04** | Base com Python **3.12+** (requisito do `basic-memory`). |
| **Node.js 20** | Runtime para o Gemini CLI (instalado globalmente). |
| **`@google/gemini-cli`** | Assistente de linha de comando no container. |
| **`basic-memory`** | Instalado via `pip` no Python do sistema; dados persistentes em `./memory`. |
| **`gh` (GitHub CLI)** | Instalado via apt; usado pelo script de novo projeto para `gh repo create` e push. |
| **Ferramentas** | `git`, `curl`, `build-essential`, `vim`, `nano`, `sudo` (utilizador `dev` com sudo). |

A pasta **`workspace/`** reúne convenções para agentes (`GEMINI.md`, `AGENT_WORKFLOW.md`, `GIT_WORKFLOW.md`, `PROJECT.md`, `MEMORY.md`), templates em **`workspace/project-templates/`** e o script **`workspace/new-project.sh`** para gerar novos projetos. Consulte também **`COMANDOS-IMPORTANTES.md`** para referência rápida de comandos.

### Memória (basic-memory)

O **`basic-memory`** usa o volume montado em **`MEMORY_PATH`** (`/home/dev/.memory` no container, **`./memory`** no host). A documentação em **`workspace/MEMORY.md`** define o uso da memória pelos agentes (contexto auxiliar, não fonte de verdade).

## Pré-requisitos

- Docker e Docker Compose (`docker compose`)
- Conta **GitHub** e permissão para criar repositórios (pessoal ou organização)
- Chave **Google** para o Gemini: **`GOOGLE_API_KEY`**

## Configuração do ambiente (`.env`)

Na raiz do repositório, crie um ficheiro **`.env`** (não versionado). Exemplo de variáveis usadas pelo `docker-compose.yml`:

```env
GOOGLE_API_KEY=sua_chave_google
GH_TOKEN=ghp_xxxxxxxx
GIT_USER_NAME=Seu Nome
GIT_USER_EMAIL=seu-email@exemplo.com
```

| Variável | Uso |
|----------|-----|
| `GOOGLE_API_KEY` | Gemini CLI / ferramentas que consumam a API Google. |
| `GH_TOKEN` | Token clássico do GitHub (ex.: âmbito `repo`) — o `gh` usa esta variável quando está definida. |
| `GIT_USER_NAME` / `GIT_USER_EMAIL` | O **`docker-entrypoint.sh`** aplica automaticamente `git config --global user.name` e `user.email` ao iniciar o container. **Não precisa** de criar nem editar `.gitconfig` à mão no repositório. |

**Segurança:** nunca commite `.env` nem tokens. O GitHub pode bloquear push se segredos aparecerem em ficheiros versionados (ex.: evitar versionar `./config/gh/`).

Subir o ambiente:

```bash
docker compose build
docker compose up -d
docker exec -it ai-jail bash
```

O `docker-compose.yml` expõe várias **portas** no host (3000, 4000, … até 10000) mapeadas para o mesmo número no container — útil para APIs em desenvolvimento.

---

## Passo a passo: Git e GitHub (`gh`) no container

### 1. Identidade do Git (commits)

Preencha **`GIT_USER_NAME`** e **`GIT_USER_EMAIL`** no `.env` e suba o container (`docker compose up -d`). O script **`docker-entrypoint.sh`** configura o Git automaticamente para o utilizador `dev` — não é necessário correr `git config --global` manualmente nem manter um ficheiro `.gitconfig` no projeto.

Se alterar nome ou email no `.env`, **reinicie o container** (`docker compose up -d`). Para confirmar:

```bash
git config --global user.name
git config --global user.email
```

### 2. Autenticação do `gh`

Com **`GH_TOKEN`** já definido no `.env`, o `gh` reconhece o token na sessão. Muitos utilizadores completam o login com uma sessão **HTTPS** interativa:

```bash
gh auth login
```

Escolha **HTTPS**, **GitHub.com** e o método que preferir (navegador ou token). O estado de autenticação pode persistir em **`./config`** no host (volume montado em `/home/dev/.config`).

Confirme:

```bash
gh auth status
```

Se algo falhar, verifique o âmbito do token (`repo`, e organização se aplicável).

### 3. Integração Git ↔ `gh` (opcional)

```bash
gh auth setup-git
```

### 4. Organização / dono do repositório (opcional)

Edite **`workspace/.project-bootstrap.conf`** no host:

- `GITHUB_OWNER=""` — repósito criado na sua conta pessoal.
- `GITHUB_OWNER="minha-org"` — repósito criado na organização `minha-org` (requer permissões no token/conta).

Outras chaves úteis: `GITHUB_VISIBILITY` (`private`/`public`), `AUTO_CREATE_REMOTE` (`true`/`false`).

---

## Passo a passo: criar um projeto com `new-project.sh`

O script gera uma pasta numerada em `/workspace`, ficheiros a partir dos templates em **`workspace/project-templates/`** e, se `AUTO_CREATE_REMOTE=true`, executa **`gh repo create`** com push.

### Pré-requisitos

- Ficheiro **`workspace/.project-bootstrap.conf`** presente e válido.
- Templates referenciados pelo script (ex.: `README.tpl.md`, `docs/*.tpl.md`).
- `GIT_USER_NAME` e `GIT_USER_EMAIL` no `.env` (identidade Git aplicada pelo entrypoint).
- `gh` autenticado e, se usar `gh repo create`, token/sessão válidos (secção anterior).

### Execução no container

```bash
chmod +x /workspace/new-project.sh
```

**Modo interativo**

```bash
/workspace/new-project.sh
```

**Modo não interativo** (nome, tipo `backend` ou `frontend`, resumo)

```bash
/workspace/new-project.sh "Nome do projeto" backend "Resumo em uma frase"
```

O nome da pasta segue o padrão **`{id}-{slug}-{tipo}-dev.local`** (ex.: `1-meuprojeto-backend-dev.local`) e o repositório remoto o padrão **`{id}-{slug}-{tipo}`**, salvo `GITHUB_OWNER` definido.

---

## Build e execução (resumo)

```bash
docker compose build
docker compose run --rm ai-jail bash
```

Ou em segundo plano:

```bash
docker compose up -d
docker exec -it ai-jail bash
```

## Volumes

| Host | Container | Uso |
|------|-------------|-----|
| `./workspace` | `/workspace` | Projetos, templates, `new-project.sh`, documentação de agentes. |
| `./config` | `/home/dev/.config` | Configuração persistente (ex.: ferramentas que gravem em `~/.config`). |
| `./memory` | `/home/dev/.memory` | Dados do **basic-memory**. |

Crie `config` e `memory` no host se não existirem. O conteúdo de `./memory` é gerido pelo **basic-memory**; evite editar manualmente sem necessidade.

## Permissões (host Linux / WSL)

Ficheiros criados no container podem aparecer no host com UID/GID do utilizador do container. Se o editor reportar *permission denied* no `workspace/`:

```bash
docker run --rm -v "$(pwd)/workspace:/w" alpine sh -c 'chown -R "$(id -u):$(id -g)" /w && chmod -R u+rwX /w'
```

*(Executar na raiz do clone `ai-jail` no host.)*

## Estrutura do repositório

```
ai-jail/
├── Dockerfile
├── docker-compose.yml
├── docker-entrypoint.sh
├── COMANDOS-IMPORTANTES.md   # Referência rápida de comandos
├── .env                      # Não versionar (chaves e tokens)
├── workspace/
│   ├── GEMINI.md
│   ├── AGENT_WORKFLOW.md
│   ├── GIT_WORKFLOW.md
│   ├── PROJECT.md
│   ├── MEMORY.md
│   ├── new-project.sh
│   ├── .project-bootstrap.conf
│   └── project-templates/
├── config/                   # Volume: config persistente (ex.: gh)
└── memory/                   # Volume: basic-memory
```

## Documentação em `workspace/`

- **`PROJECT.md`** — Estrutura e leitura de projetos em subpastas.
- **`GEMINI.md`** — Prioridade de instruções e regras do assistente.
- **`AGENT_WORKFLOW.md`** / **`GIT_WORKFLOW.md`** — Fluxo de trabalho e Git.
- **`MEMORY.md`** — Uso da memória (basic-memory).

## Licença e upstream

- **Gemini CLI**, **basic-memory** e **GitHub CLI** têm licenças nos respetivos projetos.
- Este repositório contém Docker, scripts e documentação de ambiente; não inclui o código-fonte upstream dessas ferramentas.
