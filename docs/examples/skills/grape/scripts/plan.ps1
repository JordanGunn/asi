$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$IncludeDir = Join-Path $ScriptDir "include"
$VenvDir = Join-Path $IncludeDir ".venv"

if (-not (Test-Path $VenvDir)) {
    $bootstrap = Join-Path (Split-Path -Parent $ScriptDir) "bootstrap.ps1"
    Write-Error "error: missing venv at $VenvDir (run $bootstrap)"
    exit 1
}

Push-Location $IncludeDir
try {
    & uv run python grape_cli.py plan @args
} finally {
    Pop-Location
}
