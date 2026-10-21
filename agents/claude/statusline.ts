// Statusline do Claude Code: modelo, esforço, branch, contexto usado e o que
// resta dos limites de 5h e 7d. Recebe o estado da sessão em JSON pelo stdin.

type RateLimit = {
  used_percentage?: number;
  resets_at?: number;
};

type StatusInput = {
  model?: { display_name?: string };
  effort?: { level?: string };
  workspace?: { current_dir?: string };
  cwd?: string;
  context_window?: { used_percentage?: number };
  rate_limits?: {
    five_hour?: RateLimit;
    seven_day?: RateLimit;
  };
};

const dim = "\x1b[2m";
const reset = "\x1b[0m";
const cyan = "\x1b[36m";
const yellow = "\x1b[33m";
const magenta = "\x1b[35m";
const green = "\x1b[32m";

const input = (await Bun.stdin.json()) as StatusInput;
const now = Date.now() / 1000;

function clampPercent(value: number): number {
  return Math.round(Math.min(100, Math.max(0, value)));
}

function currentBranch(cwd: string): string | undefined {
  const attempts = [
    ["symbolic-ref", "--short", "HEAD"],
    ["rev-parse", "--short", "HEAD"],
  ];
  for (const args of attempts) {
    const result = Bun.spawnSync(
      ["git", "-C", cwd, "--no-optional-locks", ...args],
      { stderr: "ignore" },
    );
    if (result.success) {
      return result.stdout.toString().trim();
    }
  }
  return undefined;
}

function formatTime(epochSeconds: number): string {
  const date = new Date(epochSeconds * 1000);
  const hours = String(date.getHours()).padStart(2, "0");
  const minutes = String(date.getMinutes()).padStart(2, "0");
  return `${hours}:${minutes}`;
}

// O "ideal" é a fração da janela que ainda falta transcorrer: restar menos
// limite que isso significa consumo acima do ritmo.
function rateLimitSegment(
  label: string,
  limit: RateLimit | undefined,
  windowSeconds: number,
  showReset: boolean,
): string | undefined {
  if (typeof limit?.used_percentage !== "number") {
    return undefined;
  }

  const remaining = clampPercent(100 - limit.used_percentage);
  let segment = `${dim}${label}:${reset} ${magenta}${remaining}%${reset}`;
  if (typeof limit.resets_at === "number") {
    const ideal = clampPercent(((limit.resets_at - now) / windowSeconds) * 100);
    const resetTime = showReset ? `, reset ${formatTime(limit.resets_at)}` : "";
    segment += ` ${dim}(ideal ${ideal}%${resetTime})${reset}`;
  }
  return segment;
}

const parts: string[] = [];

const modelAndEffort = [input.model?.display_name, input.effort?.level]
  .filter((value) => value)
  .map((value) => `${dim}${cyan}${value}${reset}`)
  .join(" ");
if (modelAndEffort) {
  parts.push(modelAndEffort);
}

const cwd = input.workspace?.current_dir ?? input.cwd;
const branch = cwd ? currentBranch(cwd) : undefined;
if (branch) {
  parts.push(`${dim}${green}${branch}${reset}`);
}

const contextUsed = input.context_window?.used_percentage;
if (typeof contextUsed === "number") {
  parts.push(`${dim}ctx:${reset} ${yellow}${Math.round(contextUsed)}%${reset}`);
}

const fiveHour = rateLimitSegment(
  "5h",
  input.rate_limits?.five_hour,
  5 * 60 * 60,
  true,
);
if (fiveHour) {
  parts.push(fiveHour);
}

const sevenDay = rateLimitSegment(
  "7d",
  input.rate_limits?.seven_day,
  7 * 24 * 60 * 60,
  false,
);
if (sevenDay) {
  parts.push(sevenDay);
}

console.log(parts.join(` ${dim}|${reset} `));
