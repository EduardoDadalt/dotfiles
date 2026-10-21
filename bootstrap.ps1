#Requires -Version 7.4
# Prepara uma máquina Windows: instala pacotes e ferramentas e, ao final, cria
# os links deste repositório. Pode ser executado novamente: cada etapa é
# ignorada quando já está concluída.
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

$repoRoot = $PSScriptRoot

function Step([string] $title) {
  Write-Host "`n==> $title" -ForegroundColor Cyan
}

# Lê uma lista de pacotes ignorando comentários e linhas vazias.
function Read-List([string] $path) {
  Get-Content $path |
    ForEach-Object { ($_ -replace "#.*", "").Trim() } |
    Where-Object { $_ }
}

function Test-WingetPackage([string] $id) {
  $PSNativeCommandUseErrorActionPreference = $false
  winget list --id $id --exact --accept-source-agreements *> $null
  return $LASTEXITCODE -eq 0
}

# Instaladores alteram o PATH do sistema, não o desta sessão.
function Update-Path {
  $machine = [Environment]::GetEnvironmentVariable("Path", "Machine")
  $user = [Environment]::GetEnvironmentVariable("Path", "User")
  $env:Path = "$machine;$user"
}

Step "Pacotes do winget"
foreach ($id in Read-List (Join-Path $repoRoot "packages/winget.txt")) {
  if (-not (Test-WingetPackage $id)) {
    winget install --id $id --exact --source winget `
      --accept-package-agreements --accept-source-agreements
  }
}
Update-Path

# O winget não oferece esta fonte; ela é instalada só para o usuário atual.
Step "FiraCode Nerd Font (ícones do Starship)"
$fontsDir = Join-Path $env:LOCALAPPDATA "Microsoft/Windows/Fonts"
if (-not (Test-Path (Join-Path $fontsDir "FiraCodeNerdFont-Regular.ttf"))) {
  $download = Join-Path ([IO.Path]::GetTempPath()) "FiraCode-$(New-Guid)"
  New-Item -ItemType Directory $download | Out-Null
  Invoke-WebRequest https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip `
    -OutFile (Join-Path $download "FiraCode.zip")
  Expand-Archive (Join-Path $download "FiraCode.zip") $download
  New-Item -ItemType Directory -Force $fontsDir | Out-Null
  $fontsKey = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
  foreach ($font in Get-ChildItem $download -Filter "FiraCodeNerdFont-*.ttf") {
    Copy-Item $font.FullName $fontsDir
    New-ItemProperty $fontsKey -Name "$($font.BaseName) (TrueType)" `
      -Value (Join-Path $fontsDir $font.Name) -Force | Out-Null
  }
  Remove-Item -Recurse $download
}

Step "Modo de Desenvolvedor (links simbólicos sem administrador)"
$devModeKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
$devMode = Get-ItemProperty $devModeKey -ErrorAction SilentlyContinue
if ($devMode.AllowDevelopmentWithoutDevLicense -ne 1) {
  $process = Start-Process reg.exe -Verb RunAs -Wait -PassThru -ArgumentList @(
    "add", "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock",
    "/v", "AllowDevelopmentWithoutDevLicense", "/t", "REG_DWORD", "/d", "1", "/f"
  )
  if ($process.ExitCode -ne 0) {
    throw "Não foi possível ativar o Modo de Desenvolvedor"
  }
}

Step "Vite+ (node, bun e pnpm)"
if (-not (Test-Path (Join-Path $env:LOCALAPPDATA "vite-plus"))) {
  Invoke-RestMethod https://vite.plus/ps1 | Invoke-Expression
  Update-Path
}

Step "Claude Code"
if (-not (Test-Path (Join-Path $HOME ".local/bin/claude.exe"))) {
  Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression
}

Step "Links do repositório"
Push-Location $repoRoot
try {
  bun install
  bun run setup -- --dry-run
  $answer = Read-Host "`nAplicar os links acima? [s/N]"
  if ($answer -match "^[sS]$") {
    bun run setup -- --apply
    bun run doctor
  } else {
    Write-Host "Links não aplicados. Rode depois: bun run setup -- --apply"
  }
} finally {
  Pop-Location
}
