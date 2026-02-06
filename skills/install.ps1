#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$cliDir = Join-Path $scriptDir "cli"

if (-not (Test-Path $cliDir)) {
    Write-Error "error: cli directory not found at $cliDir"
    exit 1
}

$uv = Get-Command uv -ErrorAction SilentlyContinue
if ($uv) {
    & $uv.Source tool install -e $cliDir
    if ($LASTEXITCODE -eq 0) {
        exit 0
    }
    Write-Warning "uv install failed; falling back to pip."
}

$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    $python = Get-Command python3 -ErrorAction SilentlyContinue
}
if (-not $python) {
    Write-Error "error: python not found (tried python, python3)."
    exit 1
}

& $python.Source -m pip install -e $cliDir
exit $LASTEXITCODE
