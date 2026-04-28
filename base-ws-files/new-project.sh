#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="/workspace/.project-bootstrap.conf"

error() {
  echo "Erro: $1" >&2
  exit 1
}

warn() {
  echo "Aviso: $1" >&2
}

info() {
  echo "==> $1"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

ensure_sudo_available() {
  command_exists sudo || error "sudo não está disponível no ambiente."
}

require_file() {
  local file="$1"
  [ -f "$file" ] || error "Arquivo não encontrado: $file"
}

require_dir() {
  local dir="$1"
  [ -d "$dir" ] || error "Diretório não encontrado: $dir"
}

copy_file() {
  local src="$1"
  local dest="$2"

  require_file "$src"
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
}

load_config() {
  require_file "$CONFIG_FILE"

  # shellcheck disable=SC1090
  source "$CONFIG_FILE"

  : "${WORKSPACE:?WORKSPACE não definido no config}"
  : "${TEMPLATES_DIR:?TEMPLATES_DIR não definido no config}"
  : "${DEFAULT_BRANCH:=main}"
  : "${GITHUB_VISIBILITY:=public}"
  : "${GITHUB_OWNER:=}"
  : "${AUTO_CREATE_REMOTE:=true}"

  require_dir "$WORKSPACE"
  require_dir "$TEMPLATES_DIR"

  require_file "$TEMPLATES_DIR/README.md"
  require_file "$TEMPLATES_DIR/.env.example"

  require_file "$TEMPLATES_DIR/docs/AGENT.local.md"
  require_file "$TEMPLATES_DIR/docs/ARCHITECTURE.md"
  require_file "$TEMPLATES_DIR/docs/DECISIONS.md"
  require_file "$TEMPLATES_DIR/docs/PRD.md"
  require_file "$TEMPLATES_DIR/docs/TASKS.md"

  require_file "$TEMPLATES_DIR/.github/workflows/ci.yml.tpl"
  require_file "$TEMPLATES_DIR/.github/workflows/deploy.yml.tpl"
}

slugify() {
  local input="$1"

  echo "$input" \
    | tr '[:upper:]' '[:lower:]' \
    | sed 's/[^a-zA-Z0-9 ]//g' \
    | xargs \
    | sed 's/ //g'
}

escape_sed() {
  printf '%s' "$1" | sed -e 's/[\/&]/\\&/g'
}

next_project_id() {
  local max_id=0
  shopt -s nullglob

  for dir in "$WORKSPACE"/*; do
    [ -d "$dir" ] || continue

    local base
    base="$(basename "$dir")"

    if [[ "$base" =~ ^([0-9]+)- ]]; then
      local current_id="${BASH_REMATCH[1]}"

      if (( current_id > max_id )); then
        max_id=$current_id
      fi
    fi
  done

  echo $((max_id + 1))
}

render_template() {
  local template_file="$1"
  local output_file="$2"

  local project_id_esc project_name_esc project_slug_esc
  local project_summary_esc local_dir_name_esc github_repo_name_esc

  project_id_esc="$(escape_sed "$PROJECT_ID")"
  project_name_esc="$(escape_sed "$PROJECT_NAME")"
  project_slug_esc="$(escape_sed "$PROJECT_SLUG")"
  project_summary_esc="$(escape_sed "$PROJECT_SUMMARY")"
  local_dir_name_esc="$(escape_sed "$LOCAL_DIR_NAME")"
  github_repo_name_esc="$(escape_sed "$GITHUB_REPO_NAME")"

  sed \
    -e "s|{{PROJECT_ID}}|$project_id_esc|g" \
    -e "s|{{PROJECT_NAME}}|$project_name_esc|g" \
    -e "s|{{RAW_PROJECT_NAME}}|$project_name_esc|g" \
    -e "s|{{PROJECT_SLUG}}|$project_slug_esc|g" \
    -e "s|{{PROJECT_SUMMARY}}|$project_summary_esc|g" \
    -e "s|{{LOCAL_DIR_NAME}}|$local_dir_name_esc|g" \
    -e "s|{{GITHUB_REPO_NAME}}|$github_repo_name_esc|g" \
    "$template_file" > "$output_file"
}

create_readme() {
  local file="$1"

  cat > "$file" <<EOF
# $PROJECT_NAME

$PROJECT_SUMMARY

## Prerequisites

[If applicable]
EOF
}

create_gitignore() {
  local file="$1"

  cat > "$file" <<'EOF'
# OS
.DS_Store
Thumbs.db

# Editors
.vscode/
.idea/

# Logs
*.log

# Env
.env
.env.*

# Python
__pycache__/
*.pyc
.venv/
venv/

# JS / TS
node_modules/
dist/
build/
coverage/

# Misc
.tmp/
.cache/
EOF
}

ensure_git_identity() {
  if ! git config --global user.name >/dev/null 2>&1; then
    warn "git user.name não está configurado globalmente."
  fi

  if ! git config --global user.email >/dev/null 2>&1; then
    warn "git user.email não está configurado globalmente."
  fi
}

build_repo_target() {
  if [ -n "$GITHUB_OWNER" ]; then
    echo "${GITHUB_OWNER}/${GITHUB_REPO_NAME}"
  else
    echo "${GITHUB_REPO_NAME}"
  fi
}

create_remote_with_gh() {
  local project_dir="$1"
  local repo_target="$2"

  command_exists gh || error "GitHub CLI (gh) não instalada."

  if ! gh auth status >/dev/null 2>&1; then
    error "GitHub CLI não autenticada. Rode: gh auth login"
  fi

  cd "$project_dir"

  gh repo create "$repo_target" \
    --"$GITHUB_VISIBILITY" \
    --source=. \
    --remote=origin \
    --push
}

ensure_github_auth() {
  command_exists gh || error "gh não instalado"

  if ! gh auth status >/dev/null 2>&1; then
    error "GH_TOKEN não configurado"
  fi

  gh auth setup-git >/dev/null 2>&1 || error "Falha ao configurar git com gh"
}

init_git_repository() {
  local project_dir="$1"

  cd "$project_dir"

  git init
  git checkout -b "$DEFAULT_BRANCH"
  git add .
  git commit -m "chore: bootstrap project structure"
}

print_summary() {
  local project_dir="$1"
  local repo_target="$2"

  echo
  echo "Projeto criado com sucesso."
  echo "Diretório local: $project_dir"
  echo "Repo GitHub: $repo_target"
}

collect_input_interactive() {
  read -rp "Nome do projeto: " RAW_PROJECT_NAME
  read -rp "Resumo do projeto: " PROJECT_SUMMARY
}

collect_input_args() {
  RAW_PROJECT_NAME="${1:-}"
  PROJECT_SUMMARY="${2:-}"
}

validate_input() {
  [ -n "${RAW_PROJECT_NAME:-}" ] || error "Nome do projeto é obrigatório."
  [ -n "${PROJECT_SUMMARY:-}" ] || error "Resumo do projeto é obrigatório."
}

main() {
  load_config
  ensure_sudo_available
  ensure_git_identity

  if [ "$#" -ge 2 ]; then
    collect_input_args "$@"
  else
    echo "=== Novo Projeto AI Jail ==="
    collect_input_interactive
  fi

  validate_input

  PROJECT_SLUG="$(slugify "$RAW_PROJECT_NAME")"
  [ -n "$PROJECT_SLUG" ] || error "Não foi possível gerar slug do projeto."

  PROJECT_ID="$(next_project_id)"
  PROJECT_NAME="$RAW_PROJECT_NAME"

  LOCAL_DIR_NAME="${PROJECT_ID}-${PROJECT_SLUG}-dev.local"
  GITHUB_REPO_NAME="${PROJECT_ID}-${PROJECT_SLUG}"
  REPO_TARGET="$(build_repo_target)"

  PROJECT_DIR="${WORKSPACE}/${LOCAL_DIR_NAME}"
  DOCS_DIR="${PROJECT_DIR}/docs"
  GITHUB_WORKFLOWS_DIR="${PROJECT_DIR}/.github/workflows"

  [ ! -e "$PROJECT_DIR" ] || error "O diretório já existe: $PROJECT_DIR"

  info "Criando estrutura do projeto"

  sudo mkdir -p \
    "$PROJECT_DIR" \
    "$DOCS_DIR" \
    "$GITHUB_WORKFLOWS_DIR"

  sudo chown -R "$(id -u):$(id -g)" "$PROJECT_DIR"
  sudo chmod -R u+rwX "$PROJECT_DIR"

  create_readme "$PROJECT_DIR/README.md"

  copy_file "$TEMPLATES_DIR/.env.example" "$PROJECT_DIR/.env.example"

  render_template "$TEMPLATES_DIR/docs/AGENT.local.md" "$DOCS_DIR/AGENT.local.md"
  render_template "$TEMPLATES_DIR/docs/ARCHITECTURE.md" "$DOCS_DIR/ARCHITECTURE.md"
  render_template "$TEMPLATES_DIR/docs/DECISIONS.md" "$DOCS_DIR/DECISIONS.md"
  render_template "$TEMPLATES_DIR/docs/PRD.md" "$DOCS_DIR/PRD.md"
  render_template "$TEMPLATES_DIR/docs/TASKS.md" "$DOCS_DIR/TASKS.md"

  render_template "$TEMPLATES_DIR/.github/workflows/ci.yml.tpl" "$GITHUB_WORKFLOWS_DIR/ci.yml"
  render_template "$TEMPLATES_DIR/.github/workflows/deploy.yml.tpl" "$GITHUB_WORKFLOWS_DIR/deploy.yml"

  create_gitignore "$PROJECT_DIR/.gitignore"

  info "Inicializando git"
  init_git_repository "$PROJECT_DIR"

  if [ "$AUTO_CREATE_REMOTE" = "true" ]; then
    info "Validando autenticação GitHub"
    ensure_github_auth

    info "Criando repositório remoto no GitHub"
    create_remote_with_gh "$PROJECT_DIR" "$REPO_TARGET"
  else
    warn "AUTO_CREATE_REMOTE=false. Repositório remoto não foi criado."
  fi

  print_summary "$PROJECT_DIR" "$REPO_TARGET"
}

main "$@"