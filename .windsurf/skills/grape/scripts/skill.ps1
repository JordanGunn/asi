$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$IncludeDir = Join-Path $ScriptDir "include"

# Source config if present
$config = Join-Path $ScriptDir ".config.ps1"
if (Test-Path $config) {
    . $config
}

function Show-Help {
    Push-Location $IncludeDir
    try {
        & uv run python grape_cli.py help
    } finally {
        Pop-Location
    }
}

function Invoke-Validate {
    $errors = 0

    if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
        Write-Error "error: uv not found. Install from https://docs.astral.sh/uv/"
        $errors++
    }

    if (-not (Get-Command rg -ErrorAction SilentlyContinue)) {
        Write-Error "error: rg not found. Install ripgrep."
        $errors++
    }

    $pyproject = Join-Path $IncludeDir "pyproject.toml"
    if (-not (Test-Path $pyproject)) {
        Write-Error "error: missing $pyproject"
        $errors++
    }

    $cli = Join-Path $IncludeDir "grape_cli.py"
    if (-not (Test-Path $cli)) {
        Write-Error "error: missing $cli"
        $errors++
    }

    if ($errors -gt 0) {
        exit 1
    }

    Write-Output "ok: grape skill is runnable"
}

function Invoke-Dispatch {
    param([string[]]$Arguments)

    Push-Location $IncludeDir
    try {
        & uv run python grape_cli.py @Arguments
    } finally {
        Pop-Location
    }
}

$command = if ($args.Count -gt 0) { $args[0] } else { "help" }

switch ($command) {
    "help" { Show-Help }
    "validate" { Invoke-Validate }
    "grep" { Invoke-Dispatch -Arguments $args }
    default {
        Write-Error "error: unknown command '$command'"
        Write-Output "run 'grape help' for usage"
        exit 1
    }
}
