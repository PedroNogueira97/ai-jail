# Comandos importantes

Referência rápida de comandos úteis no ambiente **ai-jail** (host WSL/Linux e container).  
Vai acrescentando secções ou entradas à medida que precisar.

---

## Projeto novo (`new-project.sh`)

Executar **dentro do container** (caminho montado em `/workspace`).

### Modo interativo

```bash
chmod +x /workspace/new-project.sh
/workspace/new-project.sh
```

### Modo não interativo

```bash
/workspace/new-project.sh "Nome do projeto" backend "Resumo em uma frase"
```

**Exemplo (nome + tipo + resumo):**

```bash
/workspace/new-project.sh "CV Agent" backend "Agente de IA para análise e otimização de currículos"
```

---

## SSH — túnel para porta local

Útil quando um serviço corre no servidor e queres aceder como `localhost` na tua máquina.

**Formato:**

```bash
ssh -L [porta_local]:127.0.0.1:[porta_remota] usuario@servidor
```

**Exemplo (porta 3000):**

```bash
ssh -L 3000:127.0.0.1:3000 usuario@servidor
```

---

## Permissões — corrigir dono do `workspace` (host)

Quando ficheiros criados no container ficam com UID errado e o editor dá *permission denied*:

```bash
docker run --rm -v "$(pwd)/workspace:/w" alpine sh -c 'chown -R "$(id -u):$(id -g)" /w && chmod -R u+rwX /w'
```

```bash
sudo chmod -R g+rwX,o-rwx /home/pedro/ai-jail/workspace
```

*(Executar na pasta raiz do repo `ai-jail` no host.)*

---

## Docker — rebuild rápido

```bash
docker compose down
docker compose up -d --build
```

---

## A acrescentar

| Secção sugerida | Exemplos |
|-----------------|----------|
| Git / `gh` | login, criar repo, variáveis |
| Nest / Node | `npm run`, testes |
| Depuração | portas, logs do container |
