$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$IncludeDir = Join-Path $ScriptDir "include"

function Show-Help {
    Push-Location $IncludeDir
    try {
        & uv run python plan_cli.py help
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

    $planCli = Join-Path $IncludeDir "plan_cli.py"
    if (-not (Test-Path $planCli)) {
        Write-Error "error: missing $planCli"
        $errors++
    }

    if ($errors -gt 0) {
        exit 1
    }

    Write-Output "ok: plan skill is runnable"
}

function Invoke-Dispatch {
    param([string[]]$Arguments)
    
    Push-Location $IncludeDir
    try {
        & uv run python plan_cli.py @Arguments
    } finally {
        Pop-Location
    }
}

$command = if ($args.Count -gt 0) { $args[0] } else { "help" }

switch ($command) {
    "help" { Show-Help }
    "validate" { Invoke-Validate }
    { $_ -in @("list", "status", "next", "init", "surface", "clean") } {
        Invoke-Dispatch -Arguments $args
    }
    default {
        Write-Error "error: unknown command '$command'"
        Write-Output "run 'plan help' for usage"
        exit 1
    }
}
