#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SrcDir = Join-Path $ScriptDir "src"

function Show-Help {
    @"
grep - Agent-assisted text search (deterministic ripgrep wrapper)

Commands:
  help                         Show this help message
  validate                     Verify the skill is runnable (read-only)
  run [opts]                   Execute a deterministic text search

Options (run):
  --root <path>                Root directory (default: .)
  --pattern <text>             Search pattern (repeatable)
  --glob <pattern>             Include glob (repeatable)
  --exclude <pattern>          Exclude glob (repeatable)
  --mode <fixed|regex>         Match mode (default: fixed)
  --case <sensitive|insensitive|smart>  Case behavior (default: smart)
  --context <n>                Lines of context (default: 0)
  --format <auto|human|jsonl>  Output format (default: auto)
  --max-lines <n>              Max output lines (default: 500)
  --max-files <n>              Stop after n files with matches
  --max-matches <n>            Stop after n total matches
  --parallelism <n>            Concurrent processes (default: 4)
  --hidden                     Include hidden files
  --follow                     Follow symlinks
  --no-ignore                  Ignore .gitignore rules
  --stdin                      Read plan JSON from stdin
"@
}

function Test-Validate {
    $errors = 0

    if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
        Write-Error "error: uv not found. Install from https://docs.astral.sh/uv/"
        $errors++
    }

    if (-not (Get-Command rg -ErrorAction SilentlyContinue)) {
        Write-Error "error: rg not found. Install ripgrep."
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

    Write-Output "ok: grep skill is runnable"
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
        Write-Error "run 'grep help' for usage"
        exit 1
    }
}
