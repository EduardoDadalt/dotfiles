# Dotfiles

Fonte única para instruções globais e skills pessoais usadas pelo Codex e pelo
Claude Code, e para os dotfiles compartilhados entre as máquinas Windows e
Arch Linux (WSL).

## Requisitos

- [Bun](https://bun.sh/)
- Codex e/ou Claude Code

## Estrutura

- `agents/instructions/AGENTS.md`: instruções globais carregadas pelo Codex.
- `agents/instructions/CLAUDE.md`: instruções globais do Claude Code; importa
  `AGENTS.md` para evitar duplicação.
- `agents/skills/`: cópia canônica das skills pessoais.
- `agents/claude/statusline.ts`: statusline do Claude Code, executada com `bun`
  por `statusLine.command` em `~/.claude/settings.json`.
- `packages/winget.txt`: pacotes instalados pelo `bootstrap.ps1`;
  `packages/pacman.txt` e `packages/aur.txt`: pacotes instalados pelo
  `bootstrap.sh` (um por linha; `#` inicia comentário).
- `bootstrap.ps1` (Windows) e `bootstrap.sh` (Arch Linux): preparam uma máquina
  nova e terminam aplicando os links.
- `home/`: dotfiles comuns a todos os sistemas, espelhando `~`. Cada arquivo é
  ligado ao mesmo caminho relativo no diretório pessoal; basta adicionar um
  arquivo aqui para gerenciá-lo.
- `home-linux/`: dotfiles só do Linux (zsh, btop), também espelhando `~`.
- `src/setup.ts`: instala os links, com dry-run e backup automático.
- `src/doctor.ts`: valida links, instruções e estrutura das skills.

## Máquina nova

### Windows

Instale o PowerShell 7 e o Git, clone o repositório e rode o bootstrap num
novo terminal:

```powershell
winget install --id Microsoft.PowerShell --exact
winget install --id Git.Git --exact
git clone https://github.com/EduardoDadalt/dotfiles.git C:\repo\dotfiles
pwsh -File C:\repo\dotfiles\bootstrap.ps1
```

O script instala os pacotes de `packages/winget.txt`, a FiraCode Nerd Font
(usada pelos ícones do Starship), o Vite+ (que fornece node, bun e pnpm) e o
Claude Code. Também ativa o Modo de Desenvolvedor, necessário para criar links
simbólicos de arquivo sem administrador; essa etapa abre um pedido do UAC. Ao
final mostra o dry-run do setup e pede confirmação antes de criar os links.
Depois, defina a fonte `FiraCode Nerd Font` no terminal (no Windows Terminal,
em `profiles.defaults.font.face`).

### Arch Linux (WSL)

Num Arch Linux (WSL) recém-instalado, com um usuário com `sudo`:

```bash
sudo pacman -S --needed git
git clone https://github.com/EduardoDadalt/dotfiles.git ~/repo/dotfiles
~/repo/dotfiles/bootstrap.sh
```

O script instala os pacotes das listas, o `yay`, Oh My Zsh e seus plugins, nvm,
Rust, Bun, pnpm, Flutter, Claude Code e Codex, ignorando o que já existir. Ao
final mostra o dry-run do setup e pede confirmação antes de criar os links.
Pode ser executado novamente a qualquer momento.

Se a máquina já tinha configurações próprias, siga o
[`MIGRATION.md`](MIGRATION.md) com um agente antes do bootstrap: ele compara a
máquina com o repositório e pergunta o que deve ser sincronizado.

Para incluir um pacote em todas as máquinas, adicione-o a `packages/winget.txt`
(Windows), `packages/pacman.txt` (repositórios oficiais) ou `packages/aur.txt`.

## Instalação

Revise primeiro o que será alterado:

```bash
bun run setup -- --dry-run
```

Depois aplique:

```bash
bun run setup -- --apply
bun run doctor
bun run typecheck
```

O setup configura:

```text
~/.codex/AGENTS.md              → agents/instructions/AGENTS.md
~/.claude/CLAUDE.md             → agents/instructions/CLAUDE.md
~/.agents/skills                → agents/skills/
~/.claude/skills                → agents/skills/
~/.claude/statusline.ts         → agents/claude/statusline.ts
~/<arquivo>                     → home/<arquivo>
~/<arquivo>                     → home-linux/<arquivo> (só no Linux)
```

No Windows, diretórios viram junctions e dois arquivos de `home/` vão para o
local que o programa realmente lê:

```text
%APPDATA%\GitHub CLI\config.yml → home/.config/gh/config.yml
<Documentos>\PowerShell\Microsoft.PowerShell_profile.ps1
  → home/.config/powershell/Microsoft.PowerShell_profile.ps1
```

Para usar a statusline, configure em `~/.claude/settings.json` (no Windows,
use o caminho absoluto, como `C:/Users/<usuário>/.claude/statusline.ts`):

```json
"statusLine": { "type": "command", "command": "bun ~/.claude/statusline.ts" }
```

Destinos existentes são movidos para um diretório datado em
`~/.local/state/dotfiles/backups/` antes da criação dos links. Executar o
setup novamente é seguro: links corretos não são recriados.

## Dotfiles

Os links de `home/` são criados arquivo por arquivo, então diretórios como
`~/.config` continuam reais e apenas os arquivos versionados viram links.

Configurações específicas de uma máquina ficam em arquivos `.local` fora do
repositório. O `.zshrc` carrega `~/.zshrc.local` e o perfil do PowerShell
carrega `~/.config/powershell/profile.local.ps1` quando eles existem.

Ferramentas que acrescentam linhas ao `.zshrc` (instaladores de pnpm, bun etc.)
escrevem pelo link diretamente no repositório; revise com `git diff` antes de
criar um commit.

## Gerenciar skills com skills.sh

Use diretamente o CLI do `skills.sh`, sempre com escopo global:

```bash
bunx skills add owner/repo@skill -g -a codex -a claude-code
bunx skills update -g
bunx skills remove --global nome-da-skill
```

Como `~/.agents/skills` aponta para este repositório, instalações globais são
gravadas em `agents/skills/`. O CLI também mantém o lock global próprio em
`~/.agents/.skill-lock.json`; ele não é versionado aqui.

Após adicionar, atualizar ou remover uma skill, revise as mudanças antes de
criar um commit:

```bash
git status --short
git diff
```

Não use uma instalação sem `-g` para este fluxo: o escopo padrão do CLI é o
projeto aberto no terminal.

## Referências

- [OpenAI: AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md)
- [OpenAI: skills](https://learn.chatgpt.com/docs/build-skills)
- [Claude Code: memory](https://code.claude.com/docs/en/memory)
- [Claude Code: skills](https://code.claude.com/docs/en/slash-commands)
- [Skills CLI](https://github.com/vercel-labs/skills)
