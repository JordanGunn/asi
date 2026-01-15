$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$IncludeDir = Join-Path $ScriptDir "include"

# Source config if present
$ConfigPath = Join-Path $ScriptDir ".config.ps1"
if (Test-Path $ConfigPath) {
    . $ConfigPath
}

function Show-Help {
    @"
task - Task management CLI

Commands:
  help      Show this help message
  validate  Verify the skill is runnable (read-only)
  clean     Remove generated artifacts (.tasks/)
  create    Create a new task
  list      List tasks with derived flags
  select    Select a task as active
  close     Close a task

Usage:
  task help
  task validate
  task clean [--dry-run]
  task create <id> [--title TITLE] [--kind KIND] [--risk RISK] [--select]
  task list [--state STATE] [--stale]
  task select <id>
  task close <id> --reason {completed|abandoned}

Tasks are stored in .tasks/<id>.md
Active task is tracked in .tasks/.active
"@
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

    $taskCli = Join-Path $IncludeDir "task_cli.py"
    if (-not (Test-Path $taskCli)) {
        Write-Error "error: missing $taskCli"
        $errors++
    }

    if ($errors -gt 0) {
        exit 1
    }

    Write-Output "ok: task skill is runnable"
}

function Invoke-Clean {
    param([switch]$DryRun)

    $tasksDir = ".tasks"

    if (-not (Test-Path $tasksDir)) {
        Write-Output "nothing to clean: $tasksDir does not exist"
        return
    }

    if ($DryRun) {
        Write-Output "would remove: $tasksDir"
    } else {
        Remove-Item -Recurse -Force $tasksDir
        Write-Output "removed: $tasksDir"
    }
}

function Invoke-Dispatch {
    param([string[]]$Arguments)
    
    Push-Location $IncludeDir
    try {
        & uv run python task_cli.py @Arguments
    } finally {
        Pop-Location
    }
}

# Main dispatch
$command = if ($args.Count -gt 0) { $args[0] } else { "help" }
$remainingArgs = if ($args.Count -gt 1) { $args[1..($args.Count - 1)] } else { @() }

switch ($command) {
    "help" { Show-Help }
    "validate" { Invoke-Validate }
    "clean" {
        $dryRun = $remainingArgs -contains "--dry-run"
        Invoke-Clean -DryRun:$dryRun
    }
    { $_ -in @("create", "list", "select", "close") } {
        Invoke-Dispatch -Arguments $args
    }
    default {
        Write-Error "error: unknown command '$command'"
        Write-Output "run 'task help' for usage"
        exit 1
    }
}
