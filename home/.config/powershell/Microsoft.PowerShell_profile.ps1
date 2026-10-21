$env:VISUAL = "code --wait"
$env:EDITOR = "code --wait"

# Configurações específicas desta máquina (não versionadas)
$localProfile = Join-Path $HOME ".config/powershell/profile.local.ps1"
if (Test-Path $localProfile) {
  . $localProfile
}

# Starship prompt
if (Get-Command starship -ErrorAction SilentlyContinue) {
  Invoke-Expression (& starship init powershell)
}

# zoxide (deve ficar no final do arquivo)
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
  Invoke-Expression (& { (zoxide init powershell | Out-String) })
}
