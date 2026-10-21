import { readdir } from "node:fs/promises";
import { homedir } from "node:os";
import { join, relative, resolve, sep } from "node:path";

export type LinkSpec = {
  label: string;
  source: string;
  target: string;
};

export const isWindows = process.platform === "win32";
export const homeDir = homedir();
export const repoRoot = resolve(import.meta.dir, "..");
export const agentsDir = join(repoRoot, "agents");
export const instructionsDir = join(agentsDir, "instructions");
export const skillsDir = join(agentsDir, "skills");
export const claudeDir = join(agentsDir, "claude");
export const dotfilesDir = join(repoRoot, "home");
export const linuxDotfilesDir = join(repoRoot, "home-linux");

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
    source: join(claudeDir, "statusline.ts"),
    target: join(homeDir, ".claude", "statusline.ts"),
  },
];

// O perfil do PowerShell 7 fica na pasta Documentos, que pode estar no
// OneDrive. O powershell.exe é usado na consulta porque sempre existe no
// Windows, enquanto o pwsh costuma ser um alias que o Bun não executa.
function powershellProfilePath(): string {
  const result = Bun.spawnSync([
    "powershell.exe",
    "-NoLogo",
    "-NoProfile",
    "-Command",
    "[Environment]::GetFolderPath('MyDocuments')",
  ]);
  const documentsDir = result.stdout.toString().trim();
  if (!result.success || !documentsDir) {
    throw new Error("Não foi possível obter a pasta Documentos do Windows");
  }
  return join(documentsDir, "PowerShell", "Microsoft.PowerShell_profile.ps1");
}

function requiredEnv(name: string): string {
  const value = process.env[name];
  if (!value) {
    throw new Error(`Variável de ambiente ausente: ${name}`);
  }
  return value;
}

// No Windows alguns programas não leem o caminho equivalente em ~; estes
// arquivos de home/ são ligados ao local que cada um realmente usa.
const windowsTargets: Record<string, string> = isWindows
  ? {
      ".config/gh/config.yml": join(
        requiredEnv("APPDATA"),
        "GitHub CLI",
        "config.yml",
      ),
      ".config/powershell/Microsoft.PowerShell_profile.ps1":
        powershellProfilePath(),
    }
  : {};

// home/ vale para todos os sistemas; home-linux/ só para o Linux.
const dotfileRoots = isWindows
  ? [dotfilesDir]
  : [dotfilesDir, linuxDotfilesDir];

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

const dotfileLinkSpecs: LinkSpec[] = (
  await Promise.all(
    dotfileRoots.map(async (root) =>
      (await collectDotfiles(root)).map((source) => {
        const relativePath = relative(root, source).replaceAll(sep, "/");
        return {
          label: `Dotfile ~/${relativePath}`,
          source,
          target: windowsTargets[relativePath] ?? join(homeDir, relativePath),
        };
      }),
    ),
  )
).flat();

export const linkSpecs: LinkSpec[] = [...agentLinkSpecs, ...dotfileLinkSpecs];

export function displayPath(path: string): string {
  return path === homeDir || path.startsWith(`${homeDir}${sep}`)
    ? path.replace(homeDir, "~")
    : path;
}
