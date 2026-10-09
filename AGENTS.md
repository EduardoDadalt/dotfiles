# Repository Guidelines

## Project Structure & Module Organization

This repository is the canonical source for personal Codex and Claude Code configuration and for the dotfiles shared across personal Arch Linux (WSL) machines. TypeScript utilities live in `src/`: `config.ts` defines paths and link specifications, `setup.ts` installs symbolic links with backups, and `doctor.ts` validates an installation. Agent files live in `agents/`: global instructions in `agents/instructions/`, the Claude Code statusline in `agents/claude/`, and skills in `agents/skills/`. Each directory under `agents/skills/` is a self-contained skill with a required `SKILL.md`; supporting templates and the skill's own `agents/openai.yaml` belong beside that skill. Dotfiles live in `home/`, mirroring `~`: every file there is linked to the same relative path under the home directory, so adding a file to `home/` is enough to manage it. Machine-specific settings belong in untracked `.local` files (for example `~/.zshrc.local`), never in templates. `bootstrap.sh` prepares a fresh machine: it installs the packages listed in `packages/pacman.txt` and `packages/aur.txt` plus tools that use their own installers, then runs the setup. Keep it a linear, idempotent Bash script where every step skips work that is already done. Project metadata is in `package.json`, `bun.lock`, and `tsconfig.json`.

## Skill Management

Create new personal skills directly in `agents/skills/<skill-name>/` within this repository, including any supporting resources. Pass this destination explicitly to skill creation tools. The existing `~/.agents/skills` and `~/.claude/skills` symbolic links expose this directory to Codex and Claude Code.

## Build, Test, and Development Commands

- `bun install` installs the pinned development dependencies.
- `bun run typecheck` runs strict TypeScript checking without emitting files.
- `bun run setup -- --dry-run` previews link creation and backup actions. Run this before applying configuration changes.
- `bun run setup -- --apply` installs the configured links into the user’s home directory.
- `bun run doctor` checks Bun, repository links, instruction imports, and skill metadata.
- `./bootstrap.sh` installs packages and tools on a fresh machine, then applies the links after confirmation. Validate changes with `bash -n bootstrap.sh`; running it calls `sudo pacman -Syu`.

There is no build artifact; Bun executes the TypeScript sources directly.

## Coding Style & Naming Conventions

Follow the existing TypeScript style: two-space indentation, double quotes, semicolons, trailing commas, explicit return types for named functions, and `node:` imports. Keep ESM imports explicit, including the `.ts` extension for local modules. Preserve strict compiler guarantees; do not weaken `tsconfig.json` to bypass an error. Name source files and variables in lower camel case. Use kebab-case for skill directories, and make each `SKILL.md` frontmatter `name` exactly match its directory.

## Testing Guidelines

No automated test framework is configured. Treat `bun run typecheck` as the minimum code check. For setup or link changes, run the dry-run first and then `bun run doctor` in a configured environment. Add focused tests if logic becomes complex; use `*.test.ts` names and keep tests close to the relevant source or under a future `tests/` directory.

## Commit & Pull Request Guidelines

The current history uses Conventional Commit-style subjects, for example `chore: centralize agent configuration`. Continue with concise, imperative subjects such as `fix: restore conflicting link after failure`. Pull requests should explain the motivation and user-visible configuration impact, list validation commands run, and link relevant issues. Include terminal output when setup behavior changes; screenshots are unnecessary for CLI-only changes.

## Safety & Configuration Tips

Never commit credentials or machine-specific state. Review `git diff` after managing skills. Because `setup --apply` changes home-directory paths, verify its dry-run output and backup destination before applying it.
