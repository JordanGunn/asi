$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$IncludeDir = Join-Path $ScriptDir "include"

# Source config if present
$ConfigPath = Join-Path $ScriptDir ".config.ps1"
if (Test-Path $ConfigPath) {
    . $ConfigPath
}

function Show-Help {
    Push-Location $IncludeDir
    try {
        & uv run python prompt_cli.py help
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

    $promptCli = Join-Path $IncludeDir "prompt_cli.py"
    if (-not (Test-Path $promptCli)) {
        Write-Error "error: missing $promptCli"
        $errors++
    }

    if ($errors -gt 0) {
        exit 1
    }

    Write-Output "ok: prompt skill is runnable"
}

function Invoke-Dispatch {
    param([string[]]$Arguments)
    
    Push-Location $IncludeDir
    try {
        & uv run python prompt_cli.py @Arguments
    } finally {
        Pop-Location
    }
}

# Main dispatch
$command = if ($args.Count -gt 0) { $args[0] } else { "help" }

switch ($command) {
    "help" { Show-Help }
    "validate" { Invoke-Validate }
    { $_ -in @("status", "init", "show", "ready", "compile", "exec", "receipts", "clean") } {
        Invoke-Dispatch -Arguments $args
    }
    default {
        Write-Error "error: unknown command '$command'"
        Write-Output "run 'prompt help' for usage"
        exit 1
    }
}
