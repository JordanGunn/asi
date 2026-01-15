$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$IncludeDir = Join-Path $ScriptDir "include"

function Show-Help {
    Push-Location $IncludeDir
    try {
        & uv run python dtx_validate_cli.py help
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

    $pyproject = Join-Path $IncludeDir "pyproject.toml"
    if (-not (Test-Path $pyproject)) {
        Write-Error "error: missing $pyproject"
        $errors++
    }

    if ($errors -gt 0) {
        exit 1
    }

    Write-Output "ok: dtx-validate skill is runnable"
}

function Invoke-Dispatch {
    param([string[]]$Arguments)

    Push-Location $IncludeDir
    try {
        & uv run python dtx_validate_cli.py @Arguments
    } finally {
        Pop-Location
    }
}

$command = if ($args.Count -gt 0) { $args[0] } else { "help" }

switch ($command) {
    "help" { Show-Help }
    "validate" { Invoke-Validate }
    "check" { Invoke-Dispatch -Arguments $args }
    default {
        Write-Error "error: unknown command '$command'"
        Write-Output "run 'dtx-validate help' for usage"
        exit 1
    }
}
