# 🔒 ai-jail

> A Docker-based **AI development environment** designed to run multiple coding assistants in complete isolation — your own personal **AI Dev OS**.

Each AI agent runs in its own container while sharing a single, controlled workspace. No conflicts. No leakage. Full reproducibility.

---

## 🤖 Supported AI Agents

| Agent | Provider | Description |
|---|---|---|
| **OpenClaude** | OpenRouter / OpenAI | Multi-provider, cost-optimized |
| **Claude Code** | Anthropic | Official CLI, best-in-class coding |
| **Gemini CLI** | Google | Gemini models via terminal |

---

## 🧠 Architecture

The environment is structured in two layers:

### 🔹 `ai-base` — Shared Base Image

A foundational Docker image that all containers extend. It includes:

- Ubuntu 24.04
- PHP 8.3
- Node.js 22
- Python
- Git + GitHub CLI (`gh`)
- Composer
- Dev tools: `ripgrep`, `jq`, and more

> ⚠️ This image is **not meant to run directly** — it exists to be extended by each AI container.

---

### 🔹 AI Containers

| Container | Purpose |
|---|---|
| `ai-jail` | Main development environment |
| `openclaude` | Multi-provider AI (OpenRouter / OpenAI) |
| `claudecode` | Official Anthropic Claude Code CLI |
| `gemini` | Google Gemini CLI |

All containers mount the same shared workspace at `/workspace`.

---

## 📁 Workspace Layout

The workspace lives **outside the repository** to avoid Git conflicts:

```
~
├── ai-jail/        ← this repo
└── workspace/      ← your projects live here
```

Each subdirectory inside `/workspace` becomes its own independent Git repository.

**Docker volume mapping:**

```yaml
- ../workspace:/workspace
```

---

## ⚙️ Environment Configuration

Create a `.env` file in the project root:

```env
# Git
GH_TOKEN=ghp_xxxxx
GIT_USER_NAME=Your Name
GIT_USER_EMAIL=your@email.com

# OpenClaude (OpenAI / OpenRouter)
OPENAI_API_KEY=
OPENAI_BASE_URL=https://api.openai.com/v1
OPENAI_MODEL=gpt-4o-mini

# Claude Code
ANTHROPIC_API_KEY=

# Gemini
GOOGLE_API_KEY=
```

---

## 🐳 Building the Environment

**Step 1 — Build the base image:**

```bash
docker build -f Dockerfile.ai-base -t ai-base:latest .
```

**Step 2 — Build all containers:**

```bash
docker compose build
```

---

## 🚀 Running Containers

You don't need to run everything — spin up only the agents you need.

### Base Environment

```bash
docker compose up -d ai-jail
docker compose exec ai-jail bash
```

### OpenClaude

```bash
docker compose up -d openclaude
docker compose exec openclaude bash

# Or launch Openclaude directly:
docker compose exec openclaude openclaude
```

### Claude Code

```bash
docker compose up -d claudecode
docker compose exec claudecode bash

# Or launch Claude directly:
docker compose exec claudecode claude
```

### Gemini

```bash
docker compose up -d gemini
docker compose exec gemini bash

# Or launch Gemini directly:
docker compose exec gemini gemini
```

### Running Multiple Agents Simultaneously

```bash
docker compose up -d ai-jail openclaude
```

---

## 🧪 Quick Smoke Test

Once inside a container, verify the workspace is accessible:

```bash
ls /workspace
```

Create a test project:

```bash
mkdir /workspace/test
cd /workspace/test
git init
```

---

## 🔐 Permissions

If you encounter permission errors like:

```
Permission denied
```

Run this on the **host machine** to fix ownership:

```bash
sudo chown -R 1000:1000 ../workspace
sudo chmod -R u+rwX,g+rwX ../workspace
```

---

## ⚡ Creating a New Project

Use the helper script to scaffold a new project inside `/workspace`:

```bash
/workspace/new-project.sh
```

Or pass arguments directly:

```bash
/workspace/new-project.sh "My Project" backend "Short description"
```

---

## 🧠 Choosing the Right AI Agent

| Use Case | Recommended Agent |
|---|---|
| Multi-model support / cost optimization | **OpenClaude** |
| Best coding experience with Claude | **Claude Code** |
| Google ecosystem / Gemini experiments | **Gemini** |

---

## 🧩 Project Structure

```
ai-jail/
├── Dockerfile.ai-base       ← shared base image
├── Dockerfile               ← main ai-jail container
├── Dockerfile.openclaude    ← OpenClaude container
├── Dockerfile.claudecode    ← Claude Code container
├── Dockerfile.geminicli     ← Gemini CLI container
├── docker-compose.yml
├── docker-entrypoint.sh
├── .env                     ← your secrets (not committed)
└── ../workspace/            ← external shared workspace
```

---

## 💡 Philosophy

- **Isolation** — each AI runs in its own sandboxed container
- **Controlled access** — all agents share one workspace, nothing else
- **Independence** — each project is a self-contained Git repository
- **Reproducibility** — the full environment can be rebuilt from scratch at any time

---

## ⚠️ Important Notes

- This repository is **not directly deployable** to production
- CI/CD pipelines live **inside projects** created under `/workspace`, not in this repo
- Never commit your `.env` file — add it to `.gitignore`