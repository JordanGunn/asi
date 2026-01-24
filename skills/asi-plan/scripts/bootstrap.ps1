#Requires -Version 7.0

$ErrorActionPreference = "Stop"

$sh = Join-Path $PSScriptRoot "bootstrap.sh"
$bash = Get-Command bash -ErrorAction SilentlyContinue

if (-not (Test-Path $sh)) {
  Write-Error "Missing script: $sh"
  exit 1
}

if (-not $bash) {
  Write-Error "bash not found. Run $sh instead (or install bash/WSL/Git Bash)."
  exit 1
}

& $bash.Source $sh @args
exit $LASTEXITCODE
