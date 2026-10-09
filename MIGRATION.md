# Migração de uma máquina existente

Roteiro para um agente (Claude Code ou Codex) executar numa máquina Arch Linux
(WSL) que já tem configurações próprias, possivelmente deixadas pelo antigo
projeto `setup-linux`. O objetivo é deixar a máquina igual ao repositório sem
perder nada que só exista nela.

Para iniciar, peça ao agente, dentro do repositório: "siga o MIGRATION.md".

## Regras para o agente

- Faça o inventário inteiro antes de alterar qualquer coisa.
- Pergunte antes de sobrescrever, apagar ou mover qualquer arquivo fora do
  repositório. O setup já move destinos existentes para backup; mesmo assim,
  confirme.
- Numere as perguntas e os achados sequencialmente para que o usuário possa
  responder por número.
- Nunca traga para o repositório credenciais ou estado da máquina: chaves SSH,
  `~/.codex/auth.json`, `~/.config/gh/hosts.yml`, tokens, históricos, caches e
  bancos `*.sqlite`. Na dúvida, mostre o conteúdo ao usuário e pergunte.
- Importar uma skill para `agents/skills/` exige autorização explícita do
  usuário para cada skill.
- O `bootstrap.sh` usa `sudo` e pede confirmação interativa; peça ao usuário que
  o execute num terminal, não o rode você mesmo.
- Não faça commit nem push sem pedir.

## 1. Preparar o repositório

1. Confirme que é Arch Linux sob WSL (`/etc/os-release` e `uname -r`).
2. Confirme que o repositório está atualizado (`git status`, `git pull`).
3. Verifique se as dependências do Bun estão instaladas (`bun install`). Se o
   Bun não existir, siga para a etapa 2 apenas com comandos de leitura e deixe a
   validação para depois do bootstrap.

## 2. Inventário (somente leitura)

Monte uma tabela por categoria. Para cada item, classifique como: **igual**,
**só no repositório**, **só na máquina** ou **diferente**.

### Dotfiles

- Para cada arquivo em `home/`, compare com o caminho equivalente em `~`: link
  correto, ausente, idêntico ou diferente. Se for diferente, mostre o `diff`.
- Procure candidatos que existam na máquina e ainda não estejam no repositório:
  `~/.gitconfig`, `~/.zprofile`, `~/.bashrc`, `~/.ssh/config` (só o arquivo de
  configuração, nunca as chaves), `~/.claude/settings.json`,
  `~/.codex/config.toml` e arquivos de configuração em `~/.config/*` (por
  exemplo `git`, `nvim`, `btop`, `gh/config.yml`).

### Configuração dos agentes

- Compare `~/.codex/AGENTS.md`, `~/.claude/CLAUDE.md` e
  `~/.claude/statusline-command.sh` com `agents/`.
- Liste as skills em `~/.agents/skills` e `~/.claude/skills` que não existem em
  `agents/skills/`. Ignore `synced/` e `.trash/`, que são gerenciados pelo
  Claude Code.

### Pacotes

- Compare `pacman -Qqen` com `packages/pacman.txt` e `pacman -Qqem` com
  `packages/aur.txt` (desconsidere `yay` e `yay-debug`).
- Pacotes **só no repositório** serão instalados pelo bootstrap; apenas
  informe.
- Pacotes **só na máquina** são candidatos a entrar nas listas. Agrupe por
  finalidade para facilitar a decisão.

### Ferramentas fora do pacman

- Plugins em `~/.oh-my-zsh/custom/plugins` que não estejam no `bootstrap.sh`
  (anote a URL com `git -C <plugin> remote get-url origin`).
- Binários em `~/.local/bin` e ferramentas instaladas por script (nvm, Rust,
  Bun, pnpm, Flutter, Claude Code, Codex). Para cada uma que não esteja no
  `bootstrap.sh`, descubra como foi instalada, consultando também o histórico do
  shell.

### Restos do setup-linux

- Procure links quebrados no diretório pessoal
  (`find ~ -maxdepth 3 -xtype l -not -path '*/node_modules/*'`) e links que
  apontem para um checkout do `setup-linux`.
- Procure trechos em `~/.zshrc`, `~/.bashrc` e `~/.zprofile` que carreguem
  arquivos do `setup-linux`.

## 3. Perguntas ao usuário

Apresente um resumo numerado e pergunte, item a item ou em grupos:

1. **Dotfile diferente:** usar a versão do repositório, trazer as mudanças
   locais para o repositório, ou mover a parte específica desta máquina para um
   arquivo `.local` (por exemplo `~/.zshrc.local`, que o `.zshrc` já carrega).
2. **Dotfile só na máquina:** adicionar a `home/` ou ignorar.
3. **Pacote só na máquina:** adicionar a `packages/pacman.txt` ou
   `packages/aur.txt`, ou ignorar.
4. **Ferramenta ou plugin fora do bootstrap:** adicionar uma etapa ao
   `bootstrap.sh` ou ignorar.
5. **Skill só na máquina:** importar para `agents/skills/` (exige autorização
   explícita) ou ignorar.
6. **Resto do setup-linux:** remover ou manter.

Diferenças entre as duas máquinas que devam continuar existindo vão para
arquivos `.local`, nunca para condicionais ou templates no repositório.

## 4. Aplicar as decisões

1. Altere o repositório conforme as respostas: copie arquivos para `home/`,
   edite as listas em `packages/`, acrescente etapas ao `bootstrap.sh` mantendo
   o estilo linear e idempotente.
2. Crie os arquivos `.local` combinados com o usuário.
3. Remova os restos do `setup-linux` que o usuário autorizou.
4. Peça ao usuário que execute `./bootstrap.sh` num terminal. Se ele preferir
   não reinstalar nada, `bun run setup -- --dry-run` seguido de
   `bun run setup -- --apply` cria apenas os links.

## 5. Validar

```bash
bash -n bootstrap.sh
bun run typecheck
bun run doctor
zsh -ic exit
```

`zsh -ic exit` não deve imprimir erros. Informe o diretório de backup criado
pelo setup em `~/.local/state/agent-config/backups/`.

## 6. Encerrar

Mostre `git status` e `git diff`, resuma o que mudou nesta máquina e no
repositório, e pergunte se o usuário quer fazer commit e push para que a outra
máquina receba as mudanças com `git pull`.
