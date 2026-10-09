import { readdir } from "node:fs/promises";
import { homedir } from "node:os";
import { join, relative, resolve } from "node:path";

export type LinkSpec = {
  label: string;
  source: string;
  target: string;
};

export const homeDir = homedir();
export const repoRoot = resolve(import.meta.dir, "..");
export const agentsDir = join(repoRoot, "agents");
export const instructionsDir = join(agentsDir, "instructions");
export const skillsDir = join(agentsDir, "skills");
export const claudeDir = join(agentsDir, "claude");
export const dotfilesDir = join(repoRoot, "home");

const agentLinkSpecs: LinkSpec[] = [
  {
    label: "Instruções globais do Codex",
    source: join(instructionsDir, "AGENTS.md"),
    target: join(homeDir, ".codex", "AGENTS.md"),
  },
  {
    label: "Instruções globais do Claude Code",
    source: join(instructionsDir, "CLAUDE.md"),
    target: join(homeDir, ".claude", "CLAUDE.md"),
  },
  {
    label: "Skills canônicas",
    source: skillsDir,
    target: join(homeDir, ".agents", "skills"),
  },
  {
    label: "Skills do Claude Code",
    source: skillsDir,
    target: join(homeDir, ".claude", "skills"),
  },
  {
    label: "Statusline do Claude Code",
    source: join(claudeDir, "statusline-command.sh"),
    target: join(homeDir, ".claude", "statusline-command.sh"),
  },
];

// Cada arquivo em home/ é ligado ao caminho equivalente em ~. Os links são
// criados por arquivo para não substituir diretórios inteiros como ~/.config.
async function collectDotfiles(directory: string): Promise<string[]> {
  const entries = await readdir(directory, { withFileTypes: true });
  const files = await Promise.all(
    entries.map(async (entry) => {
      const path = join(directory, entry.name);
      return entry.isDirectory() ? collectDotfiles(path) : [path];
    }),
  );
  return files.flat().sort();
}

const dotfileLinkSpecs: LinkSpec[] = (await collectDotfiles(dotfilesDir)).map(
  (source) => {
    const relativePath = relative(dotfilesDir, source);
    return {
      label: `Dotfile ~/${relativePath}`,
      source,
      target: join(homeDir, relativePath),
    };
  },
);

export const linkSpecs: LinkSpec[] = [...agentLinkSpecs, ...dotfileLinkSpecs];

export function displayPath(path: string): string {
  return path === homeDir || path.startsWith(`${homeDir}/`)
    ? path.replace(homeDir, "~")
    : path;
}
