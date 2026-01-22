#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SrcDir = Join-Path $ScriptDir "src"

function Show-Help {
    @"
re - Agent-assisted pattern matching (deterministic regex execution)

Commands:
  help                         Show this help message
  validate                     Verify the skill is runnable (read-only)
  run [opts]                   Execute a deterministic regex match

Options (run):
  --pattern <regex>            Regex pattern to match
  --input <text>               Input text to match against
  --file <path>                Read input from file
  --ignore-case                Case insensitive matching
  --multiline                  ^ and $ match line boundaries
  --dotall                     . matches newlines
  --max-matches <n>            Max matches (default: 1000)
  --timeout <n>                Timeout in seconds (default: 30)
  --format <auto|human|jsonl>  Output format (default: auto)
  --stdin                      Read plan JSON from stdin
"@
}

function Test-Validate {
    $errors = 0

    if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
        Write-Error "error: uv not found. Install from https://docs.astral.sh/uv/"
        $errors++
    }

    $pyproject = Join-Path $SrcDir "pyproject.toml"
    if (-not (Test-Path $pyproject)) {
        Write-Error "error: missing $pyproject"
        $errors++
    }

    $cli = Join-Path $SrcDir "cli.py"
    if (-not (Test-Path $cli)) {
        Write-Error "error: missing $cli"
        $errors++
    }

    if ($errors -gt 0) {
        exit 1
    }

    Write-Output "ok: re skill is runnable"
}

function Invoke-Run {
    param([string[]]$Arguments)
    Push-Location $SrcDir
    try {
        & uv run python cli.py run @Arguments
    } finally {
        Pop-Location
    }
}

$command = if ($args.Count -gt 0) { $args[0] } else { "help" }

switch ($command) {
    "help" { Show-Help }
    "validate" { Test-Validate }
    "run" { Invoke-Run -Arguments ($args | Select-Object -Skip 1) }
    default {
        Write-Error "error: unknown command '$command'"
        Write-Error "run 're help' for usage"
        exit 1
    }
}
