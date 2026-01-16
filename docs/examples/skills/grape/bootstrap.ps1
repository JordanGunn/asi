$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$IncludeDir = Join-Path $ScriptDir "scripts/include"

if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Error "error: uv not found. Install from https://docs.astral.sh/uv/"
    exit 1
}

$pyproject = Join-Path $IncludeDir "pyproject.toml"
if (-not (Test-Path $pyproject)) {
    Write-Error "error: missing $pyproject"
    exit 1
}

Push-Location $IncludeDir
try {
    & uv sync
} finally {
    Pop-Location
}

Write-Output "ok: grape bootstrap complete"
