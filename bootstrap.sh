#!/usr/bin/env bash
# Prepara uma máquina Arch Linux (WSL): instala pacotes e ferramentas e, ao
# final, cria os links deste repositório. Pode ser executado novamente: cada
# etapa é ignorada quando já está concluída.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

step() {
  printf '\n\033[1;36m==> %s\033[0m\n' "$1"
}

have() {
  command -v "$1" >/dev/null 2>&1
}

# Lê uma lista de pacotes ignorando comentários e linhas vazias.
read_list() {
  sed -e 's/#.*//' -e 's/[[:space:]]*$//' -e '/^$/d' "$1"
}

clone_if_missing() {
  local url="$1" target="$2"
  shift 2
  if [ ! -d "$target" ]; then
    git clone --depth=1 "$@" "$url" "$target"
  fi
}

step "Pacotes oficiais"
read_list "$repo_root/packages/pacman.txt" | sudo pacman -Syu --needed -

step "yay"
if ! have yay; then
  build_dir="$(mktemp -d)"
  git clone https://aur.archlinux.org/yay.git "$build_dir/yay"
  (cd "$build_dir/yay" && makepkg -si --noconfirm)
  rm -rf "$build_dir"
fi

step "Pacotes do AUR"
aur_packages="$(read_list "$repo_root/packages/aur.txt")"
if [ -n "$aur_packages" ]; then
  yay -S --needed $aur_packages
fi

step "Banco do pkgfile (plugin command-not-found)"
if [ -z "$(ls -A /var/cache/pkgfile 2>/dev/null)" ]; then
  sudo pkgfile --update
fi

step "Oh My Zsh e plugins"
zsh_custom="$HOME/.oh-my-zsh/custom/plugins"
clone_if_missing https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
clone_if_missing https://github.com/Aloxaf/fzf-tab "$zsh_custom/fzf-tab"
clone_if_missing https://github.com/MichaelAquilina/zsh-you-should-use "$zsh_custom/you-should-use"
clone_if_missing https://github.com/zsh-users/zsh-autosuggestions "$zsh_custom/zsh-autosuggestions"
clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting "$zsh_custom/zsh-syntax-highlighting"

if [ "$(getent passwd "$USER" | cut -d: -f7)" != "/usr/bin/zsh" ]; then
  chsh -s /usr/bin/zsh
fi

# Os instaladores abaixo podem alterar arquivos de shell; como rodam antes do
# setup, essas alterações vão para o backup e não para o repositório.
step "nvm"
if [ ! -d "$HOME/.nvm" ]; then
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.7/install.sh | PROFILE=/dev/null bash
fi

step "Rust"
if [ ! -d "$HOME/.cargo" ]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
fi

step "Bun"
if [ ! -x "$HOME/.bun/bin/bun" ]; then
  curl -fsSL https://bun.sh/install | bash
fi

step "pnpm"
if [ ! -d "$HOME/.local/share/pnpm" ]; then
  curl -fsSL https://get.pnpm.io/install.sh | sh -
fi

step "Flutter"
if [ ! -d "$HOME/development/flutter" ]; then
  mkdir -p "$HOME/development"
  git clone https://github.com/flutter/flutter.git -b stable "$HOME/development/flutter"
fi

step "Claude Code"
if [ ! -e "$HOME/.local/bin/claude" ]; then
  curl -fsSL https://claude.ai/install.sh | bash
fi

step "Codex"
if [ ! -e "$HOME/.local/bin/codex" ]; then
  curl -fsSL https://chatgpt.com/codex/install.sh | CODEX_NON_INTERACTIVE=1 sh
fi

step "Links do repositório"
bun="$HOME/.bun/bin/bun"
cd "$repo_root"
"$bun" install
"$bun" run setup -- --dry-run
read -rp $'\nAplicar os links acima? [s/N] ' answer
if [[ "$answer" =~ ^[sS]$ ]]; then
  "$bun" run setup -- --apply
  "$bun" run doctor
else
  echo "Links não aplicados. Rode depois: bun run setup -- --apply"
fi
